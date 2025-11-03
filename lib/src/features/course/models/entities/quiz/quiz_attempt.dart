// quiz attempts made by users
import 'package:codemy_app/src/core/models/entity.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/user_answer.dart';

class QuizAttempt extends EntityModel {
  final String userId;
  final String quizId;
  final DateTime attemptDate;
  final int score;
  final DateTime completedAt;
  final String status; // e.g., 'completed', 'in-progress'
  final List<UserAnswer> userAnswers;

  QuizAttempt({
    required this.userId,
    required this.quizId,
    required this.attemptDate,
    required this.score,
    required this.completedAt,
    required this.status,
    required this.userAnswers,
    required super.id,
    required super.createdAt,
  });
}
