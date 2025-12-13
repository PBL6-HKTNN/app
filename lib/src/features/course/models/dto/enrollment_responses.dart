import 'package:codemy_app/src/features/course/models/entities/enrollment.dart';
import 'package:decimal/decimal.dart';

class JoinedCourse {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final Decimal price;
  final String instructorId;

  JoinedCourse(
    this.id,
    this.title,
    this.description,
    this.thumbnail,
    this.price,
    this.instructorId,
  );

  factory JoinedCourse.fromJson(Map<String, dynamic> json) {
    return JoinedCourse(
      json['id'] as String,
      json['title'] as String,
      json['description'] as String,
      json['thumbnail'] as String,
      Decimal.parse(json['price'].toString()),
      json['instructorId'] as String,
    );
  }
}

class EnrollmentCheckResponse {
  final bool success;
  final String? message;
  final Enrollment? enrollment;
  EnrollmentCheckResponse({
    required this.success,
    this.message,
    this.enrollment,
  });
  factory EnrollmentCheckResponse.fromJson(Map<String, dynamic> json) {
    return EnrollmentCheckResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      enrollment: json['enrollment'] != null
          ? Enrollment.fromJson(json['enrollment'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GetEnrolledCoursesResponse {
  final List<JoinedCourse> courses;

  GetEnrolledCoursesResponse({required this.courses});

  factory GetEnrolledCoursesResponse.fromJson(Map<String, dynamic> json) {
    return GetEnrolledCoursesResponse(
      courses: (json['courses'] as List<dynamic>? ?? [])
          .map((item) => JoinedCourse.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
