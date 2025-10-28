// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import '../models/entity/user.dart';
// import '../services/user_service.dart';

// final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>((ref) {
//   final service = ref.watch(userServiceProvider);
//   return UserNotifier(service);
// });

// class UserNotifier extends StateNotifier<AsyncValue<User?>> {
//   final UserService _service;

//   UserNotifier(this._service) : super(const AsyncValue.loading()) {
//     loadUser();
//   }

//   Future<void> loadUser() async {
//     try {
//       final user = await _service.fetchCurrentUser();
//       state = AsyncValue.data(user);
//     } catch (e, st) {
//       state = AsyncValue.error(e, st);
//     }
//   }

//   void logout() {
//     _service.logout();
//     state = const AsyncValue.data(null);
//   }
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/entity/user.dart';
import 'auth_providers.dart';

final userProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).user;
});
