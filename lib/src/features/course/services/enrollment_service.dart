import 'package:codemy_app/src/core/conf/api_routes.dart';
import 'package:codemy_app/src/core/networks/api_client.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/course/models/dto/enrollment_requests.dart';
import 'package:codemy_app/src/features/course/models/dto/enrollment_responses.dart';
import 'package:codemy_app/src/features/course/models/entities/enrollment.dart';

class EnrollmentService {
  EnrollmentService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiRes<List<JoinedCourse>>> getMyCourses({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final url = '${ApiRoutes.ENROLLMENT.list}?page=$page&pageSize=$pageSize';
      final response = await _apiClient.get(url);
      return ApiRes<List<JoinedCourse>>.fromJson(
        response,
        (data) => (data as List<dynamic>)
            .map((item) => JoinedCourse.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (error) {
      Logger.error(
        'Failed to fetch enrolled courses',
        tag: 'ENROLLMENT',
        error: error,
      );
      return ApiRes<List<JoinedCourse>>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  //check if user enrolled course
  Future<ApiRes<EnrollmentCheckResponse>> getCourseEnrollment(
    String courseId,
  ) async {
    final url = ApiRoutes.ENROLLMENT.getCourse(courseId);
    try {
      final response = await _apiClient.post(url);
      return ApiRes<EnrollmentCheckResponse>.fromJson(
        response,
        (data) =>
            EnrollmentCheckResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error(
        'Failed to fetch enrollment details',
        tag: 'ENROLLMENT',
        error: error,
      );
      return ApiRes<EnrollmentCheckResponse>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Enrollment>> enrollCourse(String courseId) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.ENROLLMENT.enroll(courseId),
      );
      return ApiRes<Enrollment>.fromJson(
        response,
        (data) => Enrollment.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to enroll course', tag: 'ENROLLMENT', error: error);
      return ApiRes<Enrollment>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Enrollment>> updateEnrollment(
    UpdateEnrollmentRequest payload,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.ENROLLMENT.update(),
        body: payload.toJson(),
      );
      return ApiRes<Enrollment>.fromJson(
        response,
        (data) => Enrollment.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error(
        'Failed to update enrollment',
        tag: 'ENROLLMENT',
        error: error,
      );
      return ApiRes<Enrollment>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  /// Check if user is enrolled in a course
  Future<ApiRes<EnrollmentCheckResponse>> isEnrolled(String courseId) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.ENROLLMENT.isEnrolled(courseId),
      );
      return ApiRes<EnrollmentCheckResponse>.fromJson(
        response,
        (data) =>
            EnrollmentCheckResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error(
        'Failed to check enrollment',
        tag: 'ENROLLMENT',
        error: error,
      );
      return ApiRes<EnrollmentCheckResponse>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  /// Get completed lessons for an enrollment
  Future<ApiRes<List<String>>> getCompletedLessons(String enrollmentId) async {
    try {
      final response = await _apiClient.get(
        ApiRoutes.ENROLLMENT.completedLessons(enrollmentId),
      );
      return ApiRes<List<String>>.fromJson(
        response,
        (data) => (data as List<dynamic>).cast<String>(),
      );
    } catch (error) {
      Logger.error(
        'Failed to get completed lessons',
        tag: 'ENROLLMENT',
        error: error,
      );
      return ApiRes<List<String>>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  /// Update enrollment progress (mark lesson complete)
  Future<ApiRes<Enrollment>> updateEnrollmentProgress({
    required String courseId,
    required String lessonId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.ENROLLMENT.updateProgress(),
        body: {'courseId': courseId, 'lessonId': lessonId},
      );
      return ApiRes<Enrollment>.fromJson(
        response,
        (data) => Enrollment.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error(
        'Failed to update enrollment progress',
        tag: 'ENROLLMENT',
        error: error,
      );
      return ApiRes<Enrollment>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  /// Update current view (track which lesson user is currently viewing)
  Future<ApiRes<Enrollment>> updateCurrentView({
    required String courseId,
    required String currentLessonId,
    int? watchedSeconds,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.ENROLLMENT.updateCurrentView(),
        body: {
          'courseId': courseId,
          'currentLessonId': currentLessonId,
          if (watchedSeconds != null) 'watchedSeconds': watchedSeconds,
        },
      );
      return ApiRes<Enrollment>.fromJson(
        response,
        (data) => Enrollment.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error(
        'Failed to update current view',
        tag: 'ENROLLMENT',
        error: error,
      );
      return ApiRes<Enrollment>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  /// Alias for getCompletedLessons to match web service naming
  Future<ApiRes<List<String>>> getEnrolledCourseCompletedLessons(
    String enrollmentId,
  ) async {
    return getCompletedLessons(enrollmentId);
  }
}
