import 'package:go_router/go_router.dart';
import '../screens/user_menu_screen.dart';
import '../screens/user_profile_screen.dart';

class UserRoutes {
  static final routes = [
    GoRoute(path: '/user', builder: (context, state) => const UserMenuScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ];
}
