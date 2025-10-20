import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

//Thay bằng API khi backend sẵn sàng.
final userProvider = StateProvider<UserModel>((ref) {
  return UserModel(
    id: 'u001',
    name: 'Nguyễn Văn A',
    email: 'nguyenvana@gmail.com',
    role: 'student',
    avatarUrl: null,
  );
});
