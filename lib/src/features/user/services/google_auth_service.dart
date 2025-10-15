import 'package:codemy_app/src/core/conf/app_config.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/google_oauth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static GoogleSignIn get _googleSignIn => GoogleSignIn(
    clientId: AppConfig.instance.googleClientId.isNotEmpty
        ? AppConfig.instance.googleClientId
        : null,
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google and return OAuth data
  static Future<GoogleOAuthDto?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create DTO with Google OAuth data
      return GoogleOAuthDto(
        idToken: googleAuth.idToken ?? '',
        accessToken: googleAuth.accessToken ?? '',
        serverAuthCode: googleUser.serverAuthCode ?? '',
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
      await _googleSignIn.signOut();
    } catch (error) {
      Logger.error('Google Sign-Out error: $error');
    }
  }

  /// Check if user is already signed in
  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get current user if signed in
  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}
