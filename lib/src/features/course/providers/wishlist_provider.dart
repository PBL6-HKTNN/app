import 'package:codemy_app/src/core/networks/exception.dart';
import 'package:codemy_app/src/features/course/models/dto/wishlist_responses.dart';
import 'package:codemy_app/src/features/course/models/entities/wishlist_item.dart';
import 'package:codemy_app/src/features/course/services/wishlist_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wishlistServiceProvider = Provider<WishlistService>((ref) {
  return WishlistService();
});

final wishlistProvider = FutureProvider.autoDispose<WishlistResponse>((
  ref,
) async {
  final service = ref.read(wishlistServiceProvider);
  final response = await service.getWishlist();
  if (!response.isSuccess || response.data == null) {
    throw ApiException(
      response.error?.toString() ?? 'Failed to load wishlist',
      statusCode: response.status,
      data: response.data,
    );
  }
  return response.data!;
});

final addToWishlistProvider = FutureProvider.autoDispose
    .family<WishlistItem, String>((ref, courseId) async {
      final service = ref.read(wishlistServiceProvider);
      final response = await service.addToWishlist(courseId);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to add to wishlist',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });

final removeFromWishlistProvider = FutureProvider.autoDispose
    .family<String, String>((ref, courseId) async {
      final service = ref.read(wishlistServiceProvider);
      final response = await service.removeFromWishlist(courseId);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to remove from wishlist',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });
