import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_question.dart';
import 'package:codemy_app/src/features/course/providers/quiz_provider.mock.dart';

class ShortAnswerView extends ConsumerStatefulWidget {
  final QuizQuestion question;

  const ShortAnswerView({super.key, required this.question});

  @override
  ConsumerState<ShortAnswerView> createState() => _ShortAnswerViewState();
}

class _ShortAnswerViewState extends ConsumerState<ShortAnswerView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizNotifier = ref.watch(quizProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your answer:',
          style: Theme.of(context).typography.small.copyWith(
            color: Theme.of(context).colorScheme.mutedForeground,
          ),
        ),
        const Gap(16),
        TextField(
          controller: _controller,
          placeholder: const Text('Type your answer here...'),
          maxLines: 3,
          onChanged: (value) {
            quizNotifier.setShortAnswer(value);
          },
        ),
        const Gap(12),
        Text(
          'Hint: Your answer will be reviewed and graded.',
          style: Theme.of(context).typography.xSmall.copyWith(
            color: Theme.of(context).colorScheme.mutedForeground,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
