import 'dart:io';

/// File type enumeration matching web API
enum FileType {
  image('image'),
  video('video'),
  document('document'),
  other('other');

  const FileType(this.value);
  final String value;

  static FileType fromString(String value) {
    return FileType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => FileType.other,
    );
  }
}

/// Upload file request DTO
class UploadFileRequest {
  final FileType type;
  final File file;
  final String? fileName;

  const UploadFileRequest({
    required this.type,
    required this.file,
    this.fileName,
  });

  /// Automatically determine file type from file extension
  static FileType getFileTypeFromFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return FileType.image;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return FileType.video;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
        return FileType.document;
      default:
        return FileType.other;
    }
  }
}

/// Upload file response DTO
class UploadFileResponse {
  final String url;
  final String publicId;
  final FileType type;

  const UploadFileResponse({
    required this.url,
    required this.publicId,
    required this.type,
  });

  factory UploadFileResponse.fromJson(Map<String, dynamic> json) {
    return UploadFileResponse(
      url: json['url'] as String,
      publicId: json['publicId'] as String,
      type: FileType.fromString(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'publicId': publicId, 'type': type.value};
  }
}
