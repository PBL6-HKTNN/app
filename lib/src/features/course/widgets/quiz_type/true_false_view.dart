import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_question.dart';
import 'package:codemy_app/src/features/course/states/quiz_attempt_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TrueFalseView extends StatelessWidget {
  final QuizQuestion question;
  final QuizUserAnswer? answer;
  final void Function(String answerId) onSelect;

  const TrueFalseView({
    super.key,
    required this.question,
    required this.answer,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
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
        ...question.answers.map((option) {
          final optionId = option.id;
          final isSelected =
              optionId != null &&
              (answer?.selectedAnswerIds.contains(optionId) ?? false);
          final isTrue = option.answerText.toLowerCase() == 'true';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Button(
              style: isSelected ? ButtonStyle.primary() : ButtonStyle.outline(),
              onPressed: optionId == null ? null : () => onSelect(optionId),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isTrue ? RadixIcons.checkCircled : RadixIcons.crossCircled,
                  ),
                  const Gap(12),
                  Text(
                    option.answerText,
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
