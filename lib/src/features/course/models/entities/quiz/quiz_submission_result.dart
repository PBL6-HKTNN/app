import 'package:codemy_app/src/features/course/models/entities/quiz/user_answer.dart';

class QuizSubmissionResult {
  final String quizId;
  final int score;
  final bool passed;
  final List<UserAnswer> userAnswers;

  QuizSubmissionResult({
    required this.quizId,
    required this.score,
    required this.passed,
    required this.userAnswers,
  });

  factory QuizSubmissionResult.fromJson(Map<String, dynamic> json) {
    return QuizSubmissionResult(
      quizId: json['quizId'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      passed: json['passed'] as bool? ?? false,
      userAnswers: (json['userAnswers'] as List<dynamic>? ?? [])
          .map((answer) => UserAnswer.fromJson(answer as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'score': score,
      'passed': passed,
      'userAnswers': userAnswers.map((answer) => answer.toJson()).toList(),
    };
  }
}
