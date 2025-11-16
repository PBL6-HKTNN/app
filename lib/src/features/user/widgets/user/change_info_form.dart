import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../models/dto/user/change_info_request.dart';
import '../../models/entity/user.dart';
import '../../services/user_service.dart';

class ChangeInfoForm extends ConsumerStatefulWidget {
  final User user;

  const ChangeInfoForm({super.key, required this.user});

  @override
  ConsumerState<ChangeInfoForm> createState() => _ChangeInfoFormState();
}

class _ChangeInfoFormState extends ConsumerState<ChangeInfoForm> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name ?? '';
    _bioController.text = widget.user.bio ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final request = ChangeInfoRequest(
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
      );

      final userService = ref.read(userServiceProvider);
      final result = await userService.changeInfo(request);

      if (result.isSuccess) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: const Text('Profile updated successfully!'),
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
            content: Text('Failed to update profile: $e'),
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
          controller: _nameController,
          placeholder: const Text('Enter your full name'),
          enabled: !_isLoading,
        ),
        const Gap(16),
        TextField(
          controller: _bioController,
          placeholder: const Text('Tell us about yourself'),
          enabled: !_isLoading,
          maxLines: 3,
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
                    Text('Updating...'),
                  ],
                )
              : const Text('Update Profile'),
        ),
      ],
    );
  }
}
