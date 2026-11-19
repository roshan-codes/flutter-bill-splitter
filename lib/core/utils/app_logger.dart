import 'package:flutter/foundation.dart';

/// Centralized, structured logging and error tracking utility for TTMM Club.
/// Replaces unstructured `debugPrint` / `print` calls with consistent log tagging.
class AppLogger {
  AppLogger._();

  /// Logs informational events (e.g. sync started, story loaded).
  static void info(String message, {String tag = 'INFO'}) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  /// Logs warnings (e.g. network retry, fallback resolution).
  static void warn(String message, {String tag = 'WARN', Object? error}) {
    if (kDebugMode) {
      debugPrint('[$tag] $message ${error != null ? '($error)' : ''}');
    }
  }

  /// Logs caught exceptions with optional stack trace.
  static void error(
    String message, {
    String tag = 'ERROR',
    Object? error,
    StackTrace? stackTrace,
  }) {
    debugPrint('[$tag] $message');
    if (error != null) {
      debugPrint('[$tag] Error details: $error');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('[$tag] Stack trace:\n$stackTrace');
    }
  }
}
