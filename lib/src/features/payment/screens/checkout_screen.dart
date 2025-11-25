import 'package:codemy_app/src/features/payment/models/entities/order_item.dart';
import 'package:codemy_app/src/features/payment/providers/payment_provider.dart';
import 'package:codemy_app/src/features/payment/states/checkout_state.dart';
import 'package:codemy_app/src/features/payment/widgets/checkout_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Checkout screen for completing payment
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutProvider.notifier).loadCurrentPayment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);
    final theme = Theme.of(context);

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => context.go('/cart'),
            ),
          ],
          title: Row(
            children: [
              const Icon(LucideIcons.creditCard),
              const Gap(8),
              const Text('Checkout'),
              if (checkoutState.totalItems > 0) ...[
                const Gap(8),
                PrimaryBadge(child: Text('${checkoutState.totalItems} items')),
              ],
            ],
          ),
        ),
      ],
      child: _buildBody(checkoutState, theme),
    );
  }

  Widget _buildBody(CheckoutState checkoutState, ThemeData theme) {
    if (checkoutState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (checkoutState.error != null || checkoutState.paymentData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.circleAlert,
              size: 64,
              color: theme.colorScheme.destructive,
            ),
            const Gap(16),
            Text('Payment not found', style: theme.typography.h4),
            const Gap(8),
            Text(
              checkoutState.error ?? 'No pending payment found',
              style: TextStyle(color: theme.colorScheme.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlineButton(
                  onPressed: () =>
                      ref.read(checkoutProvider.notifier).loadCurrentPayment(),
                  leading: const Icon(LucideIcons.refreshCw),
                  child: const Text('Retry'),
                ),
                const Gap(12),
                PrimaryButton(
                  onPressed: () => context.go('/cart'),
                  child: const Text('Back to Cart'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final paymentData = checkoutState.paymentData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order Summary Card
          Card(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Summary', style: theme.typography.h4),
                const Gap(16),
                ...paymentData.orderItems.map(
                  (item) => _buildOrderItem(item, theme),
                ),
                const Divider(),
                const Gap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: theme.typography.semiBold),
                    Text(
                      '\$${checkoutState.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(24),

          // Payment Form Card
          Card(
            padding: const EdgeInsets.all(16),
            child: CheckoutFormWidget(
              paymentData: paymentData,
              totalAmount: checkoutState.totalAmount,
              onSuccess: _onPaymentSuccess,
              onError: _onPaymentError,
            ),
          ),
          const Gap(16),

          // Cancel Button
          OutlineButton(
            onPressed: () => _showCancelDialog(context),
            child: const Text('Cancel Payment'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 45,
              child: item.thumbnailUrl != null
                  ? Image.network(item.thumbnailUrl!, fit: BoxFit.cover)
                  : Container(
                      color: theme.colorScheme.muted,
                      child: Icon(
                        LucideIcons.bookOpen,
                        size: 24,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.courseTitle,
                  style: theme.typography.medium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onPaymentSuccess() {
    if (!mounted) return;

    showToast(
      context: context,
      builder: (context, overlay) => SurfaceCard(
        child: Basic(
          leading: Icon(
            LucideIcons.circleCheck,
            color: theme.colorScheme.primary,
          ),
          title: const Text('Payment Successful'),
          subtitle: const Text('Your courses are now available'),
        ),
      ),
    );
    context.go('/my-courses');
  }

  void _onPaymentError(String error) {
    if (!mounted) return;

    showToast(
      context: context,
      builder: (context, overlay) => SurfaceCard(
        child: Basic(
          leading: Icon(
            LucideIcons.circleX,
            color: theme.colorScheme.destructive,
          ),
          title: const Text('Payment Failed'),
          subtitle: Text(error),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Payment'),
        content: const Text(
          'Are you sure you want to cancel this payment? '
          'Your items will remain in the cart.',
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep Payment'),
          ),
          DestructiveButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(checkoutProvider.notifier).cancelPayment();
              context.go('/cart');
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  ThemeData get theme => Theme.of(context);
}
