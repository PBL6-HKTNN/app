import '../../../core/networks/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../../core/conf/api_routes.dart';
import '../models/dto/auth/login.dart';
import '../models/dto/auth/register.dart';
import '../models/dto/auth/verify.dart';
import '../models/dto/auth/oauth.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(LoginDto loginDto) async {
    try {
      Logger.log('Attempting login for: ${loginDto.email}', tag: 'AUTH');
      final response = await _apiClient.post(
        ApiRoutes.login,
        body: loginDto.toJson(),
      );
      Logger.log('Login successful', tag: 'AUTH');
      return response;
    } catch (e) {
      Logger.error('Login failed', tag: 'AUTH', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(RegisterDto registerDto) async {
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
      return response;
    } catch (e) {
      Logger.error('Registration failed', tag: 'AUTH', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyEmail(VerifyDto verifyDto) async {
    try {
      Logger.log('Attempting email verification', tag: 'AUTH');
      final response = await _apiClient.post(
        ApiRoutes.verify,
        body: verifyDto.toJson(),
      );
      Logger.log('Email verification successful', tag: 'AUTH');
      return response;
    } catch (e) {
      Logger.error('Email verification failed', tag: 'AUTH', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> oauthLogin(OAuthDto oauthDto) async {
    try {
      Logger.log('Attempting OAuth login', tag: 'AUTH');
      final response = await _apiClient.post(
        ApiRoutes.oauth,
        body: oauthDto.toJson(),
      );
      Logger.log('OAuth login successful', tag: 'AUTH');
      return response;
    } catch (e) {
      Logger.error('OAuth login failed', tag: 'AUTH', error: e);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      Logger.log('Logging out', tag: 'AUTH');
      await _apiClient.post(ApiRoutes.logout);
      Logger.log('Logout successful', tag: 'AUTH');
    } catch (e) {
      Logger.error('Logout failed', tag: 'AUTH', error: e);
      rethrow;
    }
  }
}
