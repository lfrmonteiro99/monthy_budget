import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Centralized logging service.
/// Debug mode: console output. Release mode: sends to Sentry.
class LogService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, printTime: true),
    filter: kReleaseMode ? ProductionFilter() : DevelopmentFilter(),
  );

  static void info(String message, [dynamic data]) {
    _logger.i(message, error: data);
  }

  static void warning(String message, [dynamic error]) {
    _logger.w(message, error: error);
    if (kReleaseMode && error != null) {
      Sentry.captureMessage(message, level: SentryLevel.warning);
    }
  }

  static void error(String message, dynamic error, [StackTrace? stack]) {
    _logger.e(message, error: error, stackTrace: stack);
    if (kReleaseMode) {
      Sentry.captureException(error, stackTrace: stack);
    }
  }

  static void debug(String message, [dynamic data]) {
    _logger.d(message, error: data);
  }
}
