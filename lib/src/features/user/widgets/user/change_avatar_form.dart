import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../models/dto/user/change_avatar_request.dart';
import '../../models/entity/user.dart';
import '../../services/user_service.dart';

class ChangeAvatarForm extends ConsumerStatefulWidget {
  final User user;

  const ChangeAvatarForm({super.key, required this.user});

  @override
  ConsumerState<ChangeAvatarForm> createState() => _ChangeAvatarFormState();
}

class _ChangeAvatarFormState extends ConsumerState<ChangeAvatarForm> {
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1024,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to pick image: $e'),
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
  }

  Future<void> _submit() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      final request = ChangeAvatarRequest(avatar: _selectedImage!);
      final userService = ref.read(userServiceProvider);
      final result = await userService.changeAvatar(request);

      if (result.isSuccess) {
        setState(() {
          _selectedImage = null;
        });

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: const Text('Avatar updated successfully!'),
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
            content: Text('Failed to update avatar: $e'),
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
      children: [
        // Current Avatar Preview
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Theme.of(context).colorScheme.muted,
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
              : widget.user.profilePicture != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    widget.user.profilePicture!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(LucideIcons.user, size: 40),
                  ),
                )
              : const Icon(LucideIcons.user, size: 40),
        ),

        const Gap(16),

        // Pick Image Button
        SecondaryButton(
          onPressed: _isLoading ? null : _pickImage,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.image, size: 16),
              Gap(8),
              Text('Choose Image'),
            ],
          ),
        ),

        if (_selectedImage != null) ...[
          const Gap(16),
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
                      Text('Uploading...'),
                    ],
                  )
                : const Text('Update Avatar'),
          ),
        ],
      ],
    );
  }
}
