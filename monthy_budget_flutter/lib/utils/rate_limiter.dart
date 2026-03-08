import 'package:flutter/foundation.dart';

/// Simple time-based rate limiter for expensive operations.
///
/// Prevents repeated calls within [minInterval]. Returns `true` if the
/// call is allowed, `false` if throttled.
class RateLimiter {
  final Duration minInterval;
  DateTime? _lastCall;

  RateLimiter({required this.minInterval});

  /// Returns `true` if the call is allowed (enough time has passed).
  bool tryCall() {
    final now = DateTime.now();
    if (_lastCall != null && now.difference(_lastCall!) < minInterval) {
      return false;
    }
    _lastCall = now;
    return true;
  }

  /// Resets the limiter so the next call is always allowed.
  void reset() => _lastCall = null;

  /// How long until the next call is allowed, or [Duration.zero] if ready.
  Duration get cooldownRemaining {
    if (_lastCall == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_lastCall!);
    final remaining = minInterval - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @visibleForTesting
  set lastCallForTest(DateTime? value) => _lastCall = value;
}
