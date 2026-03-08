import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/utils/rate_limiter.dart';

void main() {
  group('RateLimiter', () {
    test('allows first call', () {
      final limiter = RateLimiter(minInterval: const Duration(seconds: 3));
      expect(limiter.tryCall(), isTrue);
    });

    test('blocks rapid second call', () {
      final limiter = RateLimiter(minInterval: const Duration(seconds: 3));
      expect(limiter.tryCall(), isTrue);
      expect(limiter.tryCall(), isFalse);
    });

    test('allows call after interval has elapsed', () {
      final limiter = RateLimiter(minInterval: const Duration(seconds: 3));
      limiter.lastCallForTest = DateTime.now().subtract(const Duration(seconds: 4));
      expect(limiter.tryCall(), isTrue);
    });

    test('reset allows immediate next call', () {
      final limiter = RateLimiter(minInterval: const Duration(seconds: 3));
      limiter.tryCall();
      limiter.reset();
      expect(limiter.tryCall(), isTrue);
    });

    test('cooldownRemaining returns zero when ready', () {
      final limiter = RateLimiter(minInterval: const Duration(seconds: 3));
      expect(limiter.cooldownRemaining, Duration.zero);
    });

    test('cooldownRemaining returns positive when throttled', () {
      final limiter = RateLimiter(minInterval: const Duration(seconds: 3));
      limiter.tryCall();
      expect(limiter.cooldownRemaining, greaterThan(Duration.zero));
    });
  });
}
