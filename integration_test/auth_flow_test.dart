import 'package:codemy_app/l10n/app_localizations.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/login.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/res.dart';
import 'package:codemy_app/src/features/user/models/entity/user.dart';
import 'package:codemy_app/src/features/user/providers/auth_providers.dart';
import 'package:codemy_app/src/features/user/services/auth_service.dart';
import 'package:codemy_app/src/features/user/widgets/auth/login_form.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../test/helpers/test_auth_state_notifier.dart';

class MockAuthService extends Mock implements AuthService {}

class FakeLoginDto extends Fake implements LoginDto {
  @override
  String get email => '';

  @override
  String get password => '';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerFallbackValue(FakeLoginDto());

  testWidgets('navigates to verify when login requires verification', (
    tester,
  ) async {
    final mockAuthService = MockAuthService();
    final savedStates = <Map<String, dynamic>>[];

    when(() => mockAuthService.login(any())).thenAnswer(
      (_) async => ApiRes<AuthRes>(
        status: 200,
        data: AuthRes(requiresEmailVerification: true),
        error: null,
        isSuccess: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          authStateProvider.overrideWith(
            () => TestAuthStateNotifier(
              onSave: (token, userData) async {
                savedStates.add({'token': token, 'user': userData});
              },
            ),
          ),
        ],
        child: shadcn.ShadcnApp.router(
          title: 'Auth Test',
          routerConfig: _buildRouter(),
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

    await tester.enterText(
      find.byType(shadcn.TextField).at(0),
      'needs.verify@example.com',
    );
    await tester.enterText(find.byType(shadcn.TextField).at(1), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Verify Screen'), findsOneWidget);
    expect(savedStates, isEmpty);
  });

  testWidgets('successful login persists auth state and navigates home', (
    tester,
  ) async {
    final mockAuthService = MockAuthService();
    final persisted = <Map<String, dynamic>>[];
    final now = DateTime(2024, 1, 1);
    final user = User(
      id: 'user-1',
      name: 'Tester',
      email: 'tester@example.com',
      googleId: 'gid',
      role: 0,
      status: 1,
      profilePicture: 'https://example.com/avatar.png',
      bio: 'bio',
      emailVerified: true,
      totalCourses: 0,
      rating: 4.0,
      createdAt: now,
      createdBy: 'system',
    );

    when(() => mockAuthService.login(any())).thenAnswer(
      (_) async => ApiRes<AuthRes>(
        status: 200,
        data: AuthRes(token: 'abc123', user: user),
        error: null,
        isSuccess: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          authStateProvider.overrideWith(
            () => TestAuthStateNotifier(
              onSave: (token, userData) async {
                persisted.add({'token': token, 'user': userData});
              },
            ),
          ),
        ],
        child: shadcn.ShadcnApp.router(
          title: 'Auth Test',
          routerConfig: _buildRouter(),
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

    await tester.enterText(
      find.byType(shadcn.TextField).at(0),
      'tester@example.com',
    );
    await tester.enterText(find.byType(shadcn.TextField).at(1), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Home Screen'), findsOneWidget);
    expect(persisted, isNotEmpty);
    expect(persisted.single['token'], 'abc123');
  });
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => material.Scaffold(
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
