import 'package:flutter_test/flutter_test.dart';
import 'excel_reporter.dart';

class TestWrapper {
  final ExcelReporter reporter;
  String _currentCategory = '';

  TestWrapper(this.reporter);

  // Cho unit tests thông thường
  void testWithReport(
    String description,
    dynamic Function() body, {
    String? expected,
    int? expectedStatusCode,
    String? category,
  }) {
    test(description, () async {
      reporter.startTest();

      final testCategory = category ?? _currentCategory;

      try {
        await body();

        reporter.recordTest(
          category: testCategory,
          testName: description,
          passed: true,
          statusCode: expectedStatusCode,
          expected: expected,
          actual: 'Success',
        );
      } catch (e, stackTrace) {
        reporter.recordTest(
          category: testCategory,
          testName: description,
          passed: false,
          statusCode: null,
          expected: expected,
          actual: 'Failed',
          error: e.toString(),
        );
        rethrow;
      }
    });
  }

  // ✅ MỚI: Cho widget tests
  void testWidgetWithReport(
    String description,
    Future<void> Function(WidgetTester) callback, {
    String? expected,
    String? category,
  }) {
    testWidgets(description, (WidgetTester tester) async {
      reporter.startTest();

      final testCategory = category ?? _currentCategory;

      try {
        await callback(tester);

        reporter.recordTest(
          category: testCategory,
          testName: description,
          passed: true,
          expected: expected,
          actual: 'Widget rendered and behaved correctly',
        );
      } catch (e, stackTrace) {
        reporter.recordTest(
          category: testCategory,
          testName: description,
          passed: false,
          expected: expected,
          actual: 'Widget test failed',
          error: e.toString(),
        );
        rethrow;
      }
    });
  }

  void groupWithReport(String description, void Function() body) {
    group(description, () {
      setUp(() {
        _currentCategory = description;
      });
      body();
    });
  }
}
