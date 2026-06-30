import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

/// Holds the currently-selected bottom-navigation tab.
///
/// First domain migrated out of [AppHome] as part of the #632 incremental
/// strangler: pure ephemeral UI state, no services or async, so it carries the
/// least risk while establishing the Riverpod wiring (ProviderScope +
/// ConsumerStatefulWidget + provider test) the later domains will follow.
class CurrentTabNotifier extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.dashboard;

  /// Select a tab. Idempotent — setting the same tab is a no-op for listeners.
  void setTab(AppTab tab) => state = tab;
}

final currentTabProvider =
    NotifierProvider<CurrentTabNotifier, AppTab>(CurrentTabNotifier.new);
