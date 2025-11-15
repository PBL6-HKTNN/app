import 'package:go_router/go_router.dart';

import '../screens/course_detail_screen.dart';
import '../screens/course_list_screen.dart';
import '../screens/joined_course_screen.dart';
import '../screens/learning_content_screen.dart';
import '../screens/lesson_screen.dart';
import '../screens/quiz_doing_screen.dart';
import '../screens/review_screen.dart';
import '../screens/wishlist_course_screen.dart';

class CourseRoutes {
  static final routes = [
    GoRoute(
      path: '/courses',
      builder: (context, state) => const CourseListScreen(),
    ),
    GoRoute(
      path: '/your-courses',
      builder: (context, state) => const JoinedCourseScreen(),
    ),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: '/courses/:courseId',
      builder: (context, state) {
        final courseId = state.pathParameters['courseId']!;
        final source = state.uri.queryParameters['source'] ?? 'all';
        return CourseDetailScreen(courseId: courseId, source: source);
      },
    ),
    GoRoute(
      path: '/course/:courseId/reviews',
      builder: (context, state) {
        final courseId = state.pathParameters['courseId']!;
        return ReviewScreen(courseId: courseId);
      },
    ),
    GoRoute(
      path: '/learn/:courseId',
      builder: (context, state) {
        final courseId = state.pathParameters['courseId']!;
        return LearningContentScreen(courseId: courseId);
      },
      routes: [
        GoRoute(
          path: ':moduleId',
          builder: (context, state) {
            final courseId = state.pathParameters['courseId']!;
            final moduleId = state.pathParameters['moduleId']!;
            return LearningContentScreen(
              courseId: courseId,
              initialModuleId: moduleId,
            );
          },
          routes: [
            GoRoute(
              path: ':lessonId',
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
              routes: [
                GoRoute(
                  path: 'quiz',
                  builder: (context, state) {
                    final courseId = state.pathParameters['courseId']!;
                    final moduleId = state.pathParameters['moduleId']!;
                    final lessonId = state.pathParameters['lessonId']!;
                    final quizId =
                        state.uri.queryParameters['quizId'] ??
                        (state.extra is String ? state.extra as String : null);
                    return QuizDoingScreen(
                      courseId: courseId,
                      moduleId: moduleId,
                      lessonId: lessonId,
                      quizId: quizId,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];
}
