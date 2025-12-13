import 'package:mocktail/mocktail.dart';
import 'package:codemy_app/src/features/course/services/course_service.dart';
import 'package:codemy_app/src/features/course/services/enrollment_service.dart';
import 'package:codemy_app/src/features/course/services/category_service.dart';
import 'package:codemy_app/src/features/course/services/module_service.dart';
import 'package:codemy_app/src/features/course/services/lesson_service.dart';
import 'package:codemy_app/src/features/course/models/dto/course_requests.dart';
import 'package:codemy_app/src/features/course/models/dto/enrollment_requests.dart';

// Mock Services
class MockCourseService extends Mock implements CourseService {}

class MockEnrollmentService extends Mock implements EnrollmentService {}

class MockCategoryService extends Mock implements CategoryService {}

class MockModuleService extends Mock implements ModuleService {}

class MockLessonService extends Mock implements LessonService {}

// Fake DTOs
class FakeCourseQueryParams extends Fake implements CourseQueryParams {}

class FakeCreateCourseRequest extends Fake implements CreateCourseRequest {}

class FakeUpdateCourseRequest extends Fake implements UpdateCourseRequest {}

class FakeUpdateEnrollmentRequest extends Fake
    implements UpdateEnrollmentRequest {}

// Register all fakes
void registerMockFallbacks() {
  registerFallbackValue(FakeCourseQueryParams());
  registerFallbackValue(FakeCreateCourseRequest());
  registerFallbackValue(FakeUpdateCourseRequest());
  registerFallbackValue(FakeUpdateEnrollmentRequest());
}
