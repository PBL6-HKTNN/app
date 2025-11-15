import 'package:codemy_app/src/core/networks/exception.dart';
import 'package:codemy_app/src/features/course/models/entities/course.dart';
import 'package:codemy_app/src/features/course/services/enrollment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final enrollmentServiceProvider = Provider<EnrollmentService>((ref) {
  return EnrollmentService();
});

final enrolledCoursesProvider = FutureProvider.autoDispose<List<Course>>((
  ref,
) async {
  final service = ref.read(enrollmentServiceProvider);
  final response = await service.getMyCourses();
  if (!response.isSuccess || response.data == null) {
    throw ApiException(
      response.error?.toString() ?? 'Failed to load enrolled courses',
      statusCode: response.status,
      data: response.data,
    );
  }
  return response.data!;
});

final courseEnrollmentProvider = FutureProvider.autoDispose
    .family<Course, String>((ref, courseId) async {
      final service = ref.read(enrollmentServiceProvider);
      final response = await service.getCourseEnrollment(courseId);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to load course enrollment',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });

final enrollCourseProvider = FutureProvider.autoDispose.family<bool, String>((
  ref,
  courseId,
) async {
  final service = ref.read(enrollmentServiceProvider);
  final response = await service.enrollCourse(courseId);
  if (!response.isSuccess) {
    throw ApiException(
      response.error?.toString() ?? 'Failed to enroll course',
      statusCode: response.status,
      data: null,
    );
  }
  return true;
});

final updateEnrollmentProvider = FutureProvider.autoDispose
    .family<bool, Map<String, dynamic>>((ref, payload) async {
      final service = ref.read(enrollmentServiceProvider);
      final response = await service.updateEnrollment(payload);
      if (!response.isSuccess) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to update enrollment',
          statusCode: response.status,
          data: null,
        );
      }
      return true;
    });
