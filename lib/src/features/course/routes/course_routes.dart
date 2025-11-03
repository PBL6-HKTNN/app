import '../screens/wishlist_course_screen.dart';
import 'package:go_router/go_router.dart';
import '../screens/course_list_screen.dart';
import '../screens/course_detail_screen.dart';
import '../screens/review_screen.dart';
import '../screens/joined_course_screen.dart';

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
  ];
}
