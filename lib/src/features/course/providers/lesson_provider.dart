import 'package:codemy_app/src/core/networks/exception.dart';
import 'package:codemy_app/src/features/course/models/dto/lesson_requests.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/features/course/services/lesson_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lessonServiceProvider = Provider<LessonService>((ref) {
  return LessonService();
});

final lessonsProvider = FutureProvider.autoDispose<List<Lesson>>((ref) async {
  final service = ref.read(lessonServiceProvider);
  final response = await service.getLessons();
  if (!response.isSuccess || response.data == null) {
    throw ApiException(
      response.error?.toString() ?? 'Failed to load lessons',
      statusCode: response.status,
      data: response.data,
    );
  }
  return response.data!;
});

final lessonDetailProvider = FutureProvider.autoDispose.family<Lesson, String>((
  ref,
  lessonId,
) async {
  final service = ref.read(lessonServiceProvider);
  final response = await service.getLessonById(lessonId);
  if (!response.isSuccess || response.data == null) {
    throw ApiException(
      response.error?.toString() ?? 'Failed to load lesson detail',
      statusCode: response.status,
      data: response.data,
    );
  }
  return response.data!;
});

final createLessonProvider = FutureProvider.autoDispose
    .family<Lesson, CreateLessonRequest>((ref, request) async {
      final service = ref.read(lessonServiceProvider);
      final response = await service.createLesson(request);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to create lesson',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });

final updateLessonProvider = FutureProvider.autoDispose
    .family<Lesson, (String, UpdateLessonRequest)>((ref, params) async {
      final service = ref.read(lessonServiceProvider);
      final response = await service.updateLesson(params.$1, params.$2);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to update lesson',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });

final deleteLessonProvider = FutureProvider.autoDispose.family<String, String>((
  ref,
  lessonId,
) async {
  final service = ref.read(lessonServiceProvider);
  final response = await service.deleteLesson(lessonId);
  if (!response.isSuccess || response.data == null) {
    throw ApiException(
      response.error?.toString() ?? 'Failed to delete lesson',
      statusCode: response.status,
      data: response.data,
    );
  }
  return response.data!;
});
