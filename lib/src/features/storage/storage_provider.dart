import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_dto.dart';
import 'storage_service.dart';
import 'storage_state.dart';

/// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Provider for upload state management
final uploadStateProvider = NotifierProvider<UploadStateNotifier, UploadState>(
  () {
    return UploadStateNotifier();
  },
);

/// Provider for media selection state
final mediaSelectionProvider =
    NotifierProvider<MediaSelectionNotifier, MediaSelectionState>(() {
      return MediaSelectionNotifier();
    });

class UploadStateNotifier extends Notifier<UploadState> {
  @override
  UploadState build() => const UploadState();

  /// Upload a file
  Future<UploadFileResponse?> uploadFile(UploadFileRequest request) async {
    state = state.copyWith(
      isUploading: true,
      progress: 0.0,
      clearError: true,
      clearResult: true,
    );

    try {
      // Simulate progress updates (since we can't get real progress from http package easily)
      _simulateProgress();

      final service = ref.read(storageServiceProvider);
      final response = await service.uploadFile(request);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          isUploading: false,
          progress: 1.0,
          result: response.data,
        );
        return response.data;
      } else {
        state = state.copyWith(
          isUploading: false,
          error: response.error?.toString() ?? 'Upload failed',
        );
        return null;
      }
    } catch (error) {
      state = state.copyWith(isUploading: false, error: error.toString());
      return null;
    }
  }

  /// Delete a file
  Future<bool> deleteFile(String publicId) async {
    try {
      final service = ref.read(storageServiceProvider);
      final response = await service.deleteFile(publicId);
      return response.isSuccess;
    } catch (error) {
      return false;
    }
  }

  /// Reset upload state
  void reset() {
    state = const UploadState();
  }

  /// Simulate progress for better UX
  void _simulateProgress() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (state.isUploading && state.progress < 0.9) {
        state = state.copyWith(progress: state.progress + 0.1);
        _simulateProgress();
      }
    });
  }
}

class MediaSelectionNotifier extends Notifier<MediaSelectionState> {
  @override
  MediaSelectionState build() => const MediaSelectionState();

  /// Select a file
  void selectFile(File file) {
    final fileType = UploadFileRequest.getFileTypeFromFile(file);
    String? previewUrl;

    // Create preview URL for images
    if (fileType == FileType.image) {
      previewUrl = file.path;
    }

    state = state.copyWith(
      selectedFile: file,
      fileType: fileType,
      previewUrl: previewUrl,
    );
  }

  /// Clear selection
  void clearSelection() {
    state = state.copyWith(clearSelection: true);
  }
}
