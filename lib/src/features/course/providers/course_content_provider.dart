import 'package:codemy_app/src/core/networks/exception.dart';
import 'package:codemy_app/src/features/course/models/dto/course_content.dart';
import 'package:codemy_app/src/features/course/providers/course_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final courseContentProvider = FutureProvider.autoDispose
    .family<CourseContent, String>((ref, courseId) async {
      final service = ref.read(courseServiceProvider);
      final response = await service.getCourseContent(courseId);

      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to load course content',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });
