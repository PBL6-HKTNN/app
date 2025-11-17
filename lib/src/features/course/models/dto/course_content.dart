import 'package:codemy_app/src/features/course/models/entities/course.dart';
import 'package:codemy_app/src/features/course/models/entities/module.dart';

class CourseContent {
  final Course course;
  final List<Module> modules;

  CourseContent({required this.course, required this.modules});

  factory CourseContent.fromJson(Map<String, dynamic> json) {
    return CourseContent(
      course: Course.fromJson(json['course'] as Map<String, dynamic>),
      modules: (json['module'] as List<dynamic>? ?? [])
          .map((module) => Module.fromJson(module as Map<String, dynamic>))
          .toList(),
    );
  }
}
