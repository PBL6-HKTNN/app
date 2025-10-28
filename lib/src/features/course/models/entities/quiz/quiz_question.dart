import 'package:codemy_app/src/core/models/entity.dart';
import 'package:codemy_app/src/features/course/enums/quiz_question_type.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/answer.dart';

class QuizQuestion extends EntityModel {
  final String questionText;
  final int correctOptionIndex;
  final QuizQuestionType type;
  final int marks;
  final List<Answer> answers;

  QuizQuestion({
    required this.type,
    required this.questionText,
    required this.answers,
    required this.correctOptionIndex,
    required this.marks,
    required super.id,
    required super.createdAt,
  });
}
