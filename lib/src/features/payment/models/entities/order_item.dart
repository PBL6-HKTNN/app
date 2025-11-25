import 'package:decimal/decimal.dart';

/// Order item entity mirroring web OrderItem type
class OrderItem {
  final String instructorId;
  final String? description;
  final Decimal price;
  final String courseId;
  final String courseTitle;
  final String? thumbnailUrl;

  const OrderItem({
    required this.instructorId,
    this.description,
    required this.price,
    required this.courseId,
    required this.courseTitle,
    this.thumbnailUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      instructorId: json['instructorId'] as String? ?? '',
      description: json['description'] as String?,
      price: Decimal.parse((json['price'] ?? 0).toString()),
      courseId: json['courseId'] as String,
      courseTitle: json['courseTitle'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instructorId': instructorId,
      'description': description,
      'price': price.toDouble(),
      'courseId': courseId,
      'courseTitle': courseTitle,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  OrderItem copyWith({
    String? instructorId,
    String? description,
    Decimal? price,
    String? courseId,
    String? courseTitle,
    String? thumbnailUrl,
  }) {
    return OrderItem(
      instructorId: instructorId ?? this.instructorId,
      description: description ?? this.description,
      price: price ?? this.price,
      courseId: courseId ?? this.courseId,
      courseTitle: courseTitle ?? this.courseTitle,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}
