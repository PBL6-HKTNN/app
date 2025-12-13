import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/features/course/models/entities/course.dart';
import 'package:codemy_app/src/features/course/providers/course_provider.dart';
import 'package:codemy_app/src/features/course/services/course_service.dart';

import '../../../helpers/mock_services.dart';
import '../../../helpers/test_data.dart';
import '../../../helpers/excel_reporter.dart';
import '../../../helpers/test_wrapper.dart';

void main() {
  late MockCourseService mockCourseService;
  final reporter = ExcelReporter('course_provider_test.dart');
  final wrapper = TestWrapper(reporter);

  setUpAll(() {
    registerMockFallbacks();
  });

  setUp(() {
    mockCourseService = MockCourseService();
  });

  tearDownAll(() async {
    await reporter.save('test_reports/course_provider_test_report.xlsx');
  });

  // =================================================================
  // TEST 1: allCoursesProvider - Load courses thành công
  // =================================================================
  wrapper.groupWithReport('CourseProvider - allCoursesProvider', () {
    wrapper.testWithReport(
      'should load all courses successfully',
      () async {
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
          overrides: [
            courseServiceProvider.overrideWithValue(mockCourseService),
          ],
        );
        addTearDown(container.dispose);

        // ACT - Đọc provider (nó sẽ tự động gọi service)
        final asyncValue = await container.read(allCoursesProvider.future);

        // ASSERT
        expect(asyncValue, isA<List<Course>>());
        expect(asyncValue.length, 3);
        expect(asyncValue.first.title, 'Flutter Complete Guide');
      },
      expected: 'Status 200, List of 3 courses',
      expectedStatusCode: 200,
    );

    wrapper.testWithReport(
      'should return empty list when no courses',
      () async {
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
          overrides: [
            courseServiceProvider.overrideWithValue(mockCourseService),
          ],
        );
        addTearDown(container.dispose);

        // ACT
        final asyncValue = await container.read(allCoursesProvider.future);

        // ASSERT
        expect(asyncValue, isEmpty);
        expect(asyncValue.length, 0);
      },
      expected: 'Status 200, Empty list',
      expectedStatusCode: 200,
    );
  });

  // =================================================================
  // TEST 2: CourseListState - Test state class
  // =================================================================
  wrapper.groupWithReport('CourseProvider - CourseListState', () {
    wrapper.testWithReport(
      'should create initial state correctly',
      () async {
        // ACT
        const state = CourseListState();

        // ASSERT
        expect(state.courses, isEmpty);
        expect(state.loading, false);
        expect(state.filter.query, '');
        expect(state.filter.category, isNull);
        expect(state.error, isNull);
      },
      expected: 'Initial state with empty courses and loading=false',
    );

    wrapper.testWithReport(
      'should copy state with new values',
      () async {
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
      },
      expected: 'State copied with 3 courses, loading=true, query=Flutter',
    );

    wrapper.testWithReport(
      'should reset error when resetError is true',
      () async {
        // ARRANGE
        const stateWithError = CourseListState(error: 'Some error');

        // ACT
        final newState = stateWithError.copyWith(resetError: true);

        // ASSERT
        expect(newState.error, isNull);
      },
      expected: 'Error should be null after reset',
    );
  });

  // =================================================================
  // TEST 3: CourseFilter - Test filter class
  // =================================================================
  wrapper.groupWithReport('CourseProvider - CourseFilter', () {
    wrapper.testWithReport(
      'should create filter with default values',
      () async {
        // ACT
        const filter = CourseFilter();

        // ASSERT
        expect(filter.query, '');
        expect(filter.category, isNull);
      },
      expected: 'Default filter with empty query and null category',
    );

    wrapper.testWithReport(
      'should create filter with custom values',
      () async {
        // ACT
        const filter = CourseFilter(query: 'Flutter', category: 'cat-1');

        // ASSERT
        expect(filter.query, 'Flutter');
        expect(filter.category, 'cat-1');
      },
      expected: 'Filter with query=Flutter and category=cat-1',
    );

    wrapper.testWithReport(
      'should copy filter with new values',
      () async {
        // ARRANGE
        const filter = CourseFilter(query: 'Old', category: 'cat-1');

        // ACT
        final newFilter = filter.copyWith(query: 'New');

        // ASSERT
        expect(newFilter.query, 'New');
        expect(newFilter.category, 'cat-1'); // Unchanged
      },
      expected: 'Filter copied with new query, category unchanged',
    );
  });
}
