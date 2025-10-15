import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../../../locale/index.dart';

class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      headers: [AppBar(title: Text(l10n.verifyButton))],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Email Verification',
                      style: Theme.of(context).typography.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We sent a verification code to your email. Please enter it below.',
                      style: Theme.of(context).typography.small,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Text('Verify Screen - Form Coming Soon'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
