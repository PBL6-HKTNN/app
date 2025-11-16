import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/conf/api_routes.dart';
import '../../../core/networks/api_client.dart';
import '../../../core/networks/models/api_res.dart';
import '../../../core/utils/persistence.dart';
import '../models/dto/user/change_avatar_request.dart';
import '../models/dto/user/change_info_request.dart';
import '../models/dto/user/change_password_request.dart';
import '../models/entity/user.dart';
import '../providers/auth_providers.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final userServiceProvider = Provider<UserService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final authState = ref.read(authStateProvider);
  return UserService(apiClient, authState.user?.id ?? '');
});

class UserService {
  final ApiClient _apiClient;
  final String _userId;

  UserService(this._apiClient, this._userId);

  Future<ApiRes<User>> changeInfo(ChangeInfoRequest request) async {
    try {
      final response = await _apiClient.put(
        ApiRoutes.USER.updateProfile(_userId),
        body: request.toJson(),
      );

      final user = User.fromJson(response);
      return ApiRes(status: 200, data: user, isSuccess: true);
    } catch (e) {
      return ApiRes(status: 500, error: e.toString(), isSuccess: false);
    }
  }

  Future<ApiRes<String>> changeAvatar(ChangeAvatarRequest request) async {
    try {
      await _uploadAvatar(request.avatar);
      return ApiRes(
        status: 200,
        data: 'Avatar updated successfully',
        isSuccess: true,
      );
    } catch (e) {
      return ApiRes(status: 500, error: e.toString(), isSuccess: false);
    }
  }

  Future<void> _uploadAvatar(File avatarFile) async {
    final uri = Uri.parse(ApiRoutes.USER.changeAvatar(_userId));
    final request = http.MultipartRequest('PUT', uri);

    // Add the file
    request.files.add(
      await http.MultipartFile.fromPath(
        'avatar',
        avatarFile.path,
        filename: 'avatar.jpg',
      ),
    );

    // Add authorization header if available
    final token = await _getAuthToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await request.send();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to upload avatar: ${response.statusCode}');
    }
  }

  Future<String?> _getAuthToken() async {
    try {
      return await PersistenceUtils.readSecureString('auth_token');
    } catch (e) {
      return null;
    }
  }

  Future<ApiRes<String>> changePassword(ChangePasswordrequest request) async {
    try {
      await _apiClient.put(
        ApiRoutes.USER.changePassword(_userId),
        body: request.toJson(),
      );

      return ApiRes(
        status: 200,
        data: 'Password changed successfully',
        isSuccess: true,
      );
    } catch (e) {
      return ApiRes(status: 500, error: e.toString(), isSuccess: false);
    }
  }
}
