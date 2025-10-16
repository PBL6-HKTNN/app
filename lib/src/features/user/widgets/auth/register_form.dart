import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';
import '../../models/dto/auth/register.dart';
import '../../../../locale/index.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    // Basic validation
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      return;
    }

    final registerDto = RegisterDto(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    await ref.read(authStateProvider.notifier).register(registerDto);

    final authState = ref.read(authStateProvider);
    if (!authState.isLoading && authState.error == null && mounted) {
      context.go('/verify');
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
          controller: _nameController,
          placeholder: const Text('Enter your name'),
          features: [InputFeature.leading(const Icon(Icons.person_outlined))],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          placeholder: Text(l10n.enterEmail),
          keyboardType: TextInputType.emailAddress,
          features: [InputFeature.leading(const Icon(Icons.email_outlined))],
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
