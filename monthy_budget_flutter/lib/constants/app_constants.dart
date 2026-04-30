/// Application-wide named constants.
/// Replaces magic numbers for readability and maintainability.
class AppConstants {
  AppConstants._(); // prevent instantiation

  // ---------------------------------------------------------------------------
  // Lifecycle / debounce
  // ---------------------------------------------------------------------------

  /// Skip data refresh when app is resumed within this window.
  static const resumeDebounce = Duration(seconds: 30);

  /// Minimum interval between AI / rate-limited calls.
  static const rateLimitInterval = Duration(seconds: 3);

  // ---------------------------------------------------------------------------
  // API & network timeouts
  // ---------------------------------------------------------------------------

  /// Timeout for the AI command-chat service call.
  static const commandChatTimeout = Duration(seconds: 12);

  /// Timeout for remote grocery-data fetch.
  static const groceryFetchTimeout = Duration(seconds: 15);

  /// Timeout for geolocation position request.
  static const geoLocationTimeout = Duration(seconds: 10);

  // ---------------------------------------------------------------------------
  // SnackBar display durations
  // ---------------------------------------------------------------------------

  /// Brief, informational snackbar (e.g. "added to list").
  static const snackBarShort = Duration(seconds: 2);

  /// Medium snackbar (e.g. barcode-invoice detection).
  static const snackBarMedium = Duration(seconds: 4);

  /// Long / error snackbar (e.g. auth errors).
  static const snackBarLong = Duration(seconds: 5);

  /// Extended snackbar with undo action.
  static const snackBarUndo = Duration(seconds: 8);

  // ---------------------------------------------------------------------------
  // Animation durations
  // ---------------------------------------------------------------------------

  /// Quick micro-interaction (toggle, chip select, position snap).
  static const animFast = Duration(milliseconds: 200);

  /// Smooth scroll to bottom in chat panels.
  static const animScrollToBottom = Duration(milliseconds: 220);

  /// Standard transition (expand/collapse, recurring-expense cards).
  static const animStandard = Duration(milliseconds: 250);

  /// Page swipe / scroll-into-view / onboarding tour focus.
  static const animPageTransition = Duration(milliseconds: 300);

  /// Progress-bar fill animation.
  static const animProgressBar = Duration(milliseconds: 400);

  /// Wizard entrance bounce / setup-wizard scale.
  static const animBounce = Duration(milliseconds: 500);

  /// Health-ring / tween animation builder.
  static const animHealthRing = Duration(milliseconds: 600);

  /// Command-chat FAB pulse cycle.
  static const animFabPulse = Duration(milliseconds: 1000);

  /// Branded loading breathing animation.
  static const animBrandedLoading = Duration(milliseconds: 1400);

  /// First-use FAB auto-dismiss pulse.
  static const fabFirstUseDismiss = Duration(milliseconds: 3000);

  // ---------------------------------------------------------------------------
  // Delays (post-frame callbacks, tour start, etc.)
  // ---------------------------------------------------------------------------

  /// Delay before starting an onboarding tour after layout.
  static const tourStartDelay = Duration(milliseconds: 500);

  // ---------------------------------------------------------------------------
  // Notification scheduling
  // ---------------------------------------------------------------------------

  /// Near-future fallback when the reminder window has already started.
  static const nearFutureReminder = Duration(minutes: 1);

  // ---------------------------------------------------------------------------
  // Coach / recommendation
  // ---------------------------------------------------------------------------

  /// Auto-dismiss timer for the coach mode recommendation banner.
  static const recommendationAutoDismiss = Duration(seconds: 8);

  // ---------------------------------------------------------------------------
  // Sentinel dates
  // ---------------------------------------------------------------------------

  /// Far-past sentinel so subscription trial is NOT active before load().
  static final farPastDate = DateTime(2000);
}

/// Bottom-navigation tab indices.
///
/// Use [AppTab.navigationIndex] instead of storing raw `0`, `1`, `2`, `3` integers.
enum AppTab {
  dashboard, // 0
  expenses, // 1
  planHub, // 2
  more; // 3

  int get navigationIndex => switch (this) {
    AppTab.dashboard => 0,
    AppTab.expenses => 1,
    AppTab.planHub => 2,
    AppTab.more => 3,
  };

  String get featureKey => switch (this) {
    AppTab.dashboard => 'dashboard',
    AppTab.expenses => 'expense_tracker',
    AppTab.planHub => 'plan_and_shop',
    AppTab.more => 'more',
  };

  static AppTab fromNavigationIndex(int index) {
    return switch (index) {
      0 => AppTab.dashboard,
      1 => AppTab.expenses,
      2 => AppTab.planHub,
      3 => AppTab.more,
      _ => throw RangeError.range(index, 0, 3, 'index'),
    };
  }
}
