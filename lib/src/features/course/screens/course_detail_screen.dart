import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../providers/course_content_provider.dart';
import '../widgets/course_content_view.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;
  final String source;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    this.source = 'all',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(courseContentProvider(courseId));

    return contentAsync.when(
      loading: () =>
          const Scaffold(child: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          _ErrorView(onBack: () => _goBack(context), message: error.toString()),
      data: (content) {
        final course = content.course;
        final theme = Theme.of(context);
        final isGuest = true; // TODO: Integrate with auth provider
        final thumbnail = course.thumbnail;
        final modules = content.modules;

        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Button.ghost(
                        onPressed: () => _goBack(context),
                        child: const Icon(LucideIcons.arrowLeft, size: 24),
                      ),
                      Expanded(
                        child: Text(
                          course.title,
                          style: theme.typography.h4,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Button.ghost(
                        onPressed: () => context.go('/'),
                        child: const Icon(Icons.home_outlined, size: 24),
                      ),
                    ],
                  ),
                  const Gap(16),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: theme.colorScheme.muted,
                    ),
                    child: thumbnail != null && thumbnail.isNotEmpty
                        ? Image.network(
                            thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(LucideIcons.imageOff, size: 48),
                                ),
                          )
                        : const Center(
                            child: Icon(LucideIcons.imageOff, size: 48),
                          ),
                  ),
                  const Gap(20),
                  Text(course.title, style: theme.typography.h3),
                  const Gap(8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const Gap(4),
                      Text(_formatRating(course.averageRating)),
                      const Gap(8),
                      Text(
                        '(${course.numberOfReviews} reviews)',
                        style: TextStyle(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  if (course.description != null)
                    Text(course.description!, style: theme.typography.small),
                  if (course.description != null) const Gap(20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      _InfoPill(
                        icon: Icons.access_time,
                        label: _formatDuration(course.duration),
                      ),
                      _InfoPill(
                        icon: LucideIcons.languages,
                        label: course.language,
                      ),
                      _InfoPill(
                        icon: Icons.monetization_on_outlined,
                        label: _formatPrice(course.price),
                      ),
                      _InfoPill(
                        icon: LucideIcons.layers,
                        label: '${course.numberOfModules} modules',
                      ),
                    ],
                  ),
                  const Gap(24),
                  if (modules.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Course Content',
                              style: theme.typography.h4.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Button.outline(
                              onPressed: () => CourseContentView.show(
                                context,
                                courseId: course.id,
                                onLessonTap: (lesson) {
                                  Navigator.of(context).pop();
                                  _handleLessonNavigate(
                                    context,
                                    course.id,
                                    lesson.moduleId,
                                    lesson.id,
                                  );
                                },
                              ),
                              child: const Text('Open as panel'),
                            ),
                          ],
                        ),
                        const Gap(12),
                        Card(
                          padding: const EdgeInsets.all(12),
                          child: CourseContentView(
                            courseId: course.id,
                            showHeader: false,
                            onLessonTap: (lesson) => _handleLessonNavigate(
                              context,
                              course.id,
                              lesson.moduleId,
                              lesson.id,
                            ),
                          ),
                        ),
                        if (kDebugMode) ...[
                          const Gap(12),
                          Button.outline(
                            onPressed: () =>
                                context.push('/learn/${course.id}'),
                            child: const Text('Open Learning (Debug)'),
                          ),
                        ],
                      ],
                    ),
                  if (modules.isNotEmpty) const Gap(24),
                  Button.primary(
                    onPressed: () =>
                        context.push('/course/${course.id}/reviews'),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.messageSquare, size: 20),
                        Gap(8),
                        Text('View & Add Reviews'),
                      ],
                    ),
                  ),
                  const Gap(24),
                  Button(
                    style: ButtonStyle.primary(
                      size: ButtonSize.large,
                      shape: ButtonShape.rectangle,
                    ),
                    onPressed: () => _handleEnroll(context, isGuest),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.school_outlined, size: 20),
                        const Gap(8),
                        Text(isGuest ? 'Enroll Now' : 'Enrolled'),
                      ],
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

  void _handleEnroll(BuildContext context, bool isGuest) {
    if (!isGuest) {
      // TODO: implement enroll flow for authenticated users
      return;
    }

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (dialogContext) => AlertDialog(
        leading: const Icon(LucideIcons.circleAlert, size: 40),
        title: const Text(
          'You are not logged in',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Please sign in to enroll in this course and access its content.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SecondaryButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.push('/login');
            },
            child: const Text('Go to Login'),
          ),
        ],
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

  void _goBack(BuildContext context) {
    switch (source) {
      case 'joined':
        context.go('/your-courses');
        break;
      case 'wishlist':
        context.go('/wishlist');
        break;
      default:
        context.go('/courses');
    }
  }

  static String _formatPrice(Decimal price) {
    final value = double.tryParse(price.toString()) ?? 0;
    return "\$${value.toStringAsFixed(2)}";
  }

  static String _formatDuration(String raw) {
    final parts = raw.split(':');
    if (parts.length == 3) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      if (hours > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${minutes}m';
    }
    return raw;
  }

  static String _formatRating(double value) {
    return value.toStringAsFixed(1);
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const Gap(8),
          Text(label, style: theme.typography.xSmall),
        ],
      ),
    );
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.triangleAlert, size: 48),
              const Gap(12),
              Text('Course Not Found', style: theme.typography.h4),
              const Gap(8),
              Text(
                message,
                style: theme.typography.small,
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              PrimaryButton(
                onPressed: onBack,
                child: const Text('Back to Courses'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
