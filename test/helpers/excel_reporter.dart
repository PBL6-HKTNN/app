import 'dart:io';
import 'package:excel/excel.dart';

class ExcelReporter {
  final Excel _excel = Excel.createExcel();
  late Sheet _sheet;
  int _currentRow = 1;
  final String _testFileName;
  DateTime? _testStartTime;

  ExcelReporter(this._testFileName) {
    _sheet = _excel['Test Results'];
    _createHeaders();
  }

  void _createHeaders() {
    final headers = [
      'No.',
      'Test File',
      'Test Category',
      'Description',
      'Status',
      'Status Code',
      'Duration (ms)',
      'Expected',
      'Actual',
      'Error',
      'Timestamp',
    ];

    for (var i = 0; i < headers.length; i++) {
      final cell = _sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);

      // Style cho header
      cell.cellStyle = CellStyle(
        bold: true,
        fontSize: 12,
        backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
        fontColorHex: ExcelColor.white,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
    }

    // Auto-fit columns
    for (var i = 0; i < headers.length; i++) {
      _sheet.setColumnWidth(i, 20);
    }
  }

  void startTest() {
    _testStartTime = DateTime.now();
  }

  void recordTest({
    required String category,
    required String testName,
    required bool passed,
    int? statusCode,
    String? expected,
    String? actual,
    String? error,
  }) {
    final duration = _testStartTime != null
        ? DateTime.now().difference(_testStartTime!).inMilliseconds
        : 0;

    final rowData = [
      _currentRow.toString(),
      _testFileName,
      category,
      testName,
      passed ? 'PASS' : 'FAIL',
      statusCode?.toString() ?? 'N/A',
      duration.toString(),
      expected ?? 'N/A',
      actual ?? 'N/A',
      error ?? '',
      DateTime.now().toIso8601String(),
    ];

    for (var i = 0; i < rowData.length; i++) {
      final cell = _sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: _currentRow),
      );
      cell.value = TextCellValue(rowData[i]);

      // Style cho status
      if (i == 4) {
        // Status column
        if (passed) {
          cell.cellStyle = CellStyle(
            backgroundColorHex: ExcelColor.fromHexString('#C6EFCE'),
            fontColorHex: ExcelColor.fromHexString('#006100'),
            bold: true,
          );
        } else {
          cell.cellStyle = CellStyle(
            backgroundColorHex: ExcelColor.fromHexString('#FFC7CE'),
            fontColorHex: ExcelColor.fromHexString('#9C0006'),
            bold: true,
          );
        }
      }
    }

    _currentRow++;
  }

  Future<void> save(String outputPath) async {
    final fileBytes = _excel.save();
    if (fileBytes != null) {
      final file = File(outputPath);
      await file.create(recursive: true);
      await file.writeAsBytes(fileBytes);
      print('\n✅ Excel report saved: $outputPath');
    }
  }
}
