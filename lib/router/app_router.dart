import 'package:go_router/go_router.dart';
import 'package:codemy_app/src/presentation/screens/home_screen.dart';
import 'package:codemy_app/src/presentation/screens/not_found_screen.dart';

final appRouter = GoRouter(
  routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())],
  errorBuilder: (context, state) => const NotFoundScreen(),
);
