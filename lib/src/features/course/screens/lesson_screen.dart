import 'package:codemy_app/src/features/course/widgets/lesson_type/quiz_view.dart';
import 'package:codemy_app/src/features/course/widgets/lesson_type/video_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:codemy_app/src/features/course/widgets/lesson_type/md_view.dart';
import 'package:codemy_app/src/features/course/enums/lesson_type.dart';

class LessonScreen extends ConsumerWidget {
  // Mock data - in real implementation this would come from route params or provider
  final LessonType lessonType = LessonType.quiz;
  final String courseId;
  final String moduleId;
  final String lessonId;
  const LessonScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      headers: [
        AppBar(
          title: Text('Lesson: $courseId/$moduleId/$lessonId'),
          trailing: [
            Button(
              style: ButtonStyle.ghost(),
              onPressed: () {
                context.go('/');
              },
              child: const Icon(RadixIcons.cross1),
            ),
          ],
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: _buildLessonContent(),
      ),
    );
  }

  Widget _buildLessonContent() {
    switch (lessonType) {
      case LessonType.markdown:
        return const MdView();
      case LessonType.video:
        return const VideoView();
      case LessonType.quiz:
        return const QuizView();
    }
  }
}
