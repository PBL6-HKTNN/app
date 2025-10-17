class ApiRes<T> {
  final String status;
  final T? data;
  final dynamic error;
  final bool isSuccess;

  ApiRes({
    required this.status,
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory ApiRes.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiRes<T>(
      status: json['status'].toString(),
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      error: json['error'],
      isSuccess: json['isSuccess'] as bool,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T?)? toJsonT) {
    return {
      'status': status,
      'data': data != null && toJsonT != null ? toJsonT(data) : null,
      'error': error,
      'isSuccess': isSuccess,
    };
  }
}
