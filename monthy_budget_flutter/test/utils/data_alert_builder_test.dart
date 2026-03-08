import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/data_health_status.dart';
import 'package:orcamento_mensal/utils/data_alert_builder.dart';

void main() {
  final now = DateTime(2026, 3, 8, 12, 0);

  group('stale threshold logic', () {
    test('domain with no sync is stale', () {
      final status = SyncDomainStatus(
        domain: SyncDomain.shopping,
        staleAfter: const Duration(hours: 24),
      );
      expect(status.isStale, isTrue);
      expect(status.isHealthy, isFalse);
    });

    test('domain synced within threshold is healthy', () {
      final status = SyncDomainStatus(
        domain: SyncDomain.shopping,
        lastLoadAt: DateTime.now().subtract(const Duration(hours: 1)),
        staleAfter: const Duration(hours: 24),
      );
      expect(status.isStale, isFalse);
      expect(status.isHealthy, isTrue);
    });

    test('domain synced beyond threshold is stale', () {
      final status = SyncDomainStatus(
        domain: SyncDomain.shopping,
        lastLoadAt: DateTime.now().subtract(const Duration(hours: 25)),
        staleAfter: const Duration(hours: 24),
      );
      expect(status.isStale, isTrue);
      expect(status.isHealthy, isFalse);
    });

    test('domain with error after success is unhealthy', () {
      final successTime = DateTime.now().subtract(const Duration(hours: 2));
      final errorTime = DateTime.now().subtract(const Duration(hours: 1));
      final status = SyncDomainStatus(
        domain: SyncDomain.expenses,
        lastLoadAt: successTime,
        lastErrorAt: errorTime,
        lastErrorMessage: 'Connection failed',
        staleAfter: const Duration(hours: 24),
      );
      expect(status.hasRecentError, isTrue);
      expect(status.isHealthy, isFalse);
    });

    test('domain with error before success is healthy', () {
      final errorTime = DateTime.now().subtract(const Duration(hours: 3));
      final successTime = DateTime.now().subtract(const Duration(hours: 1));
      final status = SyncDomainStatus(
        domain: SyncDomain.expenses,
        lastLoadAt: successTime,
        lastErrorAt: errorTime,
        lastErrorMessage: 'Old error',
        staleAfter: const Duration(hours: 24),
      );
      expect(status.hasRecentError, isFalse);
      expect(status.isHealthy, isTrue);
    });
  });

  group('alert derivation rules', () {
    test('generates critical alert for domain with recent error', () {
      final statuses = {
        SyncDomain.shopping: SyncDomainStatus(
          domain: SyncDomain.shopping,
          lastLoadAt: now.subtract(const Duration(hours: 2)),
          lastErrorAt: now.subtract(const Duration(hours: 1)),
          lastErrorMessage: 'Network timeout',
          staleAfter: const Duration(hours: 24),
        ),
      };

      final alerts = buildAlerts(statuses: statuses, now: now);
      final shoppingAlert = alerts.firstWhere(
        (a) => a.domain == SyncDomain.shopping && a.severity == AlertSeverity.critical,
      );
      expect(shoppingAlert.title, contains('Shopping list'));
      expect(shoppingAlert.title, contains('failed to sync'));
    });

    test('generates warning alert for stale domain', () {
      final statuses = {
        SyncDomain.mealPlan: SyncDomainStatus(
          domain: SyncDomain.mealPlan,
          lastLoadAt: now.subtract(const Duration(days: 10)),
          staleAfter: const Duration(days: 7),
        ),
      };

      final alerts = buildAlerts(statuses: statuses, now: now);
      final staleAlert = alerts.firstWhere(
        (a) => a.domain == SyncDomain.mealPlan && a.severity == AlertSeverity.warning,
      );
      expect(staleAlert.title, contains('outdated'));
    });

    test('generates warning for recurring expenses not populated', () {
      final alerts = buildAlerts(
        statuses: {},
        recurringExpensesPopulatedThisMonth: false,
        now: now,
      );
      final recurringAlert = alerts.firstWhere(
        (a) => a.id == 'recurring_not_populated',
      );
      expect(recurringAlert.severity, AlertSeverity.warning);
    });

    test('generates info alert for old meal plan', () {
      final alerts = buildAlerts(
        statuses: {},
        mealPlanGeneratedAt: now.subtract(const Duration(days: 10)),
        now: now,
      );
      final mealAlert = alerts.firstWhere(
        (a) => a.id == 'meal_plan_old',
      );
      expect(mealAlert.severity, AlertSeverity.info);
      expect(mealAlert.body, contains('10 days ago'));
    });

    test('does not generate meal plan alert if recent', () {
      final alerts = buildAlerts(
        statuses: {},
        mealPlanGeneratedAt: now.subtract(const Duration(days: 3)),
        now: now,
      );
      expect(alerts.where((a) => a.id == 'meal_plan_old'), isEmpty);
    });

    test('generates warning for 30%+ food spend increase', () {
      final alerts = buildAlerts(
        statuses: {},
        currentMonthFoodSpend: 260,
        priorMonthFoodSpend: 200,
        now: now,
      );
      final spendAlert = alerts.firstWhere(
        (a) => a.id == 'food_spend_jump',
      );
      expect(spendAlert.severity, AlertSeverity.warning);
      expect(spendAlert.title, contains('30%'));
    });

    test('generates critical for 50%+ food spend increase', () {
      final alerts = buildAlerts(
        statuses: {},
        currentMonthFoodSpend: 300,
        priorMonthFoodSpend: 200,
        now: now,
      );
      final spendAlert = alerts.firstWhere(
        (a) => a.id == 'food_spend_jump',
      );
      expect(spendAlert.severity, AlertSeverity.critical);
    });

    test('no food spend alert when increase is under 30%', () {
      final alerts = buildAlerts(
        statuses: {},
        currentMonthFoodSpend: 220,
        priorMonthFoodSpend: 200,
        now: now,
      );
      expect(alerts.where((a) => a.id == 'food_spend_jump'), isEmpty);
    });
  });

  group('severity ordering', () {
    test('critical alerts sort before warning and info', () {
      final statuses = {
        SyncDomain.shopping: SyncDomainStatus(
          domain: SyncDomain.shopping,
          lastLoadAt: now.subtract(const Duration(hours: 2)),
          lastErrorAt: now.subtract(const Duration(hours: 1)),
          lastErrorMessage: 'Error',
          staleAfter: const Duration(hours: 24),
        ),
      };

      final alerts = buildAlerts(
        statuses: statuses,
        mealPlanGeneratedAt: now.subtract(const Duration(days: 10)),
        now: now,
      );

      // First alert should be critical
      expect(alerts.first.severity, AlertSeverity.critical);
      // Verify ordering is maintained
      for (int i = 1; i < alerts.length; i++) {
        expect(
          alerts[i].severity.sortOrder,
          greaterThanOrEqualTo(alerts[i - 1].severity.sortOrder),
        );
      }
    });

    test('AlertSeverity sortOrder is critical < warning < info', () {
      expect(AlertSeverity.critical.sortOrder, lessThan(AlertSeverity.warning.sortOrder));
      expect(AlertSeverity.warning.sortOrder, lessThan(AlertSeverity.info.sortOrder));
    });
  });

  group('SyncDomainStatus serialization', () {
    test('round-trips through JSON', () {
      final original = SyncDomainStatus(
        domain: SyncDomain.expenses,
        lastLoadAt: DateTime(2026, 3, 8, 10, 0),
        lastSaveAt: DateTime(2026, 3, 8, 11, 0),
        lastErrorAt: DateTime(2026, 3, 7, 15, 0),
        lastErrorMessage: 'timeout',
        staleAfter: const Duration(hours: 48),
      );

      final json = original.toJson();
      final restored = SyncDomainStatus.fromJson(json);

      expect(restored.domain, original.domain);
      expect(restored.lastLoadAt, original.lastLoadAt);
      expect(restored.lastSaveAt, original.lastSaveAt);
      expect(restored.lastErrorAt, original.lastErrorAt);
      expect(restored.lastErrorMessage, original.lastErrorMessage);
      expect(restored.staleAfter, original.staleAfter);
    });

    test('encodeDomainStatuses and decodeDomainStatuses round-trip', () {
      final statuses = {
        SyncDomain.settings: SyncDomainStatus(
          domain: SyncDomain.settings,
          lastLoadAt: DateTime(2026, 3, 8),
        ),
        SyncDomain.expenses: SyncDomainStatus(
          domain: SyncDomain.expenses,
          lastSaveAt: DateTime(2026, 3, 7),
        ),
      };

      final encoded = encodeDomainStatuses(statuses);
      final decoded = decodeDomainStatuses(encoded);

      expect(decoded.length, 2);
      expect(decoded[SyncDomain.settings]!.lastLoadAt, DateTime(2026, 3, 8));
      expect(decoded[SyncDomain.expenses]!.lastSaveAt, DateTime(2026, 3, 7));
    });
  });

  group('lastSuccessAt', () {
    test('returns null when neither load nor save recorded', () {
      final status = SyncDomainStatus(domain: SyncDomain.settings);
      expect(status.lastSuccessAt, isNull);
    });

    test('returns loadAt when only load recorded', () {
      final t = DateTime(2026, 3, 8);
      final status = SyncDomainStatus(domain: SyncDomain.settings, lastLoadAt: t);
      expect(status.lastSuccessAt, t);
    });

    test('returns the more recent of load and save', () {
      final earlier = DateTime(2026, 3, 7);
      final later = DateTime(2026, 3, 8);
      final status = SyncDomainStatus(
        domain: SyncDomain.settings,
        lastLoadAt: earlier,
        lastSaveAt: later,
      );
      expect(status.lastSuccessAt, later);
    });
  });
}
