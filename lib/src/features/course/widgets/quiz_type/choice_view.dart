import 'package:codemy_app/src/features/course/enums/quiz_question_type.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_question.dart';
import 'package:codemy_app/src/features/course/states/quiz_attempt_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ChoiceView extends StatelessWidget {
  final QuizQuestion question;
  final QuizUserAnswer? answer;
  final void Function(String answerId) onSelection;

  const ChoiceView({
    super.key,
    required this.question,
    required this.answer,
    required this.onSelection,
  });

  @override
  Widget build(BuildContext context) {
    final isMultiple = question.questionType == QuizQuestionType.multipleChoice;
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
        ...question.answers.map((option) {
          final optionId = option.id;
          final isSelected =
              optionId != null &&
              (answer?.selectedAnswerIds.contains(optionId) ?? false);

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
                onPressed: optionId == null
                    ? null
                    : () {
                        onSelection(optionId);
                      },
                child: Row(
                  children: [
                    if (isMultiple)
                      Checkbox(
                        state: isSelected
                            ? CheckboxState.checked
                            : CheckboxState.unchecked,
                        onChanged: optionId == null
                            ? null
                            : (_) => onSelection(optionId),
                      )
                    else
                      Radio(value: isSelected),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        option.answerText,
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
