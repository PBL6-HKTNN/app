import 'package:codemy_app/src/core/models/entity.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_question.dart';

class Quiz extends EntityModel {
  final String title;
  final String description;
  final int totalMarks;
  final int passingScore;
  final List<QuizQuestion> questions;

  Quiz({
    required this.title,
    required this.description,
    required this.totalMarks,
    required this.passingScore,
    required this.questions,
    required super.id,
    required super.createdAt,
  });
}
