import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/course.dart';
import '../services/course_service.dart';

// Service provider
final courseServiceProvider = Provider((ref) => CourseService());

// State providers for filtering and navigation
final selectedCourseIdProvider = StateProvider<String?>((ref) => null);
final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

// Course list provider with pagination
final coursesProvider = StateNotifierProvider<CourseNotifier, AsyncValue<List<Course>>>((ref) {
  return CourseNotifier(ref.watch(courseServiceProvider));
});

// Selected course details provider
final selectedCourseProvider = FutureProvider<Course?>((ref) async {
  final courseId = ref.watch(selectedCourseIdProvider);
  if (courseId == null) return null;
  
  final courseService = ref.watch(courseServiceProvider);
  return courseService.getCourseById(courseId);
});

// Filtered courses provider combining search and category filters
final filteredCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final coursesAsync = ref.watch(coursesProvider);
  final category = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return coursesAsync.when(
    data: (courses) {
      return AsyncValue.data(courses.where((course) {
        final matchesCategory = category == null || course.category == category;
        final matchesSearch = searchQuery.isEmpty || 
          course.title.toLowerCase().contains(searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList());
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

class CourseNotifier extends StateNotifier<AsyncValue<List<Course>>> {
  final CourseService _courseService;
  int _currentPage = 1;
  bool _hasMore = true;

  CourseNotifier(this._courseService) : super(const AsyncValue.loading()) {
    loadInitialCourses();
  }

  Future<void> loadInitialCourses() async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    
    try {
      final courses = await _courseService.getCourses(page: 1);
      state = AsyncValue.data(courses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    final currentCourses = state.value ?? [];
    _currentPage++;

    try {
      final newCourses = await _courseService.getCourses(page: _currentPage);
      if (newCourses.isEmpty) {
        _hasMore = false;
      } else {
        state = AsyncValue.data([...currentCourses, ...newCourses]);
      }
    } catch (e, st) {
      _currentPage--;
      // Optionally notify error without changing current state
      // state = AsyncValue.error(e, st);
    }
  }

  bool get hasMore => _hasMore;
}