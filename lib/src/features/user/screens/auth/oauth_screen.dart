import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../models/dto/auth/google_oauth.dart';
import '../../../../presentation/layouts/modal_layout.dart';

class OAuthScreen extends StatelessWidget {
  const OAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the Google OAuth data passed from the GoogleSignInButton
    final GoogleOAuthDto? googleData =
        GoRouterState.of(context).extra as GoogleOAuthDto?;

    return ModalLayout(
      title: 'Google Sign In Success',
      subtitle: 'You have successfully signed in with Google.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (googleData != null) ...[
            // Display user information
            _buildDataCard('User Information', [
              _buildDataRow('Email', googleData.email),
              _buildDataRow('Display Name', googleData.displayName),
              _buildDataRow('Photo URL', googleData.photoUrl ?? 'Not provided'),
            ]),
            const SizedBox(height: 16),

            // Display OAuth tokens (for development purposes)
            _buildDataCard('OAuth Tokens', [
              _buildDataRow('ID Token', _truncateToken(googleData.idToken)),
              _buildDataRow(
                'Access Token',
                _truncateToken(googleData.accessToken),
              ),
              _buildDataRow(
                'Server Auth Code',
                googleData.serverAuthCode ?? 'Not provided',
              ),
            ]),
            const SizedBox(height: 24),

            // Profile picture if available
            if (googleData.photoUrl != null)
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(googleData.photoUrl!),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        // Handle image loading error
                      },
                    ),
                  ),
                  child: googleData.photoUrl == null
                      ? const Icon(LucideIcons.user, size: 50)
                      : null,
                ),
              ),
            const SizedBox(height: 24),
          ] else ...[
            Text(
              'No OAuth data received.',
              style: Theme.of(context).typography.large,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],

          Row(
            children: [
              Expanded(
                child: Button.outline(
                  child: const Text('Back to Login'),
                  onPressed: () => context.go('/login'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Button.primary(
                  child: const Text('Continue to Home'),
                  onPressed: () => context.go('/'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _truncateToken(String token) {
    if (token.length <= 50) return token;
    return '${token.substring(0, 20)}...${token.substring(token.length - 20)}';
  }
}
