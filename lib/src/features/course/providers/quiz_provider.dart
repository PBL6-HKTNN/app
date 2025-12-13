import 'package:codemy_app/src/core/networks/exception.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/course/enums/quiz_question_type.dart';
import 'package:codemy_app/src/features/course/models/dto/quiz_requests.dart';
import 'package:codemy_app/src/features/course/models/dto/quiz_responses.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/index.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_question.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_submission_result.dart';
import 'package:codemy_app/src/features/course/services/quiz_service.dart';
import 'package:codemy_app/src/features/course/states/quiz_attempt_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final quizServiceProvider = Provider<QuizService>((ref) {
  return QuizService();
});

final quizByIdProvider = FutureProvider.autoDispose.family<Quiz, String>((
  ref,
  quizId,
) async {
  final service = ref.read(quizServiceProvider);
  final response = await service.getQuizById(quizId);
  if (!response.isSuccess || response.data == null) {
    throw ApiException(
      response.error?.toString() ?? 'Failed to load quiz detail',
      statusCode: response.status,
      data: response.data,
    );
  }
  return response.data!;
});

final quizByLessonProvider = FutureProvider.autoDispose.family<Quiz, String>((
  ref,
  lessonId,
) async {
  final service = ref.read(quizServiceProvider);
  final response = await service.getQuizByLessonId(lessonId);
  if (!response.isSuccess || response.data == null) {
    throw ApiException(
      response.error?.toString() ?? 'Failed to load quiz by lesson',
      statusCode: response.status,
      data: response.data,
    );
  }
  return response.data!;
});

