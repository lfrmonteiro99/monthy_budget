import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/services/log_service.dart';

void main() {
  group('LogService', () {
    test('runs app bootstrap when Sentry is disabled', () async {
      var bootstrapped = false;

      await LogService.initApp(() async {
        bootstrapped = true;
      });

      expect(LogService.sentryEnabled, isFalse);
      expect(bootstrapped, isTrue);
    });

    test('accepts structured log payloads without throwing', () {
      expect(
        () => LogService.info(
          'Info log',
          category: 'test.info',
          data: {'attempt': 1, 'enabled': true},
        ),
        returnsNormally,
      );

      expect(
        () => LogService.warning(
          'Warning log',
          category: 'test.warning',
          error: StateError('warning'),
          data: {'step': 'retry'},
        ),
        returnsNormally,
      );

      expect(
        () => LogService.error(
          'Error log',
          category: 'test.error',
          error: ArgumentError('bad input'),
          data: {'field': 'amount'},
        ),
        returnsNormally,
      );
    });
  });
}
