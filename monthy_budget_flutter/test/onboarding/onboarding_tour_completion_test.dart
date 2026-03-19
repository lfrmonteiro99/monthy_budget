import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/onboarding_state.dart';
import 'package:monthly_management/onboarding/onboarding_tour_completion.dart';

void main() {
  group('markOnboardingTourDone', () {
    test('persists immediately and updates state on next frame', () async {
      OnboardingState? appliedState;
      OnboardingState? persistedState;
      FrameCallback? scheduledCallback;

      markOnboardingTourDone(
        key: 'meals',
        currentState: const OnboardingState(),
        mounted: true,
        applyState: (state) => appliedState = state,
        persistState: (state) async => persistedState = state,
        schedulePostFrame: (callback) => scheduledCallback = callback,
      );

      expect(appliedState, isNull);
      expect(persistedState?.isTourDone('meals'), isTrue);
      expect(scheduledCallback, isNotNull);

      scheduledCallback!(Duration.zero);

      expect(appliedState?.isTourDone('meals'), isTrue);
    });

    test('skips state update after unmount but still persists', () async {
      OnboardingState? appliedState;
      OnboardingState? persistedState;
      FrameCallback? scheduledCallback;

      markOnboardingTourDone(
        key: 'coach',
        currentState: const OnboardingState(),
        mounted: false,
        applyState: (state) => appliedState = state,
        persistState: (state) async => persistedState = state,
        schedulePostFrame: (callback) => scheduledCallback = callback,
      );

      scheduledCallback!(Duration.zero);

      expect(appliedState, isNull);
      expect(persistedState?.isTourDone('coach'), isTrue);
    });
  });
}
