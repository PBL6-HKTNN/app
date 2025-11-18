import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/features/course/models/dto/enrollment_responses.dart';
import 'package:codemy_app/src/features/course/models/entities/enrollment.dart';
import 'package:codemy_app/src/features/course/providers/enrollment_provider.dart';

import '../../../helpers/mock_services.dart';
import '../../../helpers/test_data.dart';

void main() {
  late MockEnrollmentService mockEnrollmentService;

  setUpAll(() {
    registerMockFallbacks();
  });

  setUp(() {
    mockEnrollmentService = MockEnrollmentService();
  });

  // =================================================================
  // TEST GROUP 1: enrolledCoursesProvider
  // =================================================================
  group('EnrollmentProvider - enrolledCoursesProvider', () {
    test('should load enrolled courses successfully', () async {
      // ARRANGE
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

      final container = ProviderContainer(
        overrides: [
          enrollmentServiceProvider.overrideWithValue(mockEnrollmentService),
        ],
      );
      addTearDown(container.dispose);

      // ACT
      final asyncValue = await container.read(enrolledCoursesProvider.future);

      // ASSERT
      expect(asyncValue, isA<List<JoinedCourse>>());
      expect(asyncValue.length, 3);
      expect(asyncValue.first.title, 'Flutter Complete Guide');
      expect(asyncValue.first.id, 'course-1');
    });

    test('should return empty list when no enrollments', () async {
      // ARRANGE
      when(
        () => mockEnrollmentService.getMyCourses(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer(
        (_) async =>
            ApiRes<List<JoinedCourse>>(status: 200, data: [], isSuccess: true),
      );

      final container = ProviderContainer(
        overrides: [
          enrollmentServiceProvider.overrideWithValue(mockEnrollmentService),
        ],
      );
      addTearDown(container.dispose);

      // ACT
      final asyncValue = await container.read(enrolledCoursesProvider.future);

      // ASSERT
      expect(asyncValue, isEmpty);
      expect(asyncValue.length, 0);
    });
  });

  // =================================================================
  // TEST GROUP 2: courseEnrollmentProvider
  // =================================================================
  group('EnrollmentProvider - courseEnrollmentProvider', () {
    test('should check enrollment status for enrolled course', () async {
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

      final container = ProviderContainer(
        overrides: [
          enrollmentServiceProvider.overrideWithValue(mockEnrollmentService),
        ],
      );
      addTearDown(container.dispose);

      // ACT
      final asyncValue = await container.read(
        courseEnrollmentProvider('course-1').future,
      );

      // ASSERT
      expect(asyncValue, isA<EnrollmentCheckResponse>());
      expect(asyncValue.success, true);
      expect(asyncValue.message, 'User is enrolled in this course');
    });

    test('should check enrollment status for non-enrolled course', () async {
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

      final container = ProviderContainer(
        overrides: [
          enrollmentServiceProvider.overrideWithValue(mockEnrollmentService),
        ],
      );
      addTearDown(container.dispose);

      // ACT
      final asyncValue = await container.read(
        courseEnrollmentProvider('course-999').future,
      );

      // ASSERT
      expect(asyncValue.success, false);
      expect(asyncValue.message, 'User is not enrolled in this course');
    });
  });

  // =================================================================
  // TEST GROUP 3: enrollCourseProvider
  // =================================================================
  group('EnrollmentProvider - enrollCourseProvider', () {
    test('should enroll in course successfully', () async {
      // ARRANGE
      when(() => mockEnrollmentService.enrollCourse('course-1')).thenAnswer(
        (_) async => ApiRes<Enrollment>(
          status: 201,
          data: testEnrollment,
          isSuccess: true,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          enrollmentServiceProvider.overrideWithValue(mockEnrollmentService),
        ],
      );
      addTearDown(container.dispose);

      // ACT
      final result = await container.read(
        enrollCourseProvider('course-1').future,
      );

      // ASSERT
      expect(result, true);
      verify(() => mockEnrollmentService.enrollCourse('course-1')).called(1);
    });
  });

  // =================================================================
  // TEST GROUP 4: updateEnrollmentProvider
  // =================================================================
  group('EnrollmentProvider - updateEnrollmentProvider', () {
    test('should update enrollment successfully', () async {
      // ARRANGE
      when(() => mockEnrollmentService.updateEnrollment(any())).thenAnswer(
        (_) async => ApiRes<Enrollment>(
          status: 200,
          data: testEnrollment,
          isSuccess: true,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          enrollmentServiceProvider.overrideWithValue(mockEnrollmentService),
        ],
      );
      addTearDown(container.dispose);

      // ACT
      final result = await container.read(
        updateEnrollmentProvider(testUpdateEnrollmentRequest).future,
      );

      // ASSERT
      expect(result, true);
      verify(() => mockEnrollmentService.updateEnrollment(any())).called(1);
    });

    test('should update enrollment to completed state', () async {
      // ARRANGE
      when(() => mockEnrollmentService.updateEnrollment(any())).thenAnswer(
        (_) async => ApiRes<Enrollment>(
          status: 200,
          data: testEnrollmentCompleted,
          isSuccess: true,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          enrollmentServiceProvider.overrideWithValue(mockEnrollmentService),
        ],
      );
      addTearDown(container.dispose);

      // ACT
      final result = await container.read(
        updateEnrollmentProvider(testUpdateEnrollmentRequestCompleted).future,
      );

      // ASSERT
      expect(result, true);
      verify(() => mockEnrollmentService.updateEnrollment(any())).called(1);
    });
  });
}
