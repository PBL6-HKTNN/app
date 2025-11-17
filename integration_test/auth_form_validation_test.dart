import 'package:codemy_app/l10n/app_localizations.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/login.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/register.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/res.dart';
import 'package:codemy_app/src/features/user/models/entity/user.dart';
import 'package:codemy_app/src/features/user/providers/auth_providers.dart';
import 'package:codemy_app/src/features/user/services/auth_service.dart';
import 'package:codemy_app/src/features/user/widgets/auth/login_form.dart';
import 'package:codemy_app/src/features/user/widgets/auth/register_form.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class MockAuthService extends Mock implements AuthService {}

class FakeLoginDto extends Fake implements LoginDto {}

class FakeRegisterDto extends Fake implements RegisterDto {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  registerFallbackValue(FakeLoginDto());
  registerFallbackValue(FakeRegisterDto());

  group('Auth Forms Integration Tests', () {
    testWidgets('login form validation flow', (tester) async {
      final mockAuthService = MockAuthService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          child: shadcn.ShadcnApp.router(
            title: 'Auth Test',
            routerConfig: _buildLoginRouter(),
            theme: shadcn.ThemeData(
              colorScheme: shadcn.ColorSchemes.lightDefaultColor,
              radius: 0.5,
            ),
            darkTheme: shadcn.ThemeData(
              colorScheme: shadcn.ColorSchemes.darkDefaultColor,
              radius: 0.5,
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test empty form submission
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.textContaining('required'), findsWidgets);

      // Test invalid email
      await tester.enterText(
        find.byType(shadcn.TextField).at(0),
        'invalid-email',
      );
      await tester.enterText(find.byType(shadcn.TextField).at(1), 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.textContaining('valid email'), findsOneWidget);

      // Test valid form with mocked success
      when(() => mockAuthService.login(any())).thenAnswer(
        (_) async => ApiRes<AuthRes>(
          status: 200,
          data: AuthRes(token: 'test-token', user: _createTestUser()),
          error: null,
          isSuccess: true,
        ),
      );

      await tester.enterText(
        find.byType(shadcn.TextField).at(0),
        'test@example.com',
      );
      await tester.enterText(
        find.byType(shadcn.TextField).at(1),
        'validPassword',
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should navigate to home on success
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('register form validation flow', (tester) async {
      final mockAuthService = MockAuthService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          child: shadcn.ShadcnApp.router(
            title: 'Auth Test',
            routerConfig: _buildRegisterRouter(),
            theme: shadcn.ThemeData(
              colorScheme: shadcn.ColorSchemes.lightDefaultColor,
              radius: 0.5,
            ),
            darkTheme: shadcn.ThemeData(
              colorScheme: shadcn.ColorSchemes.darkDefaultColor,
              radius: 0.5,
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test password mismatch
      await tester.enterText(
        find.byType(shadcn.TextField).at(0),
        'test@example.com',
      );
      await tester.enterText(
        find.byType(shadcn.TextField).at(1),
        'ValidPass123!',
      );
      await tester.enterText(
        find.byType(shadcn.TextField).at(2),
        'DifferentPass123!',
      );
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);

      // Test weak password
      await tester.enterText(find.byType(shadcn.TextField).at(1), 'weak');
      await tester.enterText(find.byType(shadcn.TextField).at(2), 'weak');
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.textContaining('8 characters'), findsOneWidget);

      // Test successful registration
      when(() => mockAuthService.register(any())).thenAnswer(
        (_) async => ApiRes<AuthRes>(
          status: 200,
          data: AuthRes(),
          error: null,
          isSuccess: true,
        ),
      );

      await tester.enterText(
        find.byType(shadcn.TextField).at(1),
        'ValidPass123!',
      );
      await tester.enterText(
        find.byType(shadcn.TextField).at(2),
        'ValidPass123!',
      );
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Should navigate to verify screen
      expect(find.textContaining('Verify Screen'), findsOneWidget);
    });

    testWidgets('error handling in login form', (tester) async {
      final mockAuthService = MockAuthService();

      when(() => mockAuthService.login(any())).thenAnswer(
        (_) async => ApiRes<AuthRes>(
          status: 401,
          data: null,
          error: 'Invalid credentials',
          isSuccess: false,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          child: shadcn.ShadcnApp.router(
            title: 'Auth Test',
            routerConfig: _buildLoginRouter(),
            theme: shadcn.ThemeData(
              colorScheme: shadcn.ColorSchemes.lightDefaultColor,
              radius: 0.5,
            ),
            darkTheme: shadcn.ThemeData(
              colorScheme: shadcn.ColorSchemes.darkDefaultColor,
              radius: 0.5,
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter valid credentials but simulate server error
      await tester.enterText(
        find.byType(shadcn.TextField).at(0),
        'test@example.com',
      );
      await tester.enterText(find.byType(shadcn.TextField).at(1), 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show error dialog
      expect(find.text('Invalid credentials'), findsOneWidget);

      // Close error dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });
  });
}

GoRouter _buildLoginRouter() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const material.Scaffold(
          body: material.Center(child: material.Text('Home Screen')),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => material.Scaffold(
          body: material.Padding(
            padding: const material.EdgeInsets.all(16),
            child: const LoginForm(),
          ),
        ),
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return material.Scaffold(
            body: material.Center(
              child: material.Text('Verify Screen for $email'),
            ),
          );
        },
      ),
    ],
  );
}

GoRouter _buildRegisterRouter() {
  return GoRouter(
    initialLocation: '/register',
    routes: [
      GoRoute(
        path: '/register',
        builder: (context, state) => material.Scaffold(
          body: material.Padding(
            padding: const material.EdgeInsets.all(16),
            child: const RegisterForm(),
          ),
        ),
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return material.Scaffold(
            body: material.Center(
              child: material.Text('Verify Screen for $email'),
            ),
          );
        },
      ),
    ],
  );
}

User _createTestUser() {
  final now = DateTime(2024, 1, 1);
  return User(
    id: 'user-123',
    name: 'Test User',
    email: 'test@example.com',
    googleId: 'gid-1',
    role: 0,
    status: 1,
    profilePicture: 'https://example.com/avatar.png',
    bio: 'Test bio',
    emailVerified: true,
    totalCourses: 2,
    rating: 4.5,
    createdAt: now,
    createdBy: 'system',
  );
}
