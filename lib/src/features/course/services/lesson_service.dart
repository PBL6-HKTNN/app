import 'package:codemy_app/src/core/conf/api_routes.dart';
import 'package:codemy_app/src/core/networks/api_client.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/course/models/dto/lesson_requests.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';

class LessonService {
  LessonService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiRes<List<Lesson>>> getLessons() async {
    try {
      final response = await _apiClient.get(ApiRoutes.LESSON.list);
      return ApiRes<List<Lesson>>.fromJson(
        response,
        (data) => (data as List<dynamic>)
            .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (error) {
      Logger.error('Failed to fetch lessons', tag: 'LESSON', error: error);
      return ApiRes<List<Lesson>>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Lesson>> createLesson(CreateLessonRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.LESSON.create,
        body: request.toJson(),
      );
      return ApiRes<Lesson>.fromJson(
        response,
        (data) => Lesson.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to create lesson', tag: 'LESSON', error: error);
      return ApiRes<Lesson>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Lesson>> getLessonById(String lessonId) async {
    final url = ApiRoutes.LESSON.byId(lessonId);
    try {
      final response = await _apiClient.get(url);
      return ApiRes<Lesson>.fromJson(
        response,
        (data) => Lesson.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error(
        'Failed to fetch lesson detail',
        tag: 'LESSON',
        error: error,
      );
      return ApiRes<Lesson>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Lesson>> updateLesson(
    String lessonId,
    UpdateLessonRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.LESSON.update(lessonId),
        body: request.toJson(),
      );
      return ApiRes<Lesson>.fromJson(
        response,
        (data) => Lesson.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to update lesson', tag: 'LESSON', error: error);
      return ApiRes<Lesson>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<String>> deleteLesson(String lessonId) async {
    try {
      final response = await _apiClient.delete(
        ApiRoutes.LESSON.delete(lessonId),
      );
      return ApiRes<String>.fromJson(
        response,
        (data) => data?.toString() ?? '',
      );
    } catch (error) {
      Logger.error('Failed to delete lesson', tag: 'LESSON', error: error);
      return ApiRes<String>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }
}
