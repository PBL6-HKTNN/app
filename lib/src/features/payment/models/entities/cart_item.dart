import 'package:codemy_app/src/core/models/entity.dart';
import 'package:decimal/decimal.dart';

/// Cart item entity mirroring web CartItem type
class CartItem extends EntityModel {
  final String? userId;
  final String courseId;
  final Decimal price;
  final String? thumbnailUrl;
  final String courseTitle;
  final String? description;

  const CartItem({
    required super.id,
    required super.createdAt,
    super.createdBy,
    super.updatedAt,
    super.updatedBy,
    super.isDeleted,
    super.deletedAt,
    super.deletedBy,
    this.userId,
    required this.courseId,
    required this.price,
    this.thumbnailUrl,
    required this.courseTitle,
    this.description,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final base = EntityModel.fromJson(json);
    return CartItem(
      id: base.id,
      createdAt: base.createdAt,
      createdBy: base.createdBy,
      updatedAt: base.updatedAt,
      updatedBy: base.updatedBy,
      isDeleted: base.isDeleted,
      deletedAt: base.deletedAt,
      deletedBy: base.deletedBy,
      userId: json['userId'] as String?,
      courseId: json['courseId'] as String,
      price: Decimal.parse((json['price'] ?? 0).toString()),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      courseTitle: json['courseTitle'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'userId': userId,
      'courseId': courseId,
      'price': price.toDouble(),
      'thumbnailUrl': thumbnailUrl,
      'courseTitle': courseTitle,
      'description': description,
    };
  }

  CartItem copyWith({
    String? id,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
    String? userId,
    String? courseId,
    Decimal? price,
    String? thumbnailUrl,
    String? courseTitle,
    String? description,
  }) {
    return CartItem(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      price: price ?? this.price,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      courseTitle: courseTitle ?? this.courseTitle,
      description: description ?? this.description,
    );
  }
}
