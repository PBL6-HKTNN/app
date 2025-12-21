import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../utils/safe_pop.dart';

class NotEnrolledView extends StatelessWidget {
  final String courseId;
  const NotEnrolledView({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.bookX, size: 48),
                const Gap(16),
                Text('Not Enrolled', style: theme.typography.h3),
                const Gap(8),
                Text(
                  'You are not enrolled in this course. Please enroll to access the content.',
                  style: theme.typography.small,
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Button.secondary(
                      onPressed: () => safePop(context),
                      child: const Text('Back to Courses'),
                    ),
                    const Gap(12),
                    Button.primary(
                      onPressed: () => context.push('/courses/$courseId'),
                      child: const Text('View Course'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
