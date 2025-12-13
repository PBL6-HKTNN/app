import 'package:codemy_app/src/features/payment/enums/payment_method.dart';
import 'package:codemy_app/src/features/payment/models/dto/payment_requests.dart';
import 'package:codemy_app/src/features/payment/providers/cart_provider.dart';
import 'package:codemy_app/src/features/payment/providers/payment_provider.dart';
import 'package:codemy_app/src/features/payment/states/cart_state.dart';
import 'package:codemy_app/src/features/payment/states/checkout_state.dart';
import 'package:codemy_app/src/features/payment/widgets/cart_item_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Cart screen displaying user's cart items and checkout option
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartProvider.notifier).loadCart();
      ref.read(checkoutProvider.notifier).loadCurrentPayment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final theme = Theme.of(context);

    return Scaffold(
      headers: [
        AppBar(
          title: Row(
            children: [
              const Icon(LucideIcons.shoppingCart),
              const Gap(8),
              const Text('Shopping Cart'),
              if (cartState.totalItems > 0) ...[
                const Gap(8),
                PrimaryBadge(child: Text('${cartState.totalItems}')),
              ],
            ],
          ),
        ),
      ],
      child: _buildBody(cartState, checkoutState, theme),
    );
  }

  Widget _buildBody(
    CartState cartState,
    CheckoutState checkoutState,
    ThemeData theme,
  ) {
    // Loading state
    if (cartState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (cartState.error != null) {
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
            Text('Failed to load cart', style: theme.typography.h4),
            const Gap(8),
            Text(
              cartState.error!,
              style: TextStyle(color: theme.colorScheme.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            OutlineButton(
              onPressed: () => ref.read(cartProvider.notifier).loadCart(),
              leading: const Icon(LucideIcons.refreshCw),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty cart state
    if (cartState.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.shoppingCart,
              size: 80,
              color: theme.colorScheme.mutedForeground,
            ),
            const Gap(16),
            Text('Your cart is empty', style: theme.typography.h3),
            const Gap(8),
            Text(
              'Browse our courses and add some to your cart',
              style: TextStyle(color: theme.colorScheme.mutedForeground),
            ),
            const Gap(24),
            PrimaryButton(
              onPressed: () => context.go('/courses'),
              child: const Text('Browse Courses'),
            ),
          ],
        ),
      );
    }

    // Cart with items
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartState.items.length,
            itemBuilder: (context, index) {
              final item = cartState.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CartItemWidget(
                  item: item,
                  onRemoved: () {
                    showToast(
                      context: context,
                      builder: (context, overlay) => SurfaceCard(
                        child: Basic(
                          title: const Text('Item removed from cart'),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // Order Summary & Checkout Button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.foreground.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Order Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal (${cartState.totalItems} items)',
                      style: theme.typography.small,
                    ),
                    Text(
                      '\$${cartState.totalAmount.toStringAsFixed(2)}',
                      style: theme.typography.small,
                    ),
                  ],
                ),
                const Gap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Taxes', style: theme.typography.small),
                    Text(
                      'Calculated at checkout',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const Gap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: theme.typography.h4),
                    Text(
                      '\$${cartState.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const Gap(16),

                // Ongoing Payment Warning
                if (checkoutState.hasOngoingPayment) ...[
                  Alert(
                    leading: Icon(
                      LucideIcons.info,
                      color: theme.colorScheme.foreground,
                    ),
                    title: const Text(
                      'You have an unfinished payment. Please complete it first.',
                    ),
                  ),
                  const Gap(12),
                  OutlineButton(
                    onPressed: () => context.go('/checkout'),
                    leading: const Icon(LucideIcons.receipt),
                    child: const Text('View Ongoing Payment'),
                  ),
                  const Gap(8),
                ],

                // Checkout Button
                PrimaryButton(
                  onPressed:
                      (checkoutState.isCreatingPayment ||
                          checkoutState.hasOngoingPayment)
                      ? null
                      : _handleCheckout,
                  child: checkoutState.isCreatingPayment
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(size: 18),
                            ),
                            Gap(8),
                            Text('Processing...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.creditCard, size: 20),
                            Gap(8),
                            Text('Proceed to Checkout'),
                          ],
                        ),
                ),
                const Gap(8),

                // Continue Shopping
                OutlineButton(
                  onPressed: () => context.go('/courses'),
                  child: const Text('Continue Shopping'),
                ),

                const Gap(8),

                // Security Note
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.lock,
                      size: 12,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const Gap(4),
                    Text(
                      'Secure checkout powered by Stripe',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleCheckout() async {
    final cartState = ref.read(cartProvider);
    if (cartState.isEmpty) return;

    final courseIds = cartState.items.map((item) => item.courseId).toList();

    final request = PaymentRequest(
      method: PaymentMethod.stripe,
      courseIds: courseIds,
    );

    final success = await ref
        .read(checkoutProvider.notifier)
        .createPayment(request);

    if (success && mounted) {
      context.go('/checkout');
    }
  }
}
