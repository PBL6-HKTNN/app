// quiz attempts made by users
import 'package:codemy_app/src/core/models/entity.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/user_answer.dart';

class QuizAttempt extends EntityModel {
  final String userId;
  final String quizId;
  final int score;
  final bool passed;
  final int status;
  final DateTime attemptedAt;
  final DateTime? completedAt;
  final List<UserAnswer>? userAnswers;

  QuizAttempt({
    required this.userId,
    required this.quizId,
    required this.score,
    required this.passed,
    required this.status,
    required this.attemptedAt,
    required this.completedAt,
    required this.userAnswers,
    required super.id,
    required super.createdAt,
    super.createdBy,
    super.updatedAt,
    super.updatedBy,
    super.isDeleted,
    super.deletedAt,
    super.deletedBy,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    final base = EntityModel.fromJson(json);
    return QuizAttempt(
      id: base.id,
      createdAt: base.createdAt,
      createdBy: base.createdBy,
      updatedAt: base.updatedAt,
      updatedBy: base.updatedBy,
      isDeleted: base.isDeleted,
      deletedAt: base.deletedAt,
      deletedBy: base.deletedBy,
      userId: json['userId'] as String,
      quizId: json['quizId'] as String,
      score: json['score'] as int? ?? 0,
      passed: json['passed'] as bool? ?? false,
      status: json['status'] as int? ?? 0,
      attemptedAt: DateTime.parse(json['attemptedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      userAnswers: (json['userAnswers'] as List<dynamic>?)
          ?.map((answer) => UserAnswer.fromJson(answer as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'userId': userId,
      'quizId': quizId,
      'score': score,
      'passed': passed,
      'status': status,
      'attemptedAt': attemptedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'userAnswers': userAnswers?.map((answer) => answer.toJson()).toList(),
    };
  }
}
