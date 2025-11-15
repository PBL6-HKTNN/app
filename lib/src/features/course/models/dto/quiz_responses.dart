import 'package:codemy_app/src/features/course/models/entities/quiz/index.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_attempt.dart';

class QuizStartAttempt {
  final QuizAttempt quizAttempt;
  final Quiz quiz;

  QuizStartAttempt({required this.quizAttempt, required this.quiz});

  factory QuizStartAttempt.fromJson(Map<String, dynamic> json) {
    return QuizStartAttempt(
      quizAttempt: QuizAttempt.fromJson(
        json['quizAttempt'] as Map<String, dynamic>,
      ),
      quiz: Quiz.fromJson(json['quiz'] as Map<String, dynamic>),
    );
  }
}
