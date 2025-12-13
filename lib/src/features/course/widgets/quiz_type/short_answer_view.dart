import 'package:codemy_app/src/features/course/models/entities/quiz/quiz_question.dart';
import 'package:codemy_app/src/features/course/states/quiz_attempt_state.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ShortAnswerView extends StatefulWidget {
  final QuizQuestion question;
  final QuizUserAnswer? answer;
  final ValueChanged<String> onAnswerChange;

  const ShortAnswerView({
    super.key,
    required this.question,
    required this.answer,
    required this.onAnswerChange,
  });

  @override
  State<ShortAnswerView> createState() => _ShortAnswerViewState();
}

class _ShortAnswerViewState extends State<ShortAnswerView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.answer?.answerText ?? '');
  }

  @override
  void didUpdateWidget(covariant ShortAnswerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.answer?.answerText ?? '';
    if (newValue != _controller.text) {
      _controller.text = newValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          onChanged: widget.onAnswerChange,
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
