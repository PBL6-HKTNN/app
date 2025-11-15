import 'package:codemy_app/src/features/course/enums/lesson_type.dart';
import 'package:codemy_app/src/features/course/providers/lesson_provider.dart';
import 'package:codemy_app/src/features/course/widgets/lesson_type/md_view.dart';
import 'package:codemy_app/src/features/course/widgets/lesson_type/quiz_view.dart';
import 'package:codemy_app/src/features/course/widgets/lesson_type/video_view.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class LessonScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonDetailProvider(lessonId));

    return lessonAsync.when(
      data: (lesson) {
        return Scaffold(
          headers: [
            AppBar(
              title: Text(lesson.title),
              trailing: [
                Button(
                  style: ButtonStyle.ghost(),
                  onPressed: () => context.push('/learn/$courseId'),
                  child: const Icon(RadixIcons.hamburgerMenu),
                ),
                Button(
                  style: ButtonStyle.ghost(),
                  onPressed: () => context.go('/'),
                  child: const Icon(RadixIcons.cross1),
                ),
              ],
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: _buildLessonContent(context, ref, lesson),
          ),
        );
      },
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
    );
  }

  Widget _buildLessonContent(
    BuildContext context,
    WidgetRef ref,
    Lesson lesson,
  ) {
    if (showQuizOnly) {
      if (lesson.lessonType == LessonType.quiz) {
        return QuizView(lesson: lesson, courseId: courseId, moduleId: moduleId);
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
        return MdView(lessonId: lessonId);
      case LessonType.video:
        return VideoView(lessonId: lessonId);
      case LessonType.quiz:
        return QuizView(lesson: lesson, courseId: courseId, moduleId: moduleId);
    }
  }
}
