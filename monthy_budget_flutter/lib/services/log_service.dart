import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'analytics_service.dart';

class LogService {
  LogService._();

  static const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 100,
    ),
  );

  static bool get sentryEnabled => !kDebugMode && _sentryDsn.isNotEmpty;

  static Future<void> initApp(FutureOr<void> Function() appRunner) async {
    if (!sentryEnabled) {
      await Future.sync(appRunner);
      return;
    }

    await SentryFlutter.init((options) {
      options.dsn = _sentryDsn;
      options.environment = kReleaseMode ? 'production' : 'development';
      options.tracesSampleRate = 0.2;
      options.attachStacktrace = true;
      options.sendDefaultPii = false;
      options.enableAutoSessionTracking = true;
    }, appRunner: () async => Future.sync(appRunner));
  }

  static void info(
    String message, {
    String category = 'app',
    Map<String, Object?> data = const {},
  }) {
    _logger.i(_formatMessage(message, category: category, data: data));
  }

  static void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String category = 'app',
    Map<String, Object?> data = const {},
  }) {
    _logger.w(
      _formatMessage(message, category: category, data: data),
      error: error,
      stackTrace: stackTrace,
    );
    breadcrumb(
      message,
      category: category,
      data: data,
      level: SentryLevel.warning,
    );
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String category = 'app',
    Map<String, Object?> data = const {},
  }) {
    _logger.e(
      _formatMessage(message, category: category, data: data),
      error: error,
      stackTrace: stackTrace,
    );
    breadcrumb(
      message,
      category: category,
      data: data,
      level: SentryLevel.error,
    );

    unawaited(
      AnalyticsService.instance.trackError(
        category: category,
        error: error,
        properties: data,
      ),
    );

    if (!sentryEnabled) return;

    unawaited(
      Sentry.captureException(
        error ?? message,
        stackTrace: stackTrace,
        withScope: (scope) async {
          scope.setTag('category', category);
          final contextData = <String, Object?>{
            for (final entry in data.entries)
              if (entry.value != null) entry.key: entry.value,
          };
          if (contextData.isNotEmpty) {
            await scope.setContexts('log_data', contextData);
          }
        },
      ),
    );
  }

  static void breadcrumb(
    String message, {
    String category = 'app',
    Map<String, Object?> data = const {},
    SentryLevel level = SentryLevel.info,
  }) {
    if (!sentryEnabled) return;
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        level: level,
        data: data,
      ),
    );
  }

  static String _formatMessage(
    String message, {
    required String category,
    required Map<String, Object?> data,
  }) {
    if (data.isEmpty) return '[$category] $message';
    final extra = data.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join(', ');
    return '[$category] $message ($extra)';
  }
}
