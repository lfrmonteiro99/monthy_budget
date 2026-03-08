import '../models/data_health_status.dart';

/// Human-readable labels for each sync domain.
String domainLabel(SyncDomain domain) => switch (domain) {
      SyncDomain.settings => 'Settings',
      SyncDomain.shopping => 'Shopping list',
      SyncDomain.mealPlan => 'Meal plan',
      SyncDomain.expenses => 'Expenses',
      SyncDomain.purchaseHistory => 'Purchase history',
      SyncDomain.savingsGoals => 'Savings goals',
      SyncDomain.recurringExpenses => 'Recurring expenses',
    };

/// Derives [DataAlert] instances from the current set of domain statuses
/// and optional contextual data.
///
/// Pure function — no side effects, easy to test.
List<DataAlert> buildAlerts({
  required Map<SyncDomain, SyncDomainStatus> statuses,
  DateTime? mealPlanGeneratedAt,
  bool recurringExpensesPopulatedThisMonth = true,
  double? currentMonthFoodSpend,
  double? priorMonthFoodSpend,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final alerts = <DataAlert>[];

  // 1. Per-domain sync health alerts
  for (final domain in SyncDomain.values) {
    final status = statuses[domain] ??
        SyncDomainStatus(domain: domain);

    if (status.hasRecentError) {
      alerts.add(DataAlert(
        id: 'sync_error_${domain.name}',
        severity: AlertSeverity.critical,
        domain: domain,
        title: '${domainLabel(domain)} failed to sync',
        body: status.lastErrorMessage ?? 'An error occurred during sync.',
        recommendedAction: 'Try refreshing or check your connection.',
        createdAt: status.lastErrorAt ?? effectiveNow,
      ));
    } else if (status.isStale) {
      alerts.add(DataAlert(
        id: 'stale_${domain.name}',
        severity: AlertSeverity.warning,
        domain: domain,
        title: '${domainLabel(domain)} data may be outdated',
        body: status.lastSuccessAt != null
            ? 'Last synced ${_timeAgo(status.lastSuccessAt!, effectiveNow)}.'
            : 'Never synced on this device.',
        recommendedAction: 'Open the app section to refresh.',
        createdAt: effectiveNow,
      ));
    }
  }

  // 2. Recurring expenses not populated this month
  if (!recurringExpensesPopulatedThisMonth) {
    alerts.add(DataAlert(
      id: 'recurring_not_populated',
      severity: AlertSeverity.warning,
      domain: SyncDomain.recurringExpenses,
      title: 'Recurring expenses not populated this month',
      body: 'Your recurring expenses have not been applied to this month yet.',
      recommendedAction: 'Open Expense Tracker to trigger population.',
      createdAt: effectiveNow,
    ));
  }

  // 3. Meal plan older than current week
  if (mealPlanGeneratedAt != null) {
    final daysSinceGenerated =
        effectiveNow.difference(mealPlanGeneratedAt).inDays;
    if (daysSinceGenerated > 7) {
      alerts.add(DataAlert(
        id: 'meal_plan_old',
        severity: AlertSeverity.info,
        domain: SyncDomain.mealPlan,
        title: 'Meal plan may be outdated',
        body: 'Your meal plan was generated $daysSinceGenerated days ago.',
        recommendedAction: 'Consider regenerating your meal plan.',
        createdAt: effectiveNow,
      ));
    }
  }

  // 4. Unusually large food-spend jump vs prior month
  if (currentMonthFoodSpend != null && priorMonthFoodSpend != null) {
    if (priorMonthFoodSpend > 0) {
      final increase =
          (currentMonthFoodSpend - priorMonthFoodSpend) / priorMonthFoodSpend;
      if (increase >= 0.30) {
        final pct = (increase * 100).toStringAsFixed(0);
        alerts.add(DataAlert(
          id: 'food_spend_jump',
          severity: increase >= 0.50
              ? AlertSeverity.critical
              : AlertSeverity.warning,
          domain: SyncDomain.expenses,
          title: 'Food spending up $pct% vs last month',
          body:
              'Current month food spend is significantly higher than the prior month.',
          recommendedAction: 'Review your grocery and meal expenses.',
          createdAt: effectiveNow,
        ));
      }
    }
  }

  // Sort: critical first, then warning, then info
  alerts.sort((a, b) => a.severity.sortOrder.compareTo(b.severity.sortOrder));

  return alerts;
}

String _timeAgo(DateTime past, DateTime now) {
  final diff = now.difference(past);
  if (diff.inDays > 0) {
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
  if (diff.inHours > 0) {
    return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  }
  return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
}
