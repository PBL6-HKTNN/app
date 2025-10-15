import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/core/utils/persistence.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/login.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/oauth.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/register.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/verify.dart';
import 'package:codemy_app/src/features/user/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth state provider
final authStateProvider = NotifierProvider<AuthStateNotifier, AuthState>(() {
  return AuthStateNotifier();
});

// Auth state
class AuthState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth state notifier
class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  AuthService get _authService => ref.read(authServiceProvider);

  Future<void> login(LoginDto loginDto) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.login(loginDto);
      state = state.copyWith(
        isLoading: false,
        user: response,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(RegisterDto registerDto) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.register(registerDto);
      state = state.copyWith(isLoading: false);
      // Don't set authenticated here, user needs to verify email first
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyEmail(VerifyDto verifyDto) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.verifyEmail(verifyDto);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> oauthLogin(OAuthDto oauthDto) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.oauthLogin(oauthDto);
      state = state.copyWith(
        isLoading: false,
        user: response,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.logout();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> initializeFromStorage() async {
    try {
      final token = await PersistenceUtils.readSecureString('auth_token');
      final userData = await PersistenceUtils.readSecureString('user_data');

      if (token != null && userData != null) {
        state = state.copyWith(isAuthenticated: true, user: {'token': token});
      }
    } catch (e) {
      Logger.error('Error initializing auth state: $e');
    }
  }

  /// Initialize auth state from persistent storage on app start
  Future<void> initializeAuthState() async {
    await initializeFromStorage();
  }

  /// Save auth state to persistent storage
  Future<void> saveAuthState(
    String token,
    Map<String, dynamic> userData,
  ) async {
    await PersistenceUtils.writeSecureString('auth_token', token);
    await PersistenceUtils.writeSecureString('user_data', userData.toString());
  }

  /// Clear auth state from persistent storage
  Future<void> clearAuthState() async {
    await PersistenceUtils.deleteSecure('auth_token');
    await PersistenceUtils.deleteSecure('user_data');
  }
}
