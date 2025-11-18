import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/features/course/models/entities/course.dart';
import 'package:codemy_app/src/features/course/models/dto/course_requests.dart';
import 'package:codemy_app/src/features/course/enums/course_level.dart';

import '../../../helpers/mock_services.dart';
import '../../../helpers/test_data.dart';

void main() {
  late MockCourseService mockCourseService;

  setUpAll(() {
    registerMockFallbacks(); // Register fakes
  });

  setUp(() {
    mockCourseService = MockCourseService();
  });

  // =================================================================
  // TEST 1: Lấy danh sách courses
  // =================================================================
  group('CourseService - getCourses', () {
    test('should return list of courses successfully', () async {
      // ARRANGE - Chuẩn bị mock response
      when(() => mockCourseService.getCourses()).thenAnswer(
        (_) async => ApiRes<List<Course>>(
          status: 200,
          data: testCourseList,
          isSuccess: true,
        ),
      );

      // ACT - Gọi function
      final result = await mockCourseService.getCourses();

      // ASSERT - Kiểm tra kết quả
      expect(result.status, 200);
      expect(result.isSuccess, true);
      expect(result.data?.length, 3);
      expect(result.data?.first.title, 'Flutter Complete Guide');

      // Verify được gọi 1 lần
      verify(() => mockCourseService.getCourses()).called(1);
    });

    test('should filter courses by level', () async {
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
      expect(result.data?.every((c) => c.level == CourseLevel.beginner), true);
    });
  });

  // =================================================================
  // TEST 2: Lấy course detail
  // =================================================================
  group('CourseService - getCourseById', () {
    test('should return course details when found', () async {
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
    });

    test('should return error when course not found', () async {
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
    });
  });
}
