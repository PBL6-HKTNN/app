import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:codemy_app/src/features/course/enums/quiz_question_type.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_question.dart';
import 'package:codemy_app/src/features/course/providers/quiz_provider.mock.dart';

class ChoiceView extends ConsumerWidget {
  final QuizQuestion question;

  const ChoiceView({super.key, required this.question});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizNotifier = ref.watch(quizProvider.notifier);
    final isMultiple = question.type == QuizQuestionType.multipleChoice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMultiple ? 'Select all that apply:' : 'Select one:',
          style: Theme.of(context).typography.small.copyWith(
            color: Theme.of(context).colorScheme.mutedForeground,
          ),
        ),
        const Gap(16),
        ...question.answers.map((answer) {
          final isSelected = quizNotifier.isAnswerSelected(answer);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedContainer(
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : null,
              borderColor: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : null,
              child: Button(
                style: ButtonStyle.ghost(),
                onPressed: () {
                  quizNotifier.selectAnswer(answer);
                },
                child: Row(
                  children: [
                    if (isMultiple)
                      Checkbox(
                        state: isSelected
                            ? CheckboxState.checked
                            : CheckboxState.unchecked,
                        onChanged: (_) {
                          quizNotifier.selectAnswer(answer);
                        },
                      )
                    else
                      Radio(value: isSelected),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        answer.text,
                        style: Theme.of(context).typography.base,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
