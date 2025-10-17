import 'package:codemy_app/src/features/user/screens/auth/login_screen.dart';
import 'package:codemy_app/src/features/user/screens/auth/oauth_screen.dart';
import 'package:codemy_app/src/features/user/screens/auth/register_screen.dart';
import 'package:codemy_app/src/features/user/screens/auth/verify_screen.dart';
import 'package:go_router/go_router.dart';

class AuthRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String oauth = '/oauth';
  static const String verify = '/verify';

  static List<GoRoute> get routes => [
    GoRoute(path: login, builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(path: oauth, builder: (context, state) => const OAuthScreen()),
    GoRoute(
      path: verify,
      builder: (context, state) {
        final email = state.uri.queryParameters['email'];
        return VerifyScreen(email: email);
      },
    ),
  ];
}
