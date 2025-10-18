import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/dto/auth/google_oauth.dart';
import '../../models/dto/auth/oauth.dart';
import '../../providers/auth_providers.dart';
import '../../../../presentation/layouts/modal_layout.dart';

class OAuthScreen extends ConsumerStatefulWidget {
  const OAuthScreen({super.key});

  @override
  ConsumerState<OAuthScreen> createState() => _OAuthScreenState();
}

class _OAuthScreenState extends ConsumerState<OAuthScreen> {
  GoogleOAuthDto? _googleData;
  bool _hasPerformedLogin = false;

  @override
  void initState() {
    super.initState();
    // Get the Google OAuth data passed from the GoogleSignInButton
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final googleData = GoRouterState.of(context).extra as GoogleOAuthDto?;
      print(
        'OAuthScreen: Received googleData: ${googleData != null ? 'YES' : 'NO'}',
      );
      if (googleData != null) {
        print(
          'OAuthScreen: Google data - email: ${googleData.email}, has idToken: ${googleData.idToken.isNotEmpty}',
        );
      }
      if (googleData != null && !_hasPerformedLogin) {
        _googleData = googleData;
        _hasPerformedLogin = true;
        _performOAuthLogin();
      }
    });
  }

  Future<void> _performOAuthLogin() async {
    if (_googleData == null) {
      print('OAuthScreen: No Google data available');
      return;
    }

    print(
      'OAuthScreen: Performing OAuth login with token: ${_googleData!.idToken.substring(0, 20)}...',
    );

    final oauthDto = OAuthDto(token: _googleData!.idToken, provider: 'google');

    await ref.read(authStateProvider.notifier).oauthLogin(oauthDto);

    final authState = ref.read(authStateProvider);
    if (!authState.isLoading && authState.error == null && mounted) {
      print('OAuthScreen: Login successful, navigating to home');
      // Success - navigate to home
      context.go('/');
    } else if (!authState.isLoading && authState.error != null && mounted) {
      print('OAuthScreen: Login failed with error: ${authState.error}');
      // Error - show alert and go back to login
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Authentication Failed'),
          content: Text(authState.error!),
          actions: [
            Button.primary(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/login');
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return ModalLayout(
      title: 'Signing you in...',
      subtitle: 'Please wait while we complete your Google sign-in.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile picture if available
          if (_googleData?.photoUrl != null)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(_googleData!.photoUrl!),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // Handle image loading error
                  },
                ),
              ),
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.gray,
              ),
              child: const Icon(LucideIcons.user, size: 40),
            ),

          const SizedBox(height: 24),

          if (authState.isLoading)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Completing sign-in...'),
              ],
            )
          else if (authState.error != null)
            Column(
              children: [
                Icon(
                  LucideIcons.messageCircleWarning,
                  color: Theme.of(context).colorScheme.destructive,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sign-in failed',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.destructive,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(authState.error!, textAlign: TextAlign.center),
              ],
            )
          else
            const Column(
              children: [
                Icon(LucideIcons.check, color: Colors.green, size: 48),
                SizedBox(height: 16),
                Text('Sign-in successful!'),
              ],
            ),
        ],
      ),
    );
  }
}
