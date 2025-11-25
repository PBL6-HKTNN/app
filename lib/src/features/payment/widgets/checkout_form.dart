import 'package:codemy_app/src/features/payment/models/entities/payment_data.dart';
import 'package:codemy_app/src/features/payment/providers/payment_provider.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Checkout form widget with Stripe card input
class CheckoutFormWidget extends ConsumerStatefulWidget {
  final PaymentData paymentData;
  final Decimal totalAmount;
  final VoidCallback onSuccess;
  final Function(String error)? onError;

  const CheckoutFormWidget({
    super.key,
    required this.paymentData,
    required this.totalAmount,
    required this.onSuccess,
    this.onError,
  });

  @override
  ConsumerState<CheckoutFormWidget> createState() => _CheckoutFormWidgetState();
}

class _CheckoutFormWidgetState extends ConsumerState<CheckoutFormWidget> {
  bool _isProcessing = false;
  String? _error;
  CardFieldInputDetails? _cardDetails;

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Total Amount Display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.muted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: theme.typography.medium.copyWith(fontSize: 14),
              ),
              Text(
                '\$${widget.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const Gap(24),

        // Card Input Field
        Text(
          'Card Information',
          style: theme.typography.semiBold.copyWith(fontSize: 14),
        ),
        const Gap(8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CardField(
            onCardChanged: (details) {
              setState(() {
                _cardDetails = details;
                _error = null;
              });
            },
          ),
        ),

        // Error Display
        if (_error != null) ...[
          const Gap(12),
          Alert(
            leading: Icon(
              LucideIcons.circleAlert,
              color: theme.colorScheme.destructive,
            ),
            title: Text(
              _error!,
              style: TextStyle(color: theme.colorScheme.destructive),
            ),
            destructive: true,
          ),
        ],

        const Gap(24),

        // Pay Button
        PrimaryButton(
          onPressed:
              (_isProcessing ||
                  checkoutState.isProcessing ||
                  _cardDetails?.complete != true)
              ? null
              : _handlePayment,
          child: _isProcessing || checkoutState.isCreatingIntent
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(size: 18),
                    ),
                    const Gap(8),
                    const Text('Processing...'),
                  ],
                )
              : Text('Pay \$${widget.totalAmount.toStringAsFixed(2)}'),
        ),

        const Gap(16),

        // Security Note
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.lock,
              size: 14,
              color: theme.colorScheme.mutedForeground,
            ),
            const Gap(4),
            Text(
              'Secure payment powered by Stripe',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handlePayment() async {
    if (_cardDetails?.complete != true) {
      setState(() {
        _error = 'Please complete card details';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // Step 1: Create PaymentMethod
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // Step 2: Create PaymentIntent with backend
      final clientSecret = await ref
          .read(checkoutProvider.notifier)
          .createPaymentIntent(
            paymentId: widget.paymentData.payment.id,
            amount: widget.totalAmount,
            paymentMethodId: paymentMethod.id,
          );

      if (clientSecret == null) {
        setState(() {
          _error = 'Failed to create payment intent';
          _isProcessing = false;
        });
        widget.onError?.call('Payment setup failed');
        return;
      }

      // Step 3: Confirm payment with Stripe
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: paymentMethod.id,
          ),
        ),
      );

      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        // Payment successful
        ref.read(checkoutProvider.notifier).onPaymentSuccess();
        widget.onSuccess();
      } else {
        setState(() {
          _error = 'Payment was not completed';
          _isProcessing = false;
        });
        widget.onError?.call('Payment was not completed');
      }
    } on StripeException catch (e) {
      setState(() {
        _error = e.error.localizedMessage ?? 'Payment failed';
        _isProcessing = false;
      });
      widget.onError?.call(e.error.localizedMessage ?? 'Payment failed');
    } catch (e) {
      setState(() {
        _error = 'An unexpected error occurred';
        _isProcessing = false;
      });
      widget.onError?.call(e.toString());
    }
  }
}
