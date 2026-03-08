import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/data_health_status.dart';
import 'package:orcamento_mensal/screens/confidence_center_screen.dart';

import '../helpers/test_app.dart';

void main() {
  group('ConfidenceCenterScreen', () {
    testWidgets('renders sync health section with domain chips', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          const ConfidenceCenterScreen(
            statuses: {},
            alerts: [],
          ),
        ),
      );

      // Section headers
      expect(find.text('Sync Health'), findsOneWidget);
      expect(find.text('Data Quality Alerts'), findsOneWidget);
      expect(find.text('Recommended Actions'), findsOneWidget);

      // All domain chips should appear
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Shopping list'), findsOneWidget);
      expect(find.text('Meal plan'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Purchase history'), findsOneWidget);
      expect(find.text('Savings goals'), findsOneWidget);
      expect(find.text('Recurring expenses'), findsOneWidget);
    });

    testWidgets('shows empty state when no alerts', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          const ConfidenceCenterScreen(
            statuses: {},
            alerts: [],
          ),
        ),
      );

      expect(find.text('No alerts. Everything looks good.'), findsOneWidget);
      expect(find.text('All systems healthy. No actions needed.'), findsOneWidget);
    });

    testWidgets('renders alert cards with correct severity styling', (tester) async {
      final alerts = [
        DataAlert(
          id: 'test_critical',
          severity: AlertSeverity.critical,
          domain: SyncDomain.shopping,
          title: 'Shopping list sync failed',
          body: 'Connection error',
          recommendedAction: 'Check your connection',
          createdAt: DateTime(2026, 3, 8),
        ),
        DataAlert(
          id: 'test_warning',
          severity: AlertSeverity.warning,
          domain: SyncDomain.expenses,
          title: 'Expenses data outdated',
          body: 'Last synced 3 days ago',
          createdAt: DateTime(2026, 3, 8),
        ),
        DataAlert(
          id: 'test_info',
          severity: AlertSeverity.info,
          domain: SyncDomain.mealPlan,
          title: 'Meal plan may be outdated',
          body: 'Generated 10 days ago',
          createdAt: DateTime(2026, 3, 8),
        ),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          ConfidenceCenterScreen(
            statuses: const {},
            alerts: alerts,
          ),
        ),
      );

      expect(find.text('Shopping list sync failed'), findsOneWidget);
      expect(find.text('Expenses data outdated'), findsOneWidget);
      expect(find.text('Meal plan may be outdated'), findsOneWidget);
      expect(find.text('Check your connection'), findsOneWidget);
    });

    testWidgets('renders recommended actions from alerts', (tester) async {
      final alerts = [
        DataAlert(
          id: 'a1',
          severity: AlertSeverity.warning,
          title: 'Test',
          body: 'Body',
          recommendedAction: 'Do something',
          createdAt: DateTime(2026, 3, 8),
        ),
        DataAlert(
          id: 'a2',
          severity: AlertSeverity.info,
          title: 'Test2',
          body: 'Body2',
          recommendedAction: 'Do another thing',
          createdAt: DateTime(2026, 3, 8),
        ),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          ConfidenceCenterScreen(
            statuses: const {},
            alerts: alerts,
          ),
        ),
      );

      expect(find.text('Do something'), findsOneWidget);
      expect(find.text('Do another thing'), findsOneWidget);
    });
  });

  group('CriticalAlertBanner', () {
    testWidgets('renders nothing when count is 0', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          CriticalAlertBanner(criticalCount: 0, onTap: () {}),
        ),
      );

      expect(find.text('critical alert'), findsNothing);
    });

    testWidgets('renders banner with correct count', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: CriticalAlertBanner(
              criticalCount: 2,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.textContaining('2 critical alerts'), findsOneWidget);
      await tester.tap(find.textContaining('2 critical alerts'));
      expect(tapped, isTrue);
    });

    testWidgets('uses singular form for 1 alert', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: CriticalAlertBanner(criticalCount: 1, onTap: () {}),
          ),
        ),
      );

      expect(find.textContaining('1 critical alert'), findsOneWidget);
      // Should NOT contain "alerts" (plural)
      expect(find.textContaining('1 critical alerts'), findsNothing);
    });
  });
}
