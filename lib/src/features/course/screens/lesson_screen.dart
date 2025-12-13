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
  bool _askedResumeDialog = false;
  int? _resumePositionMs;
  int? _lastSentWatchedMs;
  String _formatTime(int seconds) {
    final dur = Duration(seconds: seconds);
    final h = dur.inHours;
    final m = dur.inMinutes % 60;
    final s = dur.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  void initState() {
    super.initState();
    // Progress initialization will happen in build method
  }

  @override
  void dispose() {
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
              final currentViewId = enrollmentCheck.enrollment?.currentView;
              final watchedSeconds = enrollmentCheck.enrollment?.watchedSeconds;
              final isVideo = lesson.lessonType == LessonType.video;
              // Show resume dialog for video lesson if currentView and watchedSeconds exist
              if (!_askedResumeDialog &&
                  isVideo &&
                  currentViewId != null &&
                  currentViewId == lesson.id &&
                  (watchedSeconds ?? 0) > 0) {
                _askedResumeDialog = true;
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  // Show dialog
                  final choice = await showDialog<bool>(
                    context: context,
                    barrierDismissible: true,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('Resume Video'),
                      content: Text(
                        'Resume at ${_formatTime(watchedSeconds ?? 0)}?',
                      ),
                      actions: [
                        Button(
                          style: ButtonStyle.ghost(),
                          onPressed: () => Navigator.of(dialogCtx).pop(false),
                          child: const Text('Start from Beginning'),
                        ),
                        Button(
                          style: ButtonStyle.primary(),
                          onPressed: () => Navigator.of(dialogCtx).pop(true),
                          child: const Text('Resume'),
                        ),
                      ],
                    ),
                  );
                  if (context.mounted && choice == true) {
                    setState(() {
                      _resumePositionMs = (watchedSeconds ?? 0) * 1000;
                    });
                  }
                });
              }
              // Ensure current view is updated on entry with enrolled watchedSeconds if any
              if (_enrollmentId != null) {
                final int? sendSeconds =
                    (enrollmentCheck.enrollment?.watchedSeconds ?? 0) > 0
                    ? (enrollmentCheck.enrollment!.watchedSeconds!)
                    : null;
                updateCurrentView(
                  widget.courseId,
                  lesson.id,
                  _enrollmentId!,
                  sendSeconds,
                );
              }

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
          initialPositionMs: _resumePositionMs,
          onProgressUpdate: enrollmentId != null
              ? (currentTime, duration) {
                  // Track video progress
                  ref
                      .read(courseProgressProvider.notifier)
                      .trackVideoProgress(
                        currentTime,
                        duration,
                        widget.courseId,
                        widget.lessonId,
                        enrollmentId,
                      );
                  // Send updateCurrentView with watchedSeconds every 15s
                  final ms = currentTime.round();
                  if (_lastSentWatchedMs == null ||
                      (ms - _lastSentWatchedMs!).abs() >= 15000) {
                    _lastSentWatchedMs = ms;
                    final secondsToSend = (ms ~/ 1000);
                    updateCurrentView(
                      widget.courseId,
                      widget.lessonId,
                      enrollmentId,
                      secondsToSend,
                    );
                  }
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
