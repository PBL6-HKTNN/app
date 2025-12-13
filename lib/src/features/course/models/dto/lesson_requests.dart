import 'package:codemy_app/src/features/course/enums/lesson_type.dart';

class CreateLessonRequest {
  final String title;
  final String moduleId;
  final String contentUrl;
  final String duration;
  final LessonType lessonType;
  final int orderIndex;
  final bool isPreview;

  const CreateLessonRequest({
    required this.title,
    required this.moduleId,
    required this.contentUrl,
    required this.duration,
    required this.lessonType,
    required this.orderIndex,
    required this.isPreview,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'moduleId': moduleId,
      'contentUrl': contentUrl,
      'duration': duration,
      'lessonType': lessonType.index,
      'orderIndex': orderIndex,
      'isPreview': isPreview,
    };
  }
}

class UpdateLessonRequest extends CreateLessonRequest {
  const UpdateLessonRequest({
    required super.title,
    required super.moduleId,
    required super.contentUrl,
    required super.duration,
    required super.lessonType,
    required super.orderIndex,
    required super.isPreview,
  });
}
