import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../providers/course_progress_provider.dart';

/// A widget that displays lesson completion status and progress
class LessonProgressIndicator extends ConsumerWidget {
  final String enrollmentId;
  final String lessonId;
  final bool isCurrentLesson;

  const LessonProgressIndicator({
    super.key,
    required this.enrollmentId,
    required this.lessonId,
    this.isCurrentLesson = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(courseProgressProvider);
    final isCompleted =
        progressState.completedLessonsByEnrollment[enrollmentId]?.contains(
          lessonId,
        ) ??
        false;
    final theme = Theme.of(context);

    if (isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          LucideIcons.check,
          color: theme.colorScheme.primaryForeground,
          size: 16,
        ),
      );
    }

    if (isCurrentLesson) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          LucideIcons.play,
          color: theme.colorScheme.secondaryForeground,
          size: 16,
        ),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border, width: 2),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// A widget that shows overall course progress
class CourseProgressBar extends ConsumerWidget {
  final String enrollmentId;
  final int totalLessons;

  const CourseProgressBar({
    super.key,
    required this.enrollmentId,
    required this.totalLessons,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(courseProgressProvider);
    final completedLessons =
        progressState.completedLessonsByEnrollment[enrollmentId]?.length ?? 0;
    final progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
    final theme = Theme.of(context);

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Course Progress', style: theme.typography.semiBold),
              Text(
                '$completedLessons / $totalLessons lessons',
                style: theme.typography.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
          const Gap(12),
          Progress(
            progress: progress,
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.muted,
          ),
          const Gap(8),
          Text(
            '${(progress * 100).round()}% complete',
            style: theme.typography.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that tracks scroll progress for markdown content
class MarkdownProgressTracker extends ConsumerStatefulWidget {
  final Widget child;
  final String courseId;
  final String lessonId;
  final String enrollmentId;

  const MarkdownProgressTracker({
    super.key,
    required this.child,
    required this.courseId,
    required this.lessonId,
    required this.enrollmentId,
  });

  @override
  ConsumerState<MarkdownProgressTracker> createState() =>
      _MarkdownProgressTrackerState();
}

class _MarkdownProgressTrackerState
    extends ConsumerState<MarkdownProgressTracker> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final scrollPosition = _scrollController.position;
    final scrollPercentage =
        scrollPosition.pixels / scrollPosition.maxScrollExtent;

    if (scrollPercentage.isFinite) {
      ref
          .read(courseProgressProvider.notifier)
          .trackMarkdownScroll(
            scrollPercentage,
            widget.courseId,
            widget.lessonId,
            widget.enrollmentId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: widget.child,
    );
  }
}

/// A widget that tracks video progress
class VideoProgressTracker extends ConsumerWidget {
  final Widget child;
  final double currentTime;
  final double duration;
  final String courseId;
  final String lessonId;
  final String enrollmentId;

  const VideoProgressTracker({
    super.key,
    required this.child,
    required this.currentTime,
    required this.duration,
    required this.courseId,
    required this.lessonId,
    required this.enrollmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Track progress when video time updates
    ref
        .read(courseProgressProvider.notifier)
        .trackVideoProgress(
          currentTime,
          duration,
          courseId,
          lessonId,
          enrollmentId,
        );

    return child;
  }
}

/// A mixin for screens that need to update current view
mixin CourseProgressMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  void updateCurrentView(
    String courseId,
    String lessonId,
    String enrollmentId,
  ) {
    ref
        .read(courseProgressProvider.notifier)
        .updateCurrentView(courseId, lessonId, enrollmentId);
  }

  void loadCompletedLessons(String enrollmentId) {
    ref
        .read(courseProgressProvider.notifier)
        .loadCompletedLessons(enrollmentId);
  }

  void markQuizComplete(
    String courseId,
    String lessonId,
    String enrollmentId,
    bool passed,
  ) {
    ref
        .read(courseProgressProvider.notifier)
        .markQuizComplete(courseId, lessonId, enrollmentId, passed);
  }

  bool isLessonCompleted(String enrollmentId, String lessonId) {
    return ref
        .read(courseProgressProvider.notifier)
        .isLessonCompleted(enrollmentId, lessonId);
  }
}
