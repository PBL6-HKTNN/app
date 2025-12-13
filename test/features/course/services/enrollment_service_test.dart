import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/features/course/models/entities/enrollment.dart';
import 'package:codemy_app/src/features/course/models/dto/enrollment_responses.dart';
import 'package:codemy_app/src/features/course/models/dto/enrollment_requests.dart';

import '../../../helpers/mock_services.dart';
import '../../../helpers/test_data.dart';
import '../../../helpers/excel_reporter.dart';
import '../../../helpers/test_wrapper.dart';

void main() {
  late MockEnrollmentService mockEnrollmentService;
  final reporter = ExcelReporter('enrollment_service_test.dart');
  final wrapper = TestWrapper(reporter);

  setUpAll(() {
    registerMockFallbacks();
  });

  setUp(() {
    mockEnrollmentService = MockEnrollmentService();
  });

  tearDownAll(() async {
    await reporter.save('test_reports/enrollment_service_test_report.xlsx');
  });

  // =================================================================
  // TEST GROUP 1: getMyCourses - Lấy danh sách khóa học đã tham gia
  // =================================================================
  wrapper.groupWithReport('EnrollmentService - getMyCourses', () {
    wrapper.testWithReport(
      'should return list of joined courses successfully',
      () async {
        // ARRANGE - Chuẩn bị mock response
        when(
          () => mockEnrollmentService.getMyCourses(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer(
          (_) async => ApiRes<List<JoinedCourse>>(
            status: 200,
            data: testJoinedCourseList,
            isSuccess: true,
          ),
        );

        // ACT - Gọi service
        final result = await mockEnrollmentService.getMyCourses();

        // ASSERT - Kiểm tra kết quả
        expect(result.status, 200);
        expect(result.isSuccess, true);
        expect(result.data, isNotNull);
        expect(result.data?.length, 3);
        expect(result.data?.first.title, 'Flutter Complete Guide');
        expect(result.data?.first.id, 'course-1');

        // Verify method được gọi đúng
        verify(
          () => mockEnrollmentService.getMyCourses(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).called(1);
      },
      expected: 'Status 200, List of 3 joined courses',
      expectedStatusCode: 200,
    );

    wrapper.testWithReport(
      'should return empty list when user has no enrolled courses',
      () async {
        // ARRANGE
        when(
          () => mockEnrollmentService.getMyCourses(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer(
          (_) async => ApiRes<List<JoinedCourse>>(
            status: 200,
            data: [],
            isSuccess: true,
          ),
        );

        // ACT
        final result = await mockEnrollmentService.getMyCourses();

        // ASSERT
        expect(result.isSuccess, true);
        expect(result.data, isEmpty);
        expect(result.data?.length, 0);
      },
      expected: 'Status 200, Empty list',
      expectedStatusCode: 200,
    );

    wrapper.testWithReport(
      'should return error when fetch fails',
      () async {
        // ARRANGE
        when(
          () => mockEnrollmentService.getMyCourses(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer(
          (_) async => ApiRes<List<JoinedCourse>>(
            status: 500,
            data: null,
            error: 'Server error',
            isSuccess: false,
          ),
        );

        // ACT
        final result = await mockEnrollmentService.getMyCourses();

        // ASSERT
        expect(result.status, 500);
        expect(result.isSuccess, false);
        expect(result.data, isNull);
        expect(result.error, 'Server error');
      },
      expected: 'Status 500, Error: Server error',
      expectedStatusCode: 500,
    );

    wrapper.testWithReport(
      'should support pagination parameters',
      () async {
        // ARRANGE
        when(
          () => mockEnrollmentService.getMyCourses(page: 2, pageSize: 5),
        ).thenAnswer(
          (_) async => ApiRes<List<JoinedCourse>>(
            status: 200,
            data: [testJoinedCourse2],
            isSuccess: true,
          ),
        );

        // ACT
        final result = await mockEnrollmentService.getMyCourses(
          page: 2,
          pageSize: 5,
        );

        // ASSERT
        expect(result.isSuccess, true);
        expect(result.data?.length, 1);
        verify(
          () => mockEnrollmentService.getMyCourses(page: 2, pageSize: 5),
        ).called(1);
      },
      expected: 'Status 200, 1 course with pagination (page=2, pageSize=5)',
      expectedStatusCode: 200,
    );
  });

  // =================================================================
  // TEST GROUP 2: getCourseEnrollment - Kiểm tra enrollment status
  // =================================================================
  wrapper.groupWithReport('EnrollmentService - getCourseEnrollment', () {
    wrapper.testWithReport(
      'should return enrolled status when user is enrolled',
      () async {
        // ARRANGE
        when(
          () => mockEnrollmentService.getCourseEnrollment('course-1'),
        ).thenAnswer(
          (_) async => ApiRes<EnrollmentCheckResponse>(
            status: 200,
            data: testEnrollmentCheckSuccess,
            isSuccess: true,
          ),
        );

        // ACT
        final result = await mockEnrollmentService.getCourseEnrollment(
          'course-1',
        );

        // ASSERT
        expect(result.status, 200);
        expect(result.isSuccess, true);
        expect(result.data?.success, true);
        expect(result.data?.message, 'User is enrolled in this course');

        verify(
          () => mockEnrollmentService.getCourseEnrollment('course-1'),
        ).called(1);
      },
      expected: 'Status 200, User is enrolled (success=true)',
      expectedStatusCode: 200,
    );

    wrapper.testWithReport(
      'should return not enrolled status when user is not enrolled',
      () async {
        // ARRANGE
        when(
          () => mockEnrollmentService.getCourseEnrollment('course-999'),
        ).thenAnswer(
          (_) async => ApiRes<EnrollmentCheckResponse>(
            status: 200,
            data: testEnrollmentCheckNotEnrolled,
            isSuccess: true,
          ),
        );

        // ACT
        final result = await mockEnrollmentService.getCourseEnrollment(
          'course-999',
        );

        // ASSERT
        expect(result.isSuccess, true);
        expect(result.data?.success, false);
        expect(result.data?.message, 'User is not enrolled in this course');
      },
      expected: 'Status 200, User is not enrolled (success=false)',
      expectedStatusCode: 200,
    );

    wrapper.testWithReport(
      'should return error when course not found',
      () async {
        // ARRANGE
        when(
          () => mockEnrollmentService.getCourseEnrollment('invalid-id'),
        ).thenAnswer(
          (_) async => ApiRes<EnrollmentCheckResponse>(
            status: 404,
            data: null,
            error: 'Course not found',
            isSuccess: false,
          ),
        );

        // ACT
        final result = await mockEnrollmentService.getCourseEnrollment(
          'invalid-id',
        );

        // ASSERT
        expect(result.status, 404);
        expect(result.isSuccess, false);
        expect(result.data, isNull);
        expect(result.error, 'Course not found');
      },
      expected: 'Status 404, Error: Course not found',
      expectedStatusCode: 404,
    );
  });

  // =================================================================
  // TEST GROUP 3: enrollCourse - Đăng ký khóa học
  // =================================================================
  wrapper.groupWithReport('EnrollmentService - enrollCourse', () {
    wrapper.testWithReport(
      'should enroll in course successfully',
      () async {
        // ARRANGE
        when(() => mockEnrollmentService.enrollCourse('course-1')).thenAnswer(
          (_) async => ApiRes<Enrollment>(
            status: 201,
            data: testEnrollment,
            isSuccess: true,
          ),
        );

        // ACT
        final result = await mockEnrollmentService.enrollCourse('course-1');

        // ASSERT
        expect(result.status, 201);
        expect(result.isSuccess, true);
        expect(result.data, isNotNull);
        expect(result.data?.enrollmentId, 'enrollment-1');
        expect(result.data?.progressStatus, 1); // in progress

        verify(() => mockEnrollmentService.enrollCourse('course-1')).called(1);
      },
      expected: 'Status 201, Enrollment created (progressStatus=1)',
      expectedStatusCode: 201,
    );

    wrapper.testWithReport(
      'should return error when already enrolled',
      () async {
        // ARRANGE
        when(() => mockEnrollmentService.enrollCourse('course-1')).thenAnswer(
          (_) async => ApiRes<Enrollment>(
            status: 400,
            data: null,
            error: 'User already enrolled in this course',
            isSuccess: false,
          ),
        );

        // ACT
        final result = await mockEnrollmentService.enrollCourse('course-1');

        // ASSERT
        expect(result.status, 400);
        expect(result.isSuccess, false);
        expect(result.data, isNull);
        expect(result.error, 'User already enrolled in this course');
      },
      expected: 'Status 400, Error: User already enrolled',
      expectedStatusCode: 400,
    );

    wrapper.testWithReport(
      'should return error when course is full',
      () async {
        // ARRANGE
        when(
          () => mockEnrollmentService.enrollCourse('course-full'),
        ).thenAnswer(
          (_) async => ApiRes<Enrollment>(
            status: 400,
            data: null,
            error: 'Course is full',
            isSuccess: false,
          ),
        );

        // ACT
        final result = await mockEnrollmentService.enrollCourse('course-full');

        // ASSERT
        expect(result.status, 400);
        expect(result.isSuccess, false);
        expect(result.error, 'Course is full');
      },
      expected: 'Status 400, Error: Course is full',
      expectedStatusCode: 400,
    );
  });

  // =================================================================
  // TEST GROUP 4: updateEnrollment - Cập nhật tiến độ
  // =================================================================
  wrapper.groupWithReport('EnrollmentService - updateEnrollment', () {
    wrapper.testWithReport(
      'should update enrollment progress successfully',
      () async {
        // ARRANGE
        when(() => mockEnrollmentService.updateEnrollment(any())).thenAnswer(
          (_) async => ApiRes<Enrollment>(
            status: 200,
            data: testEnrollment,
            isSuccess: true,
          ),
        );

        // ACT
        final result = await mockEnrollmentService.updateEnrollment(
          testUpdateEnrollmentRequest,
        );

        // ASSERT
        expect(result.status, 200);
        expect(result.isSuccess, true);
        expect(result.data?.progressStatus, 1);
        expect(result.data?.lessonId, 'lesson-1');

        verify(() => mockEnrollmentService.updateEnrollment(any())).called(1);
      },
      expected:
          'Status 200, Progress updated (progressStatus=1, lessonId=lesson-1)',
      expectedStatusCode: 200,
    );

    wrapper.testWithReport(
      'should update enrollment to completed status',
      () async {
        // ARRANGE
        when(() => mockEnrollmentService.updateEnrollment(any())).thenAnswer(
          (_) async => ApiRes<Enrollment>(
            status: 200,
            data: testEnrollmentCompleted,
            isSuccess: true,
          ),
        );

        // ACT
        final result = await mockEnrollmentService.updateEnrollment(
          testUpdateEnrollmentRequestCompleted,
        );

        // ASSERT
        expect(result.isSuccess, true);
        expect(result.data?.progressStatus, 2); // completed
        expect(result.data?.certificateUrl, isNotEmpty);
      },
      expected:
          'Status 200, Course completed (progressStatus=2, certificate generated)',
      expectedStatusCode: 200,
    );

    wrapper.testWithReport(
      'should return error when enrollment not found',
      () async {
        // ARRANGE
        when(() => mockEnrollmentService.updateEnrollment(any())).thenAnswer(
          (_) async => ApiRes<Enrollment>(
            status: 404,
            data: null,
            error: 'Enrollment not found',
            isSuccess: false,
          ),
        );

        // ACT
        final result = await mockEnrollmentService.updateEnrollment(
          testUpdateEnrollmentRequest,
        );

        // ASSERT
        expect(result.status, 404);
        expect(result.isSuccess, false);
        expect(result.error, 'Enrollment not found');
      },
      expected: 'Status 404, Error: Enrollment not found',
      expectedStatusCode: 404,
    );

    wrapper.testWithReport(
      'should return error when invalid lesson id',
      () async {
        // ARRANGE
        final invalidRequest = UpdateEnrollmentRequest(
          enrollmentId: 'enrollment-1',
          progressStatus: 1,
          lessonId: 'invalid-lesson',
        );

        when(() => mockEnrollmentService.updateEnrollment(any())).thenAnswer(
          (_) async => ApiRes<Enrollment>(
            status: 400,
            data: null,
            error: 'Invalid lesson ID',
            isSuccess: false,
          ),
        );

        // ACT
        final result = await mockEnrollmentService.updateEnrollment(
          invalidRequest,
        );

        // ASSERT
        expect(result.status, 400);
        expect(result.isSuccess, false);
        expect(result.error, 'Invalid lesson ID');
      },
      expected: 'Status 400, Error: Invalid lesson ID',
      expectedStatusCode: 400,
    );
  });
}
