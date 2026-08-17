import '../l10n/generated/app_localizations.dart';
import '../models/data_health_status.dart';

/// Human-readable labels for each sync domain.
String domainLabel(SyncDomain domain, S l10n) => switch (domain) {
  SyncDomain.settings => l10n.syncDomainSettings,
  SyncDomain.shopping => l10n.syncDomainShopping,
  SyncDomain.mealPlan => l10n.syncDomainMealPlan,
  SyncDomain.expenses => l10n.syncDomainExpenses,
  SyncDomain.purchaseHistory => l10n.syncDomainPurchaseHistory,
  SyncDomain.savingsGoals => l10n.syncDomainSavingsGoals,
  SyncDomain.recurringExpenses => l10n.syncDomainRecurringExpenses,
};

/// Derives [DataAlert] instances from the current set of domain statuses
/// and optional contextual data.
///
/// Pure function — no side effects, easy to test.
List<DataAlert> buildAlerts({
  required Map<SyncDomain, SyncDomainStatus> statuses,
  required S l10n,
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
    final status = statuses[domain] ?? SyncDomainStatus(domain: domain);

    if (status.hasRecentError) {
      alerts.add(
        DataAlert(
          id: 'sync_error_${domain.name}',
          severity: AlertSeverity.critical,
          domain: domain,
          title: l10n.syncFailedToSyncTitle(domainLabel(domain, l10n)),
          body: status.lastErrorMessage ?? l10n.syncErrorFallbackBody,
          recommendedAction: l10n.syncErrorAction,
          createdAt: status.lastErrorAt ?? effectiveNow,
        ),
      );
    } else if (status.isStale) {
      alerts.add(
        DataAlert(
          id: 'stale_${domain.name}',
          severity: AlertSeverity.warning,
          domain: domain,
          title: l10n.syncStaleTitle(domainLabel(domain, l10n)),
          body: status.lastSuccessAt != null
              ? l10n.syncLastSyncedBody(
                  _timeAgo(status.lastSuccessAt!, effectiveNow, l10n),
                )
              : l10n.syncNeverSyncedBody,
          recommendedAction: l10n.syncOpenSectionAction,
          createdAt: effectiveNow,
        ),
      );
    }
  }

  // 2. Recurring expenses not populated this month
  if (!recurringExpensesPopulatedThisMonth) {
    alerts.add(
      DataAlert(
        id: 'recurring_not_populated',
        severity: AlertSeverity.warning,
        domain: SyncDomain.recurringExpenses,
        title: l10n.syncRecurringNotPopulatedTitle,
        body: l10n.syncRecurringNotPopulatedBody,
        recommendedAction: l10n.syncRecurringNotPopulatedAction,
        createdAt: effectiveNow,
      ),
    );
  }

  // 3. Meal plan older than current week
  if (mealPlanGeneratedAt != null) {
    final daysSinceGenerated = effectiveNow
        .difference(mealPlanGeneratedAt)
        .inDays;
    if (daysSinceGenerated > 7) {
      alerts.add(
        DataAlert(
          id: 'meal_plan_old',
          severity: AlertSeverity.info,
          domain: SyncDomain.mealPlan,
          title: l10n.syncMealPlanOldTitle,
          body: l10n.syncMealPlanOldBody(daysSinceGenerated),
          recommendedAction: l10n.syncMealPlanOldAction,
          createdAt: effectiveNow,
        ),
      );
    }
  }

  // 4. Unusually large food-spend jump vs prior month
  if (currentMonthFoodSpend != null && priorMonthFoodSpend != null) {
    if (priorMonthFoodSpend > 0) {
      final increase =
          (currentMonthFoodSpend - priorMonthFoodSpend) / priorMonthFoodSpend;
      if (increase >= 0.30) {
        final pct = (increase * 100).toStringAsFixed(0);
        alerts.add(
          DataAlert(
            id: 'food_spend_jump',
            severity: increase >= 0.50
                ? AlertSeverity.critical
                : AlertSeverity.warning,
            domain: SyncDomain.expenses,
            title: l10n.syncFoodSpendUpTitle(pct),
            body: l10n.syncFoodSpendUpBody,
            recommendedAction: l10n.syncFoodSpendUpAction,
            createdAt: effectiveNow,
          ),
        );
      }
    }
  }

  // Sort: critical first, then warning, then info
  alerts.sort((a, b) => a.severity.sortOrder.compareTo(b.severity.sortOrder));

  return alerts;
}

String _timeAgo(DateTime past, DateTime now, S l10n) {
  final diff = now.difference(past);
  if (diff.inDays > 0) {
    return l10n.syncTimeAgoDays(diff.inDays);
  }
  if (diff.inHours > 0) {
    return l10n.syncTimeAgoHours(diff.inHours);
  }
  return l10n.syncTimeAgoMinutes(diff.inMinutes);
}
