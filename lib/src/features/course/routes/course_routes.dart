import 'package:codemy_app/src/features/course/enums/lesson_type.dart';
import 'package:codemy_app/src/features/course/screens/lesson_screen.dart';
import 'package:codemy_app/src/features/course/screens/learning_content_screen.dart';
import 'package:go_router/go_router.dart';

class CourseRoutes {
  static const testLessonScreen = '/course/:courseId/learn/:moduleId/:lessonId';
  static const learningContentScreen = '/course/:courseId/content';
  static List<GoRoute> get routes => [
    GoRoute(
      path: testLessonScreen,
      builder: (context, state) {
        final courseId = state.pathParameters['courseId']!;
        final moduleId = state.pathParameters['moduleId']!;
        final lessonId = state.pathParameters['lessonId']!;
        return LessonScreen(
          courseId: courseId,
          moduleId: moduleId,
          lessonId: lessonId,
        );
      },
    ),
    GoRoute(
      path: learningContentScreen,
      builder: (context, state) {
        final courseId = state.pathParameters['courseId']!;
        return LearningContentScreen(courseId: courseId);
      },
    ),
  ];
}
