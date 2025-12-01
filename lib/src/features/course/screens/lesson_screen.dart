import 'package:codemy_app/src/features/course/enums/lesson_type.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/features/course/providers/course_progress_provider.dart';
import 'package:codemy_app/src/features/course/providers/enrollment_provider.dart';
import 'package:codemy_app/src/features/course/providers/lesson_provider.dart';
import 'package:codemy_app/src/features/course/widgets/course_progress_widgets.dart';
import 'package:codemy_app/src/features/course/widgets/lesson_type/locked_view.dart';
import 'package:codemy_app/src/features/course/widgets/lesson_type/md_view.dart';
import 'package:codemy_app/src/features/course/widgets/lesson_type/quiz_view.dart';
import 'package:codemy_app/src/features/course/widgets/lesson_type/video_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String moduleId;
  final String lessonId;
  final bool showQuizOnly;

  const LessonScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
    this.showQuizOnly = false,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen>
    with CourseProgressMixin {
  String? _enrollmentId;

  @override
  void initState() {
    super.initState();
    // Progress initialization will happen in build method
  }

  @override
  void dispose() {
    // Update current view on unmount
    if (_enrollmentId != null) {
      ref
          .read(courseProgressProvider.notifier)
          .updateCurrentView(widget.courseId, widget.lessonId, _enrollmentId!);
    }
    super.dispose();
  }

  void _openCourseContentSheet(BuildContext context) {
    context.push('/learn/${widget.courseId}/content-listing');
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Exit Lesson?'),
          content: const Text(
            'Your progress will be saved. Are you sure you want to exit?',
          ),
          actions: [
            Button(
              style: ButtonStyle.ghost(),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            Button(
              style: ButtonStyle.primary(),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      if (context.mounted) {
        context.push('/learn/${widget.courseId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(checkLessonLockedProvider(widget.lessonId));
    final enrollmentAsync = ref.watch(
      courseEnrollmentProvider(widget.courseId),
    );

    return lessonAsync.when(
      data: (lesson) => lesson != null
          ? _buildLessonScaffold(context, lesson, enrollmentAsync)
          : Scaffold(
              headers: [
                AppBar(
                  title: const Text('Lesson Locked'),
                  trailing: [
                    Button(
                      style: ButtonStyle.ghost(),
                      onPressed: () => _openCourseContentSheet(context),
                      child: const Icon(RadixIcons.hamburgerMenu),
                    ),
                    Button(
                      style: ButtonStyle.ghost(),
                      onPressed: () => _confirmExit(context),
                      child: const Icon(RadixIcons.cross1),
                    ),
                  ],
                ),
              ],
              child: DrawerOverlay(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: LockedLessonView(lessonTitle: 'Lesson Locked'),
                ),
              ),
            ),
      loading: () => const Scaffold(
        child: DrawerOverlay(child: Center(child: CircularProgressIndicator())),
      ),
      error: (error, _) => Scaffold(
        child: DrawerOverlay(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(RadixIcons.exclamationTriangle, size: 40),
                const Gap(12),
                Text(
                  'Failed to load lesson',
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
      ),
    );
  }

  Widget _buildLessonScaffold(
    BuildContext context,
    Lesson lesson,
    AsyncValue enrollmentAsync,
  ) {
    return Scaffold(
      headers: [
        AppBar(
          title: Text(lesson.title),
          trailing: [
            Button(
              style: ButtonStyle.ghost(),
              onPressed: () => _openCourseContentSheet(context),
              child: const Icon(RadixIcons.hamburgerMenu),
            ),
            Button(
              style: ButtonStyle.ghost(),
              onPressed: () => _confirmExit(context),
              child: const Icon(RadixIcons.cross1),
            ),
          ],
        ),
      ],
      child: DrawerOverlay(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: enrollmentAsync.when(
            data: (enrollmentCheck) {
              _enrollmentId = enrollmentCheck.enrollment?.id;
              return _buildLessonContent(
                context,
                ref,
                lesson,
                enrollmentCheck.enrollment?.id,
              );
            },
            error: (error, stack) =>
                Center(child: Text('Error loading enrollment: $error')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonContent(
    BuildContext context,
    WidgetRef ref,
    Lesson lesson,
    String? enrollmentId,
  ) {
    if (widget.showQuizOnly) {
      if (lesson.lessonType == LessonType.quiz) {
        return QuizView(
          lesson: lesson,
          courseId: widget.courseId,
          moduleId: widget.moduleId,
        );
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(RadixIcons.infoCircled, size: 48),
              const Gap(12),
              Text(
                'This lesson does not contain a quiz.',
                style: Theme.of(context).typography.small,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    switch (lesson.lessonType) {
      case LessonType.markdown:
        return enrollmentId != null
            ? MarkdownProgressTracker(
                courseId: widget.courseId,
                lessonId: widget.lessonId,
                enrollmentId: enrollmentId,
                child: MdView(lessonId: widget.lessonId),
              )
            : MdView(lessonId: widget.lessonId);
      case LessonType.video:
        return VideoView(
          lesson: lesson,
          onProgressUpdate: enrollmentId != null
              ? (currentTime, duration) {
                  ref
                      .read(courseProgressProvider.notifier)
                      .trackVideoProgress(
                        currentTime,
                        duration,
                        widget.courseId,
                        widget.lessonId,
                        enrollmentId,
                      );
                }
              : null,
        );
      case LessonType.quiz:
        return QuizView(
          lesson: lesson,
          courseId: widget.courseId,
          moduleId: widget.moduleId,
        );
    }
  }
}
