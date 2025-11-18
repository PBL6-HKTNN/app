import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:decimal/decimal.dart';

import 'package:codemy_app/src/features/course/widgets/course_card.dart';
import 'package:codemy_app/src/features/course/models/entities/course.dart';
import 'package:codemy_app/src/features/course/models/entities/module.dart';
import 'package:codemy_app/src/features/course/enums/course_level.dart';
import 'package:codemy_app/src/features/course/enums/course_status.dart';

void main() {
  group('CourseCard Widget Tests', () {
    late Course testCourse;
    late Course testCourseWithModules;

    setUp(() {
      // Course cơ bản
      testCourse = Course(
        id: 'test-course-1',
        instructorId: 'instructor-1',
        categoryId: 'cat-1',
        title: 'Flutter Complete Guide 2024',
        description:
            'Learn Flutter from scratch with hands-on projects and real-world examples.',
        thumbnail: 'https://example.com/thumbnail.jpg',
        status: CourseStatus.published,
        duration: '40h 30m',
        price: Decimal.parse('99.99'),
        level: CourseLevel.beginner,
        language: 'English',
        numberOfModules: 12,
        numberOfReviews: 100,
        averageRating: 4.8,
        modules: null,
        createdAt: DateTime(2024, 1, 1),
        createdBy: 'instructor-1',
      );

      // Course có modules
      testCourseWithModules = Course(
        id: 'test-course-2',
        instructorId: 'instructor-1',
        categoryId: 'cat-1',
        title: 'Advanced Flutter',
        description: 'Master advanced Flutter concepts.',
        thumbnail: 'https://example.com/advanced.jpg',
        status: CourseStatus.published,
        duration: '60h',
        price: Decimal.parse('149.99'),
        level: CourseLevel.advanced,
        language: 'English',
        numberOfModules: 8,
        numberOfReviews: 80,
        averageRating: 4.9,
        modules: [
          Module(
            id: 'mod-1',
            title: 'State Management',
            durationMinutes: '10h',
            numberOfLessons: 5,
            order: 1,
            lessons: null,
            createdAt: DateTime(2024, 1, 1),
            createdBy: 'instructor-1',
          ),
          Module(
            id: 'mod-2',
            title: 'Advanced Widgets',
            durationMinutes: '12h',
            numberOfLessons: 7,
            order: 2,
            lessons: null,
            createdAt: DateTime(2024, 1, 1),
            createdBy: 'instructor-1',
          ),
        ],
        createdAt: DateTime(2024, 1, 1),
        createdBy: 'instructor-1',
      );
    });

    /// Helper: Build widget với ShadcnApp và GoRouter
    Widget buildTestWidget(Widget child) {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
          GoRoute(
            path: '/courses/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              final source = state.uri.queryParameters['source'];
              return Scaffold(
                child: Center(
                  child: Text('Course Detail: $id, Source: $source'),
                ),
              );
            },
          ),
          GoRoute(
            path: '/learn/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return Scaffold(child: Center(child: Text('Learn Course: $id')));
            },
          ),
        ],
      );

      return ShadcnApp.router(
        routerConfig: router,
        title: 'Test App',
        themeMode: ThemeMode.light,
        theme: ThemeData(colorScheme: ColorSchemes.lightBlue, radius: 0.5),
      );
    }

    // ============================================================
    // TEST 1: Render cơ bản
    // ============================================================
    testWidgets('should render course card with basic information', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(CourseCard(course: testCourse)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Flutter Complete Guide 2024'), findsOneWidget);
      expect(find.textContaining('Learn Flutter from scratch'), findsOneWidget);
      expect(find.text('\$99.99'), findsOneWidget);
      expect(find.text('40h 30m'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
    });

    // ============================================================
    // TEST 2: Tính toán lessons
    // ============================================================
    testWidgets('should calculate total lessons from modules correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(CourseCard(course: testCourseWithModules)),
      );
      await tester.pumpAndSettle();

      // Assert - 2 modules với 5 + 7 = 12 lessons
      expect(find.text('2 modules, 12 lessons'), findsOneWidget);
      expect(find.text('Advanced Flutter'), findsOneWidget);
    });

    // ============================================================
    // TEST 3: Button Learn vs View
    // ============================================================
    testWidgets('should show "Learn" button when isJoined is true', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(CourseCard(course: testCourse, isJoined: true)),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('View'), findsNothing);
    });

    testWidgets('should show "View" button when isJoined is false', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(CourseCard(course: testCourse, isJoined: false)),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('View'), findsOneWidget);
      expect(find.text('Learn'), findsNothing);
    });

    // ============================================================
    // TEST 4: Navigation
    // ============================================================
    testWidgets('should navigate to learn page when tapping "Learn" button', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildTestWidget(CourseCard(course: testCourse, isJoined: true)),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Learn'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Learn Course: test-course-1'), findsOneWidget);
    });

    testWidgets('should navigate to course detail when tapping "View" button', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildTestWidget(CourseCard(course: testCourse, isJoined: false)),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('Course Detail: test-course-1, Source: all'),
        findsOneWidget,
      );
    });

    // ============================================================
    // TEST 5: Icons
    // ============================================================
    testWidgets('should display clock and book icons', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(CourseCard(course: testCourse)));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == LucideIcons.clock,
        ),
        findsOneWidget,
      );

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == LucideIcons.bookOpen,
        ),
        findsOneWidget,
      );
    });

    // ============================================================
    // TEST 6: Widgets cơ bản
    // ============================================================
    testWidgets('should have Card and PrimaryButton widgets', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(CourseCard(course: testCourse)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.byType(Gap), findsWidgets);
    });
  });
}