final createQuizProvider = FutureProvider.autoDispose
    .family<Quiz, CreateQuizRequest>((ref, request) async {
      final service = ref.read(quizServiceProvider);
      final response = await service.createQuiz(request);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to create quiz',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });

final updateQuizProvider = FutureProvider.autoDispose
    .family<Quiz, (String, UpdateQuizRequest)>((ref, params) async {
      final service = ref.read(quizServiceProvider);
      final response = await service.updateQuiz(params.$1, params.$2);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to update quiz',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });

final deleteQuizProvider = FutureProvider.autoDispose.family<String, String>((
  ref,
  quizId,
) async {
  final service = ref.read(quizServiceProvider);
  final response = await service.deleteQuiz(quizId);
  if (!response.isSuccess || response.data == null) {
    throw ApiException(
      response.error?.toString() ?? 'Failed to delete quiz',
      statusCode: response.status,
      data: response.data,
    );
  }
  return response.data!;
});

final beginQuizAttemptProvider = FutureProvider.autoDispose
    .family<QuizStartAttempt, String>((ref, quizId) async {
      final service = ref.read(quizServiceProvider);
      final response = await service.beginQuizAttempt(quizId);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to start quiz attempt',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });

final submitQuizProvider = FutureProvider.autoDispose
    .family<QuizSubmissionResult, QuizSubmissionRequest>((ref, request) async {
      final service = ref.read(quizServiceProvider);
      final response = await service.submitQuiz(request);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to submit quiz',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });

final quizAttemptControllerProvider = StateNotifierProvider.autoDispose
    .family<QuizAttemptController, QuizAttemptState, String>((ref, quizId) {
      return QuizAttemptController(ref, quizId);
    });

class QuizAttemptController extends StateNotifier<QuizAttemptState> {
  QuizAttemptController(Ref ref, this._quizId)
    : _service = ref.read(quizServiceProvider),
      super(QuizAttemptState.initial()) {
    _loadQuizAttempt();
  }

  final QuizService _service;
  final String _quizId;

  Future<void> reload() => _loadQuizAttempt();

  Future<void> _loadQuizAttempt() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearAttemptResult: true,
      currentQuestionIndex: 0,
    );

    final response = await _service.beginQuizAttempt(_quizId);
    if (!response.isSuccess || response.data == null) {
      Logger.error(
        'Failed to begin quiz attempt',
        tag: 'QUIZ_ATTEMPT',
        error: response.error,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            response.error?.toString() ?? 'Failed to start quiz attempt',
      );
      return;
    }

    final attemptBundle = response.data!;
    final quiz = attemptBundle.quiz;
    final attempt = attemptBundle.quizAttempt;

    final answers = <String, QuizUserAnswer>{};
    final userAnswers = attempt.userAnswers ?? [];
    for (final userAnswer in userAnswers) {
      final questionId = userAnswer.questionId;
      final existing = answers[questionId];
      final selected = Set<String>.from(
        existing?.selectedAnswerIds ?? const <String>{},
      );
      final answerId = userAnswer.answerId;
      if (answerId != null && answerId.isNotEmpty) {
        selected.add(answerId);
      }
      final answerText = userAnswer.answerText ?? existing?.answerText;
      answers[questionId] = QuizUserAnswer(
        questionId: questionId,
        selectedAnswerIds: selected,
        answerText: answerText,
      );
    }

    state = QuizAttemptState(
      isLoading: false,
      quiz: quiz,
      attemptId: attempt.id,
      answers: answers,
    );
  }

  void nextQuestion() {
    if (state.isSubmitted || state.quiz == null || state.isLastQuestion) {
      return;
    }
    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
      clearError: true,
    );
  }

  void previousQuestion() {
    if (state.isSubmitted || !state.canGoPrevious) {
      return;
    }
    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex - 1,
      clearError: true,
    );
  }

  void toggleChoice(QuizQuestion question, String answerId) {
    if (state.isSubmitted || answerId.isEmpty) {
      return;
    }

    final isMultiple = question.questionType == QuizQuestionType.multipleChoice;
    final current = state.answers[question.id];
    final selected = Set<String>.from(
      current?.selectedAnswerIds ?? const <String>{},
    );

    if (isMultiple) {
      if (selected.contains(answerId)) {
        selected.remove(answerId);
      } else {
        selected.add(answerId);
      }
    } else {
      selected
        ..clear()
        ..add(answerId);
    }

    final updatedAnswer = (current ?? QuizUserAnswer(questionId: question.id))
        .copyWith(selectedAnswerIds: selected);

    state = state.copyWith(
      answers: {...state.answers, question.id: updatedAnswer},
    );
  }

  void updateShortAnswer(QuizQuestion question, String text) {
    if (state.isSubmitted) {
      return;
    }
    final trimmed = text.trim();
    final current = state.answers[question.id];
    final updatedAnswer = (current ?? QuizUserAnswer(questionId: question.id))
        .copyWith(answerText: trimmed.isEmpty ? null : trimmed);

    state = state.copyWith(
      answers: {...state.answers, question.id: updatedAnswer},
    );
  }

  bool get canGoNext {
    if (state.quiz == null) {
      return false;
    }
    return !state.isLastQuestion;
  }

  bool get canGoPrevious => state.canGoPrevious;

  Future<void> submitQuiz() async {
    if (state.isSubmitted || state.attemptId == null) {
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    final payload = state.answers.values.map((answer) {
      return QuizSubmissionAnswerPayload(
        questionId: answer.questionId,
        answerText: answer.answerText,
        selectedAnswerIds: answer.selectedAnswerIds.toList(),
      );
    }).toList();

    final response = await _service.submitQuiz(
      QuizSubmissionRequest(quizAttemptId: state.attemptId!, answers: payload),
    );

    if (!response.isSuccess || response.data == null) {
      Logger.error(
        'Failed to submit quiz',
        tag: 'QUIZ_ATTEMPT',
        error: response.error,
      );
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: response.error?.toString() ?? 'Failed to submit quiz',
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: false,
      attemptResult: response.data!,
      clearError: true,
      currentQuestionIndex: state.totalQuestions == 0
          ? 0
          : state.totalQuestions - 1,
    );
  }
}
