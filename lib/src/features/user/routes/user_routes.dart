import 'package:go_router/go_router.dart';
import '../screens/user_menu_screen.dart';

class UserRoutes {
  static final routes = [
    GoRoute(path: '/user', builder: (context, state) => const UserMenuScreen()),
  ];
}
