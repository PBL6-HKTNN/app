import 'package:codemy_app/src/features/course/models/dto/course_content.dart';
import 'package:codemy_app/src/features/course/providers/course_content_provider.dart';
import 'package:codemy_app/src/features/course/providers/enrollment_provider.dart';
import 'package:codemy_app/src/features/course/widgets/course_content_list.dart';
import 'package:codemy_app/src/features/course/widgets/course_progress_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../utils/safe_pop.dart';

class LearningContentScreen extends ConsumerWidget {
  final String courseId;
  final String? initialModuleId;
  final String? initialLessonId;

  const LearningContentScreen({
    super.key,
    required this.courseId,
    this.initialModuleId,
    this.initialLessonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseContent = ref.watch(courseContentProvider(courseId));
    // Watch enrollment to get progress tracking capability
    final enrollmentAsync = ref.watch(courseEnrollmentProvider(courseId));

    return courseContent.when(
      data: (content) => enrollmentAsync.when(
        data: (enrollmentCheck) => _LearningContentView(
          courseId: courseId,
          content: content,
          initialModuleId: initialModuleId,
          initialLessonId: initialLessonId,
          enrollmentId:
              enrollmentCheck.success && enrollmentCheck.enrollment != null
              ? enrollmentCheck.enrollment!.id
              : null,
        ),
        loading: () =>
            const Scaffold(child: Center(child: CircularProgressIndicator())),
        error: (_, __) => _LearningContentView(
          courseId: courseId,
          content: content,
          initialModuleId: initialModuleId,
          initialLessonId: initialLessonId,
          enrollmentId: null,
        ),
      ),
      loading: () =>
          const Scaffold(child: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(RadixIcons.exclamationTriangle, size: 40),
              const Gap(12),
              Text(
                'Failed to load course content',
                style: Theme.of(
                  context,
                ).typography.small.copyWith(color: Colors.red),
              ),
              const Gap(8),
              Text(
                error.toString(),
                style: Theme.of(context).typography.xSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningContentView extends StatefulWidget {
  final String courseId;
  final CourseContent content;
  final String? initialModuleId;
  final String? initialLessonId;
  final String? enrollmentId;

  const _LearningContentView({
    required this.courseId,
    required this.content,
    this.initialModuleId,
    this.initialLessonId,
    this.enrollmentId,
  });

  @override
  State<_LearningContentView> createState() => _LearningContentViewState();
}

class _LearningContentViewState extends State<_LearningContentView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: Text('Course Content - ${widget.courseId}'),
          leading: [
            Button(
              style: ButtonStyle.ghost(),
              onPressed: () =>
                  safePop(context, fallbackRoute: '/learn/${widget.courseId}'),
              child: const Icon(RadixIcons.arrowLeft),
            ),
          ],
        ),
        // Add course progress bar if enrolled
        if (widget.enrollmentId != null)
          Container(
            padding: const EdgeInsets.all(16),
            child: CourseProgressBar(
              enrollmentId: widget.enrollmentId!,
              totalLessons: _getTotalLessonsCount(),
            ),
          ),
      ],
      child: CourseContentList(
        modules: widget.content.modules,
        courseId: widget.courseId,
        enrollmentId: widget.enrollmentId,
        currentLessonId: widget.initialLessonId,
        defaultExpandedModuleId: widget.initialModuleId,
        onLessonSelect: (moduleId, lessonId) =>
            context.go('/learn/${widget.courseId}/$moduleId/$lessonId'),
      ),
    );
  }

  int _getTotalLessonsCount() {
    return widget.content.modules.fold(
      0,
      (total, module) => total + (module.lessons?.length ?? 0),
    );
  }
}
