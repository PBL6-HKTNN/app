import 'package:codemy_app/src/core/models/entity.dart';
import 'package:codemy_app/src/features/course/enums/quiz_question_type.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/answer.dart';

class QuizQuestion extends EntityModel {
  final String questionText;
  final QuizQuestionType questionType;
  final int marks;
  final List<Answer> answers;

  QuizQuestion({
    required this.questionText,
    required this.questionType,
    required this.marks,
    required this.answers,
    required super.id,
    required super.createdAt,
    super.createdBy,
    super.updatedAt,
    super.updatedBy,
    super.isDeleted,
    super.deletedAt,
    super.deletedBy,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final id = json['questionId'] as String? ?? json['id'] as String? ?? '';
    final createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String)
        : null;
    final updatedAt = json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'] as String)
        : null;
    return QuizQuestion(
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
      questionText: json['questionText'] as String? ?? '',
      questionType: quizQuestionTypeFromValue(
        json['questionType'] as int? ?? 0,
      ),
      marks: json['marks'] as int? ?? 0,
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map((answer) => Answer.fromJson(answer as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'questionText': questionText,
      'questionType': questionType.index,
      'marks': marks,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}
