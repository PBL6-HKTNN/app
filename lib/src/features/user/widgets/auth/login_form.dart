import 'package:codemy_app/src/core/validators/index.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/login.dart';
import 'package:codemy_app/src/features/user/providers/auth_providers.dart';
import 'package:codemy_app/src/locale/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';

import 'google_sign_in_button.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final emailError = validateEmail(_emailController.text);
    final passwordError = validateLength(_passwordController.text, min: 1);

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    if (emailError != null || passwordError != null) {
      return;
    }

    final loginDto = LoginDto(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    await ref.read(authStateProvider.notifier).login(loginDto);

    final authState = ref.read(authStateProvider);
    if (authState.isAuthenticated && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (previous, next) {
      if (next.error != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.error),
            content: Text(next.error!),
            actions: [
              Button.primary(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(authStateProvider.notifier).clearError();
                },
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          placeholder: Text(l10n.enterEmail),
          keyboardType: TextInputType.emailAddress,
          features: [InputFeature.leading(const Icon(Icons.email_outlined))],
        ),
        if (_emailError != null)
          Text(
            _emailError!,
            style: TextStyle(color: Theme.of(context).colorScheme.destructive),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          placeholder: Text(l10n.enterPassword),
          obscureText: _obscurePassword,
          features: [
            InputFeature.leading(const Icon(Icons.lock_outlined)),
            InputFeature.trailing(
              Button.ghost(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
          ],
        ),
        if (_passwordError != null)
          Text(
            _passwordError!,
            style: TextStyle(color: Theme.of(context).colorScheme.destructive),
          ),
        const SizedBox(height: 24),
        Button.primary(
          onPressed: authState.isLoading ? null : _handleLogin,
          child: authState.isLoading
              ? const Text('Loading...')
              : Text(l10n.login),
        ),
        const SizedBox(height: 16),
        // Divider with "or" text
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Text(
                'or',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        // Google Sign-In Button
        GoogleSignInButton(
          onError: (error) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.error),
                content: Text(error),
                actions: [
                  Button.primary(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.ok),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.dontHaveAccount, style: TextStyle(fontSize: 17)),
            const SizedBox(width: 8),
            Button.ghost(
              onPressed: () => context.go('/register'),
              child: Text(l10n.register),
            ),
          ],
        ),
      ],
    );
  }
}
