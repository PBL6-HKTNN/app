import 'package:codemy_app/src/features/course/enums/course_level.dart';
import 'package:decimal/decimal.dart';

class CourseQueryParams {
  final String? categoryId;
  final CourseLevel? level;
  final String? language;
  final String? sortBy;
  final int? page;
  final int? pageSize;

  const CourseQueryParams({
    this.categoryId,
    this.level,
    this.language,
    this.sortBy,
    this.page,
    this.pageSize,
  });

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};
    if (categoryId != null && categoryId!.isNotEmpty) {
      params['CategoryId'] = categoryId!;
    }
    if (level != null) {
      params['Level'] = level!.index.toString();
    }
    if (language != null && language!.isNotEmpty) {
      params['Language'] = language!;
    }
    if (sortBy != null && sortBy!.isNotEmpty) {
      params['SortBy'] = sortBy!;
    }
    if (page != null && page! > 0) {
      params['Page'] = page!.toString();
    }
    if (pageSize != null && pageSize! > 0) {
      params['PageSize'] = pageSize!.toString();
    }
    return params;
  }

  CourseQueryParams copyWith({
    String? categoryId,
    CourseLevel? level,
    String? language,
    String? sortBy,
    int? page,
    int? pageSize,
  }) {
    return CourseQueryParams(
      categoryId: categoryId ?? this.categoryId,
      level: level ?? this.level,
      language: language ?? this.language,
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class CreateCourseRequest {
  final String instructorId;
  final String categoryId;
  final String title;
  final String? description;
  final String? thumbnail;
  final Decimal price;
  final CourseLevel level;
  final String language;

  CreateCourseRequest({
    required this.instructorId,
    required this.categoryId,
    required this.title,
    this.description,
    this.thumbnail,
    required this.price,
    required this.level,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'instructorId': instructorId,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'price': price.toString(),
      'level': level.index,
      'language': language,
    };
  }
}

class UpdateCourseRequest extends CreateCourseRequest {
  UpdateCourseRequest({
    required super.instructorId,
    required super.categoryId,
    required super.title,
    super.description,
    super.thumbnail,
    required super.price,
    required super.level,
    required super.language,
  });
}
