import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entity/user.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

class UserService {
  Future<User> fetchCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return User(
      id: 'u001',
      name: 'Nguyễn Văn A',
      email: 'a@student.edu.vn',
      googleId: 'google_12345',
      role: 1,
      status: 1,
      profilePicture: 'https://i.pravatar.cc/150?img=5',
      bio: 'Sinh viên ngành CNTT - yêu thích Flutter.',
      emailVerified: true,
      totalCourses: 12,
      rating: 4.8,
      createdAt: DateTime.now(),
    );
  }

  void logout() {
   
  }
}
