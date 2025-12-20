class Certificate {
  final String certificateId;
  final String certificateUrl;
  final String publicId;
  final DateTime? completionDate;
  final DateTime? expiryDate;

  Certificate({
    required this.certificateId,
    required this.certificateUrl,
    required this.publicId,
    this.completionDate,
    this.expiryDate,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      certificateId: json['certificateId'] as String,
      certificateUrl: json['certificateUrl'] as String,
      publicId: json['publicId'] as String,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificateId': certificateId,
      'certificateUrl': certificateUrl,
      'publicId': publicId,
      'completionDate': completionDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }
}
