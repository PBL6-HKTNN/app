class UpdateEnrollmentRequest {
  final String enrollmentId;
  final int progressStatus;
  final String lessonId;
  final String? completionDate;
  final String? certificateUrl;
  final String? certificateExpiryDate;

  UpdateEnrollmentRequest({
    required this.enrollmentId,
    required this.progressStatus,
    required this.lessonId,
    this.completionDate,
    this.certificateUrl,
    this.certificateExpiryDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'enrollmentId': enrollmentId,
      'progressStatus': progressStatus,
      'lessonId': lessonId,
      'completionDate': completionDate,
      'certificateUrl': certificateUrl,
      'certificateExpiryDate': certificateExpiryDate,
    };
  }
}
