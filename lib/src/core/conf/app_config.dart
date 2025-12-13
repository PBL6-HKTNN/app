import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  final String baseUrl;
  final String env;
  final String googleClientId;
  final String googleServerClientId;
  final String googleClientSecret;
  final String stripePkKey;
  static late AppConfig instance;

  AppConfig._internal(
    this.baseUrl,
    this.env,
    this.googleClientId,
    this.googleServerClientId,
    this.googleClientSecret,
    this.stripePkKey,
  );

  factory AppConfig() {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000';
    final env = dotenv.env['ENV'] ?? 'development';
    final googleClientId = dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
    final googleServerClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '';
    final googleClientSecret = dotenv.env['GOOGLE_CLIENT_SECRET'] ?? '';
    final stripePkKey = dotenv.env['STRIPE_PK_KEY'] ?? '';

    instance = AppConfig._internal(
      baseUrl,
      env,
      googleClientId,
      googleServerClientId,
      googleClientSecret,
      stripePkKey,
    );
    return instance;
  }

  static Future<AppConfig> load() async {
    await dotenv.load(fileName: '.env');
    // Initialize the instance after loading environment variables
    return AppConfig();
  }
}
