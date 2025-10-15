import 'app_config.dart';

class ApiRoutes {
  // Base URL from AppConfig
  static String get baseUrl => AppConfig.instance.baseUrl;

  // Auth routes
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get verify => '$baseUrl/auth/verify';
  static String get oauth => '$baseUrl/auth/oauth';
  static String get logout => '$baseUrl/auth/logout';
}
