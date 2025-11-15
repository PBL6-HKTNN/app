import 'package:codemy_app/src/core/conf/api_routes.dart';
import 'package:codemy_app/src/core/networks/api_client.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/course/models/dto/wishlist_responses.dart';
import 'package:codemy_app/src/features/course/models/entities/wishlist_item.dart';

class WishlistService {
  WishlistService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiRes<WishlistResponse>> getWishlist() async {
    try {
      final response = await _apiClient.get(ApiRoutes.WISHLIST.list);
      return ApiRes<WishlistResponse>.fromJson(
        response,
        (data) => WishlistResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to fetch wishlist', tag: 'WISHLIST', error: error);
      return ApiRes<WishlistResponse>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<WishlistItem>> addToWishlist(String courseId) async {
    try {
      final response = await _apiClient.post(ApiRoutes.WISHLIST.add(courseId));
      return ApiRes<WishlistItem>.fromJson(
        response,
        (data) => WishlistItem.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to add to wishlist', tag: 'WISHLIST', error: error);
      return ApiRes<WishlistItem>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<String>> removeFromWishlist(String courseId) async {
    try {
      final response = await _apiClient.delete(
        ApiRoutes.WISHLIST.remove(courseId),
      );
      return ApiRes<String>.fromJson(
        response,
        (data) => data?.toString() ?? '',
      );
    } catch (error) {
      Logger.error(
        'Failed to remove from wishlist',
        tag: 'WISHLIST',
        error: error,
      );
      return ApiRes<String>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }
}
