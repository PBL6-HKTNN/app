import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../utils/safe_pop.dart';
import '../../user/providers/auth_providers.dart';
import '../providers/course_content_provider.dart';
import '../providers/enrollment_provider.dart';
import '../widgets/course_content_list.dart';

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
      return _buildUnauthorizedView(context);
    }

    if (!isEnrolled && !enrollmentAsync.isLoading) {
      return _buildNotEnrolledView(context, courseId);
    }

    return contentAsync.when(
      loading: () =>
          const Scaffold(child: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          _ErrorView(onBack: () => safePop(context), message: error.toString()),
      data: (content) {
        final course = content.course;
        final modules = content.modules;
        final enrollmentId = enrollmentAsync.asData?.value.enrollment?.id;
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          child: SafeArea(
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.bookOpen, size: 20),
                              const Gap(8),
                              Text(
                                'Course Progress',
                                style: theme.typography.h4,
                              ),
                            ],
                          ),
                          const Gap(12),

                          // Progress indicator
                          LinearProgressIndicator(
                            value: 0.0, // TODO: Calculate actual progress
                            backgroundColor: theme.colorScheme.muted,
                          ),
                          const Gap(8),
                          Text(
                            '0% Complete', // TODO: Show actual progress
                            style: theme.typography.small,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Gap(24),

                  // Course overview
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Course Overview', style: theme.typography.h4),
                          const Gap(12),
                          if (course.description != null)
                            Text(
                              course.description!,
                              style: theme.typography.small,
                            ),
                          const Gap(16),

                          // Course stats
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              Chip(
                                leading: Icon(LucideIcons.clock),
                                child: Text(course.duration),
                              ),
                              Chip(
                                leading: Icon(LucideIcons.bookOpen),
                                child: Text('${modules.length} modules'),
                              ),
                              Chip(
                                leading: Icon(LucideIcons.star),
                                child: Text(
                                  course.averageRating.toStringAsFixed(1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Gap(24),

                  // Course content
                  if (modules.isNotEmpty) ...[
                    Card(
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
                              onLessonSelect: (moduleId, lessonId) =>
                                  _handleLessonNavigate(
                                    context,
                                    courseId,
                                    moduleId,
                                    lessonId,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(24),
                  ],

                  // Quick actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quick Actions', style: theme.typography.h4),
                          const Gap(12),

                          Button.primary(
                            onPressed: modules.isNotEmpty
                                ? () => _startFirstLesson(
                                    context,
                                    courseId,
                                    modules,
                                  )
                                : null,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.play, size: 18),
                                Gap(8),
                                Text('Start Learning'),
                              ],
                            ),
                          ),

                          const Gap(12),

                          Button.ghost(
                            onPressed: () =>
                                context.push('/course/$courseId/reviews'),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.messageSquare, size: 18),
                                Gap(8),
                                Text('View Reviews'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnauthorizedView(BuildContext context) {
    return Scaffold(
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.lock, size: 48),
                const Gap(16),
                Text('Access Denied', style: Theme.of(context).typography.h3),
                const Gap(8),
                Text(
                  'You need to be logged in to access this course.',
                  style: Theme.of(context).typography.small,
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                Button.primary(
                  onPressed: () => context.push('/login'),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotEnrolledView(BuildContext context, String courseId) {
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
                Text('Not Enrolled', style: Theme.of(context).typography.h3),
                const Gap(8),
                Text(
                  'You are not enrolled in this course. Please enroll to access the content.',
                  style: Theme.of(context).typography.small,
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
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onBack;
  final String message;

  const _ErrorView({required this.onBack, required this.message});

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
                const Icon(LucideIcons.triangleAlert, size: 48),
                const Gap(16),
                Text('Error Loading Course', style: theme.typography.h3),
                const Gap(8),
                Text(
                  message,
                  style: theme.typography.small,
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                Button.primary(
                  onPressed: onBack,
                  child: const Text('Back to Courses'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
