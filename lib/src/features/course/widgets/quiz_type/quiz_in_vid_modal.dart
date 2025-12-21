import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../models/dto/lesson_responses.dart';
import '../../providers/quiz_provider.dart';

class QuizInVideoModal extends ConsumerStatefulWidget {
  final QuizInVideoResponse quiz;
  final void Function() onSuccess;

  const QuizInVideoModal({
    super.key,
    required this.quiz,
    required this.onSuccess,
  });

  @override
  ConsumerState<QuizInVideoModal> createState() => _QuizInVideoModalState();
}

class _QuizInVideoModalState extends ConsumerState<QuizInVideoModal> {
  String? _selected;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Quiz', style: theme.typography.h4),
            const Gap(8),
            Text(widget.quiz.question, style: theme.typography.small),
            const Gap(12),
            ...widget.quiz.options.map((opt) {
              final optStr = opt?.toString() ?? '';
              return material.RadioListTile<String>(
                value: optStr,
                groupValue: _selected,
                onChanged: (v) {
                  setState(() => _selected = v);
                },
                title: Text(optStr),
              );
            }),
            const Gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button.secondary(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                const Gap(8),
                Button.primary(
                  onPressed: (_selected == null || _submitting)
                      ? null
                      : () async {
                          setState(() => _submitting = true);
                          final response = await ref
                              .read(quizServiceProvider)
                              .submitQuizInVideo(widget.quiz.id, _selected!);
                          setState(() => _submitting = false);
                          if (response.isSuccess) {
                            showToast(
                              context: context,
                              builder: (ctx, overlay) => Alert(
                                title: const Text('Success'),
                                content: const Text('Correct!'),
                                trailing: IconButton.ghost(
                                  icon: const Icon(LucideIcons.x),
                                  onPressed: overlay.close,
                                ),
                              ),
                            );
                            widget.onSuccess();
                            if (context.mounted) Navigator.of(context).pop();
                          } else {
                            showToast(
                              context: context,
                              builder: (ctx, overlay) => Alert.destructive(
                                title: const Text('Incorrect'),
                                content: Text(
                                  response.error?.toString() ??
                                      'Incorrect answer',
                                ),
                                trailing: IconButton.ghost(
                                  icon: const Icon(LucideIcons.x),
                                  onPressed: overlay.close,
                                ),
                              ),
                            );
                          }
                        },
                  child: _submitting
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: material.CircularProgressIndicator(),
                        )
                      : const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
