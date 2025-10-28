import 'package:codemy_app/src/features/course/models/entities/quiz/answer.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_question.dart';

class QuizState {
  final String lesson;
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final List<Answer> selectedAnswers;

  const QuizState(
    this.lesson,
    this.questions,
    this.currentQuestionIndex,
    this.selectedAnswers,
  );

  QuizState copyWith({
    String? lesson,
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    List<Answer>? selectedAnswers,
  }) {
    return QuizState(
      lesson ?? this.lesson,
      questions ?? this.questions,
      currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers ?? this.selectedAnswers,
    );
  }
}
