import 'package:decimal/decimal.dart';

import 'cart_item.dart';

/// Cart entity mirroring web Cart type
class Cart {
  final List<CartItem> items;
  final int totalItems;
  final Decimal totalAmount;

  const Cart({
    required this.items,
    required this.totalItems,
    required this.totalAmount,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalItems: json['totalItems'] as int? ?? 0,
      totalAmount: Decimal.parse((json['totalAmount'] ?? 0).toString()),
    );
  }

  /// Create Cart from a list of CartItems (API returns array directly)
  factory Cart.fromItems(List<CartItem> items) {
    final totalAmount = items.fold<Decimal>(
      Decimal.zero,
      (sum, item) => sum + item.price,
    );
    return Cart(
      items: items,
      totalItems: items.length,
      totalAmount: totalAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalItems': totalItems,
      'totalAmount': totalAmount.toDouble(),
    };
  }

  Cart copyWith({
    List<CartItem>? items,
    int? totalItems,
    Decimal? totalAmount,
  }) {
    return Cart(
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  /// Check if a course is already in the cart
  bool containsCourse(String courseId) {
    return items.any((item) => item.courseId == courseId);
  }
}
