import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/features/course/models/entities/course.dart';
import 'package:codemy_app/src/features/course/models/dto/course_requests.dart';
import 'package:codemy_app/src/features/course/enums/course_level.dart';

import '../../../helpers/mock_services.dart';
import '../../../helpers/test_data.dart';
import '../../../helpers/excel_reporter.dart';
import '../../../helpers/test_wrapper.dart';

void main() {
  late MockCourseService mockCourseService;
  final reporter = ExcelReporter('course_service_test.dart');
  final wrapper = TestWrapper(reporter);

  setUpAll(() {
    registerMockFallbacks();
  });

  setUp(() {
    mockCourseService = MockCourseService();
  });

  tearDownAll(() async {
    await reporter.save('test_reports/course_service_test_report.xlsx');
  });

  // =================================================================
  // TEST GROUP 1: getCourses
  // =================================================================
  wrapper.groupWithReport('CourseService - getCourses', () {
    wrapper.testWithReport(
      'should return list of courses successfully',
      () async {
        // ARRANGE
        when(() => mockCourseService.getCourses()).thenAnswer(
          (_) async => ApiRes<List<Course>>(
            status: 200,
            data: testCourseList,
            isSuccess: true,
          ),
        );

        // ACT
        final result = await mockCourseService.getCourses();

        // ASSERT
        expect(result.status, 200);
        expect(result.isSuccess, true);
        expect(result.data?.length, 3);
        expect(result.data?.first.title, 'Flutter Complete Guide');

        verify(() => mockCourseService.getCourses()).called(1);
      },
      expected: 'Status 200, List of 3 courses',
      expectedStatusCode: 200,
    );

    wrapper.testWithReport(
      'should filter courses by level',
      () async {
        // ARRANGE
        final queryParams = CourseQueryParams(level: CourseLevel.beginner);

        when(
          () => mockCourseService.getCourses(queryParams: queryParams),
        ).thenAnswer(
          (_) async => ApiRes<List<Course>>(
            status: 200,
            data: [testCourse, testCourseBeginner],
            isSuccess: true,
          ),
        );

        // ACT
        final result = await mockCourseService.getCourses(
          queryParams: queryParams,
        );

        // ASSERT
        expect(result.isSuccess, true);
        expect(result.data?.length, 2);
        expect(
          result.data?.every((c) => c.level == CourseLevel.beginner),
          true,
        );
      },
      expected: 'Status 200, 2 beginner courses',
      expectedStatusCode: 200,
    );
  });

  // =================================================================
  // TEST GROUP 2: getCourseById
  // =================================================================
  wrapper.groupWithReport('CourseService - getCourseById', () {
    wrapper.testWithReport(
      'should return course details when found',
      () async {
        // ARRANGE
        when(() => mockCourseService.getCourseById('course-1')).thenAnswer(
          (_) async =>
              ApiRes<Course>(status: 200, data: testCourse, isSuccess: true),
        );

        // ACT
        final result = await mockCourseService.getCourseById('course-1');

        // ASSERT
        expect(result.status, 200);
        expect(result.isSuccess, true);
        expect(result.data?.id, 'course-1');
        expect(result.data?.title, 'Flutter Complete Guide');
      },
      expected: 'Status 200, Course with id course-1',
      expectedStatusCode: 200,
    );

    wrapper.testWithReport(
      'should return error when course not found',
      () async {
        // ARRANGE
        when(() => mockCourseService.getCourseById('invalid-id')).thenAnswer(
          (_) async => ApiRes<Course>(
            status: 500,
            data: null,
            error: 'Course not found',
            isSuccess: false,
          ),
        );

        // ACT
        final result = await mockCourseService.getCourseById('invalid-id');

        // ASSERT
        expect(result.status, 500);
        expect(result.isSuccess, false);
        expect(result.data, isNull);
      },
      expected: 'Status 500, Error: Course not found',
      expectedStatusCode: 500,
    );
  });
}
