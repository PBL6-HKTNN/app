import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../models/entities/course.dart';
import '../../models/entities/module.dart';

class CourseOverviewCard extends StatelessWidget {
  final Course course;
  final List<Module> modules;

  const CourseOverviewCard({
    super.key,
    required this.course,
    required this.modules,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Course Overview', style: theme.typography.h4),
            const Gap(12),
            if (course.description != null)
              Text(course.description!, style: theme.typography.small),
            const Gap(16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Chip(
                  leading: const Icon(LucideIcons.clock),
                  child: Text(course.duration),
                ),
                Chip(
                  leading: const Icon(LucideIcons.bookOpen),
                  child: Text('${modules.length} modules'),
                ),
                Chip(
                  leading: const Icon(LucideIcons.star),
                  child: Text(course.averageRating.toStringAsFixed(1)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
