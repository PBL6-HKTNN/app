import 'package:codemy_app/src/core/models/entity.dart';
import 'package:codemy_app/src/features/course/enums/enrollment.dart';

class Enrollment extends EntityModel {
  final String? enrollmentId;
  final ProgressStatus progressStatus;
  final EnrollmentStatus enrollmentStatus;
  final String? currentView;
  final int? watchedSeconds;
  final String? lessonId;
  final DateTime? completionDate;
  final String? certificateUrl;
  final DateTime? certificateExpiryDate;

  Enrollment(
    this.enrollmentId,
    this.progressStatus,
    this.currentView,
    this.watchedSeconds,
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
      'progressStatus': progressStatus.index,
      'enrollmentStatus': enrollmentStatus.index,
      'currentView': currentView,
      'watchedSeconds': watchedSeconds,
      'lessonId': lessonId,
      'completionDate': completionDate?.toIso8601String(),
      'certificateUrl': certificateUrl,
      'certificateExpiryDate': certificateExpiryDate?.toIso8601String(),
    };
  }

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      json['enrollmentId'] as String?,
      progressStatusFromValue(json['progressStatus'] as int? ?? 0),
      json['currentView'] as String?,
      json['watchedSeconds'] as int?,
      json['lessonId'] as String?,
      json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
      json['certificateUrl'] as String?,
      json['certificateExpiryDate'] != null
          ? DateTime.parse(json['certificateExpiryDate'] as String)
          : null,
      enrollmentStatusFromValue(json['enrollmentStatus'] as int? ?? 0),
      id: json['id'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
