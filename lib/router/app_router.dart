import 'package:codemy_app/src/core/guards/auth_guard.dart';
import 'package:codemy_app/src/features/course/routes/course_routes.dart';
import 'package:codemy_app/src/features/payment/routes/payment_routes.dart';
import 'package:codemy_app/src/features/user/routes/auth_routes.dart';
import 'package:codemy_app/src/features/user/routes/user_routes.dart';
import 'package:codemy_app/src/presentation/screens/home_screen.dart';
import 'package:codemy_app/src/presentation/screens/not_found_screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/user',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    ...AuthRoutes.routes,
    ...UserRoutes.routes,
    ...CourseRoutes.routes,
    ...PaymentRoutes.routes,
  ],
  redirect: authGuardRedirect,
  errorBuilder: (context, state) => const NotFoundScreen(),
);
