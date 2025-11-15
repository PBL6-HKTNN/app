import 'package:codemy_app/src/core/models/entity.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_question.dart';

class Quiz extends EntityModel {
  final String title;
  final String? description;
  final String lessonId;
  final int totalMarks;
  final int passingMarks;
  final List<QuizQuestion> questions;

  Quiz({
    required this.title,
    required this.description,
    required this.lessonId,
    required this.totalMarks,
    required this.passingMarks,
    required this.questions,
    required super.id,
    required super.createdAt,
    super.createdBy,
    super.updatedAt,
    super.updatedBy,
    super.isDeleted,
    super.deletedAt,
    super.deletedBy,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['quizId'] as String? ?? '';
    final createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String)
        : null;
    final updatedAt = json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'] as String)
        : null;

    return Quiz(
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
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String?,
      lessonId:
          json['lessonId'] as String? ??
          (json['lesson'] is Map<String, dynamic>
              ? (json['lesson'] as Map<String, dynamic>)['id'] as String?
              : null) ??
          '',
      totalMarks: json['totalMarks'] as int? ?? 0,
      passingMarks: json['passingMarks'] as int? ?? 0,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'title': title,
      'description': description,
      'lessonId': lessonId,
      'totalMarks': totalMarks,
      'passingMarks': passingMarks,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}
