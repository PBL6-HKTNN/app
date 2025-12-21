import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../models/entities/module.dart';
import '../../widgets/course_content_list.dart';

class CourseContentCard extends StatelessWidget {
  final String courseId;
  final List<Module> modules;
  final String? enrollmentId;
  final void Function(String, String) onLessonSelect;

  const CourseContentCard({
    super.key,
    required this.courseId,
    required this.modules,
    required this.enrollmentId,
    required this.onLessonSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (modules.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Course Content', style: theme.typography.h4),
            const Gap(12),
            CourseContentList(
              modules: modules,
              courseId: courseId,
              enrollmentId: enrollmentId,
              onLessonSelect: onLessonSelect,
            ),
          ],
        ),
      ),
    );
  }
}
