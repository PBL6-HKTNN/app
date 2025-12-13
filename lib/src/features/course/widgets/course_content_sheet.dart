import 'package:codemy_app/src/features/course/providers/course_content_provider.dart';
import 'package:codemy_app/src/features/course/providers/enrollment_provider.dart';
import 'package:codemy_app/src/features/course/widgets/course_content_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CourseContentSheet extends ConsumerWidget {
  final String courseId;
  final String? currentModuleId;
  final String? currentLessonId;

  const CourseContentSheet({
    super.key,
    required this.courseId,
    this.currentModuleId,
    this.currentLessonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseContent = ref.watch(courseContentProvider(courseId));
    final enrollmentAsync = ref.watch(courseEnrollmentProvider(courseId));
    final enrollmentId = enrollmentAsync.maybeWhen(
      data: (data) => data.enrollment?.id,
      orElse: () => null,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Course Content', style: Theme.of(context).typography.h3),
              const Spacer(),
              Button.ghost(
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(RadixIcons.cross1),
              ),
            ],
          ),
          const Gap(16),
          courseContent.when(
            data: (content) => Expanded(
              child: CourseContentList(
                modules: content.modules,
                courseId: courseId,
                enrollmentId: enrollmentId,
                currentLessonId: currentLessonId,
                defaultExpandedModuleId: currentModuleId,
                onLessonSelect: (moduleId, lessonId) {
                  Navigator.of(context).pop();
                  context.go('/learn/$courseId/$moduleId/$lessonId');
                },
              ),
            ),
            loading: () => const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      BootstrapIcons.exclamationTriangle,
                      size: 32,
                      color: Color(0xFFEF4444), // red-500
                    ),
                    const Gap(12),
                    Text(
                      'Failed to load course content',
                      style: Theme.of(context).typography.p,
                    ),
                    const Gap(8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).typography.small,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
