import 'package:codemy_app/l10n/app_localizations.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/user/services/google_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import '../../models/dto/auth/google_oauth.dart';

class GoogleSignInButton extends ConsumerStatefulWidget {
  final String? text;
  final bool isLoading;
  final VoidCallback? onSignInStart;
  final VoidCallback? onSignInComplete;
  final Function(String)? onError;

  const GoogleSignInButton({
    super.key,
    this.text,
    this.isLoading = false,
    this.onSignInStart,
    this.onSignInComplete,
    this.onError,
  });

  @override
  ConsumerState<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends ConsumerState<GoogleSignInButton> {
  bool _isLoading = false;
  late StreamSubscription<GoogleSignInAuthenticationEvent> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = GoogleAuthService.googleSignIn.authenticationEvents
        .listen(_handleAuthEvent, onError: _handleAuthError);
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void _handleAuthEvent(GoogleSignInAuthenticationEvent event) {
    final user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };
    if (user != null && mounted) {
      setState(() => _isLoading = true);
      _getDtoAndNavigate(user);
    }
  }

  void _handleAuthError(Object error) {
    setState(() {
      _isLoading = false;
    });
    widget.onError?.call(error.toString());
  }

  Future<void> _getDtoAndNavigate(GoogleSignInAccount user) async {
    final scopes = ['email', 'profile'];
    final headers = await user.authorizationClient.authorizationHeaders(scopes);
    final accessToken = headers?['Authorization']?.substring(7) ?? '';
    final serverAuth = await user.authorizationClient.authorizeServer(scopes);
    final serverAuthCode = serverAuth?.serverAuthCode ?? '';
    final dto = GoogleOAuthDto(
      idToken: user.authentication.idToken ?? '',
      accessToken: accessToken,
      serverAuthCode: serverAuthCode,
      email: user.email,
      displayName: user.displayName ?? '',
      photoUrl: user.photoUrl,
    );
    setState(() {
      _isLoading = false;
    });
    if (mounted) {
      Logger.log(
        'Navigating to OAuthScreen with DTO: ${dto.idToken}',
        tag: 'GOOGLE_SIGN_IN',
      );
      context.go('/oauth', extra: dto);
    }
    widget.onSignInComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = _isLoading || widget.isLoading;
    final theme = Theme.of(context);

    return Button.outline(
      onPressed: isLoading
          ? null
          : () => GoogleAuthService.googleSignIn.authenticate(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.mutedForeground,
              ),
            )
          else
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.google, size: 16),
              ),
            ),
          const SizedBox(width: 12),
          Text(
            isLoading ? 'Signing in...' : widget.text ?? l10n.signInWithGoogle,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
