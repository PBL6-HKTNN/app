import 'package:codemy_app/l10n/app_localizations.dart';
import 'package:codemy_app/src/features/user/services/google_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';

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

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    widget.onSignInStart?.call();

    try {
      final googleOAuthData = await GoogleAuthService.signInWithGoogle();

      if (googleOAuthData != null) {
        // Navigate to OAuth screen with the retrieved data
        if (mounted) {
          context.go('/oauth', extra: googleOAuthData);
          widget.onSignInComplete?.call();
        }
      } else {
        // User cancelled sign-in
        widget.onError?.call('Sign-in was cancelled');
      }
    } catch (error) {
      widget.onError?.call('Sign-in failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = _isLoading || widget.isLoading;
    final theme = Theme.of(context);

    return Button.outline(
      onPressed: isLoading ? null : _handleGoogleSignIn,
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
              decoration: const BoxDecoration(
                color: Color(0xFF4285F4), // Google Blue
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.user,
                size: 12,
                color: Color(0xFFFFFFFF),
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
