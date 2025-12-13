import 'package:codemy_app/src/core/models/entity.dart';
import 'package:codemy_app/src/features/course/enums/course_level.dart';
import 'package:codemy_app/src/features/course/enums/course_status.dart';
import 'package:codemy_app/src/features/course/models/entities/module.dart';
import 'package:decimal/decimal.dart';

class Course extends EntityModel {
  final String instructorId;
  final String categoryId;
  final String title;
  final String? description;
  final String? thumbnail;
  final CourseStatus status;
  final String duration;
  final Decimal price;
  final CourseLevel level;
  final String language;
  final int numberOfModules;
  final int numberOfReviews;
  final double averageRating;
  final List<Module>? modules;
  final bool? isEnrolled;
  final bool? isRequestedBanned;

  Course({
    required this.instructorId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.status,
    required this.duration,
    required this.price,
    required this.level,
    required this.language,
    required this.numberOfModules,
    required this.numberOfReviews,
    required this.averageRating,
    required this.modules,
    required super.id,
    required super.createdAt,
    this.isEnrolled,
    this.isRequestedBanned,
    super.createdBy,
    super.updatedAt,
    super.updatedBy,
    super.isDeleted,
    super.deletedAt,
    super.deletedBy,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final base = EntityModel.fromJson(json);
    return Course(
      id: base.id,
      createdAt: base.createdAt,
      createdBy: base.createdBy,
      updatedAt: base.updatedAt,
      updatedBy: base.updatedBy,
      isDeleted: base.isDeleted,
      deletedAt: base.deletedAt,
      deletedBy: base.deletedBy,
      instructorId: json['instructorId'] as String,
      categoryId: json['categoryId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      thumbnail: json['thumbnail'] as String?,
      status: courseStatusFromValue(json['status'] as int? ?? 0),
      duration: json['duration'] as String,
      price: Decimal.parse((json['price']).toString()),
      level: courseLevelFromValue(json['level'] as int? ?? 0),
      language: json['language'] as String,
      numberOfModules: json['numberOfModules'] as int? ?? 0,
      numberOfReviews: json['numberOfReviews'] as int? ?? 0,
      averageRating: double.tryParse((json['averageRating']).toString()) ?? 0.0,
      modules: (json['modules'] as List<dynamic>?)
          ?.map((module) => Module.fromJson(module as Map<String, dynamic>))
          .toList(),
      isEnrolled: json['isEnrolled'] as bool?,
      isRequestedBanned: json['isRequestedBanned'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'instructorId': instructorId,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'status': status.index,
      'duration': duration,
      'price': price.toString(),
      'level': level.index,
      'language': language,
      'numberOfModules': numberOfModules,
      'numberOfReviews': numberOfReviews,
      'averageRating': averageRating,
      'modules': modules?.map((module) => module.toJson()).toList(),
      'isEnrolled': isEnrolled,
      'isRequestedBanned': isRequestedBanned,
    };
  }
}
