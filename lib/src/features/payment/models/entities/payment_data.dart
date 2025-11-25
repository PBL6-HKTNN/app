import 'order_item.dart';
import 'payment.dart';

/// Payment data combining payment and order items (mirroring web PaymentData)
class PaymentData {
  final Payment payment;
  final List<OrderItem> orderItems;

  const PaymentData({required this.payment, required this.orderItems});

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      payment: Payment.fromJson(json['payment'] as Map<String, dynamic>),
      orderItems:
          (json['orderItems'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment': payment.toJson(),
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }

  PaymentData copyWith({Payment? payment, List<OrderItem>? orderItems}) {
    return PaymentData(
      payment: payment ?? this.payment,
      orderItems: orderItems ?? this.orderItems,
    );
  }

  bool get isEmpty => orderItems.isEmpty;
  bool get isNotEmpty => orderItems.isNotEmpty;
  int get totalItems => orderItems.length;
}
