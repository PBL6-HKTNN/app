import 'package:codemy_app/src/features/course/models/entities/wishlist_item.dart';

class WishlistedCourse {
  final String userId;
  final String courseId;
  final String title;
  final String description;
  final String? thumbnail;

  WishlistedCourse(
    this.userId,
    this.courseId,
    this.title,
    this.description,
    this.thumbnail,
  );

  factory WishlistedCourse.fromJson(Map<String, dynamic> json) {
    return WishlistedCourse(
      json['userId'] as String,
      json['courseId'] as String,
      json['title'] as String,
      json['description'] as String,
      json['thumbnail'] as String?,
    );
  }
}

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

class GetWishlistCoursesResponse {
  final List<WishlistedCourse> courses;

  GetWishlistCoursesResponse({required this.courses});

  factory GetWishlistCoursesResponse.fromJson(Map<String, dynamic> json) {
    return GetWishlistCoursesResponse(
      courses: (json as List<WishlistedCourse>? ?? [])
          .map(
            (item) => WishlistedCourse.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
