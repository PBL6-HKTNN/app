import 'package:codemy_app/src/features/payment/models/entities/cart_item.dart';
import 'package:codemy_app/src/features/payment/services/payment_service.dart';
import 'package:codemy_app/src/features/payment/states/cart_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service provider for payment service
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

/// Global cart state provider
final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});

/// Global cart state notifier for tracking cart items
class CartNotifier extends Notifier<CartState> {
  PaymentService get _service => ref.read(paymentServiceProvider);

  @override
  CartState build() => const CartState();

  /// Load cart items from API
  Future<void> loadCart() async {
    state = state.copyWith(
      isLoading: true,
      addingCourseId: null,
      clearError: true,
    );

    final response = await _service.getCart();

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(items: response.data!, isLoading: false);
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error?.toString() ?? 'Failed to load cart',
      );
    }
  }

  /// Add a course to the cart
  Future<bool> addToCart(String courseId) async {
    // Check if already in cart
    if (state.containsCourse(courseId)) {
      return false;
    }

    state = state.copyWith(addingCourseId: courseId, clearError: true);

    final response = await _service.addToCart(courseId);

    if (response.isSuccess) {
      // Refresh cart to get updated items
      await loadCart();
      return true;
    } else {
      state = state.copyWith(
        addingCourseId: null,
        error: response.error?.toString() ?? 'Failed to add to cart',
      );
      return false;
    }
  }

  /// Remove a course from the cart
  Future<bool> removeFromCart(String courseId) async {
    state = state.copyWith(isRemovingItem: true, clearError: true);

    final response = await _service.removeFromCart(courseId);

    if (response.isSuccess) {
      final newItems = state.items
          .where((item) => item.courseId != courseId)
          .toList();
      state = state.copyWith(items: newItems, isRemovingItem: false);
      return true;
    } else {
      state = state.copyWith(
        isRemovingItem: false,
        error: response.error?.toString() ?? 'Failed to remove from cart',
      );
      return false;
    }
  }

  /// Clear the cart (locally, after successful payment)
  void clearCart() {
    state = state.copyWith(items: []);
  }

  /// Update cart items directly (useful after refresh)
  void updateItems(List<CartItem> items) {
    state = state.copyWith(items: items);
  }

  /// Check if a course is in cart
  bool isInCart(String courseId) {
    return state.containsCourse(courseId);
  }
}

/// Provider for checking if a specific course is in cart
final isInCartProvider = Provider.family<bool, String>((ref, courseId) {
  final cartState = ref.watch(cartProvider);
  return cartState.containsCourse(courseId);
});

/// Provider for cart item count (useful for badges)
final cartItemCountProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.totalItems;
});
