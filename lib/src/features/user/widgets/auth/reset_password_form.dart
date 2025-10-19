import 'package:codemy_app/src/core/validators/index.dart';
import 'package:codemy_app/src/core/validators/password.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/reset_password.dart';
import 'package:codemy_app/src/features/user/providers/auth_providers.dart';
import 'package:codemy_app/src/locale/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordForm extends ConsumerStatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  ConsumerState<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends ConsumerState<ResetPasswordForm> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _emailError;
  String? _tokenError;
  String? _newPasswordError;
  String? _confirmPasswordError;
  bool _tokenSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendResetCode() async {
    final emailError = validateEmail(_emailController.text);
    setState(() {
      _emailError = emailError;
    });

    if (emailError != null) {
      return;
    }

    await ref
        .read(authStateProvider.notifier)
        .getResetPasswordToken(_emailController.text.trim());

    final authState = ref.read(authStateProvider);
    if (!authState.isLoading && authState.error == null && mounted) {
      setState(() => _tokenSent = true);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Reset code sent to your email'),
          actions: [
            Button.primary(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _handleResetPassword() async {
    final emailError = validateEmail(_emailController.text);
    final tokenError = validateLength(_tokenController.text, min: 1);
    final newPasswordError = validatePassword(_newPasswordController.text);
    final confirmPasswordError =
        _newPasswordController.text != _confirmPasswordController.text
        ? 'Passwords do not match'
        : null;

    setState(() {
      _emailError = emailError;
      _tokenError = tokenError;
      _newPasswordError = newPasswordError;
      _confirmPasswordError = confirmPasswordError;
    });

    if (emailError != null ||
        tokenError != null ||
        newPasswordError != null ||
        confirmPasswordError != null) {
      return;
    }

    final resetPasswordDto = ResetPasswordDto(
      email: _emailController.text.trim(),
      token: _tokenController.text,
      newPassword: _newPasswordController.text,
    );

    await ref.read(authStateProvider.notifier).resetPassword(resetPasswordDto);

    final authState = ref.read(authStateProvider);
    if (!authState.isLoading && authState.error == null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Password reset successful'),
          actions: [
            Button.primary(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/login');
              },
              child: Text('Go to Login'),
            ),
          ],
        ),
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
        // Email field
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

        // Send reset code button
        Button.outline(
          onPressed: authState.isLoading ? null : _sendResetCode,
          child: authState.isLoading && !_tokenSent
              ? const Text('Sending...')
              : Text(l10n.sendResetCode),
        ),
        const SizedBox(height: 24),

        if (_tokenSent) ...[
          // Token field
          TextField(
            controller: _tokenController,
            placeholder: Text(l10n.resetCode),
            features: [
              InputFeature.leading(const Icon(Icons.lock_reset_outlined)),
            ],
          ),
          if (_tokenError != null)
            Text(
              _tokenError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.destructive,
              ),
            ),
          const SizedBox(height: 16),

          // New password field
          TextField(
            controller: _newPasswordController,
            placeholder: Text(l10n.enterNewPassword),
            obscureText: _obscureNewPassword,
            features: [
              InputFeature.leading(const Icon(Icons.lock_outlined)),
              InputFeature.trailing(
                Button.ghost(
                  onPressed: () => setState(
                    () => _obscureNewPassword = !_obscureNewPassword,
                  ),
                  child: Icon(
                    _obscureNewPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
              ),
            ],
          ),
          if (_newPasswordError != null)
            Text(
              _newPasswordError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.destructive,
              ),
            ),
          const SizedBox(height: 16),

          // Confirm password field
          TextField(
            controller: _confirmPasswordController,
            placeholder: Text(l10n.confirmPassword),
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.destructive,
              ),
            ),
          const SizedBox(height: 24),

          // Reset password button
          Button.primary(
            onPressed: authState.isLoading ? null : _handleResetPassword,
            child: authState.isLoading
                ? const Text('Resetting...')
                : Text(l10n.resetPassword),
          ),
        ],

        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Remember your password?', style: TextStyle(fontSize: 16)),
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
