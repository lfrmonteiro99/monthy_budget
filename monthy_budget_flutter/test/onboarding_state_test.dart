import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/onboarding_state.dart';

void main() {
  group('OnboardingState', () {
    test('isTourDone reads from map with false default', () {
      const state = OnboardingState(
        welcomeSeen: true,
        toursCompleted: {'dashboard': true},
      );

      expect(state.isTourDone('dashboard'), isTrue);
      expect(state.isTourDone('grocery'), isFalse);
    });

    test('copyWith preserves fields not provided', () {
      const state = OnboardingState(
        welcomeSeen: false,
        toursCompleted: {'dashboard': true},
      );
      final updated = state.copyWith(welcomeSeen: true);

      expect(updated.welcomeSeen, isTrue);
      expect(updated.toursCompleted['dashboard'], isTrue);
    });

    test('json roundtrip works', () {
      const state = OnboardingState(
        welcomeSeen: true,
        toursCompleted: {'dashboard': true, 'coach': false},
      );

      final decoded = OnboardingState.fromJsonString(state.toJsonString());
      expect(decoded.welcomeSeen, isTrue);
      expect(decoded.toursCompleted['dashboard'], isTrue);
      expect(decoded.toursCompleted['coach'], isFalse);
    });
  });
}
