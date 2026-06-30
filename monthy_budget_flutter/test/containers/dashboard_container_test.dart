import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/containers/dashboard_container.dart';
import 'package:monthly_management/screens/dashboard_screen.dart';
import 'package:monthly_management/services/data_health_service.dart';

import '../helpers/test_app.dart';

/// Builds a [DashboardContainer] with no-op callbacks. [onOpenSettings] is
/// overridable so a test can assert an injected handler reaches AppHome.
Widget _container({VoidCallback? onOpenSettings}) {
  return ProviderScope(
    child: wrapWithTestApp(
      DashboardContainer(
        dataHealthService: DataHealthService(),
        onSaveSettings: (_) {},
        onSnapshotExpenses: () {},
        onAddExpense: () {},
        onOpenExpenseTracker: () {},
        onViewTrends: () {},
        onOpenSavingsGoals: () {},
        onOpenRecurringExpenses: () {},
        onOpenSettings: onOpenSettings ?? () {},
        onTourComplete: () {},
        onOpenInsights: () {},
        onOpenCoach: () {},
        onOpenIncome: () {},
        onOpenTaxSimulator: () {},
        onOpenConfidenceCenter: () {},
        onUpgrade: () {},
        onExploreFeature: (_) {},
        onTrackFeature: (_) {},
      ),
    ),
  );
}

/// Runs [body] with the global [ErrorWidget.builder] restored afterwards.
///
/// DashboardContainer wraps its child in an ErrorBoundary, which reassigns
/// ErrorWidget.builder on mount and never restores it. flutter_test asserts
/// that builder is unchanged at the end of each test body, so restore it before
/// the body returns.
Future<void> _withErrorBoundaryGuard(Future<void> Function() body) async {
  final original = ErrorWidget.builder;
  try {
    await body();
  } finally {
    ErrorWidget.builder = original;
  }
}

void main() {
  testWidgets('renders DashboardScreen from provider-backed state',
      (tester) async {
    await _withErrorBoundaryGuard(() async {
      await tester.pumpWidget(_container());
      await tester.pumpAndSettle();

      expect(find.byType(DashboardContainer), findsOneWidget);
      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });

  testWidgets('forwards the empty-state CTA to the injected onOpenSettings',
      (tester) async {
    await _withErrorBoundaryGuard(() async {
      var opened = 0;
      await tester.pumpWidget(_container(onOpenSettings: () => opened++));
      await tester.pumpAndSettle();

      // With default (empty) settings the dashboard shows its Calm empty state,
      // whose CTA is a TextButton wired to onOpenSettings.
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();

      expect(opened, 1);
    });
  });
}
