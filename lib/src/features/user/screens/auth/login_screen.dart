import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../widgets/auth/login_form.dart';
import '../../../../locale/index.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      headers: [AppBar(title: Text(l10n.login))],
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
                      l10n.login,
                      style: Theme.of(context).typography.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back! Please sign in to your account.',
                      style: Theme.of(context).typography.small,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const LoginForm(),
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
