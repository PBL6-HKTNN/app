class VerifyDto {
  final String email;
  final String token;

  VerifyDto({required this.email, required this.token});

  factory VerifyDto.fromJson(Map<String, dynamic> json) {
    return VerifyDto(
      email: json['email'] as String,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'token': token};
  }

  @override
  String toString() {
    return 'VerifyDto(email: $email, token: $token)';
  }
}
