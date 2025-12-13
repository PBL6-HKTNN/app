import 'package:codemy_app/src/core/networks/exception.dart';
import 'package:codemy_app/src/features/course/models/dto/category_requests.dart';
import 'package:codemy_app/src/features/course/models/entities/category.dart';
import 'package:codemy_app/src/features/course/services/category_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

final categoriesProvider = FutureProvider.autoDispose<List<Category>>((
  ref,
) async {
  final service = ref.read(categoryServiceProvider);
  final response = await service.getCategories();
  if (!response.isSuccess || response.data == null) {
    throw ApiException(
      response.error?.toString() ?? 'Failed to load categories',
      statusCode: response.status,
      data: response.data,
    );
  }
  return response.data!;
});

final createCategoryProvider = FutureProvider.autoDispose
    .family<Category, CreateCategoryRequest>((ref, request) async {
      final service = ref.read(categoryServiceProvider);
      final response = await service.createCategory(request);
      if (!response.isSuccess || response.data == null) {
        throw ApiException(
          response.error?.toString() ?? 'Failed to create category',
          statusCode: response.status,
          data: response.data,
        );
      }
      return response.data!;
    });
