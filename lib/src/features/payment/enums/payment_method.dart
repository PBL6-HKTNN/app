/// Payment method enum mirroring web MethodPayment
enum PaymentMethod {
  creditCard(0),
  paypal(1),
  stripe(2);

  const PaymentMethod(this.value);
  final int value;

  static PaymentMethod fromValue(int value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.stripe,
    );
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.stripe:
        return 'Stripe';
    }
  }
}
