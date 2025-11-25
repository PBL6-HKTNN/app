/// Order status enum mirroring web OrderStatus
enum OrderStatus {
  pending(0),
  completed(1),
  failed(2),
  cancelled(3);

  const OrderStatus(this.value);
  final int value;

  static OrderStatus fromValue(int value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.failed:
        return 'Failed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isPending => this == OrderStatus.pending;
  bool get isCompleted => this == OrderStatus.completed;
  bool get isFailed => this == OrderStatus.failed;
  bool get isCancelled => this == OrderStatus.cancelled;
}
