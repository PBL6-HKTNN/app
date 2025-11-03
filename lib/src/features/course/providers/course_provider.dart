import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/entities/course.dart';
import '../services/course_service.dart';

class CourseFilter {
  final String query;
  final String? category;

  const CourseFilter({this.query = '', this.category});

  CourseFilter copyWith({String? query, String? category}) {
    return CourseFilter(
      query: query ?? this.query,
      category: category ?? this.category,
    );
  }
}

class CourseState {
  final List<Course> courses;
  final bool loading;
  final CourseFilter filter;
  final CourseListType type;

  const CourseState({
    required this.courses,
    required this.loading,
    required this.filter,
    required this.type,
  });

  CourseState copyWith({
    List<Course>? courses,
    bool? loading,
    CourseFilter? filter,
    CourseListType? type,
  }) {
    return CourseState(
      courses: courses ?? this.courses,
      loading: loading ?? this.loading,
      filter: filter ?? this.filter,
      type: type ?? this.type,
    );
  }
}

class CourseNotifier extends StateNotifier<CourseState> {
  final CourseService _service;

  CourseNotifier(
    this._service, {
    CourseListType initialType = CourseListType.all,
  }) : super(
         CourseState(
           courses: [],
           loading: false,
           filter: const CourseFilter(),
           type: initialType,
         ),
       ) {
    // Khi khởi tạo, tự động load dữ liệu theo type ban đầu
    load(type: initialType);
  }

  Future<void> load({int limit = 20, CourseListType? type}) async {
    final listType = type ?? state.type;
    state = state.copyWith(loading: true, type: listType);

    final data = await _service.fetchCourses(type: listType, limit: limit);
    state = state.copyWith(courses: data, loading: false);
  }

  void applyFilter(CourseFilter filter) {
    state = state.copyWith(filter: filter);
  }

  List<Course> get filtered {
    final q = state.filter.query.trim().toLowerCase();
    final cat = state.filter.category;
    return state.courses.where((c) {
      final matchesQuery =
          q.isEmpty ||
          c.title.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q) ||
          c.language.toLowerCase().contains(q);
      final matchesCategory =
          (cat == null || cat == 'all' || cat == 'All') ||
          c.title.toLowerCase().contains(cat.toLowerCase());
      return matchesQuery && matchesCategory;
    }).toList();
  }
}

/// Service chung cho mọi provider
final courseServiceProvider = Provider((ref) => CourseService());

/// Provider cho danh sách **tất cả khóa học**
final allCoursesProvider = StateNotifierProvider<CourseNotifier, CourseState>((
  ref,
) {
  final service = ref.read(courseServiceProvider);
  return CourseNotifier(service, initialType: CourseListType.all);
});

/// Provider cho danh sách **khóa học đã tham gia**
final joinedCoursesProvider =
    StateNotifierProvider<CourseNotifier, CourseState>((ref) {
      final service = ref.read(courseServiceProvider);
      return CourseNotifier(service, initialType: CourseListType.joined);
    });

/// Provider cho danh sách **wishlist**
final wishlistCoursesProvider =
    StateNotifierProvider<CourseNotifier, CourseState>((ref) {
      final service = ref.read(courseServiceProvider);
      return CourseNotifier(service, initialType: CourseListType.wishlist);
    });
