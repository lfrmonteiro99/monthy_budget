import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Validates the synchronous-loading-guard pattern used by CoachScreen
/// to prevent double credit deduction from rapid chip taps (#759).
///
/// The real code sets `_loading = true` synchronously BEFORE any async work,
/// ensuring a second call is blocked by the guard check at the top.
void main() {
  group('Synchronous loading guard prevents double execution (#759)', () {
    test('second call is rejected when loading guard is set before async work', () async {
      var loading = false;
      var executionCount = 0;
      final completer = Completer<void>();

      Future<void> sendMessage() async {
        // Guard: reject if already loading
        if (loading) return;

        // Synchronously set loading BEFORE any async work (the fix)
        loading = true;

        try {
          executionCount++;
          // Simulate async work (e.g., incrementConversationCount)
          await completer.future;
        } finally {
          loading = false;
        }
      }

      // Fire two calls back-to-back (simulating rapid chip taps)
      final call1 = sendMessage();
      final call2 = sendMessage();

      // Complete the async work
      completer.complete();
      await call1;
      await call2;

      // Only one execution should have occurred
      expect(executionCount, 1);
    });

    test('without synchronous guard, both calls would execute (bug scenario)', () async {
      var loading = false;
      var executionCount = 0;

      Future<void> sendMessageBuggy() async {
        // Guard check
        if (loading) return;

        // BUG: async gap before setting loading
        await Future<void>.delayed(Duration.zero);

        loading = true;
        try {
          executionCount++;
        } finally {
          loading = false;
        }
      }

      // Both calls pass the guard because loading isn't set synchronously
      final call1 = sendMessageBuggy();
      final call2 = sendMessageBuggy();

      await call1;
      await call2;

      // Both executed -- this is the bug
      expect(executionCount, 2);
    });
  });
}
