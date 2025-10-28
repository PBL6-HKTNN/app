import 'dart:io';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../models/entity/user.dart';

class AvatarPicker extends ConsumerStatefulWidget {
  const AvatarPicker({super.key});

  @override
  ConsumerState<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends ConsumerState<AvatarPicker> {
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;
  double _progress = 0.0;

  Future<void> _pick(ImageSource src) async {
    final XFile? xfile = await _picker.pickImage(source: src, imageQuality: 85);
    if (xfile == null) return;
    setState(() => _pickedImage = File(xfile.path));
    _showPreviewDialog();
  }

  Future<void> _showPreviewDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Preview Image'),
          content: Container(
            width: double.infinity,
            height: 360,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: _pickedImage != null
                ? Image.file(
                    _pickedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 360,
                  )
                : const Center(child: Text('No image selected')),
          ),
          actions: [
            Button.ghost(
              onPressed: () {
                setState(() => _pickedImage = null);
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            Button.primary(
              onPressed: _uploading ? null : _mockUpload,
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mockUpload() async {
    if (_pickedImage == null) return;
    setState(() {
      _uploading = true;
      _progress = 0.0;
    });

    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      setState(() => _progress = i / 10);
    }

    final authNotifier = ref.read(authStateProvider.notifier);
    final currentUser = ref.read(authStateProvider).user;
    if (currentUser != null) {
      final updatedJson = currentUser.toJson();
      updatedJson['profilePicture'] = _pickedImage!.path;
      final updatedUser = User.fromJson(updatedJson);
      authNotifier.state = authNotifier.state.copyWith(user: updatedUser);
      if (authNotifier.state.token != null) {
        await authNotifier.saveAuthState(
          authNotifier.state.token!,
          updatedUser.toJson(),
        );
      }
    }

    setState(() {
      _uploading = false;
      _pickedImage = null;
      _progress = 0.0;
    });
    Navigator.pop(context);
    showToast(
      context: context,
      builder: (context, overlay) {
        return Card(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.circle, color: Color(0xFF22C55E)),
              const SizedBox(width: 8),
              const Text('Avatar updated successfully'),
              const SizedBox(width: 12),
              Button.ghost(
                onPressed: overlay.close,
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      location: ToastLocation.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final isStudent = (user?.role ?? -1) == 2;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 184, 185, 225),
                  Color.fromARGB(255, 169, 157, 196),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1A000000),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                shape: BoxShape.circle,
              ),
              child: Avatar(
                size: 140,
                provider: _pickedImage != null
                    ? FileImage(_pickedImage!)
                    : user?.profilePicture.isNotEmpty == true
                    ? (user!.profilePicture.startsWith('http')
                          ? NetworkImage(user.profilePicture)
                          : FileImage(File(user.profilePicture)))
                    : null,
                initials: (user?.name != null && user!.name.isNotEmpty)
                    ? user.name[0].toUpperCase()
                    : '?',
              ),
            ),
          ),
          const Gap(16),

          if (isStudent)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 36,
                  child: Button.primary(
                    onPressed: () => _pick(ImageSource.gallery),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(LucideIcons.image, size: 16),
                        Gap(6),
                        Text('Gallery', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const Gap(12),
                SizedBox(
                  width: 120,
                  height: 36,
                  child: Button.outline(
                    onPressed: () => _pick(ImageSource.camera),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(LucideIcons.camera, size: 16),
                        Gap(6),
                        Text('Camera', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              'Editing avatar is allowed for Students only',
              style: TextStyle(
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
          if (_uploading)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  LinearProgressIndicator(value: _progress),
                  const Gap(8),
                  Text('${(_progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
