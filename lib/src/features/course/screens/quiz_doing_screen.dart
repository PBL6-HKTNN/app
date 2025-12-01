import 'package:codemy_app/src/features/course/enums/quiz_question_type.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_question.dart';
import 'package:codemy_app/src/features/course/providers/course_progress_provider.dart';
import 'package:codemy_app/src/features/course/providers/enrollment_provider.dart';
import 'package:codemy_app/src/features/course/providers/quiz_provider.dart';
import 'package:codemy_app/src/features/course/states/quiz_attempt_state.dart';
import 'package:codemy_app/src/features/course/widgets/quiz_type/choice_view.dart';
import 'package:codemy_app/src/features/course/widgets/quiz_type/result_view.dart';
import 'package:codemy_app/src/features/course/widgets/quiz_type/short_answer_view.dart';
import 'package:codemy_app/src/features/course/widgets/quiz_type/true_false_view.dart';
import 'package:flutter/material.dart' as material show Colors;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class QuizDoingScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String moduleId;
  final String lessonId;
  final String? quizId;
  final void Function(bool passed)? onQuizComplete;

  const QuizDoingScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
    this.quizId,
    this.onQuizComplete,
  });

  @override
  ConsumerState<QuizDoingScreen> createState() => _QuizDoingScreenState();
}

class _QuizDoingScreenState extends ConsumerState<QuizDoingScreen> {
  String? _enrollmentId;

