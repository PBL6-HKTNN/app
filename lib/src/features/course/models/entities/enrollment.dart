import 'package:codemy_app/src/core/models/entity.dart';

class Enrollment extends EntityModel {
  final String? enrollmentId;
  final int progressStatus;
  final int enrollmentStatus;
  final String? lessonId;
  final DateTime? completionDate;
  final String? certificateUrl;
  final DateTime? certificateExpiryDate;

  Enrollment(
    this.enrollmentId,
    this.progressStatus,
    this.lessonId,
    this.completionDate,
    this.certificateUrl,
    this.certificateExpiryDate,
    this.enrollmentStatus, {
    required super.id,
    required super.createdAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'enrollmentId': enrollmentId,
      'progressStatus': progressStatus,
      'enrollmentStatus': enrollmentStatus,
      'lessonId': lessonId,
      'completionDate': completionDate?.toIso8601String(),
      'certificateUrl': certificateUrl,
      'certificateExpiryDate': certificateExpiryDate?.toIso8601String(),
    };
  }

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      json['enrollmentId'] as String?,
      json['progressStatus'] as int,
      json['lessonId'] as String?,
      json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
      json['certificateUrl'] as String?,
      json['certificateExpiryDate'] != null
          ? DateTime.parse(json['certificateExpiryDate'] as String)
          : null,
      json['enrollmentStatus'] as int,
      id: json['id'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
