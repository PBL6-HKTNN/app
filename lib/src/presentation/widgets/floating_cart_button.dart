import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../features/payment/providers/cart_provider.dart';

/// Floating cart button that appears in the bottom right corner
/// Shows cart icon with item count badge and navigates to cart screen
class FloatingCartButton extends ConsumerWidget {
  const FloatingCartButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(cartItemCountProvider);

    // Don't show if cart is empty
    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 80, // Above the navigation bar
      right: 16,
      child: IconButton.ghost(
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(LucideIcons.shoppingCart, size: 24),
            // Badge showing item count
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  itemCount.toString(),
                  style: Theme.of(context).typography.small.copyWith(
                    color: Theme.of(context).colorScheme.primaryForeground,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        onPressed: () {
          context.push('/cart');
        },
      ),
    );
  }
}
