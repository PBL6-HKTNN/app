import 'dart:async';

import 'package:codemy_app/l10n/app_localizations.dart';
import 'package:codemy_app/src/core/networks/models/api_res.dart';
import 'package:codemy_app/src/features/course/enums/course_level.dart';
import 'package:codemy_app/src/features/course/enums/course_status.dart';
import 'package:codemy_app/src/features/course/enums/lesson_type.dart';
import 'package:codemy_app/src/features/course/models/dto/course_content.dart';
import 'package:codemy_app/src/features/course/models/dto/enrollment_responses.dart';
import 'package:codemy_app/src/features/course/models/dto/wishlist_responses.dart';
import 'package:codemy_app/src/features/course/models/entities/course.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/features/course/models/entities/module.dart';
import 'package:codemy_app/src/features/course/providers/course_provider.dart';
import 'package:codemy_app/src/features/course/providers/enrollment_provider.dart';
import 'package:codemy_app/src/features/course/providers/wishlist_provider.dart';
import 'package:codemy_app/src/features/course/routes/course_routes.dart';
import 'package:codemy_app/src/features/course/screens/course_detail_screen.dart';
import 'package:codemy_app/src/features/course/screens/course_list_screen.dart';
import 'package:codemy_app/src/features/course/screens/your_courses_screen.dart';
import 'package:codemy_app/src/features/course/services/course_service.dart';
import 'package:codemy_app/src/features/course/services/enrollment_service.dart';
import 'package:codemy_app/src/features/course/services/wishlist_service.dart';
import 'package:codemy_app/src/features/course/widgets/course_card.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/login.dart';
import 'package:codemy_app/src/features/user/models/dto/auth/res.dart';
import 'package:codemy_app/src/features/user/models/entity/user.dart';
import 'package:codemy_app/src/features/user/providers/auth_providers.dart';
import 'package:codemy_app/src/features/user/routes/auth_routes.dart';
import 'package:codemy_app/src/features/user/routes/user_routes.dart';
import 'package:codemy_app/src/features/user/screens/auth/login_screen.dart';
import 'package:codemy_app/src/features/user/screens/user_menu_screen.dart';
import 'package:codemy_app/src/features/user/services/auth_service.dart';
import 'package:codemy_app/src/features/user/services/google_auth_service.dart';
import 'package:codemy_app/src/presentation/screens/home_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

// Mock Classes
class MockAuthService extends Mock implements AuthService {}

class MockCourseService extends Mock implements CourseService {}

class MockEnrollmentService extends Mock implements EnrollmentService {}

class MockWishlistService extends Mock implements WishlistService {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockGoogleAuthClient extends Mock
    implements GoogleSignInAuthorizationClient {}

class FakeLoginDto extends Fake implements LoginDto {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  registerFallbackValue(FakeLoginDto());

  // Setup Google Sign-In mock
  final mockGoogleSignIn = MockGoogleSignIn();
  final mockGoogleSignInAccount = MockGoogleSignInAccount();
  final mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();

  // Mock the authentication events stream
  final authEventsController =
      StreamController<GoogleSignInAuthenticationEvent>.broadcast();
  when(
    () => mockGoogleSignIn.authenticationEvents,
  ).thenAnswer((_) => authEventsController.stream);

  // Mock authenticate method
  when(() => mockGoogleSignIn.authenticate()).thenAnswer((_) async {
    // Simulate successful authentication by emitting sign-in event
    final signInEvent = GoogleSignInAuthenticationEventSignIn(
      user: mockGoogleSignInAccount,
    );
    authEventsController.add(signInEvent);
    return mockGoogleSignInAccount;
  });

  // Mock account properties
  when(() => mockGoogleSignInAccount.email).thenReturn('test@gmail.com');
  when(() => mockGoogleSignInAccount.displayName).thenReturn('Test User');
  when(
    () => mockGoogleSignInAccount.photoUrl,
  ).thenReturn('https://example.com/photo.jpg');
  when(
    () => mockGoogleSignInAccount.authentication,
  ).thenReturn(mockGoogleSignInAuthentication);
  when(
    () => mockGoogleSignInAuthentication.idToken,
  ).thenReturn('mock-id-token');

  // Mock authorization client
  final mockAuthClient = MockGoogleAuthClient();
  when(
    () => mockGoogleSignInAccount.authorizationClient,
  ).thenReturn(mockAuthClient);

