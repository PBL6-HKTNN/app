import 'package:codemy_app/src/features/payment/enums/order_status.dart';
import 'package:codemy_app/src/features/payment/models/dto/payment_requests.dart';
import 'package:codemy_app/src/features/payment/models/entities/payment_data.dart';
import 'package:codemy_app/src/features/payment/providers/cart_provider.dart';
import 'package:codemy_app/src/features/payment/services/payment_service.dart';
import 'package:codemy_app/src/features/payment/states/checkout_state.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Checkout state provider
final checkoutProvider = NotifierProvider<CheckoutNotifier, CheckoutState>(() {
  return CheckoutNotifier();
});

/// Checkout/Payment state notifier
class CheckoutNotifier extends Notifier<CheckoutState> {
  PaymentService get _service => ref.read(paymentServiceProvider);

  @override
  CheckoutState build() => const CheckoutState();

  /// Load current pending payment
  Future<void> loadCurrentPayment() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _service.getPayment();

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(paymentData: response.data!, isLoading: false);
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error?.toString() ?? 'Failed to load payment',
      );
    }
  }

  /// Create a new payment from cart items
  Future<bool> createPayment(PaymentRequest request) async {
    state = state.copyWith(isCreatingPayment: true, clearError: true);

    final response = await _service.createPayment(request);

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        paymentData: response.data!,
        isCreatingPayment: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isCreatingPayment: false,
        error: response.error?.toString() ?? 'Failed to create payment',
      );
      return false;
    }
  }

  /// Update payment status
  Future<bool> updatePayment(String paymentId, OrderStatus status) async {
    state = state.copyWith(isUpdatingPayment: true, clearError: true);

    final request = UpdatePaymentRequest(paymentId: paymentId, status: status);

    final response = await _service.updatePayment(request);

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        paymentData: response.data!,
        isUpdatingPayment: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isUpdatingPayment: false,
        error: response.error?.toString() ?? 'Failed to update payment',
      );
      return false;
    }
  }

  /// Cancel current payment
  Future<bool> cancelPayment() async {
    if (state.paymentData == null) return false;

    return updatePayment(state.paymentData!.payment.id, OrderStatus.cancelled);
  }

  /// Create Stripe payment intent
  Future<String?> createPaymentIntent({
    required String paymentId,
    required Decimal amount,
    String? paymentMethodId,
  }) async {
    state = state.copyWith(isCreatingIntent: true, clearError: true);

    final request = PaymentIntentRequest(
      paymentId: paymentId,
      amount: amount,
      paymentMethodId: paymentMethodId,
    );

    final response = await _service.createPaymentIntent(request);

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(isCreatingIntent: false);
      return response.data!.clientSecret;
    } else {
      state = state.copyWith(
        isCreatingIntent: false,
        error: response.error?.toString() ?? 'Failed to create payment intent',
      );
      return null;
    }
  }

  /// Handle successful payment completion
  void onPaymentSuccess() {
    // Clear the cart after successful payment
    ref.read(cartProvider.notifier).clearCart();

    // Update payment state
    if (state.paymentData != null) {
      final updatedPayment = state.paymentData!.copyWith(
        payment: state.paymentData!.payment.copyWith(
          orderStatus: OrderStatus.completed,
        ),
      );
      state = state.copyWith(paymentData: updatedPayment);
    }
  }

  /// Clear checkout state
  void clearCheckout() {
    state = const CheckoutState();
  }
}

/// Provider for listing all user payments
final paymentsListProvider = FutureProvider<List<PaymentData>>((ref) async {
  final service = ref.watch(paymentServiceProvider);
  final response = await service.listPayments();

  if (response.isSuccess && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.toString() ?? 'Failed to load payments');
  }
});

/// Provider for checking if there's an ongoing payment
final hasOngoingPaymentProvider = Provider<bool>((ref) {
  final checkoutState = ref.watch(checkoutProvider);
  return checkoutState.hasOngoingPayment;
});
