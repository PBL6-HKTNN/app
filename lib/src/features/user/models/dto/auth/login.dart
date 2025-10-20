class LoginDto {
  final String email;
  final String password;

  LoginDto({required this.email, required this.password});

  factory LoginDto.fromJson(Map<String, dynamic> json) {
    return LoginDto(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  @override
  String toString() {
    return 'LoginDto(email: $email, password: $password)';
  }
}
