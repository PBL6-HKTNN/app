import 'package:codemy_app/src/core/models/entity.dart';

class UserAnswer extends EntityModel {
  final String attemptId;
  final String questionId;
  final String? answerId;
  final String? answerText;
  final int? markObtained;

  UserAnswer({
    required this.attemptId,
    required this.questionId,
    this.answerId,
    this.answerText,
    this.markObtained,
    required super.id,
    required super.createdAt,
    super.createdBy,
    super.updatedAt,
    super.updatedBy,
    super.isDeleted,
    super.deletedAt,
    super.deletedBy,
  });

  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['userAnswerId'] as String? ?? '';
    final createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String)
        : null;
    final updatedAt = json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'] as String)
        : null;

    return UserAnswer(
      id: id,
      createdAt: createdAt,
      createdBy: json['createdBy'] as String?,
      updatedAt: updatedAt,
      updatedBy: json['updatedBy'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.tryParse(json['deletedAt'] as String)
          : null,
      deletedBy: json['deletedBy'] as String?,
      attemptId: json['attemptId'] as String? ?? '',
      questionId: json['questionId'] as String? ?? '',
      answerId: json['answerId'] as String?,
      answerText: json['answerText'] as String?,
      markObtained: json['markObtained'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'attemptId': attemptId,
      'questionId': questionId,
      'answerId': answerId,
      'answerText': answerText,
      'markObtained': markObtained,
    };
  }
}
