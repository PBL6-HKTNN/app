import 'dart:io';

import 'storage_dto.dart';

/// Upload state for tracking file upload progress
class UploadState {
  final bool isUploading;
  final double progress;
  final String? error;
  final UploadFileResponse? result;

  const UploadState({
    this.isUploading = false,
    this.progress = 0.0,
    this.error,
    this.result,
  });

  UploadState copyWith({
    bool? isUploading,
    double? progress,
    String? error,
    UploadFileResponse? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      error: clearError ? null : (error ?? this.error),
      result: clearResult ? null : (result ?? this.result),
    );
  }

  bool get hasError => error != null;
  bool get hasResult => result != null;
  bool get isCompleted => !isUploading && (hasResult || hasError);
}

/// Media selection state for file picker
class MediaSelectionState {
  final File? selectedFile;
  final String? previewUrl;
  final FileType? fileType;

  const MediaSelectionState({
    this.selectedFile,
    this.previewUrl,
    this.fileType,
  });

  MediaSelectionState copyWith({
    File? selectedFile,
    String? previewUrl,
    FileType? fileType,
    bool clearSelection = false,
  }) {
    return MediaSelectionState(
      selectedFile: clearSelection ? null : (selectedFile ?? this.selectedFile),
      previewUrl: clearSelection ? null : (previewUrl ?? this.previewUrl),
      fileType: clearSelection ? null : (fileType ?? this.fileType),
    );
  }

  bool get hasSelection => selectedFile != null;
  bool get isImage => fileType == FileType.image;
  bool get isVideo => fileType == FileType.video;
}
