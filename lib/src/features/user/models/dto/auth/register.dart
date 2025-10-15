class RegisterDto {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterDto({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  factory RegisterDto.fromJson(Map<String, dynamic> json) {
    return RegisterDto(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  @override
  String toString() {
    return 'RegisterDto(name: $name, email: $email, password: $password, confirmPassword: $confirmPassword)';
  }
}
