import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:codemy_app/src/features/course/providers/quiz_provider.mock.dart';

class ResultView extends ConsumerWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizNotifier = ref.watch(quizProvider.notifier);
    final score = quizNotifier.calculateScore();
    final totalMarks = quizNotifier.totalMarks;
    final percentage = (score / totalMarks * 100).toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              RadixIcons.checkCircled,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Gap(24),
            Text('Quiz Completed!', style: Theme.of(context).typography.h2),
            const Gap(16),
            Text(
              'Your Score',
              style: Theme.of(context).typography.small.copyWith(
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const Gap(8),
            Text(
              '$score / $totalMarks',
              style: Theme.of(context).typography.h1.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              '$percentage%',
              style: Theme.of(context).typography.large.copyWith(
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const Gap(24),
            LinearProgressIndicator(value: score / totalMarks, minHeight: 8),
            const Gap(32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Button(
                  style: ButtonStyle.outline(),
                  onPressed: () {
                    // Review answers
                  },
                  child: const Text('Review Answers'),
                ),
                const Gap(12),
                Button(
                  style: ButtonStyle.primary(),
                  onPressed: () {
                    // Continue to next lesson
                    quizNotifier.resetQuiz();
                    context.go('/');
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
