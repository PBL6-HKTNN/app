import 'package:codemy_app/src/core/validators/index.dart';
import 'package:codemy_app/src/core/validators/password.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/register.dart';
import 'package:codemy_app/src/features/user/providers/auth_providers.dart';
import 'package:codemy_app/src/locale/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final emailError = validateEmail(_emailController.text);
    final passwordError = validatePassword(_passwordController.text);
    String? confirmPasswordError;
    if (_passwordController.text != _confirmPasswordController.text) {
      confirmPasswordError = 'Passwords do not match';
    }

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    if (emailError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      return;
    }

    final registerDto = RegisterDto(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    await ref.read(authStateProvider.notifier).register(registerDto);

    final authState = ref.read(authStateProvider);
    if (!authState.isLoading && authState.error == null && mounted) {
      context.go(
        Uri(
          path: '/verify',
          queryParameters: {'email': registerDto.email},
        ).toString(),
      );
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
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          placeholder: const Text('Confirm your password'),
          obscureText: _obscureConfirmPassword,
          features: [
            InputFeature.leading(const Icon(Icons.lock_outlined)),
            InputFeature.trailing(
              Button.ghost(
                onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
                child: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
          ],
        ),
        if (_confirmPasswordError != null)
          Text(
            _confirmPasswordError!,
            style: TextStyle(color: Theme.of(context).colorScheme.destructive),
          ),
        const SizedBox(height: 24),
        Button.primary(
          onPressed: authState.isLoading ? null : _handleRegister,
          child: authState.isLoading
              ? const Text('Loading...')
              : Text(l10n.register),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.alreadyHaveAccount, style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Button.ghost(
              onPressed: () => context.go('/login'),
              child: Text(l10n.login),
            ),
          ],
        ),
      ],
    );
  }
}
