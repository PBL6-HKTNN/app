import 'package:codemy_app/src/core/models/entity.dart';
import 'package:codemy_app/src/features/payment/enums/order_status.dart';
import 'package:codemy_app/src/features/payment/enums/payment_method.dart';
import 'package:decimal/decimal.dart';

/// Payment entity mirroring web Payment type
class Payment extends EntityModel {
  final DateTime paymentDate;
  final PaymentMethod method;
  final String userId;
  final Decimal totalAmount;
  final OrderStatus orderStatus;

  const Payment({
    required super.id,
    required super.createdAt,
    super.createdBy,
    super.updatedAt,
    super.updatedBy,
    super.isDeleted,
    super.deletedAt,
    super.deletedBy,
    required this.paymentDate,
    required this.method,
    required this.userId,
    required this.totalAmount,
    required this.orderStatus,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    final base = EntityModel.fromJson(json);
    return Payment(
      id: base.id,
      createdAt: base.createdAt,
      createdBy: base.createdBy,
      updatedAt: base.updatedAt,
      updatedBy: base.updatedBy,
      isDeleted: base.isDeleted,
      deletedAt: base.deletedAt,
      deletedBy: base.deletedBy,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      method: PaymentMethod.fromValue(json['method'] as int? ?? 2),
      userId: json['userId'] as String,
      totalAmount: Decimal.parse((json['totalAmount'] ?? 0).toString()),
      orderStatus: OrderStatus.fromValue(json['orderStatus'] as int? ?? 0),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'paymentDate': paymentDate.toIso8601String(),
      'method': method.value,
      'userId': userId,
      'totalAmount': totalAmount.toDouble(),
      'orderStatus': orderStatus.value,
    };
  }

  Payment copyWith({
    String? id,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
    DateTime? paymentDate,
    PaymentMethod? method,
    String? userId,
    Decimal? totalAmount,
    OrderStatus? orderStatus,
  }) {
    return Payment(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      paymentDate: paymentDate ?? this.paymentDate,
      method: method ?? this.method,
      userId: userId ?? this.userId,
      totalAmount: totalAmount ?? this.totalAmount,
      orderStatus: orderStatus ?? this.orderStatus,
    );
  }
}
