import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/subscription_state.dart';

void main() {
  group('SubscriptionState.copyWith clear flags (#760)', () {
    SubscriptionState makeState({
      String? lastMicroAction,
      DateTime? lastMicroActionDate,
      String? lastSessionInsight,
      String? lastSessionInsightValue,
    }) {
      return SubscriptionState(
        trialStartDate: DateTime(2026, 1, 1),
        lastMicroAction: lastMicroAction,
        lastMicroActionDate: lastMicroActionDate,
        lastSessionInsight: lastSessionInsight,
        lastSessionInsightValue: lastSessionInsightValue,
      );
    }

    test('copyWith without clear flags preserves nullable fields', () {
      final state = makeState(
        lastMicroAction: 'save 10 EUR',
        lastMicroActionDate: DateTime(2026, 3, 20),
        lastSessionInsight: 'spending down 5%',
        lastSessionInsightValue: '€50',
      );
      final copy = state.copyWith();
      expect(copy.lastMicroAction, 'save 10 EUR');
      expect(copy.lastMicroActionDate, DateTime(2026, 3, 20));
      expect(copy.lastSessionInsight, 'spending down 5%');
      expect(copy.lastSessionInsightValue, '€50');
    });

    test('clearLastMicroAction sets lastMicroAction and lastMicroActionDate to null', () {
      final state = makeState(
        lastMicroAction: 'save 10 EUR',
        lastMicroActionDate: DateTime(2026, 3, 20),
      );
      final cleared = state.copyWith(clearLastMicroAction: true);
      expect(cleared.lastMicroAction, isNull);
      expect(cleared.lastMicroActionDate, isNull);
    });

    test('clearLastSessionInsight sets lastSessionInsight and lastSessionInsightValue to null', () {
      final state = makeState(
        lastSessionInsight: 'spending down 5%',
        lastSessionInsightValue: '€50',
      );
      final cleared = state.copyWith(clearLastSessionInsight: true);
      expect(cleared.lastSessionInsight, isNull);
      expect(cleared.lastSessionInsightValue, isNull);
    });

    test('clear flags take precedence over new values', () {
      final state = makeState(
        lastMicroAction: 'old action',
        lastMicroActionDate: DateTime(2026, 3, 1),
      );
      final result = state.copyWith(
        clearLastMicroAction: true,
        lastMicroAction: 'new action',
      );
      expect(result.lastMicroAction, isNull);
      expect(result.lastMicroActionDate, isNull);
    });

    test('clearLastSessionInsight flag takes precedence over new values', () {
      final state = makeState(
        lastSessionInsight: 'old insight',
        lastSessionInsightValue: '€100',
      );
      final result = state.copyWith(
        clearLastSessionInsight: true,
        lastSessionInsight: 'new insight',
        lastSessionInsightValue: '€200',
      );
      expect(result.lastSessionInsight, isNull);
      expect(result.lastSessionInsightValue, isNull);
    });

    test('clearing one group does not affect the other', () {
      final state = makeState(
        lastMicroAction: 'save 10 EUR',
        lastMicroActionDate: DateTime(2026, 3, 20),
        lastSessionInsight: 'spending down 5%',
        lastSessionInsightValue: '€50',
      );
      final cleared = state.copyWith(clearLastMicroAction: true);
      expect(cleared.lastMicroAction, isNull);
      expect(cleared.lastMicroActionDate, isNull);
      expect(cleared.lastSessionInsight, 'spending down 5%');
      expect(cleared.lastSessionInsightValue, '€50');
    });

    test('both clear flags can be used simultaneously', () {
      final state = makeState(
        lastMicroAction: 'save 10 EUR',
        lastMicroActionDate: DateTime(2026, 3, 20),
        lastSessionInsight: 'spending down 5%',
        lastSessionInsightValue: '€50',
      );
      final cleared = state.copyWith(
        clearLastMicroAction: true,
        clearLastSessionInsight: true,
      );
      expect(cleared.lastMicroAction, isNull);
      expect(cleared.lastMicroActionDate, isNull);
      expect(cleared.lastSessionInsight, isNull);
      expect(cleared.lastSessionInsightValue, isNull);
    });

    test('clear flags default to false (no clearing)', () {
      final state = makeState(
        lastMicroAction: 'action',
        lastSessionInsight: 'insight',
      );
      final copy = state.copyWith(clearLastMicroAction: false, clearLastSessionInsight: false);
      expect(copy.lastMicroAction, 'action');
      expect(copy.lastSessionInsight, 'insight');
    });
  });
}
