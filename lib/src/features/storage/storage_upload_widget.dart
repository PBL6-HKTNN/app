import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'storage_dto.dart';
import 'storage_provider.dart';
import 'storage_state.dart';

class MediaUploadWidget extends ConsumerStatefulWidget {
  final Function(UploadFileResponse)? onUploadSuccess;
  final Function(String)? onUploadError;
  final List<FileType> allowedTypes;
  final double maxSizeInMB;
  final String title;
  final String description;
  final bool showPreview;

  const MediaUploadWidget({
    super.key,
    this.onUploadSuccess,
    this.onUploadError,
    this.allowedTypes = const [
      FileType.image,
      FileType.video,
      FileType.document,
    ],
    this.maxSizeInMB = 10.0,
    this.title = 'Upload Media',
    this.description = 'Select a file to upload',
    this.showPreview = true,
  });

  @override
  ConsumerState<MediaUploadWidget> createState() => _MediaUploadWidgetState();
}

class _MediaUploadWidgetState extends ConsumerState<MediaUploadWidget> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadStateProvider);
    final mediaState = ref.watch(mediaSelectionProvider);
    final uploadNotifier = ref.read(uploadStateProvider.notifier);
    final mediaNotifier = ref.read(mediaSelectionProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title and description
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // File selection area
            if (!mediaState.hasSelection) ..._buildSelectionArea(),

            // File preview
            if (mediaState.hasSelection && widget.showPreview)
              ..._buildPreview(mediaState),

            // Upload progress
            if (uploadState.isUploading) ..._buildProgress(uploadState),

            // Error display
            if (uploadState.hasError) ..._buildError(uploadState.error!),

            // Success display
            if (uploadState.hasResult) ..._buildSuccess(uploadState.result!),

            const SizedBox(height: 16),

            // Action buttons
            _buildActionButtons(
              mediaState,
              uploadState,
              uploadNotifier,
              mediaNotifier,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSelectionArea() {
    return [
      GestureDetector(
        onTap: _showFileOptions,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              style: BorderStyle.solid,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to select file',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Max size: ${widget.maxSizeInMB.toStringAsFixed(1)}MB',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildPreview(MediaSelectionState mediaState) {
    return [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // File icon or image preview
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.shade200,
              ),
              child: mediaState.isImage && mediaState.previewUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(
                        File(mediaState.previewUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _getFileIcon(mediaState.fileType!),
                      ),
                    )
                  : _getFileIcon(mediaState.fileType!),
            ),
            const SizedBox(width: 12),
            // File info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mediaState.selectedFile!.path.split('/').last,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${mediaState.fileType!.value.toUpperCase()} • ${_formatBytes(mediaState.selectedFile!.lengthSync())}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            // Remove button
            IconButton(
              onPressed: () =>
                  ref.read(mediaSelectionProvider.notifier).clearSelection(),
              icon: const Icon(Icons.close),
              tooltip: 'Remove file',
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildProgress(UploadState uploadState) {
    return [
      const SizedBox(height: 8),
      LinearProgressIndicator(value: uploadState.progress),
      const SizedBox(height: 4),
      Text(
        'Uploading... ${(uploadState.progress * 100).toInt()}%',
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    ];
  }

  List<Widget> _buildError(String error) {
    return [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildSuccess(UploadFileResponse result) {
    return [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Upload successful!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildActionButtons(
    MediaSelectionState mediaState,
    UploadState uploadState,
    UploadStateNotifier uploadNotifier,
    MediaSelectionNotifier mediaNotifier,
  ) {
    return Row(
      children: [
        if (mediaState.hasSelection && !uploadState.isUploading) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                mediaNotifier.clearSelection();
                uploadNotifier.reset();
              },
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: _uploadFile,
              child: const Text('Upload'),
            ),
          ),
        ] else if (uploadState.hasResult) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                mediaNotifier.clearSelection();
                uploadNotifier.reset();
              },
              child: const Text('Upload Another'),
            ),
          ),
        ] else if (!mediaState.hasSelection && !uploadState.isUploading) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: _showFileOptions,
              child: const Text('Select File'),
            ),
          ),
        ],
      ],
    );
  }

  void _showFileOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.allowedTypes.contains(FileType.image)) ...[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
            if (widget.allowedTypes.contains(FileType.video)) ...[
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Choose Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.gallery);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Choose File'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        if (_validateFile(file)) {
          ref.read(mediaSelectionProvider.notifier).selectFile(file);
        }
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 10),
      );

      if (video != null) {
        final file = File(video.path);
        if (_validateFile(file)) {
          ref.read(mediaSelectionProvider.notifier).selectFile(file);
        }
      }
    } catch (e) {
      _showError('Failed to pick video: $e');
    }
  }

  Future<void> _pickFile() async {
    // For now, use image picker for files. In production, consider using file_picker package
    await _pickImage(ImageSource.gallery);
  }

  bool _validateFile(File file) {
    final sizeInBytes = file.lengthSync();
    final sizeInMB = sizeInBytes / (1024 * 1024);

    if (sizeInMB > widget.maxSizeInMB) {
      _showError('File size exceeds ${widget.maxSizeInMB}MB limit');
      return false;
    }

    final fileType = UploadFileRequest.getFileTypeFromFile(file);
    if (!widget.allowedTypes.contains(fileType)) {
      _showError('File type not allowed');
      return false;
    }

    return true;
  }

  Future<void> _uploadFile() async {
    final mediaState = ref.read(mediaSelectionProvider);
    if (!mediaState.hasSelection) return;

    final request = UploadFileRequest(
      type: mediaState.fileType!,
      file: mediaState.selectedFile!,
    );

    final result = await ref
        .read(uploadStateProvider.notifier)
        .uploadFile(request);

    if (result != null) {
      widget.onUploadSuccess?.call(result);
    } else {
      final error = ref.read(uploadStateProvider).error ?? 'Upload failed';
      widget.onUploadError?.call(error);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Widget _getFileIcon(FileType type) {
    IconData iconData;
    switch (type) {
      case FileType.image:
        iconData = Icons.image;
        break;
      case FileType.video:
        iconData = Icons.video_file;
        break;
      case FileType.document:
        iconData = Icons.description;
        break;
      case FileType.other:
        iconData = Icons.insert_drive_file;
        break;
    }

    return Icon(
      iconData,
      size: 24,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    final i = (bytes.bitLength - 1) ~/ 10;
    final size = bytes / (1 << (i * 10));
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}
