import 'package:codemy_app/src/features/payment/models/entities/order_item.dart';
import 'package:codemy_app/src/features/payment/models/entities/payment_data.dart';
import 'package:decimal/decimal.dart';

/// State for checkout/payment operations
class CheckoutState {
  final PaymentData? paymentData;
  final bool isLoading;
  final String? error;
  final bool isCreatingPayment;
  final bool isUpdatingPayment;
  final bool isCreatingIntent;
  final bool isProcessingPayment;

  const CheckoutState({
    this.paymentData,
    this.isLoading = false,
    this.error,
    this.isCreatingPayment = false,
    this.isUpdatingPayment = false,
    this.isCreatingIntent = false,
    this.isProcessingPayment = false,
  });

  /// Check if there's an ongoing payment
  bool get hasOngoingPayment =>
      paymentData != null && paymentData!.payment.orderStatus.isPending;

  /// Check if payment is completed
  bool get isPaymentCompleted =>
      paymentData != null && paymentData!.payment.orderStatus.isCompleted;

  /// Total items in current payment
  int get totalItems => paymentData?.orderItems.length ?? 0;

  /// Total amount of current payment
  Decimal get totalAmount =>
      paymentData?.orderItems.fold<Decimal>(
        Decimal.zero,
        (sum, item) => sum + item.price,
      ) ??
      Decimal.zero;

  /// Order items from current payment
  List<OrderItem> get orderItems => paymentData?.orderItems ?? [];

  /// Any processing state
  bool get isProcessing =>
      isCreatingPayment ||
      isUpdatingPayment ||
      isCreatingIntent ||
      isProcessingPayment;

  CheckoutState copyWith({
    PaymentData? paymentData,
    bool? isLoading,
    String? error,
    bool? isCreatingPayment,
    bool? isUpdatingPayment,
    bool? isCreatingIntent,
    bool? isProcessingPayment,
    bool clearError = false,
    bool clearPaymentData = false,
  }) {
    return CheckoutState(
      paymentData: clearPaymentData ? null : (paymentData ?? this.paymentData),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isCreatingPayment: isCreatingPayment ?? this.isCreatingPayment,
      isUpdatingPayment: isUpdatingPayment ?? this.isUpdatingPayment,
      isCreatingIntent: isCreatingIntent ?? this.isCreatingIntent,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
    );
  }
}
