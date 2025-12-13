import 'package:codemy_app/src/core/models/entity.dart';

class WishlistItem extends EntityModel {
  final String courseId;
  final String userId;

  WishlistItem({
    required this.courseId,
    required this.userId,
    required super.id,
    required super.createdAt,
    super.createdBy,
    super.updatedAt,
    super.updatedBy,
    super.isDeleted,
    super.deletedAt,
    super.deletedBy,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    final base = EntityModel.fromJson(json);
    return WishlistItem(
      id: base.id,
      createdAt: base.createdAt,
      createdBy: base.createdBy,
      updatedAt: base.updatedAt,
      updatedBy: base.updatedBy,
      isDeleted: base.isDeleted,
      deletedAt: base.deletedAt,
      deletedBy: base.deletedBy,
      courseId: json['courseId'] as String,
      userId: json['userId'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {...baseJson, 'courseId': courseId, 'userId': userId};
  }
}
