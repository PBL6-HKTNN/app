import 'dart:io';

class ChangeAvatarRequest {
  final File avatar;

  ChangeAvatarRequest({required this.avatar});

  Map<String, dynamic> toJson() {
    return {'avatar': avatar.path};
  }
}
