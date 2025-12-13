import 'package:codemy_app/src/core/conf/api_routes.dart';
import 'package:codemy_app/src/core/networks/api_client.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/course/models/dto/category_requests.dart';
import 'package:codemy_app/src/features/course/models/entities/category.dart';

class CategoryService {
  CategoryService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiRes<List<Category>>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiRoutes.CATEGORY.list);
      return ApiRes<List<Category>>.fromJson(
        response,
        (data) => (data as List<dynamic>)
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (error) {
      Logger.error('Failed to fetch categories', tag: 'CATEGORY', error: error);
      return ApiRes<List<Category>>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }

  Future<ApiRes<Category>> createCategory(CreateCategoryRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiRoutes.CATEGORY.create,
        body: request.toJson(),
      );
      return ApiRes<Category>.fromJson(
        response,
        (data) => Category.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      Logger.error('Failed to create category', tag: 'CATEGORY', error: error);
      return ApiRes<Category>(
        status: 500,
        data: null,
        error: error,
        isSuccess: false,
      );
    }
  }
}
