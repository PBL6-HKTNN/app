import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_question.dart';
import 'package:codemy_app/src/features/course/providers/quiz_provider.mock.dart';

class TrueFalseView extends ConsumerWidget {
  final QuizQuestion question;

  const TrueFalseView({super.key, required this.question});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizNotifier = ref.watch(quizProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select True or False:',
          style: Theme.of(context).typography.small.copyWith(
            color: Theme.of(context).colorScheme.mutedForeground,
          ),
        ),
        const Gap(16),
        ...question.answers.map((answer) {
          final isSelected = quizNotifier.isAnswerSelected(answer);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Button(
              style: isSelected ? ButtonStyle.primary() : ButtonStyle.outline(),
              onPressed: () {
                quizNotifier.selectAnswer(answer);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    answer.text == 'True'
                        ? RadixIcons.checkCircled
                        : RadixIcons.crossCircled,
                  ),
                  const Gap(12),
                  Text(
                    answer.text,
                    style: Theme.of(
                      context,
                    ).typography.large.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
