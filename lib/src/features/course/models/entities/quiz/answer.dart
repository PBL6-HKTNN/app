import 'package:codemy_app/src/core/models/entity.dart';

class Answer extends EntityModel {
  final String text;
  final bool isCorrect;

  Answer({
    required this.text,
    required this.isCorrect,
    required super.id,
    required super.createdAt,
  });
}
