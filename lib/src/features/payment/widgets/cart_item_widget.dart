import 'package:codemy_app/src/features/payment/models/entities/cart_item.dart';
import 'package:codemy_app/src/features/payment/providers/cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Cart item widget displaying course info and remove button
class CartItemWidget extends ConsumerWidget {
  final CartItem item;
  final VoidCallback? onRemoved;

  const CartItemWidget({super.key, required this.item, this.onRemoved});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final isRemoving = cartState.isRemovingItem;
    final theme = Theme.of(context);

    return Card(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 60,
              child: item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty
                  ? Image.network(
                      item.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(theme),
                    )
                  : _buildPlaceholder(theme),
            ),
          ),
          const Gap(12),
          // Course Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.courseTitle,
                        style: theme.typography.semiBold.copyWith(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton.ghost(
                      icon: isRemoving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(size: 16),
                            )
                          : Icon(
                              LucideIcons.trash2,
                              size: 20,
                              color: theme.colorScheme.destructive,
                            ),
                      onPressed: isRemoving ? null : () => _handleRemove(ref),
                    ),
                  ],
                ),
                if (item.description != null &&
                    item.description!.isNotEmpty) ...[
                  const Gap(4),
                  Text(
                    item.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const Gap(8),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.muted,
      child: Icon(
        LucideIcons.bookOpen,
        size: 32,
        color: theme.colorScheme.mutedForeground,
      ),
    );
  }

  Future<void> _handleRemove(WidgetRef ref) async {
    final success = await ref
        .read(cartProvider.notifier)
        .removeFromCart(item.courseId);
    if (success && onRemoved != null) {
      onRemoved!();
    }
  }
}
