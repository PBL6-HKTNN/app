import 'package:codemy_app/l10n/app_localizations.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/login.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/register.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/res.dart';
import 'package:codemy_app/src/features/user/models/entity/user.dart';
import 'package:codemy_app/src/features/user/providers/auth_providers.dart';
import 'package:codemy_app/src/features/user/services/auth_service.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import '../test/helpers/test_auth_state_notifier.dart';

class MockAuthService extends Mock implements AuthService {}

class FakeLoginDto extends Fake implements LoginDto {}

class FakeRegisterDto extends Fake implements RegisterDto {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  registerFallbackValue(FakeLoginDto());
  registerFallbackValue(FakeRegisterDto());

  group('Auth Provider Integration Tests', () {
    testWidgets('login success flow with mocked service', (tester) async {
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
          child: _buildTestApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Get the provider container and test login
      final container = ProviderScope.containerOf(
        tester.element(find.byType(material.MaterialApp).first),
      );

      final loginDto = LoginDto(
        email: 'test@example.com',
        password: 'password123',
      );

      await container.read(authStateProvider.notifier).login(loginDto);

      // Verify auth state is updated correctly
      final authState = container.read(authStateProvider);
      expect(authState.isAuthenticated, isTrue);
      expect(authState.user?.email, 'test@example.com');
      expect(authState.token, 'test-token');
      expect(authState.isLoading, isFalse);
      expect(authState.error, isNull);

      // Verify state was persisted
      expect(savedStates, hasLength(1));
      expect(savedStates.first['token'], 'test-token');

      verify(() => mockAuthService.login(any())).called(1);
    });

    testWidgets('login failure flow with error', (tester) async {
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
          child: _buildTestApp(),
        ),
      );

      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(material.MaterialApp).first),
      );

      final loginDto = LoginDto(
        email: 'bad@example.com',
        password: 'wrongpassword',
      );

      await container.read(authStateProvider.notifier).login(loginDto);

      final authState = container.read(authStateProvider);
      expect(authState.isAuthenticated, isFalse);
      expect(authState.user, isNull);
      expect(authState.token, isNull);
      expect(authState.isLoading, isFalse);
      expect(authState.error, 'Invalid credentials');

      verify(() => mockAuthService.login(any())).called(1);
    });

    testWidgets('registration success flow', (tester) async {
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
          child: _buildTestApp(),
        ),
      );

      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(material.MaterialApp).first),
      );

      final registerDto = RegisterDto(
        email: 'new@example.com',
        password: 'ValidPass123!',
      );

      await container.read(authStateProvider.notifier).register(registerDto);

      final authState = container.read(authStateProvider);
      expect(authState.isLoading, isFalse);
      expect(authState.error, isNull);
      expect(
        authState.isAuthenticated,
        isFalse,
      ); // Not authenticated until verified

      verify(() => mockAuthService.register(any())).called(1);
    });

    testWidgets('logout clears auth state', (tester) async {
      final mockAuthService = MockAuthService();
      bool clearedStorage = false;

      when(() => mockAuthService.logout()).thenAnswer(
        (_) async =>
            ApiRes<void>(status: 200, data: null, error: null, isSuccess: true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            authStateProvider.overrideWith(
              () => TestAuthStateNotifier(
                onClear: () async {
                  clearedStorage = true;
                },
              ),
            ),
          ],
          child: _buildTestApp(),
        ),
      );

      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(material.MaterialApp).first),
      );

      // First set some auth state
      container.read(authStateProvider.notifier).state = container
          .read(authStateProvider)
          .copyWith(
            isAuthenticated: true,
            token: 'existing-token',
            user: _createTestUser(),
          );

      // Then logout
      await container.read(authStateProvider.notifier).logout();

      final authState = container.read(authStateProvider);
      expect(authState.isAuthenticated, isFalse);
      expect(authState.user, isNull);
      expect(authState.token, isNull);
      expect(authState.error, isNull);
      expect(clearedStorage, isTrue);

      verify(() => mockAuthService.logout()).called(1);
    });
  });
}

material.Widget _buildTestApp() {
  return material.MaterialApp(
    title: 'Auth Test',
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const material.Scaffold(
      body: material.Center(child: material.Text('Test App')),
    ),
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
