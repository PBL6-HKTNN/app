import 'dart:async';

import 'package:codemy_app/l10n/app_localizations.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/login.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/register.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/res.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/reset_password.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/verify.dart';
import 'package:codemy_app/src/features/user/models/entity/user.dart';
import 'package:codemy_app/src/features/user/providers/auth_providers.dart';
import 'package:codemy_app/src/features/user/routes/auth_routes.dart';
import 'package:codemy_app/src/features/user/screens/auth/login_screen.dart';
import 'package:codemy_app/src/features/user/screens/auth/register_screen.dart';
import 'package:codemy_app/src/features/user/screens/auth/reset_password_screen.dart';
import 'package:codemy_app/src/features/user/screens/auth/verify_screen.dart';
import 'package:codemy_app/src/features/user/services/auth_service.dart';
import 'package:codemy_app/src/features/user/services/google_auth_service.dart';
import 'package:codemy_app/src/presentation/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../test/helpers/test_auth_state_notifier.dart';

class MockAuthService extends Mock implements AuthService {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockGoogleAuthClient extends Mock
    implements GoogleSignInAuthorizationClient {}

class FakeLoginDto extends Fake implements LoginDto {}

class FakeRegisterDto extends Fake implements RegisterDto {}

class FakeVerifyDto extends Fake implements VerifyDto {}

class FakeResetPasswordDto extends Fake implements ResetPasswordDto {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  registerFallbackValue(FakeLoginDto());
  registerFallbackValue(FakeRegisterDto());
  registerFallbackValue(FakeVerifyDto());
  registerFallbackValue(FakeResetPasswordDto());

  // Setup Google Sign-In mock
  final mockGoogleSignIn = MockGoogleSignIn();
  final mockGoogleSignInAccount = MockGoogleSignInAccount();
  final mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();

  // Mock the authentication events stream
  final authEventsController =
      StreamController<GoogleSignInAuthenticationEvent>.broadcast();
  when(
    () => mockGoogleSignIn.authenticationEvents,
  ).thenAnswer((_) => authEventsController.stream);

  // Mock authenticate method
  when(() => mockGoogleSignIn.authenticate()).thenAnswer((_) async {
    // Simulate successful authentication by emitting sign-in event
    final signInEvent = GoogleSignInAuthenticationEventSignIn(
      user: mockGoogleSignInAccount,
    );
    authEventsController.add(signInEvent);
    return mockGoogleSignInAccount;
  });

  // Mock account properties
  when(() => mockGoogleSignInAccount.email).thenReturn('test@gmail.com');
  when(() => mockGoogleSignInAccount.displayName).thenReturn('Test User');
  when(
    () => mockGoogleSignInAccount.photoUrl,
  ).thenReturn('https://example.com/photo.jpg');
  when(
    () => mockGoogleSignInAccount.authentication,
  ).thenReturn(mockGoogleSignInAuthentication);
  when(
    () => mockGoogleSignInAuthentication.idToken,
  ).thenReturn('mock-id-token');

  // Mock authorization client
  final mockAuthClient = MockGoogleAuthClient();
  when(
    () => mockGoogleSignInAccount.authorizationClient,
  ).thenReturn(mockAuthClient);

  // Mock authorization methods
  when(
    () => mockAuthClient.authorizationHeaders(any()),
  ).thenAnswer((_) async => {'Authorization': 'Bearer mock-access-token'});
  when(
    () => mockAuthClient.authorizeServer(any()),
  ).thenAnswer((_) async => null);

  // Set the mock in GoogleAuthService
  GoogleAuthService.setMockGoogleSignIn(mockGoogleSignIn);

