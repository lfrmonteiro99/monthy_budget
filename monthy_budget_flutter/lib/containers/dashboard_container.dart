import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/tax/tax_factory.dart';
import '../models/app_settings.dart';
import '../models/data_health_status.dart';
import '../providers/app_state_providers.dart';
import '../providers/budget_config_providers.dart';
import '../providers/expense_providers.dart';
import '../providers/savings_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/subscription_providers.dart';
import '../screens/confidence_center_screen.dart';
import '../screens/dashboard_screen.dart';
import '../services/ad_service.dart';
import '../services/data_health_service.dart';
import '../services/log_service.dart';
import '../utils/calculations.dart';
import '../utils/data_alert_builder.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/error_boundary.dart';
import '../widgets/feature_discovery_card.dart';
import '../widgets/trial_banner.dart';

/// Dashboard tab subtree extracted from `_AppHomeState.build` (#632 increment
/// 10a — build decomposition).
///
/// Owns the dashboard tab: reads its domain state directly from the Riverpod
/// providers (settings, expenses, budgets, savings, subscription, …) and
/// computes its own [BudgetSummary], so AppHome no longer forwards ~28 provider
/// reads into [DashboardScreen]. Only the things a container cannot derive from
/// providers are injected: the tour FAB/nav keys, the [DataHealthService]
/// instance (critical-alert count), and the navigation/action callbacks that
/// reach back into AppHome's routing and handlers.
class DashboardContainer extends ConsumerWidget {
  const DashboardContainer({
    super.key,
    required this.dataHealthService,
    required this.onSaveSettings,
    required this.onSnapshotExpenses,
    required this.onAddExpense,
    required this.onOpenExpenseTracker,
    required this.onViewTrends,
    required this.onOpenSavingsGoals,
    required this.onOpenRecurringExpenses,
    required this.onOpenSettings,
    required this.onTourComplete,
    required this.onOpenInsights,
    required this.onOpenCoach,
    required this.onOpenIncome,
    required this.onOpenTaxSimulator,
    required this.onOpenConfidenceCenter,
    required this.onUpgrade,
    required this.onExploreFeature,
    required this.onTrackFeature,
    this.fabKey,
    this.navBarKey,
  });

  /// Source of data-health statuses for the critical-alert banner. Owned by
  /// AppHome (loaded in its initState), so it is injected rather than read from
  /// a provider.
  final DataHealthService dataHealthService;

  final ValueChanged<AppSettings> onSaveSettings;
  final VoidCallback onSnapshotExpenses;
  final VoidCallback onAddExpense;
  final VoidCallback onOpenExpenseTracker;
  final VoidCallback onViewTrends;
  final VoidCallback onOpenSavingsGoals;
  final VoidCallback onOpenRecurringExpenses;
  final VoidCallback onOpenSettings;
  final VoidCallback onTourComplete;
  final VoidCallback onOpenInsights;
  final VoidCallback onOpenCoach;
  final VoidCallback onOpenIncome;
  final VoidCallback onOpenTaxSimulator;
  final VoidCallback onOpenConfidenceCenter;

  /// Opens the paywall (TrialBanner upgrade CTA).
  final VoidCallback onUpgrade;

  /// Navigates to a premium feature from the discovery card.
  final ValueChanged<String> onExploreFeature;

  /// Marks a feature as discovered when the discovery card is dismissed.
  final ValueChanged<String> onTrackFeature;

  /// Tour anchors — created and reused by AppHome's FAB/nav bar.
  final GlobalKey? fabKey;
  final GlobalKey? navBarKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the providers this tab renders so the dashboard rebuilds on change.
    final settings = ref.watch(settingsProvider);
    final subscription = ref.watch(subscriptionProvider);
    final purchaseHistory = ref.watch(purchaseHistoryProvider);
    final dashboardConfig = ref.watch(dashboardConfigProvider);
    final expenseHistory = ref.watch(expenseHistoryProvider);
    final actualExpenses = ref.watch(actualExpensesProvider);
    final actualExpenseHistory = ref.watch(actualExpenseHistoryProvider);
    final monthlyBudgets = ref.watch(monthlyBudgetsProvider);
    final savingsGoals = ref.watch(savingsGoalsProvider);
    final savingsProjections = ref.watch(savingsProjectionsProvider);
    final recurringExpenses = ref.watch(recurringExpensesProvider);
    final customCategories = ref.watch(customCategoriesProvider);
    final notificationPrefs = ref.watch(notificationPrefsProvider);
    final onboarding = ref.watch(onboardingProvider);

    final taxSystem = getTaxSystem(settings.country);
    final summary = calculateBudgetSummary(
      settings.salaries,
      settings.personalInfo,
      settings.expenses,
      taxSystem,
      monthlyBudgets: monthlyBudgets,
    );

    final dashboardScreen = ErrorBoundary(
      onError: (error, stack) => LogService.error(
        'Dashboard subtree error',
        error: error,
        stackTrace: stack,
        category: 'ui.dashboard',
      ),
      child: DashboardScreen(
        settings: settings,
        summary: summary,
        purchaseHistory: purchaseHistory,
        onSaveSettings: onSaveSettings,
        dashboardConfig: dashboardConfig,
        expenseHistory: expenseHistory,
        onSnapshotExpenses: onSnapshotExpenses,
        actualExpenses: actualExpenses,
        onAddExpense: onAddExpense,
        monthlyBudgets: monthlyBudgets,
        onOpenExpenseTracker: onOpenExpenseTracker,
        onViewTrends: onViewTrends,
        savingsGoals: savingsGoals,
        savingsProjections: savingsProjections,
        onOpenSavingsGoals: onOpenSavingsGoals,
        recurringExpenses: recurringExpenses,
        actualExpenseHistory: actualExpenseHistory,
        billReminderDaysBefore: notificationPrefs.billReminderDaysBefore,
        onOpenRecurringExpenses: onOpenRecurringExpenses,
        onOpenSettings: onOpenSettings,
        showTour: !onboarding.isTourDone('dashboard'),
        onTourComplete: onTourComplete,
        fabKey: fabKey,
        navBarKey: navBarKey,
        onOpenInsights: onOpenInsights,
        onOpenCoach: onOpenCoach,
        onOpenIncome: onOpenIncome,
        onOpenTaxSimulator: onOpenTaxSimulator,
        customCategories: customCategories,
      ),
    );

    final criticalCount = buildAlerts(statuses: dataHealthService.statuses)
        .where((a) => a.severity == AlertSeverity.critical)
        .length;

    return Column(
      children: [
        if (subscription.isTrialActive)
          TrialBanner(subscription: subscription, onUpgrade: onUpgrade),
        if (subscription.isTrialActive &&
            subscription.nextFeatureToDiscover != null)
          FeatureDiscoveryCard(
            subscription: subscription,
            onExploreFeature: onExploreFeature,
            onDismiss: () {
              final next = subscription.nextFeatureToDiscover;
              if (next != null) onTrackFeature(next);
            },
          ),
        CriticalAlertBanner(
          criticalCount: criticalCount,
          onTap: onOpenConfidenceCenter,
        ),
        Expanded(child: dashboardScreen),
        AdBannerWidget(showAd: AdService.shouldShowAds(subscription)),
      ],
    );
  }
}
