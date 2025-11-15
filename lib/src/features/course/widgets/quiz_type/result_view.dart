import 'package:codemy_app/src/features/course/models/entities/quiz/index.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_submission_result.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ResultView extends StatelessWidget {
  final Quiz quiz;
  final QuizSubmissionResult attempt;
  final VoidCallback onContinue;
  final VoidCallback onRetake;
  final VoidCallback? onReview;

  const ResultView({
    super.key,
    required this.quiz,
    required this.attempt,
    required this.onContinue,
    required this.onRetake,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final totalMarks = quiz.totalMarks == 0 ? 1 : quiz.totalMarks;
    final score = attempt.score;
    final percentage = (score / totalMarks * 100).clamp(0, 100);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              attempt.passed
                  ? RadixIcons.checkCircled
                  : RadixIcons.crossCircled,
              size: 64,
              color: attempt.passed
                  ? Theme.of(context).colorScheme.primary
                  : Colors.red,
            ),
            const Gap(24),
            Text(
              attempt.passed ? 'Quiz Completed!' : 'Quiz Submitted',
              style: Theme.of(context).typography.h2,
            ),
            const Gap(16),
            Text(
              'Your Score',
              style: Theme.of(context).typography.small.copyWith(
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const Gap(8),
            Text(
              '$score / ${quiz.totalMarks}',
              style: Theme.of(context).typography.h1.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              '${percentage.toStringAsFixed(1)}% ${attempt.passed ? '(Passed)' : '(Failed)'}',
              style: Theme.of(context).typography.large.copyWith(
                color: attempt.passed ? Colors.green : Colors.red,
              ),
            ),
            const Gap(24),
            LinearProgressIndicator(value: score / totalMarks, minHeight: 8),
            const Gap(32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                Button(
                  style: ButtonStyle.outline(),
                  onPressed: onReview,
                  child: const Text('Review Answers'),
                ),
                Button(
                  style: ButtonStyle.primary(),
                  onPressed: onContinue,
                  child: const Text('Continue'),
                ),
                Button(
                  style: ButtonStyle.ghost(),
                  onPressed: onRetake,
                  child: const Text('Retake Quiz'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
