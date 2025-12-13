import 'package:codemy_app/src/features/course/models/entities/review.dart';

class CreateReviewResponse {
  final bool isSuccess;
  final String? message;

  CreateReviewResponse({required this.isSuccess, this.message});

  factory CreateReviewResponse.fromJson(Map<String, dynamic> json) {
    return CreateReviewResponse(
      isSuccess: json['isSuccess'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }

  @override
  String toString() =>
      'CreateReviewResponse(isSuccess: $isSuccess, message: $message)';
}

class GetReviewsByCourseResponse {
  final List<Review> reviews;

  GetReviewsByCourseResponse({required this.reviews});

  factory GetReviewsByCourseResponse.fromJson(dynamic json) {
    // Handle both direct list response and wrapped response
    if (json is List) {
      return GetReviewsByCourseResponse(
        reviews: json
            .where((item) => item is Map<String, dynamic>)
            .map((item) => Review.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } else if (json is Map<String, dynamic>) {
      final result = json['result'];
      if (result is List) {
        return GetReviewsByCourseResponse(
          reviews: result
              .where((item) => item is Map<String, dynamic>)
              .map((item) => Review.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      }
    }
    return GetReviewsByCourseResponse(reviews: []);
  }

  @override
  String toString() => 'GetReviewsByCourseResponse(reviews: $reviews)';
}

class GetAverageRatingResponse {
  final String courseId;
  final double averageRating;

  GetAverageRatingResponse({
    required this.courseId,
    required this.averageRating,
  });

  factory GetAverageRatingResponse.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final result = json['result'];
      if (result is num) {
        return GetAverageRatingResponse(
          courseId: json['courseId'] as String? ?? '',
          averageRating: result.toDouble(),
        );
      } else if (result == null) {
        // Handle null result (no reviews yet)
        return GetAverageRatingResponse(
          courseId: json['courseId'] as String? ?? '',
          averageRating: 0.0,
        );
      }
    }
    // Default fallback
    return GetAverageRatingResponse(courseId: '', averageRating: 0.0);
  }

  @override
  String toString() =>
      'GetAverageRatingResponse(courseId: $courseId, averageRating: $averageRating)';
}
