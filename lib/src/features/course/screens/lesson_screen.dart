import 'package:codemy_app/src/features/course/enums/lesson_type.dart';
import 'package:codemy_app/src/features/course/models/dto/enrollment_requests.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/features/course/providers/enrollment_provider.dart';
import 'package:codemy_app/src/features/course/providers/lesson_provider.dart';
import 'package:codemy_app/src/features/course/widgets/course_content_sheet.dart';
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

class _LessonScreenState extends ConsumerState<LessonScreen> {
  /// Saves lesson progress using the proper enrollment ID
  void _saveProgress({int progressStatus = 1}) {
    final enrollmentAsync = ref.read(courseEnrollmentProvider(widget.courseId));
    enrollmentAsync.whenData((enrollmentCheck) {
      if (enrollmentCheck.success && enrollmentCheck.enrollment != null) {
        final payload = UpdateEnrollmentRequest(
          enrollmentId: enrollmentCheck.enrollment!.id,
          progressStatus: progressStatus,
          lessonId: widget.lessonId,
        );
        ref.read(updateEnrollmentProvider(payload));
      }
    });
  }

  @override
  void dispose() {
    // Save progress on unmount using proper enrollment ID
    _saveProgress(progressStatus: 1); // In progress
    super.dispose();
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
      _saveProgress(progressStatus: 1);
      if (context.mounted) {
        context.push('/learn/${widget.courseId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(lessonDetailProvider(widget.lessonId));
    // Ensure enrollment is loaded for progress tracking
    ref.watch(courseEnrollmentProvider(widget.courseId));

    return lessonAsync.when(
      data: (lesson) {
        return Scaffold(
          headers: [
            AppBar(
              title: Text(lesson.title),
              trailing: [
                Button(
                  style: ButtonStyle.ghost(),
                  onPressed: () {
                    openSheet(
                      context: context,
                      builder: (context) => CourseContentSheet(
                        courseId: widget.courseId,
                        currentModuleId: widget.moduleId,
                        currentLessonId: widget.lessonId,
                      ),
                      position: OverlayPosition.start,
                    );
                  },
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
              child: _buildLessonContent(context, ref, lesson),
            ),
          ),
        );
      },
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

  Widget _buildLessonContent(
    BuildContext context,
    WidgetRef ref,
    Lesson lesson,
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
        return MdView(lessonId: widget.lessonId);
      case LessonType.video:
        return VideoView(lessonId: widget.lessonId);
      case LessonType.quiz:
        return QuizView(
          lesson: lesson,
          courseId: widget.courseId,
          moduleId: widget.moduleId,
        );
    }
  }
}
