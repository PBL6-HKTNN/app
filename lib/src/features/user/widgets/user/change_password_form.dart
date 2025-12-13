import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../models/dto/user/change_password_request.dart';
import '../../services/user_service.dart';

class ChangePasswordForm extends ConsumerStatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  ConsumerState<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends ConsumerState<ChangePasswordForm> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('All fields are required'),
          actions: [
            PrimaryButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('New password and confirm password do not match'),
          actions: [
            PrimaryButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = ChangePasswordrequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final userService = ref.read(userServiceProvider);
      final result = await userService.changePassword(request);

      if (result.isSuccess) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: const Text('Password changed successfully!'),
              actions: [
                PrimaryButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(result.error?.toString() ?? 'Unknown error'),
              actions: [
                PrimaryButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to change password: $e'),
            actions: [
              PrimaryButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _currentPasswordController,
          obscureText: !_currentPasswordVisible,
          placeholder: const Text('Enter current password'),
          enabled: !_isLoading,
          trailing: Button.ghost(
            onPressed: () => setState(
              () => _currentPasswordVisible = !_currentPasswordVisible,
            ),
            child: Icon(
              _currentPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
            ),
          ),
        ),
        const Gap(16),
        TextField(
          controller: _newPasswordController,
          obscureText: !_newPasswordVisible,
          placeholder: const Text('Enter new password'),
          enabled: !_isLoading,
          trailing: Button.ghost(
            onPressed: () =>
                setState(() => _newPasswordVisible = !_newPasswordVisible),
            child: Icon(
              _newPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
            ),
          ),
        ),
        const Gap(16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: !_confirmPasswordVisible,
          placeholder: const Text('Confirm new password'),
          enabled: !_isLoading,
          trailing: Button.ghost(
            onPressed: () => setState(
              () => _confirmPasswordVisible = !_confirmPasswordVisible,
            ),
            child: Icon(
              _confirmPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
            ),
          ),
        ),
        const Gap(24),
        PrimaryButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    Gap(8),
                    Text('Changing...'),
                  ],
                )
              : const Text('Change Password'),
        ),
      ],
    );
  }
}
