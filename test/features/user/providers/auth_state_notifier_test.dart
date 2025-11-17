import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/login.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/register.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/res.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/reset_password.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/verify.dart';
import 'package:codemy_app/src/features/user/models/entity/user.dart';
import 'package:codemy_app/src/features/user/providers/auth_providers.dart';
import 'package:codemy_app/src/features/user/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_auth_state_notifier.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late ProviderContainer container;
  late MockAuthService mockAuthService;
  late List<Map<String, dynamic>> savedStates;
  late bool clearedStorage;

  final now = DateTime(2024, 1, 1);
  final user = User(
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

  setUp(() {
    mockAuthService = MockAuthService();
    savedStates = [];
    clearedStorage = false;
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        authStateProvider.overrideWith(
          () => TestAuthStateNotifier(
            onSave: (token, userData) async {
              savedStates.add({'token': token, 'user': userData});
            },
            onClear: () async {
              clearedStorage = true;
            },
          ),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('login success stores user and token', () async {
    final loginDto = LoginDto(email: 'test@example.com', password: 'secret');
    when(() => mockAuthService.login(loginDto)).thenAnswer(
      (_) async => ApiRes<AuthRes>(
        status: 200,
        data: AuthRes(token: 'abc123', user: user),
        error: null,
        isSuccess: true,
      ),
    );

    await container.read(authStateProvider.notifier).login(loginDto);

    final state = container.read(authStateProvider);
    expect(state.isAuthenticated, isTrue);
    expect(state.user, equals(user));
    expect(state.token, 'abc123');
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    expect(savedStates.single['token'], 'abc123');
    verify(() => mockAuthService.login(loginDto)).called(1);
  });

  test('login requiring email verification toggles the flag', () async {
    final loginDto = LoginDto(email: 'verify@example.com', password: 'secret');
    when(() => mockAuthService.login(loginDto)).thenAnswer(
      (_) async => ApiRes<AuthRes>(
        status: 200,
        data: AuthRes(requiresEmailVerification: true),
        error: null,
        isSuccess: true,
      ),
    );

    await container.read(authStateProvider.notifier).login(loginDto);

    final state = container.read(authStateProvider);
    expect(state.requiresEmailVerification, isTrue);
    expect(state.isAuthenticated, isFalse);
    expect(savedStates, isEmpty);
    verify(() => mockAuthService.login(loginDto)).called(1);
  });

  test('login failure surfaces error', () async {
    final loginDto = LoginDto(email: 'bad@example.com', password: 'wrong');
    when(() => mockAuthService.login(loginDto)).thenAnswer(
      (_) async => ApiRes<AuthRes>(
        status: 400,
        data: null,
        error: 'Invalid credentials',
        isSuccess: false,
      ),
    );

    await container.read(authStateProvider.notifier).login(loginDto);

    final state = container.read(authStateProvider);
    expect(state.error, 'Invalid credentials');
    expect(state.isLoading, isFalse);
    expect(state.isAuthenticated, isFalse);
  });

  test('register failure sets error', () async {
    final registerDto = RegisterDto(
      email: 'new@example.com',
      password: 'pewpew',
    );
    when(() => mockAuthService.register(registerDto)).thenAnswer(
      (_) async => ApiRes<AuthRes>(
        status: 422,
        data: null,
        error: 'Email already exists',
        isSuccess: false,
      ),
    );

    await container.read(authStateProvider.notifier).register(registerDto);

    final state = container.read(authStateProvider);
    expect(state.error, 'Email already exists');
    expect(state.isLoading, isFalse);
    expect(state.isAuthenticated, isFalse);
  });

  test('verify email success authenticates the user', () async {
    final verifyDto = VerifyDto(email: 'test@example.com', token: '123456');
    when(() => mockAuthService.verifyEmail(verifyDto)).thenAnswer(
      (_) async => ApiRes<AuthRes>(
        status: 200,
        data: AuthRes(token: 'ver123', user: user),
        error: null,
        isSuccess: true,
      ),
    );

    await container.read(authStateProvider.notifier).verifyEmail(verifyDto);

    final state = container.read(authStateProvider);
    expect(state.isAuthenticated, isTrue);
    expect(state.token, 'ver123');
    expect(state.user, equals(user));
    expect(savedStates.single['token'], 'ver123');
  });

  test('requesting reset token failure exposes error', () async {
    when(
      () => mockAuthService.getResetPasswordToken('fail@example.com'),
    ).thenAnswer(
      (_) async => ApiRes<Map<String, dynamic>>(
        status: 500,
        data: null,
        error: 'Server unavailable',
        isSuccess: false,
      ),
    );

    await container
        .read(authStateProvider.notifier)
        .getResetPasswordToken('fail@example.com');

    final state = container.read(authStateProvider);
    expect(state.error, 'Server unavailable');
    expect(state.isLoading, isFalse);
  });

  test('reset password success clears loading state', () async {
    final resetDto = ResetPasswordDto(
      email: 'test@example.com',
      token: 'otp-123',
      newPassword: 'newPass!23',
    );
    when(() => mockAuthService.resetPassword(resetDto)).thenAnswer(
      (_) async => ApiRes<Map<String, dynamic>>(
        status: 200,
        data: const {},
        error: null,
        isSuccess: true,
      ),
    );

    await container.read(authStateProvider.notifier).resetPassword(resetDto);

    final state = container.read(authStateProvider);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
  });

  test('logout clears state and storage', () async {
    when(() => mockAuthService.logout()).thenAnswer(
      (_) async =>
          ApiRes<void>(status: 200, data: null, error: null, isSuccess: true),
    );

    container.read(authStateProvider.notifier)
      ..state = container
          .read(authStateProvider)
          .copyWith(isAuthenticated: true, token: 'existing', user: user);

    await container.read(authStateProvider.notifier).logout();

    final state = container.read(authStateProvider);
    expect(state.isAuthenticated, isFalse);
    expect(state.token, isNull);
    expect(state.user, isNull);
    expect(clearedStorage, isTrue);
    expect(state.error, isNull);
  });
}
