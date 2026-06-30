import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../models/subscription_state.dart';

/// Holds the current [SubscriptionState] (#632 increment 3).
///
/// Storage only: the mutation logic (load, upgrade, downgrade, trial notices,
/// remote-tier sync) stays in AppHome and calls [set] with the result, exactly
/// as it previously called `setState(() => _subscription = ...)`. Reads go
/// through AppHome's `_subscription` getter; build() watches this provider.
class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() =>
      // Far-past start so the trial is NOT active before load() completes.
      SubscriptionState(trialStartDate: AppConstants.farPastDate);

  void set(SubscriptionState value) => state = value;
}

final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);
