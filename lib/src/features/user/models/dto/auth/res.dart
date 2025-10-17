import 'package:codemy_app/src/features/user/models/entity/user.dart';

class AuthRes {
  final String token;
  final User? user;

  AuthRes({required this.token, required this.user});

  factory AuthRes.fromJson(Map<String, dynamic> json) {
    return AuthRes(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user?.toJson()};
  }
}
