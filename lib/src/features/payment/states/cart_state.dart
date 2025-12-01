import 'package:codemy_app/src/features/payment/models/entities/cart.dart';
import 'package:codemy_app/src/features/payment/models/entities/cart_item.dart';
import 'package:decimal/decimal.dart';

/// Global cart state for tracking cart items
class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;
  final String? addingCourseId;
  final bool isRemovingItem;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.addingCourseId,
    this.isRemovingItem = false,
  });

  /// Total number of items in cart
  int get totalItems => items.length;

  /// Total amount of all items
  Decimal get totalAmount =>
      items.fold<Decimal>(Decimal.zero, (sum, item) => sum + item.price);

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart is not empty
  bool get isNotEmpty => items.isNotEmpty;

  /// Check if a course is in the cart
  bool containsCourse(String courseId) {
    return items.any((item) => item.courseId == courseId);
  }

  /// Convert to Cart model
  Cart toCart() {
    return Cart(items: items, totalItems: totalItems, totalAmount: totalAmount);
  }

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
    String? addingCourseId,
    bool? isRemovingItem,
    bool clearError = false,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      addingCourseId: addingCourseId ?? this.addingCourseId,
      isRemovingItem: isRemovingItem ?? this.isRemovingItem,
    );
  }
}
