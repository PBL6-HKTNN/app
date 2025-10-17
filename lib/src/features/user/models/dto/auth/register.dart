class RegisterDto {
  final String email;
  final String password;

  RegisterDto({required this.email, required this.password});

  factory RegisterDto.fromJson(Map<String, dynamic> json) {
    return RegisterDto(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  @override
  String toString() {
    return 'RegisterDto(email: $email, password: $password)';
  }
}
