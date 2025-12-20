import 'package:shadcn_flutter/shadcn_flutter.dart';

class CourseProgressCard extends StatelessWidget {
  final String progressText;

  const CourseProgressCard({super.key, required this.progressText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.bookOpen, size: 20),
                const Gap(8),
                Text('Course Progress', style: theme.typography.h4),
              ],
            ),
            const Gap(12),
            Text(progressText, style: theme.typography.small),
          ],
        ),
      ),
    );
  }
}
