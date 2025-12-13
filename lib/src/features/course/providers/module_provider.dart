import 'package:codemy_app/src/core/networks/exception.dart';
import 'package:codemy_app/src/features/course/models/dto/module_requests.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/features/course/models/entities/module.dart';
import 'package:codemy_app/src/features/course/services/module_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final moduleServiceProvider = Provider<ModuleService>((ref) {
  return ModuleService();
});

final modulesProvider = FutureProvider.autoDispose<List<Module>>((ref) async {
  final service = ref.read(moduleServiceProvider);
  final response = await service.getModules();
  if (!response.isSuccess || response.data == null) {
    throw ApiException(
      response.error?.toString() ?? 'Failed to load modules',
      statusCode: response.status,
      data: response.data,
    );
  }
  return response.data!;
});

final moduleDetailProvider = FutureProvider.autoDispose.family<Module, String>((
  ref,
  moduleId,
) async {
  final service = ref.read(moduleServiceProvider);
  final response = await service.getModuleById(moduleId);
  if (!response.isSuccess || response.data == null) {
    throw ApiException(
      response.error?.toString() ?? 'Failed to load module detail',
      statusCode: response.status,
      data: response.data,
    );
  }
  return response.data!;
});

final moduleLessonsProvider = FutureProvider.autoDispose
    .family<List<Lesson>, String>((ref, moduleId) async {
      final service = ref.read(moduleServiceProvider);
      final response = await service.getLessonsByModule(moduleId);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to load module lessons',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });

final createModuleProvider = FutureProvider.autoDispose
    .family<Module, CreateModuleRequest>((ref, request) async {
      final service = ref.read(moduleServiceProvider);
      final response = await service.createModule(request);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to create module',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });

final updateModuleProvider = FutureProvider.autoDispose
    .family<Module, (String, UpdateModuleRequest)>((ref, params) async {
      final service = ref.read(moduleServiceProvider);
      final response = await service.updateModule(params.$1, params.$2);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to update module',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });

final deleteModuleProvider = FutureProvider.autoDispose.family<String, String>((
  ref,
  moduleId,
) async {
  final service = ref.read(moduleServiceProvider);
  final response = await service.deleteModule(moduleId);
  if (!response.isSuccess || response.data == null) {
    throw ApiException(
      response.error?.toString() ?? 'Failed to delete module',
      statusCode: response.status,
      data: response.data,
    );
  }
  return response.data!;
});
