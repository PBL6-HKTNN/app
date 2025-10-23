import 'package:codemy_app/src/features/course/enums/quiz_question_type.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/answer.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_question.dart';
import 'package:codemy_app/src/features/course/states/quiz_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizNotifier extends Notifier<QuizState> {
  @override
  QuizState build() {
    return QuizState('Mock Quiz Lesson', _getMockQuestions(), 0, []);
  }

  List<QuizQuestion> _getMockQuestions() {
    return [
      // Multiple Choice Question
      QuizQuestion(
        id: '1',
        createdAt: DateTime.now(),
        type: QuizQuestionType.multipleChoice,
        questionText:
            'Which of the following are programming languages? (Select all that apply)',
        answers: [
          Answer(
            id: '1a',
            createdAt: DateTime.now(),
            text: 'Python',
            isCorrect: true,
          ),
          Answer(
            id: '1b',
            createdAt: DateTime.now(),
            text: 'HTML',
            isCorrect: false,
          ),
          Answer(
            id: '1c',
            createdAt: DateTime.now(),
            text: 'JavaScript',
            isCorrect: true,
          ),
          Answer(
            id: '1d',
            createdAt: DateTime.now(),
            text: 'CSS',
            isCorrect: false,
          ),
        ],
        correctOptionIndex: 0,
        marks: 2,
      ),
      // Single Choice Question
      QuizQuestion(
        id: '2',
        createdAt: DateTime.now(),
        type: QuizQuestionType.singleChoice,
        questionText: 'What is the capital of France?',
        answers: [
          Answer(
            id: '2a',
            createdAt: DateTime.now(),
            text: 'London',
            isCorrect: false,
          ),
          Answer(
            id: '2b',
            createdAt: DateTime.now(),
            text: 'Paris',
            isCorrect: true,
          ),
          Answer(
            id: '2c',
            createdAt: DateTime.now(),
            text: 'Berlin',
            isCorrect: false,
          ),
          Answer(
            id: '2d',
            createdAt: DateTime.now(),
            text: 'Madrid',
            isCorrect: false,
          ),
        ],
        correctOptionIndex: 1,
        marks: 1,
      ),
      // True/False Question
      QuizQuestion(
        id: '3',
        createdAt: DateTime.now(),
        type: QuizQuestionType.trueFalse,
        questionText:
            'Flutter is a framework for building mobile applications.',
        answers: [
          Answer(
            id: '3a',
            createdAt: DateTime.now(),
            text: 'True',
            isCorrect: true,
          ),
          Answer(
            id: '3b',
            createdAt: DateTime.now(),
            text: 'False',
            isCorrect: false,
          ),
        ],
        correctOptionIndex: 0,
        marks: 1,
      ),
      // Short Answer Question
      QuizQuestion(
        id: '4',
        createdAt: DateTime.now(),
        type: QuizQuestionType.shortAnswer,
        questionText: 'What does HTTP stand for?',
        answers: [
          Answer(
            id: '4a',
            createdAt: DateTime.now(),
            text: 'HyperText Transfer Protocol',
            isCorrect: true,
          ),
        ],
        correctOptionIndex: 0,
        marks: 2,
      ),
    ];
  }

  void resetQuiz() {
    state = QuizState('Mock Quiz Lesson', _getMockQuestions(), 0, []);
  }

  void selectAnswer(Answer answer) {
    final currentQuestion = state.questions[state.currentQuestionIndex];

    if (currentQuestion.type == QuizQuestionType.multipleChoice) {
      // Toggle selection for multiple choice
      final updatedAnswers = List<Answer>.from(state.selectedAnswers);
      if (updatedAnswers.any((a) => a.id == answer.id)) {
        updatedAnswers.removeWhere((a) => a.id == answer.id);
      } else {
        updatedAnswers.add(answer);
      }
      state = state.copyWith(selectedAnswers: updatedAnswers);
    } else {
      // Replace selection for single choice and true/false
      state = state.copyWith(selectedAnswers: [answer]);
    }
  }

  void setShortAnswer(String text) {
    final answer = Answer(
      id: 'user_answer',
      createdAt: DateTime.now(),
      text: text,
      isCorrect: false, // Will be evaluated later
    );
    state = state.copyWith(selectedAnswers: [answer]);
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        selectedAnswers: [],
      );
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
        selectedAnswers: [],
      );
    }
  }

  void submitQuiz() {
    // Calculate score and show results
    print('Quiz submitted!');
    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
      selectedAnswers: [],
    );
  }

  bool isAnswerSelected(Answer answer) {
    return state.selectedAnswers.any((a) => a.id == answer.id);
  }

  bool get canProceed => state.selectedAnswers.isNotEmpty;

  bool get isLastQuestion =>
      state.currentQuestionIndex == state.questions.length - 1;

  int calculateScore() {
    int score = 0;
    // This is a simplified scoring logic - in real app would be more complex
    for (int i = 0; i < state.questions.length; i++) {
      final question = state.questions[i];
      // For demo purposes, award marks if any answer is selected
      if (i < state.currentQuestionIndex) {
        score += question.marks;
      }
    }
    return score;
  }

  int get totalMarks {
    return state.questions.fold(0, (sum, q) => sum + q.marks);
  }
}

final quizProvider = NotifierProvider<QuizNotifier, QuizState>(
  () => QuizNotifier(),
);
