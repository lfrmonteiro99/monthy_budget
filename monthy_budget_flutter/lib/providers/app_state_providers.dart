import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/coach_insight.dart';
import '../models/local_dashboard_config.dart';
import '../models/notification_preferences.dart';
import '../models/onboarding_state.dart';
import '../models/purchase_record.dart';

/// Misc AppHome domains migrated to storage-only providers (#632 increment 7).
/// Loading/persistence logic stays in AppHome; each notifier just holds state.

class FavoritesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => const [];
  void set(List<String> v) => state = v;
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<String>>(FavoritesNotifier.new);

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();
  void set(OnboardingState v) => state = v;
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);

class DashboardConfigNotifier extends Notifier<LocalDashboardConfig> {
  @override
  LocalDashboardConfig build() => const LocalDashboardConfig();
  void set(LocalDashboardConfig v) => state = v;
}

final dashboardConfigProvider =
    NotifierProvider<DashboardConfigNotifier, LocalDashboardConfig>(
  DashboardConfigNotifier.new,
);

class NotificationPrefsNotifier extends Notifier<NotificationPreferences> {
  @override
  NotificationPreferences build() => NotificationPreferences();
  void set(NotificationPreferences v) => state = v;
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsNotifier, NotificationPreferences>(
  NotificationPrefsNotifier.new,
);

class PurchaseHistoryNotifier extends Notifier<PurchaseHistory> {
  @override
  PurchaseHistory build() => const PurchaseHistory();
  void set(PurchaseHistory v) => state = v;
}

final purchaseHistoryProvider =
    NotifierProvider<PurchaseHistoryNotifier, PurchaseHistory>(
  PurchaseHistoryNotifier.new,
);

class ApiKeyNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String v) => state = v;
}

final apiKeyProvider =
    NotifierProvider<ApiKeyNotifier, String>(ApiKeyNotifier.new);

class CoachInsightNotifier extends Notifier<CoachInsight?> {
  @override
  CoachInsight? build() => null;
  void set(CoachInsight? v) => state = v;
}

final latestCoachInsightProvider =
    NotifierProvider<CoachInsightNotifier, CoachInsight?>(
  CoachInsightNotifier.new,
);

class HasMealPlanNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool v) => state = v;
}

final hasMealPlanProvider =
    NotifierProvider<HasMealPlanNotifier, bool>(HasMealPlanNotifier.new);
