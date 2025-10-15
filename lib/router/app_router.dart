import 'package:go_router/go_router.dart';
import 'package:codemy_app/src/presentation/screens/home_screen.dart';
import 'package:codemy_app/src/presentation/screens/not_found_screen.dart';
import 'package:codemy_app/src/features/user/routes/auth_routes.dart';
import 'package:codemy_app/src/core/guards/auth_guard.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    ...AuthRoutes.routes,
  ],
  redirect: authGuardRedirect,
  errorBuilder: (context, state) => const NotFoundScreen(),
);
