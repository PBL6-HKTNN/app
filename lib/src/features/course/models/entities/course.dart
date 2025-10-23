import 'package:codemy_app/src/core/models/entity.dart';
import 'package:codemy_app/src/features/course/models/entities/module.dart';
import 'package:decimal/decimal.dart';

class Course extends EntityModel {
  final String title;
  final String description;
  final String thumbnail;
  final Duration duration;
  final Decimal price;
  final String language;
  final int numReviews;
  final Decimal averageRating;
  final List<Module> modules;
  Course({
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.duration,
    required this.price,
    required this.language,
    required this.numReviews,
    required this.averageRating,
    required this.modules,
    required super.id,
    required super.createdAt,
  });
}
