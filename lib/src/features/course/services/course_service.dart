import 'package:codemy_app/src/core/conf/api_routes.dart';
import 'package:codemy_app/src/core/networks/api_client.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/course/models/dto/course_content.dart';
import 'package:codemy_app/src/features/course/models/dto/course_requests.dart';
import 'package:codemy_app/src/features/course/models/entities/course.dart';
import 'package:codemy_app/src/features/course/models/entities/module.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

enum CourseListType { all, joined, wishlist }

class CourseService {
  CourseService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiRes<List<Course>>> getCourses({
    CourseQueryParams? queryParams,
  }) async {
    final params = queryParams?.toQueryParameters() ?? {};
    final url = _withQuery(ApiRoutes.COURSE.list, params);

    try {
      final response = await _apiClient.get(url);
      return ApiRes<List<Course>>.fromJson(
        response,
        (data) => (data as List<dynamic>)
            .map((item) => Course.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (error) {
      Logger.error('Failed to fetch courses', tag: 'COURSE', error: error);
      return ApiRes<List<Course>>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Course>> getCourseById(String courseId) async {
    final url = ApiRoutes.COURSE.byId(courseId);
    try {
      final response = await _apiClient.get(url);
      return ApiRes<Course>.fromJson(
        response,
        (data) => Course.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error(
        'Failed to fetch course detail',
        tag: 'COURSE',
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

  Future<ApiRes<CourseContent>> getCourseContent(String courseId) async {
    final url = ApiRoutes.COURSE.content(courseId);
    try {
      final response = await _apiClient.get(url);
      return ApiRes<CourseContent>.fromJson(
        response,
        (data) => CourseContent.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error(
        'Failed to fetch course content',
        tag: 'COURSE',
        error: error,
      );
      return ApiRes<CourseContent>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<List<Module>>> getModulesByCourse(String courseId) async {
    final url = ApiRoutes.COURSE.modules(courseId);
    try {
      final response = await _apiClient.get(url);
      return ApiRes<List<Module>>.fromJson(
        response,
        (data) => (data as List<dynamic>)
            .map((item) => Module.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (error) {
      Logger.error(
        'Failed to fetch course modules',
        tag: 'COURSE',
        error: error,
      );
      return ApiRes<List<Module>>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Course>> createCourse(CreateCourseRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.COURSE.create,
        body: request.toJson(),
      );
      return ApiRes<Course>.fromJson(
        response,
        (data) => Course.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to create course', tag: 'COURSE', error: error);
      return ApiRes<Course>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Course>> updateCourse(
    String courseId,
    UpdateCourseRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.COURSE.update(courseId),
        body: request.toJson(),
      );
      return ApiRes<Course>.fromJson(
        response,
        (data) => Course.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to update course', tag: 'COURSE', error: error);
      return ApiRes<Course>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<String>> deleteCourse(String courseId) async {
    try {
      final response = await _apiClient.delete(
        ApiRoutes.COURSE.delete(courseId),
      );
      return ApiRes<String>.fromJson(
        response,
        (data) => data?.toString() ?? '',
      );
    } catch (error) {
      Logger.error('Failed to delete course', tag: 'COURSE', error: error);
      return ApiRes<String>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  String _withQuery(String url, Map<String, String> params) {
    if (params.isEmpty) {
      return url;
    }
    final query = params.entries
        .map((entry) => '${entry.key}=${Uri.encodeQueryComponent(entry.value)}')
        .join('&');
    return '$url?$query';
  }
}
