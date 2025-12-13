import 'package:flutter_test/flutter_test.dart';
import 'excel_reporter.dart';

class TestWrapper {
  final ExcelReporter reporter;
  String _currentCategory = '';

  TestWrapper(this.reporter);

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

  void groupWithReport(String description, void Function() body) {
    group(description, () {
      setUp(() {
        _currentCategory = description;
      });
      body();
    });
  }
}
