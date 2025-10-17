import 'package:codemy_app/src/features/user/models/dto/auth/res.dart';

import '../../../core/networks/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../../core/conf/api_routes.dart';
import '../../../core/networks/models/api_res.dart';
import '../models/dto/auth/login.dart';
import '../models/dto/auth/register.dart';
import '../models/dto/auth/verify.dart';
import '../models/dto/auth/oauth.dart';
import '../models/dto/auth/reset_password.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiRes<AuthRes>> login(LoginDto loginDto) async {
    try {
      Logger.log('Attempting login for: ${loginDto.email}', tag: 'AUTH');
      final response = await _apiClient.post(
        ApiRoutes.login,
        body: loginDto.toJson(),
      );
      Logger.log('Login successful $response', tag: 'AUTH');
      return ApiRes<AuthRes>.fromJson(
        response,
        (d) => AuthRes.fromJson(d as Map<String, dynamic>),
      );
    } catch (e) {
      Logger.error('Login failed', tag: 'AUTH', error: e);
      return ApiRes<AuthRes>(
        status: 'error',
        data: null,
        error: e,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<AuthRes>> register(RegisterDto registerDto) async {
    try {
      Logger.log(
        'Attempting registration for: ${registerDto.email}',
        tag: 'AUTH',
      );
      final response = await _apiClient.post(
        ApiRoutes.register,
        body: registerDto.toJson(),
      );
      Logger.log('Registration successful', tag: 'AUTH');
      return ApiRes<AuthRes>.fromJson(
        response,
        (d) => AuthRes.fromJson(d as Map<String, dynamic>),
      );
    } catch (e) {
      Logger.error('Registration failed', tag: 'AUTH', error: e);
      return ApiRes<AuthRes>(
        status: 'error',
        data: null,
        error: e,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<AuthRes>> verifyEmail(VerifyDto verifyDto) async {
    try {
      Logger.log('Attempting email verification', tag: 'AUTH');
      final response = await _apiClient.post(
        ApiRoutes.verify,
        body: verifyDto.toJson(),
      );
      Logger.log('Email verification successful', tag: 'AUTH');
      return ApiRes<AuthRes>.fromJson(
        response,
        (d) => AuthRes.fromJson(d as Map<String, dynamic>),
      );
    } catch (e) {
      Logger.error('Email verification failed', tag: 'AUTH', error: e);
      return ApiRes<AuthRes>(
        status: 'error',
        data: null,
        error: e,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<AuthRes>> oauthLogin(OAuthDto oauthDto) async {
    try {
      Logger.log('Attempting OAuth login', tag: 'AUTH');
      final response = await _apiClient.post(
        ApiRoutes.oauth,
        body: oauthDto.toJson(),
      );
      Logger.log('OAuth login successful', tag: 'AUTH');
      return ApiRes<AuthRes>.fromJson(
        response,
        (d) => AuthRes.fromJson(d as Map<String, dynamic>),
      );
    } catch (e) {
      Logger.error('OAuth login failed', tag: 'AUTH', error: e);
      return ApiRes<AuthRes>(
        status: 'error',
        data: null,
        error: e,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<void>> resetPassword(ResetPasswordDto resetPasswordDto) async {
    try {
      Logger.log(
        'Attempting password reset for: ${resetPasswordDto.email}',
        tag: 'AUTH',
      );
      final response = await _apiClient.post(
        ApiRoutes.reset_password,
        body: resetPasswordDto.toJson(),
      );
      Logger.log('Password reset successful', tag: 'AUTH');
      return ApiRes<void>.fromJson(response, (_) {});
    } catch (e) {
      Logger.error('Password reset failed', tag: 'AUTH', error: e);
      return ApiRes<void>(
        status: 'error',
        data: null,
        error: e,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<void>> logout() async {
    try {
      Logger.log('Logging out', tag: 'AUTH');
      final response = await _apiClient.post(ApiRoutes.logout);
      Logger.log('Logout successful', tag: 'AUTH');
      return ApiRes<void>.fromJson(response, (d) => null);
    } catch (e) {
      Logger.error('Logout failed', tag: 'AUTH', error: e);
      return ApiRes<void>(
        status: 'error',
        data: null,
        error: e,
        isSuccess: false,
      );
    }
  }
}
