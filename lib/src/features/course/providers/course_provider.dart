import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/dto/course_requests.dart';
import '../models/entities/course.dart';
import '../models/entities/wishlist_item.dart';
import '../services/course_service.dart';
import '../services/enrollment_service.dart';
import '../services/wishlist_service.dart';

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
  final String? error;

  const CourseState({
    required this.courses,
    required this.loading,
    required this.filter,
    required this.type,
    this.error,
  });

  CourseState copyWith({
    List<Course>? courses,
    bool? loading,
    CourseFilter? filter,
    CourseListType? type,
    String? error,
    bool resetError = false,
  }) {
    return CourseState(
      courses: courses ?? this.courses,
      loading: loading ?? this.loading,
      filter: filter ?? this.filter,
      type: type ?? this.type,
      error: resetError ? null : (error ?? this.error),
    );
  }
}

class CourseNotifier extends StateNotifier<CourseState> {
  final CourseService _service;
  final EnrollmentService _enrollmentService;
  final WishlistService _wishlistService;

  CourseNotifier(
    this._service,
    this._enrollmentService,
    this._wishlistService, {
    CourseListType initialType = CourseListType.all,
  }) : super(
         CourseState(
           courses: [],
           loading: false,
           filter: const CourseFilter(),
           type: initialType,
           error: null,
         ),
       ) {
    // Khi khởi tạo, tự động load dữ liệu theo type ban đầu
    load(type: initialType);
  }

  Future<void> load({int limit = 20, CourseListType? type}) async {
    final listType = type ?? state.type;
    state = state.copyWith(loading: true, type: listType, resetError: true);

    try {
      switch (listType) {
        case CourseListType.joined:
          await _loadJoinedCourses();
          break;
        case CourseListType.wishlist:
          await _loadWishlistCourses();
          break;
        case CourseListType.all:
          await _loadAllCourses(limit: limit);
          break;
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
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
          (c.description?.toLowerCase().contains(q) ?? false) ||
          c.language.toLowerCase().contains(q);
      final matchesCategory = cat == null || cat.isEmpty || c.categoryId == cat;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  Future<void> _loadAllCourses({required int limit}) async {
    final params = CourseQueryParams(pageSize: limit);
    final response = await _service.getCourses(queryParams: params);
    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        courses: response.data!,
        loading: false,
        resetError: true,
      );
    } else {
      state = state.copyWith(
        courses: [],
        loading: false,
        error: response.error?.toString() ?? 'Failed to load courses',
      );
    }
  }

  Future<void> _loadJoinedCourses() async {
    final response = await _enrollmentService.getMyCourses();
    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        courses: response.data!,
        loading: false,
        resetError: true,
      );
    } else {
      state = state.copyWith(
        courses: [],
        loading: false,
        error: response.error?.toString() ?? 'Failed to load enrolled courses',
      );
    }
  }

  Future<void> _loadWishlistCourses() async {
    final response = await _wishlistService.getWishlist();
    if (!(response.isSuccess && response.data != null)) {
      state = state.copyWith(
        courses: [],
        loading: false,
        error: response.error?.toString() ?? 'Failed to load wishlist',
      );
      return;
    }

    final wishlistItems = response.data!.items;
    if (wishlistItems.isEmpty) {
      state = state.copyWith(courses: [], loading: false, resetError: true);
      return;
    }

    final courses = await _fetchCoursesByWishlist(wishlistItems);
    state = state.copyWith(courses: courses, loading: false, resetError: true);
  }

  Future<List<Course>> _fetchCoursesByWishlist(List<WishlistItem> items) async {
    final courses = <Course>[];
    for (final item in items) {
      final courseRes = await _service.getCourseById(item.courseId);
      if (courseRes.isSuccess && courseRes.data != null) {
        courses.add(courseRes.data!);
      }
    }
    return courses;
  }
}

/// Service chung cho mọi provider
final courseServiceProvider = Provider((ref) => CourseService());
final enrollmentServiceProvider = Provider((ref) => EnrollmentService());
final wishlistServiceProvider = Provider((ref) => WishlistService());

/// Provider cho danh sách **tất cả khóa học**
final allCoursesProvider = StateNotifierProvider<CourseNotifier, CourseState>((
  ref,
) {
  final service = ref.read(courseServiceProvider);
  final enrollmentService = ref.read(enrollmentServiceProvider);
  final wishlistService = ref.read(wishlistServiceProvider);
  return CourseNotifier(
    service,
    enrollmentService,
    wishlistService,
    initialType: CourseListType.all,
  );
});

/// Provider cho danh sách **khóa học đã tham gia**
final joinedCoursesProvider =
    StateNotifierProvider<CourseNotifier, CourseState>((ref) {
      final service = ref.read(courseServiceProvider);
      final enrollmentService = ref.read(enrollmentServiceProvider);
      final wishlistService = ref.read(wishlistServiceProvider);
      return CourseNotifier(
        service,
        enrollmentService,
        wishlistService,
        initialType: CourseListType.joined,
      );
    });

/// Provider cho danh sách **wishlist**
final wishlistCoursesProvider =
    StateNotifierProvider<CourseNotifier, CourseState>((ref) {
      final service = ref.read(courseServiceProvider);
      final enrollmentService = ref.read(enrollmentServiceProvider);
      final wishlistService = ref.read(wishlistServiceProvider);
      return CourseNotifier(
        service,
        enrollmentService,
        wishlistService,
        initialType: CourseListType.wishlist,
      );
    });
