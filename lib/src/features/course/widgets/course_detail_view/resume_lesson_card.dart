import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../models/entities/lesson.dart';
import '../../models/entities/module.dart';

class ResumeLessonCard extends StatelessWidget {
  final Lesson? currentLesson;
  final Module? currentModule;
  final String progressText;
  final VoidCallback onResume;

  const ResumeLessonCard({
    super.key,
    required this.currentLesson,
    required this.currentModule,
    required this.progressText,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (currentLesson == null || currentModule == null) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue where you left off',
                    style: theme.typography.h4,
                  ),
                  const Gap(8),
                  Text(currentModule!.title, style: theme.typography.small),
                  const Gap(6),
                  Text(
                    currentLesson!.title,
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(6),
                  Text(
                    progressText,
                    style: theme.typography.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                  const Gap(12),
                  Button.primary(
                    onPressed: onResume,
                    child: const Row(
                      children: [
                        Icon(LucideIcons.play, size: 18),
                        Gap(8),
                        Text('Resume'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
