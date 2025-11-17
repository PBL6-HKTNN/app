import 'package:codemy_app/src/core/conf/api_routes.dart';
import 'package:codemy_app/src/core/networks/api_client.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/course/models/dto/module_requests.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/features/course/models/entities/module.dart';

class ModuleService {
  ModuleService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiRes<List<Module>>> getModules() async {
    try {
      final response = await _apiClient.get(ApiRoutes.MODULE.list);
      return ApiRes<List<Module>>.fromJson(
        response,
        (data) => (data as List<dynamic>)
            .map((item) => Module.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (error) {
      Logger.error('Failed to fetch modules', tag: 'MODULE', error: error);
      return ApiRes<List<Module>>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Module>> createModule(CreateModuleRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.MODULE.create,
        body: request.toJson(),
      );
      return ApiRes<Module>.fromJson(
        response,
        (data) => Module.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to create module', tag: 'MODULE', error: error);
      return ApiRes<Module>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<List<Lesson>>> getLessonsByModule(String moduleId) async {
    final url = ApiRoutes.MODULE.lessons(moduleId);
    try {
      final response = await _apiClient.get(url);
      return ApiRes<List<Lesson>>.fromJson(
        response,
        (data) => (data as List<dynamic>)
            .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (error) {
      Logger.error(
        'Failed to fetch lessons by module',
        tag: 'MODULE',
        error: error,
      );
      return ApiRes<List<Lesson>>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Module>> getModuleById(String moduleId) async {
    final url = ApiRoutes.MODULE.byId(moduleId);
    try {
      final response = await _apiClient.get(url);
      return ApiRes<Module>.fromJson(
        response,
        (data) => Module.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error(
        'Failed to fetch module detail',
        tag: 'MODULE',
        error: error,
      );
      return ApiRes<Module>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Module>> updateModule(
    String moduleId,
    UpdateModuleRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.MODULE.update(moduleId),
        body: request.toJson(),
      );
      return ApiRes<Module>.fromJson(
        response,
        (data) => Module.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to update module', tag: 'MODULE', error: error);
      return ApiRes<Module>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<String>> deleteModule(String moduleId) async {
    try {
      final response = await _apiClient.delete(
        ApiRoutes.MODULE.delete(moduleId),
      );
      return ApiRes<String>.fromJson(
        response,
        (data) => data?.toString() ?? '',
      );
    } catch (error) {
      Logger.error('Failed to delete module', tag: 'MODULE', error: error);
      return ApiRes<String>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }
}
