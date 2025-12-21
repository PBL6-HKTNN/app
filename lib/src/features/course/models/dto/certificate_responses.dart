import 'package:codemy_app/src/features/course/models/entities/certificate.dart';

class GenerateCertResponse {
  final bool success;
  final String? message;
  final Certificate? certificate;

  GenerateCertResponse({required this.success, this.message, this.certificate});

  factory GenerateCertResponse.fromJson(Map<String, dynamic> json) {
    return GenerateCertResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      certificate: json['certificate'] != null
          ? Certificate.fromJson(json['certificate'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GetMyCertsResponse {
  final bool success;
  final String? message;
  final List<Certificate> certificates;

  GetMyCertsResponse({
    required this.success,
    this.message,
    required this.certificates,
  });

  factory GetMyCertsResponse.fromJson(Map<String, dynamic> json) {
    return GetMyCertsResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      certificates: (json['certificates'] as List<dynamic>? ?? [])
          .map((e) => Certificate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CertStatusResponse {
  final bool success;
  final String? message;
  final String? certificateUrl;
  final String? expiryDate;
  final String? certificateId;
  final String? status;

  CertStatusResponse({
    required this.success,
    this.message,
    this.certificateUrl,
    this.expiryDate,
    this.certificateId,
    this.status,
  });

  factory CertStatusResponse.fromJson(Map<String, dynamic> json) {
    return CertStatusResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      certificateUrl: json['certificateUrl'] as String?,
      expiryDate: json['expiryDate'] as String?,
      certificateId: json['certificateId'] as String?,
      status: json['status'] as String?,
    );
  }
}

class DownloadCertResponse {
  final bool success;
  final String? message;
  final String? certificateId;
  final String? downloadUrl;

  DownloadCertResponse({
    required this.success,
    this.message,
    this.certificateId,
    this.downloadUrl,
  });

  factory DownloadCertResponse.fromJson(Map<String, dynamic> json) {
    return DownloadCertResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      certificateId: json['certificateId'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
    );
  }
}
