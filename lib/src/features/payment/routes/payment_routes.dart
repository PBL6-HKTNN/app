import 'package:codemy_app/src/features/payment/screens/cart_screen.dart';
import 'package:codemy_app/src/features/payment/screens/checkout_screen.dart';
import 'package:go_router/go_router.dart';

/// Payment feature routes for GoRouter
class PaymentRoutes {
  PaymentRoutes._();

  static const String cart = '/cart';
  static const String checkout = '/checkout';

  /// Get all payment routes
  static List<GoRoute> get routes => [
    GoRoute(
      path: cart,
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: checkout,
      name: 'checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
  ];
}
