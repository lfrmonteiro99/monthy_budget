import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../models/onboarding_state.dart';

typedef OnboardingStateSaver = Future<void> Function(OnboardingState state);
typedef PostFrameScheduler = void Function(FrameCallback callback);

void markOnboardingTourDone({
  required String key,
  required OnboardingState currentState,
  required void Function(OnboardingState state) applyState,
  required OnboardingStateSaver persistState,
  required bool mounted,
  PostFrameScheduler? schedulePostFrame,
}) {
  final updated = currentState.copyWith(
    toursCompleted: {...currentState.toursCompleted, key: true},
  );

  final scheduler =
      schedulePostFrame ?? WidgetsBinding.instance.addPostFrameCallback;
  scheduler((_) {
    if (!mounted) return;
    applyState(updated);
  });

  unawaited(persistState(updated));
}
