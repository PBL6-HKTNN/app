import 'package:codemy_app/src/features/course/models/entities/wishlist_item.dart';

class WishlistResponse {
  final List<WishlistItem> items;

  WishlistResponse({required this.items});

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    return WishlistResponse(
      items: (json['wishlistItems'] as List<dynamic>? ?? [])
          .map((item) => WishlistItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