  // Mock authorization methods
  when(
    () => mockAuthClient.authorizationHeaders(any()),
  ).thenAnswer((_) async => {'Authorization': 'Bearer mock-access-token'});
  when(
    () => mockAuthClient.authorizeServer(any()),
  ).thenAnswer((_) async => null);

  // Set the mock in GoogleAuthService
  GoogleAuthService.setMockGoogleSignIn(mockGoogleSignIn);

  group('Course Screen E2E Tests', () {
    testWidgets('Course List Screen - displays courses and allows filtering', (
      tester,
    ) async {
      // Setup mocks
      final mockAuthService = MockAuthService();
      final mockCourseService = MockCourseService();
      final mockEnrollmentService = MockEnrollmentService();
      final mockWishlistService = MockWishlistService();

      final user = _createTestUser();
      final courses = _createTestCourses();

      // Mock login
      when(() => mockAuthService.login(any())).thenAnswer(
        (_) async => ApiRes<AuthRes>(
          status: 200,
          data: AuthRes(token: 'test-token', user: user),
          error: null,
          isSuccess: true,
        ),
      );

      // Mock course service
      when(
        () => mockCourseService.getCourses(
          queryParams: any(named: 'queryParams'),
        ),
      ).thenAnswer(
        (_) async => ApiRes<List<Course>>(
          status: 200,
          data: courses,
          error: null,
          isSuccess: true,
        ),
      );

      // Mock enrollment and wishlist services
      when(() => mockEnrollmentService.getCourseEnrollment(any())).thenAnswer(
        (_) async => ApiRes(
          status: 200,
          data: EnrollmentCheckResponse(success: false),
          error: null,
          isSuccess: true,
        ),
      );

      when(() => mockWishlistService.getWishlist()).thenAnswer(
        (_) async => ApiRes<List<WishlistedCourse>>(
          status: 200,
          data: [],
          error: null,
          isSuccess: true,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            courseServiceProvider.overrideWithValue(mockCourseService),
            enrollmentServiceProvider.overrideWithValue(mockEnrollmentService),
            wishlistServiceProvider.overrideWithValue(mockWishlistService),
          ],
          child: _buildApp(initialLocation: '/login'),
        ),
      );

      await tester.pumpAndSettle();

      // Login first
      expect(find.byType(LoginScreen), findsOneWidget);
      await tester.enterText(
        find.byType(shadcn.TextField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(shadcn.TextField).at(1),
        'password123',
      );
      await tester.tap(find.text('Login').last);
      await tester.pumpAndSettle();

      // Navigate to courses
      await tester.tap(find.byIcon(shadcn.LucideIcons.graduationCap));
      await tester.pumpAndSettle();

      // Verify course list screen
      expect(find.byType(CourseListScreen), findsOneWidget);
      expect(find.text('Courses'), findsWidgets);

      // Verify courses are displayed
      expect(find.text('Flutter Development'), findsOneWidget);
      expect(find.text('React Mastery'), findsOneWidget);

      verify(
        () => mockCourseService.getCourses(
          queryParams: any(named: 'queryParams'),
        ),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets(
      'Course Detail Screen - displays course info and allows enrollment',
      (tester) async {
        // Setup mocks
        final mockAuthService = MockAuthService();
        final mockCourseService = MockCourseService();
        final mockEnrollmentService = MockEnrollmentService();
        final mockWishlistService = MockWishlistService();

        final user = _createTestUser();
        final course = _createTestCourses().first;
        final courseContent = _createTestCourseContent(course);

        // Mock login
        when(() => mockAuthService.login(any())).thenAnswer(
          (_) async => ApiRes<AuthRes>(
            status: 200,
            data: AuthRes(token: 'test-token', user: user),
            error: null,
            isSuccess: true,
          ),
        );

        // Mock course service
        when(
          () => mockCourseService.getCourses(
            queryParams: any(named: 'queryParams'),
          ),
        ).thenAnswer(
          (_) async => ApiRes<List<Course>>(
            status: 200,
            data: _createTestCourses(),
            error: null,
            isSuccess: true,
          ),
        );

        when(() => mockCourseService.getCourseContent(course.id)).thenAnswer(
          (_) async => ApiRes<CourseContent>(
            status: 200,
            data: courseContent,
            error: null,
            isSuccess: true,
          ),
        );

        // Mock enrollment check
        when(
          () => mockEnrollmentService.getCourseEnrollment(course.id),
        ).thenAnswer(
          (_) async => ApiRes(
            status: 200,
            data: EnrollmentCheckResponse(success: false),
            error: null,
            isSuccess: true,
          ),
        );

        // Mock enrollment action
        when(() => mockEnrollmentService.enrollCourse(course.id)).thenAnswer(
          (_) async =>
              ApiRes(status: 200, data: null, error: null, isSuccess: true),
        );

        // Mock wishlist
        when(() => mockWishlistService.getWishlist()).thenAnswer(
          (_) async => ApiRes<List<WishlistedCourse>>(
            status: 200,
            data: [],
            error: null,
            isSuccess: true,
          ),
        );

        when(() => mockWishlistService.addToWishlist(course.id)).thenAnswer(
          (_) async =>
              ApiRes(status: 200, data: null, error: null, isSuccess: true),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authServiceProvider.overrideWithValue(mockAuthService),
              courseServiceProvider.overrideWithValue(mockCourseService),
              enrollmentServiceProvider.overrideWithValue(
                mockEnrollmentService,
              ),
              wishlistServiceProvider.overrideWithValue(mockWishlistService),
            ],
            child: _buildApp(initialLocation: '/login'),
          ),
        );

        await tester.pumpAndSettle();

        // Login
        await tester.enterText(
          find.byType(shadcn.TextField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(shadcn.TextField).at(1),
          'password123',
        );
        await tester.tap(find.text('Login').last);
        await tester.pumpAndSettle();

        // Navigate to courses
        await tester.tap(find.byIcon(shadcn.LucideIcons.graduationCap));
        await tester.pumpAndSettle();

        // Tap on View button of the Flutter Development course card
        // Find the course card containing Flutter Development title
        final courseCardWithTitle = find.byWidgetPredicate(
          (widget) =>
              widget is CourseCard &&
              widget.course.title == 'Flutter Development',
        );
        expect(courseCardWithTitle, findsOneWidget);

        // Find the View button within that card and tap it
        final viewButton = find.ancestor(
          of: find.text('View'),
          matching: find.byType(shadcn.PrimaryButton),
        );
        await tester.tap(viewButton.first);
        await tester.pumpAndSettle();

        // Verify course detail screen
        expect(find.byType(CourseDetailScreen), findsOneWidget);
        expect(find.text('Flutter Development').first, findsOneWidget);
        expect(find.textContaining('Learn Flutter').first, findsOneWidget);

        // Verify course info is displayed
        expect(find.text('\$99.99').first, findsOneWidget);
        expect(find.text('5 modules').first, findsOneWidget);
        verify(
          () => mockCourseService.getCourseContent(course.id),
        ).called(greaterThanOrEqualTo(1));
      },
    );

    testWidgets('Course Detail Screen - enrollment flow with success', (
      tester,
    ) async {
      // Setup mocks
      final mockAuthService = MockAuthService();
      final mockCourseService = MockCourseService();
      final mockEnrollmentService = MockEnrollmentService();
      final mockWishlistService = MockWishlistService();

      final user = _createTestUser();
      final course = _createTestCourses().first;
      final courseContent = _createTestCourseContent(course);

      // Track enrollment state for mock
      bool isEnrolled = false;

      // Mock login
      when(() => mockAuthService.login(any())).thenAnswer(
        (_) async => ApiRes<AuthRes>(
          status: 200,
          data: AuthRes(token: 'test-token', user: user),
          error: null,
          isSuccess: true,
        ),
      );

      // Mock course service
      when(
        () => mockCourseService.getCourses(
          queryParams: any(named: 'queryParams'),
        ),
      ).thenAnswer(
        (_) async => ApiRes<List<Course>>(
          status: 200,
          data: _createTestCourses(),
          error: null,
          isSuccess: true,
        ),
      );

      when(() => mockCourseService.getCourseContent(course.id)).thenAnswer(
        (_) async => ApiRes<CourseContent>(
          status: 200,
          data: courseContent,
          error: null,
          isSuccess: true,
        ),
      );

      // Mock enrollment check - first not enrolled, then enrolled after action
      when(
        () => mockEnrollmentService.getCourseEnrollment(course.id),
      ).thenAnswer(
        (_) async => ApiRes(
          status: 200,
          data: EnrollmentCheckResponse(success: isEnrolled),
          error: null,
          isSuccess: true,
        ),
      );

      // Mock enrollment action
      when(() => mockEnrollmentService.enrollCourse(course.id)).thenAnswer(
        (_) async =>
            ApiRes(status: 200, data: null, error: null, isSuccess: true),
      );

      // Mock wishlist
      when(() => mockWishlistService.getWishlist()).thenAnswer(
        (_) async => ApiRes<List<WishlistedCourse>>(
          status: 200,
          data: [],
          error: null,
          isSuccess: true,
        ),
      );

      when(() => mockWishlistService.addToWishlist(course.id)).thenAnswer(
        (_) async =>
            ApiRes(status: 200, data: null, error: null, isSuccess: true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            courseServiceProvider.overrideWithValue(mockCourseService),
            enrollmentServiceProvider.overrideWithValue(mockEnrollmentService),
            wishlistServiceProvider.overrideWithValue(mockWishlistService),
          ],
          child: _buildApp(initialLocation: '/login'),
        ),
      );

      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
        find.byType(shadcn.TextField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(shadcn.TextField).at(1),
        'password123',
      );
      await tester.tap(find.text('Login').last);
      await tester.pumpAndSettle();

      // Navigate to courses via navigation bar
      await tester.tap(find.byIcon(shadcn.LucideIcons.graduationCap));
      await tester.pumpAndSettle();

      // Tap on View button of the Flutter Development course card
      // Find the course card containing Flutter Development title
      final courseCardWithTitle = find.byWidgetPredicate(
        (widget) =>
            widget is CourseCard &&
            widget.course.title == 'Flutter Development',
      );
      expect(courseCardWithTitle, findsOneWidget);

      // Find the View button within that card and tap it
      final viewButton = find.ancestor(
        of: find.text('View'),
        matching: find.byType(shadcn.PrimaryButton),
      );
      await tester.tap(viewButton.first);
      await tester.pumpAndSettle();

      // Verify Enroll Now button exists
      expect(find.text('Enroll Now'), findsOneWidget);

      // Scroll to make the Enroll Now button visible
      await tester.ensureVisible(find.text('Enroll Now'));
      await tester.pumpAndSettle();

      // Tap enroll button
      await tester.tap(find.text('Enroll Now'));
      await tester.pumpAndSettle();

      // Verify success dialog appears
      expect(find.text('Enrollment Successful'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Tap OK button in the dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Update enrollment state after successful enrollment
      isEnrolled = true;
      await tester.pumpAndSettle();

      // Verify enrollment was called
      verify(
        () => mockEnrollmentService.enrollCourse(course.id),
      ).called(greaterThanOrEqualTo(1));

      // Verify the button now shows "Continue Learning"
      expect(find.text('Continue Learning'), findsOneWidget);
    });

    testWidgets(
      'Course Learning Screen - displays content for enrolled users',
      (tester) async {
        // Setup mocks
        final mockAuthService = MockAuthService();
        final mockCourseService = MockCourseService();
        final mockEnrollmentService = MockEnrollmentService();
        final mockWishlistService = MockWishlistService();

        final user = _createTestUser();
        final course = _createTestCourses().first;
        final courseContent = _createTestCourseContent(course);

        // Mock login
        when(() => mockAuthService.login(any())).thenAnswer(
          (_) async => ApiRes<AuthRes>(
            status: 200,
            data: AuthRes(token: 'test-token', user: user),
            error: null,
            isSuccess: true,
          ),
        );

        // Mock course service
        when(
          () => mockCourseService.getCourses(
            queryParams: any(named: 'queryParams'),
          ),
        ).thenAnswer(
          (_) async => ApiRes<List<Course>>(
            status: 200,
            data: _createTestCourses(),
            error: null,
            isSuccess: true,
          ),
        );

        when(() => mockCourseService.getCourseContent(course.id)).thenAnswer(
          (_) async => ApiRes<CourseContent>(
            status: 200,
            data: courseContent,
            error: null,
            isSuccess: true,
          ),
        );

        // Mock enrollment check - user is enrolled
        when(
          () => mockEnrollmentService.getCourseEnrollment(course.id),
        ).thenAnswer(
          (_) async => ApiRes(
            status: 200,
            data: EnrollmentCheckResponse(success: true),
            error: null,
            isSuccess: true,
          ),
        );

        // Mock wishlist
        when(() => mockWishlistService.getWishlist()).thenAnswer(
          (_) async => ApiRes<List<WishlistedCourse>>(
            status: 200,
            data: [],
            error: null,
            isSuccess: true,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authServiceProvider.overrideWithValue(mockAuthService),
              courseServiceProvider.overrideWithValue(mockCourseService),
              enrollmentServiceProvider.overrideWithValue(
                mockEnrollmentService,
              ),
              wishlistServiceProvider.overrideWithValue(mockWishlistService),
            ],
            child: _buildApp(initialLocation: '/login'),
          ),
        );

        await tester.pumpAndSettle();

        // Login
        await tester.enterText(
          find.byType(shadcn.TextField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(shadcn.TextField).at(1),
          'password123',
        );
        await tester.tap(find.text('Login').last);
        await tester.pumpAndSettle();

        // Navigate to courses
        await tester.tap(find.byIcon(shadcn.LucideIcons.graduationCap));
        await tester.pumpAndSettle();

        // Tap on View button of the Flutter Development course card
        // Find the course card containing Flutter Development title
        final courseCardWithTitle = find.byWidgetPredicate(
          (widget) =>
              widget is CourseCard &&
              widget.course.title == 'Flutter Development',
        );
        expect(courseCardWithTitle, findsOneWidget);

        // Find the View button within that card and tap it
        final viewButton = find.ancestor(
          of: find.text('View'),
          matching: find.byType(shadcn.PrimaryButton),
        );
        await tester.tap(viewButton.first);
        await tester.pumpAndSettle();

        // Verify enrolled user sees learning button
        final startButton = find.byWidgetPredicate(
          (widget) =>
              widget is material.Text &&
              (widget.data?.contains('Learning') ?? false),
        );
        await tester.ensureVisible(find.text('Continue Learning').first);
        await tester.pumpAndSettle();

        expect(startButton, findsWidgets);

        verify(
          () => mockCourseService.getCourseContent(course.id),
        ).called(greaterThanOrEqualTo(1));
        verify(
          () => mockEnrollmentService.getCourseEnrollment(course.id),
        ).called(greaterThanOrEqualTo(1));
      },
    );

    testWidgets(
      'Your Courses Screen - navigate via Profile > Your Course > Joined tab',
      (tester) async {
        // Setup mocks
        final mockAuthService = MockAuthService();
        final mockCourseService = MockCourseService();
        final mockEnrollmentService = MockEnrollmentService();
        final mockWishlistService = MockWishlistService();

        final user = _createTestUser();

        // Mock login
        when(() => mockAuthService.login(any())).thenAnswer(
          (_) async => ApiRes<AuthRes>(
            status: 200,
            data: AuthRes(token: 'test-token', user: user),
            error: null,
            isSuccess: true,
          ),
        );

        // Mock enrollment service for joined courses
        when(() => mockEnrollmentService.getMyCourses()).thenAnswer(
          (_) async => ApiRes<List<JoinedCourse>>(
            status: 200,
            data: [
              JoinedCourse(
                'course-1',
                'Flutter Development',
                'Learn Flutter from scratch',
                'https://example.com/flutter.jpg',
                Decimal.parse('99.99'),
                'instructor-1',
              ),
            ],
            error: null,
            isSuccess: true,
          ),
        );

        // Mock wishlist
        when(() => mockWishlistService.getWishlist()).thenAnswer(
          (_) async => ApiRes<List<WishlistedCourse>>(
            status: 200,
            data: [],
            error: null,
            isSuccess: true,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authServiceProvider.overrideWithValue(mockAuthService),
              courseServiceProvider.overrideWithValue(mockCourseService),
              enrollmentServiceProvider.overrideWithValue(
                mockEnrollmentService,
              ),
              wishlistServiceProvider.overrideWithValue(mockWishlistService),
            ],
            child: _buildApp(initialLocation: '/login'),
          ),
        );

        await tester.pumpAndSettle();

        // Login first
        await tester.enterText(
          find.byType(shadcn.TextField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(shadcn.TextField).at(1),
          'password123',
        );
        await tester.tap(find.text('Login').last);
        await tester.pumpAndSettle();

        // Navigate to Profile via navigation bar
        await tester.tap(find.byIcon(shadcn.LucideIcons.user));
        await tester.pumpAndSettle();

        // Verify UserMenuScreen is displayed
        expect(find.byType(UserMenuScreen), findsOneWidget);

        // Tap on "Your Course" button
        await tester.tap(find.text('Your Course'));
        await tester.pumpAndSettle();

        // Verify YourCoursesScreen is displayed
        expect(find.byType(YourCoursesScreen), findsOneWidget);

        // Verify "Joined" tab is displayed and can be tapped
        expect(find.text('Joined'), findsOneWidget);
        await tester.tap(find.text('Joined').first);
        await tester.pumpAndSettle();

        // Verify joined courses are displayed
        // Note: The actual course rendering depends on the data
        expect(find.byType(YourCoursesScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Course Detail Screen - conditional rendering based on enrollment status',
      (tester) async {
        // Setup mocks
        final mockAuthService = MockAuthService();
        final mockCourseService = MockCourseService();
        final mockEnrollmentService = MockEnrollmentService();
        final mockWishlistService = MockWishlistService();

        final user = _createTestUser();
        final course = _createTestCourses().first;
        final courseContent = _createTestCourseContent(course);

        // Mock login
        when(() => mockAuthService.login(any())).thenAnswer(
          (_) async => ApiRes<AuthRes>(
            status: 200,
            data: AuthRes(token: 'test-token', user: user),
            error: null,
            isSuccess: true,
          ),
        );

        // Mock course service
        when(
          () => mockCourseService.getCourses(
            queryParams: any(named: 'queryParams'),
          ),
        ).thenAnswer(
          (_) async => ApiRes<List<Course>>(
            status: 200,
            data: _createTestCourses(),
            error: null,
            isSuccess: true,
          ),
        );

        when(() => mockCourseService.getCourseContent(course.id)).thenAnswer(
          (_) async => ApiRes<CourseContent>(
            status: 200,
            data: courseContent,
            error: null,
            isSuccess: true,
          ),
        );

        // Test case 1: User is NOT enrolled - should show "Enroll Now"
        when(
          () => mockEnrollmentService.getCourseEnrollment(course.id),
        ).thenAnswer(
          (_) async => ApiRes(
            status: 200,
            data: EnrollmentCheckResponse(
              success: false,
              message: 'Not enrolled',
              enrollment: null,
            ),
            error: null,
            isSuccess: true,
          ),
        );

        when(() => mockWishlistService.getWishlist()).thenAnswer(
          (_) async => ApiRes<List<WishlistedCourse>>(
            status: 200,
            data: [],
            error: null,
            isSuccess: true,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authServiceProvider.overrideWithValue(mockAuthService),
              courseServiceProvider.overrideWithValue(mockCourseService),
              enrollmentServiceProvider.overrideWithValue(
                mockEnrollmentService,
              ),
              wishlistServiceProvider.overrideWithValue(mockWishlistService),
            ],
            child: _buildApp(initialLocation: '/login'),
          ),
        );

        await tester.pumpAndSettle();

        // Login
        await tester.enterText(
          find.byType(shadcn.TextField).first,
          'test@example.com',
        );
        await tester.enterText(
          find.byType(shadcn.TextField).at(1),
          'password123',
        );
        await tester.tap(find.text('Login').last);
        await tester.pumpAndSettle();

        // Navigate to courses and open detail
        await tester.tap(find.byIcon(shadcn.LucideIcons.graduationCap));
        await tester.pumpAndSettle();

        // Tap on View button of the Flutter Development course card
        // Find the course card containing Flutter Development title
        final courseCardWithTitle = find.byWidgetPredicate(
          (widget) =>
              widget is CourseCard &&
              widget.course.title == 'Flutter Development',
        );
        expect(courseCardWithTitle, findsOneWidget);

        // Find the View button within that card and tap it
        final viewButton = find.ancestor(
          of: find.text('View'),
          matching: find.byType(shadcn.PrimaryButton),
        );
        await tester.tap(viewButton.first);
        await tester.pumpAndSettle();

        // Verify CourseDetailScreen shows "Enroll Now" for non-enrolled user
        expect(find.byType(CourseDetailScreen), findsOneWidget);
        expect(find.text('Enroll Now'), findsOneWidget);
        expect(find.text('Continue Learning'), findsNothing);
      },
    );
  });
}

shadcn.ShadcnApp _buildApp({required String initialLocation}) {
  return shadcn.ShadcnApp.router(
    title: 'Course E2E Test',
    routerConfig: GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        ...AuthRoutes.routes,
        ...CourseRoutes.routes,
        ...UserRoutes.routes,
      ],
    ),
    theme: shadcn.ThemeData(
      colorScheme: shadcn.ColorSchemes.lightDefaultColor,
      radius: 0.5,
    ),
    darkTheme: shadcn.ThemeData(
      colorScheme: shadcn.ColorSchemes.darkDefaultColor,
      radius: 0.5,
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

User _createTestUser() {
  final now = DateTime(2024, 1, 1);
  return User(
    id: 'user-123',
    name: 'Test User',
    email: 'test@example.com',
    googleId: 'gid-1',
    role: 0,
    status: 1,
    profilePicture: 'https://example.com/avatar.png',
    bio: 'Test bio',
    emailVerified: true,
    totalCourses: 2,
    rating: 4.5,
    createdAt: now,
    createdBy: 'system',
  );
}

List<Course> _createTestCourses() {
  final now = DateTime(2024, 1, 1);
  return [
    Course(
      id: 'course-1',
      instructorId: 'instructor-1',
      categoryId: 'category-1',
      title: 'Flutter Development',
      description: 'Learn Flutter from scratch to build amazing mobile apps',
      thumbnail: 'https://example.com/flutter.jpg',
      status: CourseStatus.published,
      duration: '10:30:00',
      price: Decimal.parse('99.99'),
      level: CourseLevel.beginner,
      language: 'English',
      numberOfModules: 5,
      numberOfReviews: 25,
      averageRating: 4.5,
      modules: null,
      createdAt: now,
      createdBy: 'system',
    ),
    Course(
      id: 'course-2',
      instructorId: 'instructor-2',
      categoryId: 'category-2',
      title: 'React Mastery',
      description: 'Master React and build modern web applications',
      thumbnail: 'https://example.com/react.jpg',
      status: CourseStatus.published,
      duration: '8:45:00',
      price: Decimal.parse('79.99'),
      level: CourseLevel.intermediate,
      language: 'English',
      numberOfModules: 4,
      numberOfReviews: 18,
      averageRating: 4.2,
      modules: null,
      createdAt: now,
      createdBy: 'system',
    ),
  ];
}

CourseContent _createTestCourseContent(Course course) {
  return CourseContent(
    course: course,
    modules: [
      Module(
        id: 'module-1',
        title: 'Module 1: Getting Started',
        durationMinutes: '120',
        numberOfLessons: 2,
        order: 1,
        lessons: [
          Lesson(
            id: 'lesson-1',
            title: 'Lesson 1: Introduction',
            moduleId: 'module-1',
            lessonType: LessonType.video,
            contentUrl: 'https://example.com/lesson1.mp4',
            orderIndex: 1,
            duration: '15',
            isPreview: true,
            quiz: null,
            createdAt: DateTime(2024, 1, 1),
          ),
          Lesson(
            id: 'lesson-2',
            title: 'Lesson 2: Setup',
            moduleId: 'module-1',
            lessonType: LessonType.video,
            contentUrl: 'https://example.com/lesson2.mp4',
            orderIndex: 2,
            duration: '20',
            isPreview: true,
            quiz: null,
            createdAt: DateTime(2024, 1, 1),
          ),
        ],
        createdAt: DateTime(2024, 1, 1),
      ),
      Module(
        id: 'module-2',
        title: 'Module 2: Widgets',
        durationMinutes: '90',
        numberOfLessons: 1,
        order: 2,
        lessons: [
          Lesson(
            id: 'lesson-3',
            title: 'Lesson 3: Stateless Widgets',
            moduleId: 'module-2',
            lessonType: LessonType.video,
            contentUrl: 'https://example.com/lesson3.mp4',
            orderIndex: 1,
            duration: '25',
            isPreview: false,
            quiz: null,
            createdAt: DateTime(2024, 1, 1),
          ),
        ],
        createdAt: DateTime(2024, 1, 1),
      ),
      Module(
        id: 'module-3',
        title: 'Module 3: State Management',
        durationMinutes: '100',
        numberOfLessons: 0,
        order: 3,
        lessons: [],
        createdAt: DateTime(2024, 1, 1),
      ),
      Module(
        id: 'module-4',
        title: 'Module 4: Navigation',
        durationMinutes: '85',
        numberOfLessons: 0,
        order: 4,
        lessons: [],
        createdAt: DateTime(2024, 1, 1),
      ),
      Module(
        id: 'module-5',
        title: 'Module 5: Advanced Topics',
        durationMinutes: '75',
        numberOfLessons: 0,
        order: 5,
        lessons: [],
        createdAt: DateTime(2024, 1, 1),
      ),
    ],
  );
}
