import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../providers/user_provider.dart';

class AvatarPicker extends ConsumerStatefulWidget {
  const AvatarPicker({super.key});

  @override
  ConsumerState<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends ConsumerState<AvatarPicker>
    with SingleTickerProviderStateMixin {
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;
  double _progress = 0.0;

  Future<void> _pick(ImageSource src) async {
    final XFile? xfile = await _picker.pickImage(source: src, imageQuality: 85);
    if (xfile == null) return;
    setState(() => _pickedImage = File(xfile.path));
    // show preview dialog
    _showPreview();
  }

  Future<void> _showPreview() async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: double.infinity,
          height: 420,
          child: Column(
            children: [
              Expanded(
                child: _pickedImage != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.file(_pickedImage!, fit: BoxFit.cover, width: double.infinity),
                      )
                    : const SizedBox.shrink(),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _pickedImage = null);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _uploading ? null : _mockUpload,
                      child: const Text('Upload'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mockUpload() async {
    if (_pickedImage == null) return;
    setState(() {
      _uploading = true;
      _progress = 0.0;
    });
    // mock progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      setState(() => _progress = i / 10);
    }
    // when "uploaded", update provider (mock avatarUrl using local file path for preview)
    final user = ref.read(userProvider.notifier).state;
    // In real app you will call ApiClient.uploadAvatar and get remote URL.
    final updated = user.copyWith(avatarUrl: _pickedImage!.path);
    ref.read(userProvider.notifier).state = updated;
    setState(() {
      _uploading = false;
      _pickedImage = null;
      _progress = 0.0;
    });
    Navigator.of(context).pop(); // close preview
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar updated (mock)')));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isStudent = user.role.toLowerCase() == 'student';

    Widget avatarContent;
    if (_pickedImage != null) {
      avatarContent = CircleAvatar(radius: 56, backgroundImage: FileImage(_pickedImage!));
    } else if (user.avatarUrl != null) {
      // if avatarUrl is remote (http), use NetworkImage. If local path (mock), use FileImage.
      if (user.avatarUrl!.startsWith('http')) {
        avatarContent = CircleAvatar(radius: 56, backgroundImage: NetworkImage(user.avatarUrl!));
      } else {
        avatarContent = CircleAvatar(radius: 56, backgroundImage: FileImage(File(user.avatarUrl!)));
      }
    } else {
      avatarContent = const CircleAvatar(radius: 56, child: Icon(Icons.person, size: 56));
    }

    return Column(
      children: [
        // Avatar with elegant border + shadow
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withOpacity(0.3), Colors.transparent]),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: CircleAvatar(
            radius: 62,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: avatarContent,
          ),
        ),
        const SizedBox(height: 12),
        if (isStudent)
          Wrap(
            spacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              ),
              OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Camera'),
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              ),
            ],
          )
        else
          Text('Editing avatar is allowed for Students only', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        // upload progress indicator
        if (_uploading)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 8),
                Text('${(_progress * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ),
      ],
    );
  }
}