import 'package:codemy_app/src/core/models/entity.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';

class Module extends EntityModel {
  final String title;
  final String durationMinutes;
  final int numberOfLessons;
  final int order;
  final String? courseId;
  final List<Lesson>? lessons;

  Module({
    required this.title,
    required this.durationMinutes,
    required this.numberOfLessons,
    required this.order,
    this.courseId,
    required this.lessons,
    required super.id,
    required super.createdAt,
    super.createdBy,
    super.updatedAt,
    super.updatedBy,
    super.isDeleted,
    super.deletedAt,
    super.deletedBy,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    final base = EntityModel.fromJson(json);
    return Module(
      id: base.id,
      createdAt: base.createdAt,
      createdBy: base.createdBy,
      updatedAt: base.updatedAt,
      updatedBy: base.updatedBy,
      isDeleted: base.isDeleted,
      deletedAt: base.deletedAt,
      deletedBy: base.deletedBy,
      title: json['title'] as String,
      durationMinutes: (json['duration'] as String?) ?? '',
      numberOfLessons: json['numberOfLessons'] as int? ?? 0,
      order: json['order'] as int? ?? 0,
      courseId: json['courseId'] as String?,
      lessons: (json['lessons'] as List<dynamic>?)
          ?.map((lesson) => Lesson.fromJson(lesson as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'title': title,
      'duration': durationMinutes,
      'numberOfLessons': numberOfLessons,
      'order': order,
      'courseId': courseId,
      'lessons': lessons?.map((lesson) => lesson.toJson()).toList(),
    };
  }
}
