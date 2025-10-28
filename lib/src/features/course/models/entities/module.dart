import 'package:codemy_app/src/core/models/entity.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';

class Module extends EntityModel {
  final String title;
  final Duration duration;
  final int numLessons;
  final int order;
  final List<Lesson> lessons;
  Module({
    required this.title,
    required this.duration,
    required this.numLessons,
    required this.order,
    required this.lessons,
    required super.id,
    required super.createdAt,
  });
}
