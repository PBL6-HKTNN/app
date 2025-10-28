import 'package:codemy_app/src/core/models/entity.dart';
import 'package:codemy_app/src/features/course/enums/lesson_type.dart';

class Lesson extends EntityModel {
  final String title;
  final String duration;
  final LessonType lessonType; // e.g., 'markdown', 'video', 'quiz'
  final int orderIndex;
  final bool isPreviewable;
  Lesson({
    required this.title,
    required this.duration,
    required this.lessonType,
    required this.orderIndex,
    required this.isPreviewable,
    required super.id,
    required super.createdAt,
  });
}
