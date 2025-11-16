import 'package:codemy_app/src/core/models/entity.dart';

class Enrollment extends EntityModel {
  final String enrollmentId;
  final int progressStatus;
  final int enrollmentStatus;
  final String? lessonId;
  final DateTime completionDate;
  final String certificateUrl;
  final DateTime certificateExpiryDate;

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
      'createdAt': createdAt,
      'enrollmentId': enrollmentId,
      'progressStatus': progressStatus,
      'enrollmentStatus': enrollmentStatus,
      'lessonId': lessonId,
      'completionDate': completionDate,
      'certificateUrl': certificateUrl,
      'certificateExpiryDate': certificateExpiryDate,
    };
  }

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      json['enrollmentId'] as String,
      json['progressStatus'] as int,
      json['lessonId'] as String?,
      DateTime.parse(json['completionDate'] as String),
      json['certificateUrl'] as String,
      DateTime.parse(json['certificateExpiryDate'] as String),
      json['enrollmentStatus'] as int,
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
