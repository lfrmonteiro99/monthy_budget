import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/data_health_status.dart';

void main() {
  group('SyncDomainStatus', () {
    test('lastSuccessAt returns latest of load/save', () {
      final s = SyncDomainStatus(
        domain: SyncDomain.expenses,
        lastLoadAt: DateTime(2026, 3, 10),
        lastSaveAt: DateTime(2026, 3, 15),
      );
      expect(s.lastSuccessAt, DateTime(2026, 3, 15));
    });

    test('lastSuccessAt returns loadAt when saveAt is null', () {
      final s = SyncDomainStatus(
        domain: SyncDomain.expenses,
        lastLoadAt: DateTime(2026, 3, 10),
      );
      expect(s.lastSuccessAt, DateTime(2026, 3, 10));
    });

    test('lastSuccessAt returns saveAt when loadAt is null', () {
      final s = SyncDomainStatus(
        domain: SyncDomain.expenses,
        lastSaveAt: DateTime(2026, 3, 15),
      );
      expect(s.lastSuccessAt, DateTime(2026, 3, 15));
    });

    test('lastSuccessAt returns null when both are null', () {
      const s = SyncDomainStatus(domain: SyncDomain.expenses);
      expect(s.lastSuccessAt, isNull);
    });

    test('hasRecentError false when no error', () {
      final s = SyncDomainStatus(
        domain: SyncDomain.settings,
        lastLoadAt: DateTime(2026, 3, 10),
      );
      expect(s.hasRecentError, false);
    });

    test('hasRecentError true when error after success', () {
      final s = SyncDomainStatus(
        domain: SyncDomain.settings,
        lastLoadAt: DateTime(2026, 3, 10),
        lastErrorAt: DateTime(2026, 3, 11),
        lastErrorMessage: 'Network error',
      );
      expect(s.hasRecentError, true);
    });

    test('hasRecentError true when error exists but no success', () {
      final s = SyncDomainStatus(
        domain: SyncDomain.settings,
        lastErrorAt: DateTime(2026, 3, 11),
      );
      expect(s.hasRecentError, true);
    });

    test('hasRecentError false when success after error', () {
      final s = SyncDomainStatus(
        domain: SyncDomain.settings,
        lastLoadAt: DateTime(2026, 3, 12),
        lastErrorAt: DateTime(2026, 3, 11),
      );
      expect(s.hasRecentError, false);
    });

    test('isStale true when never synced', () {
      const s = SyncDomainStatus(domain: SyncDomain.mealPlan);
      expect(s.isStale, true);
    });

    test('copyWith updates fields', () {
      final s = SyncDomainStatus(
        domain: SyncDomain.expenses,
        lastLoadAt: DateTime(2026, 3, 10),
      );
      final copy = s.copyWith(
        lastSaveAt: DateTime(2026, 3, 12),
        lastErrorMessage: 'test',
      );
      expect(copy.domain, SyncDomain.expenses);
      expect(copy.lastLoadAt, DateTime(2026, 3, 10));
      expect(copy.lastSaveAt, DateTime(2026, 3, 12));
      expect(copy.lastErrorMessage, 'test');
    });

    test('toJson / fromJson roundtrip', () {
      final original = SyncDomainStatus(
        domain: SyncDomain.shopping,
        lastLoadAt: DateTime(2026, 3, 10),
        lastSaveAt: DateTime(2026, 3, 12),
        lastErrorAt: DateTime(2026, 3, 11),
        lastErrorMessage: 'timeout',
        staleAfter: const Duration(hours: 12),
      );
      final json = original.toJson();
      final restored = SyncDomainStatus.fromJson(json);
      expect(restored.domain, original.domain);
      expect(restored.lastErrorMessage, 'timeout');
      expect(restored.staleAfter, const Duration(hours: 12));
    });
  });

  group('AlertSeverity', () {
    test('sortOrder: critical < warning < info', () {
      expect(AlertSeverity.critical.sortOrder, 0);
      expect(AlertSeverity.warning.sortOrder, 1);
      expect(AlertSeverity.info.sortOrder, 2);
    });
  });

  group('DataAlert', () {
    test('toJson / fromJson roundtrip', () {
      final alert = DataAlert(
        id: 'alert_1',
        severity: AlertSeverity.warning,
        domain: SyncDomain.expenses,
        title: 'Test alert',
        body: 'Something happened',
        recommendedAction: 'Do something',
        createdAt: DateTime(2026, 3, 15),
      );
      final json = alert.toJson();
      final restored = DataAlert.fromJson(json);
      expect(restored.id, 'alert_1');
      expect(restored.severity, AlertSeverity.warning);
      expect(restored.domain, SyncDomain.expenses);
      expect(restored.title, 'Test alert');
      expect(restored.body, 'Something happened');
      expect(restored.recommendedAction, 'Do something');
    });

    test('toJson omits null domain', () {
      final alert = DataAlert(
        id: 'alert_2',
        severity: AlertSeverity.info,
        title: 'No domain',
        body: 'Body',
        createdAt: DateTime(2026, 3, 15),
      );
      final json = alert.toJson();
      expect(json.containsKey('domain'), false);
      expect(json.containsKey('recommended_action'), false);
    });
  });

  group('encode/decode DomainStatuses', () {
    test('roundtrip encode -> decode preserves all domains', () {
      final statuses = {
        SyncDomain.expenses: SyncDomainStatus(
          domain: SyncDomain.expenses,
          lastLoadAt: DateTime(2026, 3, 10),
        ),
        SyncDomain.shopping: SyncDomainStatus(
          domain: SyncDomain.shopping,
          lastSaveAt: DateTime(2026, 3, 12),
        ),
      };
      final encoded = encodeDomainStatuses(statuses);
      final decoded = decodeDomainStatuses(encoded);
      expect(decoded.keys, containsAll([SyncDomain.expenses, SyncDomain.shopping]));
      expect(decoded[SyncDomain.expenses]!.lastLoadAt, DateTime(2026, 3, 10));
      expect(decoded[SyncDomain.shopping]!.lastSaveAt, DateTime(2026, 3, 12));
    });
  });
}
