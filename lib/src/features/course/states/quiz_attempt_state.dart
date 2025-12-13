import 'package:codemy_app/src/features/course/enums/quiz_question_type.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/index.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_question.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_submission_result.dart';

class QuizUserAnswer {
  final String questionId;
  final Set<String> selectedAnswerIds;
  final String? answerText;

  const QuizUserAnswer({
    required this.questionId,
    this.selectedAnswerIds = const {},
    this.answerText,
  });

  QuizUserAnswer copyWith({
    Set<String>? selectedAnswerIds,
    String? answerText,
  }) {
    return QuizUserAnswer(
      questionId: questionId,
      selectedAnswerIds: selectedAnswerIds ?? this.selectedAnswerIds,
      answerText: answerText ?? this.answerText,
    );
  }
}

class QuizAttemptState {
  final bool isLoading;
  final bool isSubmitting;
  final Quiz? quiz;
  final String? attemptId;
  final int currentQuestionIndex;
  final Map<String, QuizUserAnswer> answers;
  final QuizSubmissionResult? attemptResult;
  final String? errorMessage;

  const QuizAttemptState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.quiz,
    this.attemptId,
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.attemptResult,
    this.errorMessage,
  });

  factory QuizAttemptState.initial() => const QuizAttemptState(isLoading: true);

  bool get isSubmitted => attemptResult != null;

  int get totalQuestions => quiz?.questions.length ?? 0;

  QuizQuestion? get currentQuestion {
    final total = totalQuestions;
    if (quiz == null || total == 0) {
      return null;
    }
    if (currentQuestionIndex < 0 || currentQuestionIndex >= total) {
      return null;
    }
    return quiz!.questions[currentQuestionIndex];
  }

  double get progress {
    final total = totalQuestions;
    if (total == 0) {
      return 0;
    }
    return ((currentQuestionIndex + 1) / total).clamp(0, 1).toDouble();
  }

  QuizUserAnswer? answerFor(String questionId) => answers[questionId];

  bool get canGoPrevious => currentQuestionIndex > 0;

  bool get isLastQuestion {
    final total = totalQuestions;
    if (total == 0) {
      return true;
    }
    return currentQuestionIndex >= total - 1;
  }

  bool get canProceed {
    final question = currentQuestion;
    if (question == null) {
      return false;
    }
    final answer = answers[question.id];
    switch (question.questionType) {
      case QuizQuestionType.shortAnswer:
        return (answer?.answerText ?? '').trim().isNotEmpty;
      case QuizQuestionType.multipleChoice:
      case QuizQuestionType.singleChoice:
      case QuizQuestionType.trueFalse:
        return (answer?.selectedAnswerIds.isNotEmpty ?? false);
    }
  }

  QuizAttemptState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    Quiz? quiz,
    String? attemptId,
    int? currentQuestionIndex,
    Map<String, QuizUserAnswer>? answers,
    QuizSubmissionResult? attemptResult,
    bool clearAttemptResult = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return QuizAttemptState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      quiz: quiz ?? this.quiz,
      attemptId: attemptId ?? this.attemptId,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      attemptResult: clearAttemptResult
          ? null
          : (attemptResult ?? this.attemptResult),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  QuizAttemptState clearError() {
    return copyWith(clearError: true);
  }
}