  group('Auth Screen E2E Tests', () {
    testWidgets('Login Screen - successful login navigates to home', (
      tester,
    ) async {
      final mockAuthService = MockAuthService();
      final savedStates = <Map<String, dynamic>>[];
      final user = _createTestUser();

      when(() => mockAuthService.login(any())).thenAnswer(
        (_) async => ApiRes<AuthRes>(
          status: 200,
          data: AuthRes(token: 'test-token', user: user),
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
          child: _buildAuthApp(initialLocation: '/login'),
        ),
      );

      await tester.pumpAndSettle(
        const Duration(milliseconds: 50), // duration
        EnginePhase.sendSemanticsUpdate, // phase
        const Duration(seconds: 10), // timeout
      );

      // Verify we're on login screen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Login'), findsWidgets);

      // Enter valid credentials
      await tester.enterText(
        find.byType(shadcn.TextField).at(0),
        'test@example.com',
      );
      await tester.enterText(
        find.byType(shadcn.TextField).at(1),
        'password123',
      );

      // Submit login form
      await tester.tap(find.text('Login').last);
      await tester.pumpAndSettle();

      // Verify navigation to home screen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      // Verify auth state was persisted
      expect(savedStates, hasLength(1));
      expect(savedStates.first['token'], 'test-token');

      verify(() => mockAuthService.login(any())).called(1);
    });

    testWidgets('Login Screen - failed login shows error and stays on login', (
      tester,
    ) async {
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
          child: _buildAuthApp(initialLocation: '/login'),
        ),
      );

      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(
        find.byType(shadcn.TextField).at(0),
        'bad@example.com',
      );
      await tester.enterText(
        find.byType(shadcn.TextField).at(1),
        'wrongpassword',
      );

      // Submit login form
      await tester.tap(find.text('Login').last);
      await tester.pumpAndSettle();

      // Verify error dialog appears
      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);

      // Close error dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Still on login screen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets(
      'Register Screen - successful registration navigates to verify',
      (tester) async {
        final mockAuthService = MockAuthService();

        when(() => mockAuthService.register(any())).thenAnswer(
          (_) async => ApiRes<AuthRes>(
            status: 200,
            data: AuthRes(),
            error: null,
            isSuccess: true,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
            child: _buildAuthApp(initialLocation: '/register'),
          ),
        );

        await tester.pumpAndSettle();

        // Verify we're on register screen
        expect(find.byType(RegisterScreen), findsOneWidget);
        expect(find.text('Register'), findsWidgets);

        // Fill registration form
        await tester.enterText(
          find.byType(shadcn.TextField).at(0),
          'newuser@example.com',
        );
        await tester.enterText(
          find.byType(shadcn.TextField).at(1),
          'ValidPass123!',
        );
        await tester.enterText(
          find.byType(shadcn.TextField).at(2),
          'ValidPass123!',
        );

        // Submit registration form
        await tester.tap(find.text('Register').last);
        await tester.pumpAndSettle();

        // Verify navigation to verify screen
        expect(find.byType(VerifyScreen), findsOneWidget);
        expect(find.byType(RegisterScreen), findsNothing);
        expect(find.textContaining('Verify'), findsWidgets);

        verify(() => mockAuthService.register(any())).called(1);
      },
    );

    testWidgets(
      'Register Screen - failed registration shows error and stays on register',
      (tester) async {
        final mockAuthService = MockAuthService();

        when(() => mockAuthService.register(any())).thenAnswer(
          (_) async => ApiRes<AuthRes>(
            status: 400,
            data: null,
            error: 'Email already exists',
            isSuccess: false,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
            child: _buildAuthApp(initialLocation: '/register'),
          ),
        );

        await tester.pumpAndSettle();

        // Fill registration form
        await tester.enterText(
          find.byType(shadcn.TextField).at(0),
          'existing@example.com',
        );
        await tester.enterText(
          find.byType(shadcn.TextField).at(1),
          'ValidPass123!',
        );
        await tester.enterText(
          find.byType(shadcn.TextField).at(2),
          'ValidPass123!',
        );

        // Submit registration form
        await tester.tap(find.text('Register').last);
        await tester.pumpAndSettle();

        // Verify error dialog appears
        expect(find.text('Email already exists'), findsOneWidget);
        expect(find.byType(RegisterScreen), findsOneWidget);

        // Close error dialog
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Still on register screen
        expect(find.byType(RegisterScreen), findsOneWidget);
        expect(find.byType(VerifyScreen), findsNothing);
      },
    );

