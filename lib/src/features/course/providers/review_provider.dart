import 'package:codemy_app/src/core/networks/exception.dart';
import 'package:codemy_app/src/features/course/models/dto/review_requests.dart';
import 'package:codemy_app/src/features/course/models/entities/review.dart';
import 'package:codemy_app/src/features/course/services/review_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});

final createReviewProvider = FutureProvider.autoDispose
    .family<bool, CreateReviewRequest>((ref, request) async {
      final service = ref.read(reviewServiceProvider);
      final response = await service.createReview(request);
      if (!response.isSuccess) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to create review',
          statusCode: response.status,
          data: null,
        );
      }
      return true;
    });

final reviewsByCourseProvider = FutureProvider.autoDispose
    .family<List<Review>, String>((ref, courseId) async {
      final service = ref.read(reviewServiceProvider);
      final response = await service.getReviewsByCourse(courseId);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to load reviews',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });

final averageRatingProvider = FutureProvider.autoDispose.family<double, String>(
  (ref, courseId) async {
    final service = ref.read(reviewServiceProvider);
    final response = await service.getAverageRatingByCourse(courseId);
    if (!response.isSuccess || response.data == null) {
      throw ApiException(
        response.error?.toString() ?? 'Failed to load average rating',
        statusCode: response.status,
        data: response.data,
      );
    }
    return response.data!;
  },
);
