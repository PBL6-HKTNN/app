import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/features/course/models/entities/course.dart';
import 'package:codemy_app/src/features/course/models/dto/course_requests.dart';
import 'package:codemy_app/src/features/course/providers/course_provider.dart';
import 'package:codemy_app/src/features/course/services/course_service.dart';

import '../../../helpers/mock_services.dart';
import '../../../helpers/test_data.dart';

void main() {
  late MockCourseService mockCourseService;

  setUpAll(() {
    registerMockFallbacks();
  });

  setUp(() {
    mockCourseService = MockCourseService();
  });

  // =================================================================
  // TEST 1: allCoursesProvider - Load courses thành công
  // =================================================================
  group('CourseProvider - allCoursesProvider', () {
    test('should load all courses successfully', () async {
      // ARRANGE
      when(
        () => mockCourseService.getCourses(
          queryParams: any(named: 'queryParams'),
        ),
      ).thenAnswer(
        (_) async => ApiRes<List<Course>>(
          status: 200,
          data: testCourseList,
          isSuccess: true,
        ),
      );

      // Tạo container với mock service
      final container = ProviderContainer(
        overrides: [courseServiceProvider.overrideWithValue(mockCourseService)],
      );

      // ACT - Đọc provider (nó sẽ tự động gọi service)
      final asyncValue = await container.read(allCoursesProvider.future);

      // ASSERT
      expect(asyncValue, isA<List<Course>>());
      expect(asyncValue.length, 3);
      expect(asyncValue.first.title, 'Flutter Complete Guide');

      // Cleanup
      container.dispose();
    });

    test('should throw error when fetch fails', () async {
      // ARRANGE
      when(
        () => mockCourseService.getCourses(
          queryParams: any(named: 'queryParams'),
        ),
      ).thenAnswer(
        (_) async => ApiRes<List<Course>>(
          status: 500,
          data: null,
          error: 'Network error',
          isSuccess: false,
        ),
      );

      final container = ProviderContainer(
        overrides: [courseServiceProvider.overrideWithValue(mockCourseService)],
      );

      // ACT & ASSERT
      expect(() => container.read(allCoursesProvider.future), throwsException);

      container.dispose();
    });

    test('should return empty list when no courses', () async {
      // ARRANGE
      when(
        () => mockCourseService.getCourses(
          queryParams: any(named: 'queryParams'),
        ),
      ).thenAnswer(
        (_) async =>
            ApiRes<List<Course>>(status: 200, data: [], isSuccess: true),
      );

      final container = ProviderContainer(
        overrides: [courseServiceProvider.overrideWithValue(mockCourseService)],
      );

      // ACT
      final asyncValue = await container.read(allCoursesProvider.future);

      // ASSERT
      expect(asyncValue, isEmpty);
      expect(asyncValue.length, 0);

      container.dispose();
    });
  });

  // =================================================================
  // TEST 2: CourseListState - Test state class
  // =================================================================
  group('CourseListState', () {
    test('should create initial state correctly', () {
      // ACT
      const state = CourseListState();

      // ASSERT
      expect(state.courses, isEmpty);
      expect(state.loading, false);
      expect(state.filter.query, '');
      expect(state.filter.category, isNull);
      expect(state.error, isNull);
    });

    test('should copy state with new values', () {
      // ARRANGE
      const initialState = CourseListState();

      // ACT
      final newState = initialState.copyWith(
        courses: testCourseList,
        loading: true,
        filter: const CourseFilter(query: 'Flutter'),
      );

      // ASSERT
      expect(newState.courses.length, 3);
      expect(newState.loading, true);
      expect(newState.filter.query, 'Flutter');
      expect(newState.error, isNull);
    });

    test('should reset error when resetError is true', () {
      // ARRANGE
      const stateWithError = CourseListState(error: 'Some error');

      // ACT
      final newState = stateWithError.copyWith(resetError: true);

      // ASSERT
      expect(newState.error, isNull);
    });
  });

  // =================================================================
  // TEST 3: CourseFilter - Test filter class
  // =================================================================
  group('CourseFilter', () {
    test('should create filter with default values', () {
      // ACT
      const filter = CourseFilter();

      // ASSERT
      expect(filter.query, '');
      expect(filter.category, isNull);
    });

    test('should create filter with custom values', () {
      // ACT
      const filter = CourseFilter(query: 'Flutter', category: 'cat-1');

      // ASSERT
      expect(filter.query, 'Flutter');
      expect(filter.category, 'cat-1');
    });

    test('should copy filter with new values', () {
      // ARRANGE
      const filter = CourseFilter(query: 'Old', category: 'cat-1');

      // ACT
      final newFilter = filter.copyWith(query: 'New');

      // ASSERT
      expect(newFilter.query, 'New');
      expect(newFilter.category, 'cat-1'); // Unchanged
    });
  });
}