  @override
  void dispose() {
    // Update current view on unmount
    if (_enrollmentId != null) {
      ref
          .read(courseProgressProvider.notifier)
          .updateCurrentView(widget.courseId, widget.lessonId, _enrollmentId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set enrollment ID for dispose
    final enrollmentAsync = ref.read(courseEnrollmentProvider(widget.courseId));
    if (enrollmentAsync.hasValue && enrollmentAsync.value!.success) {
      _enrollmentId = enrollmentAsync.value!.enrollment?.id;
    }

    if (widget.quizId == null || widget.quizId!.isEmpty) {
      return Scaffold(
        headers: [
          AppBar(
            title: const Text('Quiz Attempt'),
            leading: [
              Button(
                style: ButtonStyle.ghost(),
                onPressed: () => _goBack(context),
                child: const Icon(RadixIcons.arrowLeft),
              ),
            ],
          ),
        ],
        child: const _MissingQuizView(),
      );
    }

    final provider = quizAttemptControllerProvider(widget.quizId!);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return Scaffold(
      headers: [
        AppBar(
          title: Text(state.quiz?.title ?? 'Quiz Attempt'),
          leading: [
            Button(
              style: ButtonStyle.ghost(),
              onPressed: () => _confirmExit(context),
              child: const Icon(RadixIcons.arrowLeft),
            ),
          ],
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(context, state, controller),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    QuizAttemptState state,
    QuizAttemptController controller,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return _QuizErrorView(
        message: state.errorMessage!,
        onRetry: controller.reload,
      );
    }

    final quiz = state.quiz;
    if (quiz == null) {
      return _QuizErrorView(
        message: 'Quiz data is unavailable.',
        onRetry: controller.reload,
      );
    }

    if (quiz.questions.isEmpty) {
      return _QuizErrorView(
        message: 'This quiz does not have any questions yet.',
        onRetry: controller.reload,
      );
    }

    if (state.isSubmitted && state.attemptResult != null) {
      // Trigger progress callback when quiz is completed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.onQuizComplete != null) {
          widget.onQuizComplete!(state.attemptResult!.passed);
        }
        // Mark lesson complete if marks exceed passing marks
        if (_enrollmentId != null &&
            state.attemptResult!.score > quiz.passingMarks) {
          ref
              .read(courseProgressProvider.notifier)
              .markLessonComplete(
                widget.courseId,
                widget.lessonId,
                _enrollmentId!,
              );
        }
      });

      return SingleChildScrollView(
        child: ResultView(
          quiz: quiz,
          attempt: state.attemptResult!,
          onContinue: () => _goBack(context),
          onRetake: controller.reload,
          onReview: null,
        ),
      );
    }

    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) {
      return _QuizErrorView(
        message: 'Unable to determine current question.',
        onRetry: controller.reload,
      );
    }

    final currentAnswer = state.answerFor(currentQuestion.id);
    final progressValue = state.progress;
    final progressPercent = (progressValue * 100).clamp(0, 100);

    return SizedBox.expand(
      child: Card(
        child: Column(
          children: [
            LinearProgressIndicator(value: progressValue, minHeight: 4),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${state.currentQuestionIndex + 1} of ${quiz.questions.length}',
                    style: Theme.of(context).typography.small.copyWith(
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                  PrimaryBadge(child: Text('${currentQuestion.marks} marks')),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentQuestion.questionText,
                      style: Theme.of(
                        context,
                      ).typography.large.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Gap(24),
                    _buildQuestionView(
                      context: context,
                      question: currentQuestion,
                      answer: currentAnswer,
                      controller: controller,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (controller.canGoPrevious)
                        Button(
                          style: ButtonStyle.outline(size: ButtonSize.small),
                          leading: const Icon(RadixIcons.arrowLeft),
                          onPressed: state.isSubmitting
                              ? null
                              : controller.previousQuestion,
                          child: const Text('Previous'),
                        )
                      else
                        const SizedBox(width: 110),
                      Text(
                        currentAnswer == null ? 'Not answered yet' : 'Answered',
                        style: Theme.of(context).typography.small.copyWith(
                          color: currentAnswer == null
                              ? material.Colors.orange
                              : material.Colors.green,
                          fontSize: 14,
                        ),
                      ),
                      Button(
                        style: ButtonStyle.primary(size: ButtonSize.small),
                        trailing: Icon(
                          controller.canGoNext
                              ? RadixIcons.arrowRight
                              : RadixIcons.check,
                        ),
                        onPressed: state.isSubmitting
                            ? null
                            : controller.canGoNext
                            ? controller.nextQuestion
                            : () => _confirmSubmit(context, state, controller),
                        child: Text(controller.canGoNext ? 'Next' : 'Submit'),
                      ),
                    ],
                  ),
                  const Gap(12),
                  LinearProgressIndicator(value: progressValue, minHeight: 4),
                  const Gap(6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${progressPercent.toStringAsFixed(0)}% complete',
                      style: Theme.of(context).typography.xSmall.copyWith(
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.isSubmitting)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionView({
    required BuildContext context,
    required QuizQuestion question,
    required QuizUserAnswer? answer,
    required QuizAttemptController controller,
  }) {
    if (question.questionType == QuizQuestionType.multipleChoice ||
        question.questionType == QuizQuestionType.singleChoice) {
      return ChoiceView(
        question: question,
        answer: answer,
        onSelection: (answerId) => controller.toggleChoice(question, answerId),
      );
    }

    if (question.questionType == QuizQuestionType.trueFalse) {
      return TrueFalseView(
        question: question,
        answer: answer,
        onSelect: (answerId) => controller.toggleChoice(question, answerId),
      );
    }

    if (question.questionType == QuizQuestionType.shortAnswer) {
      return ShortAnswerView(
        question: question,
        answer: answer,
        onAnswerChange: (text) => controller.updateShortAnswer(question, text),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _confirmSubmit(
    BuildContext context,
    QuizAttemptState state,
    QuizAttemptController controller,
  ) async {
    final answeredCount = state.answers.length;
    final total = state.totalQuestions;
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Submit Quiz?'),
          content: Text(
            'You have answered $answeredCount of $total questions. Submit now?',
          ),
          actions: [
            Button(
              style: ButtonStyle.ghost(),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            Button(
              style: ButtonStyle.primary(),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (shouldSubmit == true) {
      await controller.submitQuiz();
    }
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Exit Quiz?'),
          content: const Text(
            'Your progress will be saved. Are you sure you want to exit?',
          ),
          actions: [
            Button(
              style: ButtonStyle.ghost(),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            Button(
              style: ButtonStyle.primary(),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      _goBack(context);
    }
  }

  void _goBack(BuildContext context) {
    context.go(
      '/learn/${widget.courseId}/${widget.moduleId}/${widget.lessonId}',
    );
  }
}

class _QuizErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _QuizErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(RadixIcons.exclamationTriangle, size: 48),
            const Gap(12),
            Text(
              message,
              style: Theme.of(
                context,
              ).typography.small.copyWith(color: material.Colors.red),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            Button(
              style: ButtonStyle.primary(),
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingQuizView extends StatelessWidget {
  const _MissingQuizView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(RadixIcons.questionMarkCircled, size: 48),
              const Gap(12),
              Text(
                'Quiz information is missing.',
                style: Theme.of(context).typography.small,
              ),
              const Gap(8),
              Text(
                'Please open this quiz from a lesson again.',
                style: Theme.of(context).typography.xSmall.copyWith(
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
