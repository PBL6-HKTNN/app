import 'package:codemy_app/src/core/models/entity.dart';
import 'package:codemy_app/src/features/course/enums/lesson_type.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/index.dart';

class Lesson extends EntityModel {
  final String title;
  final String moduleId;
  final String? contentUrl;
  final String duration;
  final LessonType lessonType;
  final int orderIndex;
  final bool isPreview;
  final Quiz? quiz;

  Lesson({
    required this.title,
    required this.moduleId,
    this.contentUrl,
    required this.duration,
    required this.lessonType,
    required this.orderIndex,
    required this.isPreview,
    required this.quiz,
    required super.id,
    required super.createdAt,
    super.createdBy,
    super.updatedAt,
    super.updatedBy,
    super.isDeleted,
    super.deletedAt,
    super.deletedBy,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final base = EntityModel.fromJson(json);
    return Lesson(
      id: base.id,
      createdAt: base.createdAt,
      createdBy: base.createdBy,
      updatedAt: base.updatedAt,
      updatedBy: base.updatedBy,
      isDeleted: base.isDeleted,
      deletedAt: base.deletedAt,
      deletedBy: base.deletedBy,
      title: json['title'] as String,
      moduleId: json['moduleId'] as String,
      contentUrl: _nullableString(json['contentUrl']),
      duration: json['duration'] as String,
      lessonType: lessonTypeFromValue(json['lessonType'] as int? ?? 0),
      orderIndex: json['orderIndex'] as int? ?? 0,
      isPreview: json['isPreview'] as bool? ?? false,
      quiz: json['quiz'] != null
          ? Quiz.fromJson(json['quiz'] as Map<String, dynamic>)
          : null,
    );
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      if (value.toLowerCase() == 'null') return null;
      return value;
    }
    return value.toString();
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'title': title,
      'moduleId': moduleId,
      'contentUrl': contentUrl,
      'duration': duration,
      'lessonType': lessonType.index,
      'orderIndex': orderIndex,
      'isPreview': isPreview,
      'quiz': quiz?.toJson(),
    };
  }
}
