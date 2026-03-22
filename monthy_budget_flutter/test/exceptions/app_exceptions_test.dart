import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/exceptions/app_exceptions.dart';

void main() {
  group('AppException subclasses', () {
    test('DataException stores message and original error', () {
      final original = StateError('db failure');
      final stack = StackTrace.current;
      const exc = DataException('Failed to load', null, null);
      expect(exc.message, 'Failed to load');
      expect(exc.toString(), contains('DataException'));
      expect(exc.toString(), contains('Failed to load'));

      final excFull = DataException('err', original, stack);
      expect(excFull.originalError, original);
      expect(excFull.stackTrace, stack);
    });

    test('NetworkException stores message', () {
      const exc = NetworkException('timeout');
      expect(exc.message, 'timeout');
      expect(exc.toString(), contains('NetworkException'));
    });

    test('AuthException stores message', () {
      const exc = AuthException('unauthorized');
      expect(exc.message, 'unauthorized');
      expect(exc.toString(), contains('AuthException'));
    });

    test('SubscriptionException stores message', () {
      const exc = SubscriptionException('expired');
      expect(exc.message, 'expired');
      expect(exc.toString(), contains('SubscriptionException'));
    });

    test('StorageException stores message', () {
      const exc = StorageException('disk full');
      expect(exc.message, 'disk full');
      expect(exc.toString(), contains('StorageException'));
    });

    test('all exceptions implement Exception', () {
      const exceptions = <AppException>[
        DataException('a'),
        NetworkException('b'),
        AuthException('c'),
        SubscriptionException('d'),
        StorageException('e'),
      ];
      for (final exc in exceptions) {
        expect(exc, isA<Exception>());
        expect(exc, isA<AppException>());
      }
    });
  });
}