    testWidgets('Verify Screen - successful verification navigates to login', (
      tester,
    ) async {
      final mockAuthService = MockAuthService();
      final savedStates = <Map<String, dynamic>>[];
      final user = _createTestUser();

      when(() => mockAuthService.verifyEmail(any())).thenAnswer(
        (_) async => ApiRes<AuthRes>(
          status: 200,
          data: AuthRes(token: 'verified-token', user: user),
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
          child: _buildAuthApp(
            initialLocation: '/verify?email=test@example.com',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we're on verify screen
      expect(find.byType(VerifyScreen), findsOneWidget);
      tester.pumpAndSettle(
        const Duration(milliseconds: 50), // duration
        EnginePhase.sendSemanticsUpdate, // phase
        const Duration(seconds: 10), // timeout
      );

      // Enter verification code
      await tester.enterText(find.text('Verification Token').first, '123456');

      tester.pumpAndSettle(
        const Duration(milliseconds: 50), // duration
        EnginePhase.sendSemanticsUpdate, // phase
        const Duration(seconds: 10), // timeout
      );
      // Submit verification
      await tester.tap(find.text('Verify').last);
      await tester.pumpAndSettle();

      // Verify navigation to login screen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(VerifyScreen), findsNothing);

      // Verify auth state was persisted
      expect(savedStates, hasLength(1));
      expect(savedStates.first['token'], 'verified-token');

      verify(() => mockAuthService.verifyEmail(any())).called(1);
    });

    testWidgets('Reset Password Screen - successful reset navigates to login', (
      tester,
    ) async {
      final mockAuthService = MockAuthService();

      when(() => mockAuthService.getResetPasswordToken(any())).thenAnswer(
        (_) async => ApiRes<Map<String, dynamic>>(
          status: 200,
          data: {'message': 'Token sent'},
          error: null,
          isSuccess: true,
        ),
      );

      when(() => mockAuthService.resetPassword(any())).thenAnswer(
        (_) async => ApiRes<Map<String, dynamic>>(
          status: 200,
          data: {'message': 'Password reset successful'},
          error: null,
          isSuccess: true,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          child: _buildAuthApp(initialLocation: '/reset-password'),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we're on reset password screen
      expect(find.byType(ResetPasswordScreen), findsOneWidget);

      // Enter email for reset token
      await tester.enterText(
        find.byType(shadcn.TextField).first,
        'reset@example.com',
      );

      // Request reset token
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();

      // Close success dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Enter reset token and new password
      await tester.enterText(
        find.byType(shadcn.TextField).at(1), // token field
        'RESET123',
      );
      await tester.enterText(
        find.byType(shadcn.TextField).at(2), // new password
        'NewPassword123!',
      );
      await tester.enterText(
        find.byType(shadcn.TextField).at(3), // confirm password
        'NewPassword123!',
      );

      // Submit password reset
      await tester.tap(find.text('Reset Password').first);
      await tester.pumpAndSettle();

      // Verify success dialog appears
      expect(find.text('Password reset successful'), findsOneWidget);

      // Click "Go to Login" button in the dialog
      await tester.tap(find.text('Go to Login'));
      await tester.pumpAndSettle();

      // Verify navigation to login screen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ResetPasswordScreen), findsNothing);

      verify(() => mockAuthService.getResetPasswordToken(any())).called(1);
      verify(() => mockAuthService.resetPassword(any())).called(1);
    });

    testWidgets('Login Screen - validation errors prevent form submission', (
      tester,
    ) async {
      final mockAuthService = MockAuthService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          child: _buildAuthApp(initialLocation: '/login'),
        ),
      );

      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.text('Login').last);
      await tester.pumpAndSettle();

      // Should show validation errors and stay on login screen
      expect(find.textContaining('required'), findsWidgets);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      // Verify service was not called
      verifyNever(() => mockAuthService.login(any()));
    });

    testWidgets('Register Screen - password mismatch shows error', (
      tester,
    ) async {
      final mockAuthService = MockAuthService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          child: _buildAuthApp(initialLocation: '/register'),
        ),
      );

      await tester.pumpAndSettle();

      // Fill form with mismatched passwords
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

      // Submit form
      await tester.tap(find.text('Register').last);
      await tester.pumpAndSettle();

      // Should show password mismatch error
      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.byType(VerifyScreen), findsNothing);

      // Verify service was not called
      verifyNever(() => mockAuthService.register(any()));
    });
  });
}

shadcn.ShadcnApp _buildAuthApp({required String initialLocation}) {
  return shadcn.ShadcnApp.router(
    title: 'Auth E2E Test',
    routerConfig: GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        ...AuthRoutes.routes,
      ],
    ),
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
