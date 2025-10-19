import 'app_config.dart';

class ApiRoutes {
  // Base URL from AppConfig
  static String get baseUrl => AppConfig.instance.baseUrl;

  // Auth routes
  static String get login => '$baseUrl/Auth/login';
  static String get register => '$baseUrl/Auth/register';
  static String get verify => '$baseUrl/Auth/verify-email';
  static String get oauth => '$baseUrl/Auth/google-login';
  static String get resetPassword => '$baseUrl/Auth/reset-password';
  static String get resetPasswordToken => '$baseUrl/Auth/token-reset-password';
  static String get logout => '$baseUrl/Auth/logout';
}
