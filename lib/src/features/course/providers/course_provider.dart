import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dto/course_requests.dart';
import '../models/entities/course.dart';
import '../services/course_service.dart';

class CourseFilter {
  final String query;
  final String? category;

  const CourseFilter({this.query = '', this.category});

  CourseFilter copyWith({String? query, String? category}) {
    return CourseFilter(
      query: query ?? this.query,
      category: category ?? this.category,
    );
  }
}

class CourseListState {
  final List<Course> courses;
  final bool loading;
  final CourseFilter filter;
  final String? error;

  const CourseListState({
    this.courses = const <Course>[],
    this.loading = false,
    this.filter = const CourseFilter(),
    this.error,
  });

  CourseListState copyWith({
    List<Course>? courses,
    bool? loading,
    CourseFilter? filter,
    String? error,
    bool resetError = false,
  }) {
    return CourseListState(
      courses: courses ?? this.courses,
      loading: loading ?? this.loading,
      filter: filter ?? this.filter,
      error: resetError ? null : (error ?? this.error),
    );
  }
}

/// Service provider for course service
final courseServiceProvider = Provider((ref) => CourseService());

/// Provider for all courses
final allCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final service = ref.read(courseServiceProvider);
  final params = CourseQueryParams(pageSize: 20);
  final response = await service.getCourses(queryParams: params);

  if (response.isSuccess && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.toString() ?? 'Failed to load courses');
  }
});
