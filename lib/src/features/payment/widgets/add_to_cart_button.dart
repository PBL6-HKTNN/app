import 'package:codemy_app/src/features/payment/providers/cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Add to cart button widget with loading and "in cart" states
class AddToCartButton extends ConsumerWidget {
  final String courseId;
  final VoidCallback? onAdded;
  final bool showText;
  final ButtonSize size;

  const AddToCartButton({
    super.key,
    required this.courseId,
    this.onAdded,
    this.showText = true,
    this.size = ButtonSize.normal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInCart = ref.watch(isInCartProvider(courseId));
    final cartState = ref.watch(cartProvider);
    final isAdding = cartState.addingCourseId == courseId;
    final theme = Theme.of(context);

    if (isInCart) {
      return OutlineButton(
        size: size,
        leading: Icon(
          LucideIcons.check,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        onPressed: null,
        child: showText ? const Text('In Cart') : const SizedBox.shrink(),
      );
    }

    return PrimaryButton(
      size: size,
      leading: isAdding
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(size: 16),
            )
          : const Icon(LucideIcons.shoppingCart, size: 18),
      onPressed: isAdding ? null : () => _handleAddToCart(ref),
      child: showText
          ? Text(isAdding ? 'Adding...' : 'Add to Cart')
          : const SizedBox.shrink(),
    );
  }

  Future<void> _handleAddToCart(WidgetRef ref) async {
    final success = await ref.read(cartProvider.notifier).addToCart(courseId);
    if (success && onAdded != null) {
      onAdded!();
    }
  }
}
