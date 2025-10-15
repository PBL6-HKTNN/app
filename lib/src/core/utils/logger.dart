import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '[LOG]';
      print('$prefix $message');
    }
  }

  static void error(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '[ERROR]';
      print('$prefix $message');
      if (error != null) print('$prefix Error: $error');
      if (stackTrace != null) print('$prefix StackTrace: $stackTrace');
    }
  }

  static void info(String message, {String? tag}) {
    log(message, tag: tag ?? 'INFO');
  }

  static void warning(String message, {String? tag}) {
    log(message, tag: tag ?? 'WARNING');
  }
}
