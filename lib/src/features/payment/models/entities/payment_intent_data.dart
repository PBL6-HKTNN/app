import 'package:decimal/decimal.dart';

/// Payment intent data for Stripe integration
class PaymentIntentData {
  final String clientSecret;
  final String paymentId;
  final Decimal amount;
  final String currency;

  const PaymentIntentData({
    required this.clientSecret,
    required this.paymentId,
    required this.amount,
    required this.currency,
  });

  factory PaymentIntentData.fromJson(Map<String, dynamic> json) {
    return PaymentIntentData(
      clientSecret: json['clientSecret'] as String,
      paymentId: json['paymentId'] as String,
      amount: Decimal.parse((json['amount'] ?? 0).toString()),
      currency: json['currency'] as String? ?? 'usd',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientSecret': clientSecret,
      'paymentId': paymentId,
      'amount': amount.toDouble(),
      'currency': currency,
    };
  }
}
