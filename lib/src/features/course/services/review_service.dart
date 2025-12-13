import 'package:codemy_app/src/core/conf/api_routes.dart';
import 'package:codemy_app/src/core/networks/api_client.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/course/models/dto/review_requests.dart';
import 'package:codemy_app/src/features/course/models/dto/review_responses.dart';
import 'package:codemy_app/src/features/course/models/entities/review.dart';

class ReviewService {
  ReviewService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiRes<CreateReviewResponse>> createReview(
    CreateReviewRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.REVIEW.create,
        body: request.toJson(),
      );
      return ApiRes<CreateReviewResponse>.fromJson(
        response,
        (data) => CreateReviewResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to create review', tag: 'REVIEW', error: error);
      return ApiRes<CreateReviewResponse>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<List<Review>>> getReviewsByCourse(String courseId) async {
    try {
      final response = await _apiClient.get(
        ApiRoutes.REVIEW.byCourse(courseId),
      );
      return ApiRes<List<Review>>.fromJson(response, (data) {
        final result = GetReviewsByCourseResponse.fromJson(data);
        return result.reviews;
      });
    } catch (error) {
      Logger.error(
        'Failed to fetch reviews for course',
        tag: 'REVIEW',
        error: error,
      );
      return ApiRes<List<Review>>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<double>> getAverageRatingByCourse(String courseId) async {
    try {
      final response = await _apiClient.get(
        ApiRoutes.REVIEW.averageRating(courseId),
      );
      return ApiRes<double>.fromJson(response, (data) {
        final result = GetAverageRatingResponse.fromJson(data);
        return result.averageRating;
      });
    } catch (error) {
      Logger.error(
        'Failed to fetch average rating for course',
        tag: 'REVIEW',
        error: error,
      );
      return ApiRes<double>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }
}
