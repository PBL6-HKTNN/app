import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:codemy_app/src/features/course/enums/quiz_question_type.dart';
import 'package:codemy_app/src/features/course/providers/quiz_provider.mock.dart';
import 'package:codemy_app/src/features/course/widgets/quiz_type/choice_view.dart';
import 'package:codemy_app/src/features/course/widgets/quiz_type/result_view.dart';
import 'package:codemy_app/src/features/course/widgets/quiz_type/short_answer_view.dart';
import 'package:codemy_app/src/features/course/widgets/quiz_type/true_false_view.dart';

class QuizView extends ConsumerWidget {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final quizNotifier = ref.watch(quizProvider.notifier);

    // Check if quiz is completed
    final isCompleted =
        quizState.currentQuestionIndex >= quizState.questions.length;

    if (isCompleted) {
      return const ResultView();
    }

    final currentQuestion = quizState.questions[quizState.currentQuestionIndex];
    final progress =
        (quizState.currentQuestionIndex + 1) / quizState.questions.length;

    return Card(
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(value: progress, minHeight: 4),

          // Progress text and marks
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${quizState.currentQuestionIndex + 1} of ${quizState.questions.length}',
                  style: Theme.of(context).typography.small.copyWith(
                    color: Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
                PrimaryBadge(child: Text('${currentQuestion.marks} marks')),
              ],
            ),
          ),

          const Divider(),

          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question text
                  Text(
                    currentQuestion.questionText,
                    style: Theme.of(
                      context,
                    ).typography.large.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Gap(24),

                  // Question type specific view
                  _buildQuestionView(currentQuestion),
                ],
              ),
            ),
          ),

          const Divider(),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                if (quizState.currentQuestionIndex > 0)
                  Button(
                    style: ButtonStyle.outline(),
                    leading: const Icon(RadixIcons.arrowLeft),
                    onPressed: () {
                      quizNotifier.previousQuestion();
                    },
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),

                // Next/Submit button
                Button(
                  style: ButtonStyle.primary(),
                  trailing: Icon(
                    quizNotifier.isLastQuestion
                        ? RadixIcons.check
                        : RadixIcons.arrowRight,
                  ),
                  onPressed: quizNotifier.canProceed
                      ? () {
                          if (quizNotifier.isLastQuestion) {
                            quizNotifier.submitQuiz();
                            // Move to result view
                            quizNotifier.nextQuestion();
                          } else {
                            quizNotifier.nextQuestion();
                          }
                        }
                      : null,
                  child: Text(quizNotifier.isLastQuestion ? 'Submit' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView(question) {
    switch (question.type) {
      case QuizQuestionType.multipleChoice:
      case QuizQuestionType.singleChoice:
        return ChoiceView(question: question);
      case QuizQuestionType.trueFalse:
        return TrueFalseView(question: question);
      case QuizQuestionType.shortAnswer:
        return ShortAnswerView(question: question);
      default:
        return const Text('Unknown question type');
    }
  }
}
