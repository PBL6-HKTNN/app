import 'package:codemy_app/src/features/payment/enums/order_status.dart';
import 'package:codemy_app/src/features/payment/enums/payment_method.dart';
import 'package:decimal/decimal.dart';

/// Request to create a new payment
class PaymentRequest {
  final PaymentMethod method;
  final List<String> courseIds;

  const PaymentRequest({required this.method, required this.courseIds});

  Map<String, dynamic> toJson() {
    return {'method': method.value, 'courseIds': courseIds};
  }
}

/// Request to update an existing payment
class UpdatePaymentRequest {
  final String paymentId;
  final OrderStatus status;

  const UpdatePaymentRequest({required this.paymentId, required this.status});

  Map<String, dynamic> toJson() {
    return {'paymentId': paymentId, 'status': status.value};
  }
}

/// Request to create a Stripe payment intent
class PaymentIntentRequest {
  final String paymentId;
  final Decimal amount;
  final String? paymentMethodId;

  const PaymentIntentRequest({
    required this.paymentId,
    required this.amount,
    this.paymentMethodId,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'amount': amount.toDouble(),
      if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
    };
  }
}
