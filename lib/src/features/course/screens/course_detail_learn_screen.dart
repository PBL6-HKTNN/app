import 'package:codemy_app/src/features/course/enums/enrollment.dart';
import 'package:codemy_app/src/features/course/widgets/course_detail_view/index.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../utils/safe_pop.dart';
import '../../user/providers/auth_providers.dart';
import '../models/entities/lesson.dart';
import '../models/entities/module.dart';
import '../providers/certificate_provider.dart';
import '../providers/course_content_provider.dart';
import '../providers/enrollment_provider.dart';

class CourseDetailLearnScreen extends ConsumerWidget {
  final String courseId;

  const CourseDetailLearnScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(courseContentProvider(courseId));
    final enrollmentAsync = ref.watch(courseEnrollmentProvider(courseId));
    final authState = ref.watch(authStateProvider);

    // Check if user is authenticated and enrolled
    final isAuthenticated = authState.isAuthenticated;
    final isEnrolled = enrollmentAsync.when(
      data: (enrollment) => enrollment.success,
      loading: () => false,
      error: (_, __) => false,
    );

    if (!isAuthenticated) {
      return const UnauthorizedView();
    }

    if (!isEnrolled && !enrollmentAsync.isLoading) {
      return NotEnrolledView(courseId: courseId);
    }

    return contentAsync.when(
      loading: () =>
          const Scaffold(child: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          ErrorView(onBack: () => safePop(context), message: error.toString()),
      data: (content) {
        final course = content.course;
        final modules = content.modules;
        final enrollmentId = enrollmentAsync.asData?.value.enrollment?.id;
        final enrollment = enrollmentAsync.asData?.value.enrollment;
        // Find current viewed lesson from enrollment
        final currentLessonId = enrollment?.lessonId;
        Lesson? currentLesson;
        Module? currentModule;
        if (currentLessonId != null) {
          for (final module in modules) {
            if (module.lessons == null) continue;
            for (final lesson in module.lessons!) {
              if (lesson.id == currentLessonId) {
                currentLesson = lesson;
                currentModule = module;
                break;
              }
            }
            if (currentLesson != null) break;
          }
        }
        final theme = Theme.of(context);

        // Calculate progress based on enrollment progressStatus
        final dynamic rawProgress = enrollment?.progressStatus;
        ProgressStatus parsedProgress;
        if (rawProgress == null) {
          parsedProgress = ProgressStatus.notStarted;
        } else if (rawProgress is ProgressStatus) {
          parsedProgress = rawProgress;
        } else if (rawProgress is int) {
          parsedProgress = progressStatusFromValue(rawProgress);
        } else {
          parsedProgress = ProgressStatus.notStarted;
        }
        final progressText = _getProgressText(parsedProgress);

        // Fetch certificate status early so it's available for conditional rendering
        final certStatusAsync = enrollmentId != null
            ? ref.watch(certStatusProvider(enrollmentId))
            : null;

        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          child: SafeArea(
            child: material.RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(courseContentProvider(courseId));
                ref.invalidate(courseEnrollmentProvider(courseId));
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button
                    Row(
                      children: [
                        Button.ghost(
                          onPressed: () => context.go('/your-courses'),
                          child: const Icon(LucideIcons.arrowLeft, size: 24),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            'Learning: ${course.title}',
                            style: theme.typography.h3,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const Gap(24),

                    // Course progress card
                    CourseProgressCard(progressText: progressText),

                    const Gap(24),

                    // Resume current lesson card (if present)
                    if (currentLesson != null && currentModule != null) ...[
                      ResumeLessonCard(
                        currentLesson: currentLesson,
                        currentModule: currentModule,
                        progressText: progressText,
                        onResume: () => _handleLessonNavigate(
                          context,
                          courseId,
                          currentModule!.id,
                          currentLesson!.id,
                        ),
                      ),
                      const Gap(24),
                    ],

                    // Course overview
                    CourseOverviewCard(course: course, modules: modules),

                    const Gap(24),

                    // Course content
                    CourseContentCard(
                      courseId: courseId,
                      modules: modules,
                      enrollmentId: enrollmentId,
                      onLessonSelect: (moduleId, lessonId) =>
                          _handleLessonNavigate(
                            context,
                            courseId,
                            moduleId,
                            lessonId,
                          ),
                    ),
                    if (modules.isNotEmpty) const Gap(24),

                    // Quick actions
                    QuickActionsCard(
                      courseId: courseId,
                      modules: modules,
                      parsedProgress: parsedProgress,
                      enrollmentId: enrollmentId,
                      certStatusAsync: certStatusAsync,
                      onStartLearning: _startFirstLesson,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleLessonNavigate(
    BuildContext context,
    String courseId,
    String moduleId,
    String lessonId,
  ) {
    context.push('/learn/$courseId/$moduleId/$lessonId');
  }

  void _startFirstLesson(BuildContext context, String courseId, List modules) {
    if (modules.isNotEmpty && modules.first.lessons?.isNotEmpty == true) {
      final firstModule = modules.first;
      final firstLesson = firstModule.lessons!.first;
      context.push('/learn/$courseId/${firstModule.id}/${firstLesson.id}');
    }
  }

  String _getProgressText(ProgressStatus progressStatus) {
    switch (progressStatus) {
      case ProgressStatus.notStarted:
        return 'Not Started';
      case ProgressStatus.inProgress:
        return 'In Progress'; // Could be enhanced to show actual progress
      case ProgressStatus.completed:
        return 'Completed';
      default:
        return 'Not Started';
    }
  }
}
