class VerifyDto {
  final String email;
  final String code;

  VerifyDto({required this.email, required this.code});

  factory VerifyDto.fromJson(Map<String, dynamic> json) {
    return VerifyDto(
      email: json['email'] as String,
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'code': code};
  }

  @override
  String toString() {
    return 'VerifyDto(email: $email, code: $code)';
  }
}
