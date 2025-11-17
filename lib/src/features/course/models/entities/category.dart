import 'package:codemy_app/src/core/models/entity.dart';

class Category extends EntityModel {
  final String name;
  final String? description;

  Category({
    required this.name,
    this.description,
    required super.id,
    required super.createdAt,
    super.createdBy,
    super.updatedAt,
    super.updatedBy,
    super.isDeleted,
    super.deletedAt,
    super.deletedBy,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final base = EntityModel.fromJson(json);
    return Category(
      id: base.id,
      createdAt: base.createdAt,
      createdBy: base.createdBy,
      updatedAt: base.updatedAt,
      updatedBy: base.updatedBy,
      isDeleted: base.isDeleted,
      deletedAt: base.deletedAt,
      deletedBy: base.deletedBy,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {...baseJson, 'name': name, 'description': description};
  }
}
