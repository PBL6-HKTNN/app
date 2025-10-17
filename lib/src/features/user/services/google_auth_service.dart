import 'package:codemy_app/src/core/conf/app_config.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/google_oauth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static GoogleSignIn? _googleSignIn;

  static GoogleSignIn get googleSignIn => _googleSignIn!;

  static Future<void> initialize() async {
    _googleSignIn ??= GoogleSignIn.instance;
    await _googleSignIn!.initialize(
      clientId: AppConfig.instance.googleClientId,
      serverClientId: AppConfig.instance.googleServerClientId,
    );
    Logger.log(
      'GoogleAuthService initialized ${AppConfig.instance.googleClientId}, ${AppConfig.instance.googleServerClientId}',
      tag: 'GOOGLE_AUTH',
    );
  }

  /// Stream of authentication state changes
  static Stream<GoogleSignInAccount?> get authStateChanges {
    return googleSignIn.authenticationEvents.map((event) {
      return switch (event) {
        GoogleSignInAuthenticationEventSignIn() => event.user,
        GoogleSignInAuthenticationEventSignOut() => null,
      };
    });
  }

  /// Sign in with Google and return OAuth data
  static Future<GoogleOAuthDto?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      final scopes = <String>['email', 'profile', 'openid'];
      final headers = await googleUser.authorizationClient.authorizationHeaders(
        scopes,
      );
      final accessToken = headers?['Authorization']?.substring(7) ?? '';
      final serverAuth = await googleUser.authorizationClient.authorizeServer(
        scopes,
      );
      final serverAuthCode = serverAuth?.serverAuthCode ?? '';
      Logger.info(
        'Google Sign-In successful: ${googleUser.email}, idToken: ${googleUser.authentication.idToken}',
        tag: 'GOOGLE_AUTH',
      );

      // Create DTO with Google OAuth data
      return GoogleOAuthDto(
        idToken: googleUser.authentication.idToken ?? '',
        accessToken: accessToken,
        serverAuthCode: serverAuthCode,
        email: googleUser.email,
        displayName: googleUser.displayName ?? '',
        photoUrl: googleUser.photoUrl,
      );
    } catch (error) {
      Logger.error('Google Sign-In error: $error');
      return null;
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
    } catch (error) {
      Logger.error('Google Sign-Out error: $error');
    }
  }

  /// Check if user is already signed in
  static Future<bool> isSignedIn() async {
    return false; // TODO: implement with stream
  }
}
