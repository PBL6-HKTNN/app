import 'package:codemy_app/src/features/user/models/entity/user.dart';

class AuthRes {
  final String? token;
  final User? user;
  final bool? requiresEmailVerification;
  AuthRes({this.token, this.user, this.requiresEmailVerification});

  factory AuthRes.fromJson(Map<String, dynamic> json) {
    return AuthRes(
      token: json['token'] as String?,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      requiresEmailVerification: json['requiresEmailVerification'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user?.toJson(),
      'requiresEmailVerification': requiresEmailVerification,
    };
  }
}
