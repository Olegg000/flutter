import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final timeStamp = DateTime.now().toString().split('.')[0];
      final logTag = tag != null ? '[$tag]' : '';
      debugPrint('[$timeStamp] $logTag $message');
    }
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final timeStamp = DateTime.now().toString().split('.')[0];
      final logTag = tag != null ? '[$tag]' : '';
      debugPrint('[$timeStamp] $logTag ERROR: $message');
      if (error != null) {
        debugPrint('ERROR FULL: $error');
      }
      if (error != null) {
        debugPrint('STACKTRACE: $stackTrace');
      }
    }
  }

  static void info(String message, {String? tag}) {
    log(message, tag: tag);
  }

  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final timeStamp = DateTime.now().toString().split('.')[0];
      final logTag = tag != null ? '[$tag]' : '';
      debugPrint('[$timeStamp] $logTag WARNING: $message');
    }
  }
}
