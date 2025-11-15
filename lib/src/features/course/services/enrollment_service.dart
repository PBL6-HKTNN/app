import 'package:codemy_app/src/core/conf/api_routes.dart';
import 'package:codemy_app/src/core/networks/api_client.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/course/models/entities/course.dart';

class EnrollmentService {
  EnrollmentService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiRes<List<Course>>> getMyCourses() async {
    try {
      final response = await _apiClient.get(ApiRoutes.ENROLLMENT.list);
      return ApiRes<List<Course>>.fromJson(
        response,
        (data) => (data as List<dynamic>)
            .map((item) => Course.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (error) {
      Logger.error(
        'Failed to fetch enrolled courses',
        tag: 'ENROLLMENT',
        error: error,
      );
      return ApiRes<List<Course>>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Course>> getCourseEnrollment(String courseId) async {
    final url = ApiRoutes.ENROLLMENT.getCourse(courseId);
    try {
      final response = await _apiClient.get(url);
      return ApiRes<Course>.fromJson(
        response,
        (data) => Course.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error(
        'Failed to fetch enrollment details',
        tag: 'ENROLLMENT',
        error: error,
      );
      return ApiRes<Course>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<void>> enrollCourse(String courseId) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.ENROLLMENT.enroll(courseId),
      );
      return ApiRes<void>.fromJson(response, (_) => null);
    } catch (error) {
      Logger.error('Failed to enroll course', tag: 'ENROLLMENT', error: error);
      return ApiRes<void>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<void>> updateEnrollment(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.ENROLLMENT.update(),
        body: payload,
      );
      return ApiRes<void>.fromJson(response, (_) => null);
    } catch (error) {
      Logger.error(
        'Failed to update enrollment',
        tag: 'ENROLLMENT',
        error: error,
      );
      return ApiRes<void>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }
}
