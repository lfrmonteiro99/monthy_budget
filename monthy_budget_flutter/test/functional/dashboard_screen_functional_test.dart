import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/screens/dashboard_screen.dart';
import 'package:monthly_management/widgets/calm/calm_avatar_badge.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('Dashboard empty state action triggers open settings callback',
      (tester) async {
    var called = 0;

    await tester.pumpWidget(
      wrapWithTestApp(
        DashboardScreen(
          settings: const AppSettings(),
          summary: const BudgetSummary(),
          purchaseHistory: const PurchaseHistory(),
          dashboardConfig: const LocalDashboardConfig(),
          expenseHistory: const {},
          actualExpenses: const [],
          monthlyBudgets: const {},
          recurringExpenses: const [],
          actualExpenseHistory: const {},
          onOpenSettings: () => called++,
          onSaveSettings: (_) {},
          onSnapshotExpenses: () {},
          onAddExpense: () {},
          onOpenExpenseTracker: () {},
        ),
      ),
    );

    // Calm empty state renders the CTA as a TextButton with the localized
    // label — match the action by button type rather than text so the test
    // stays locale-agnostic.
    await tester.tap(find.byType(TextButton).first);
    await tester.pumpAndSettle();

    expect(called, 1);
  });

  testWidgets('Dashboard avatar triggers onOpenSettings callback when data exists',
      (tester) async {
    var called = 0;

    await tester.pumpWidget(
      wrapWithTestApp(
        DashboardScreen(
          settings: const AppSettings(),
          summary: const BudgetSummary(
            totalGross: 1000,
            totalNetWithMeal: 1000,
            totalExpenses: 500,
            netLiquidity: 500,
          ),
          purchaseHistory: const PurchaseHistory(),
          dashboardConfig: const LocalDashboardConfig(
            showSummaryCards: false,
            showSalaryBreakdown: false,
            showBudgetVsActual: false,
            showPurchaseHistory: false,
            showCharts: false,
            showStressIndex: false,
            showMonthReview: false,
            showUpcomingBills: false,
            showTaxDeductions: false,
            showSavingsGoals: false,
            showExpensesBreakdown: false,
            showBudgetStreaks: false,
          ),
          expenseHistory: const {},
          actualExpenses: const [],
          monthlyBudgets: const {},
          recurringExpenses: const [],
          actualExpenseHistory: const {},
          onOpenSettings: () => called++,
          onSaveSettings: (_) {},
          onSnapshotExpenses: () {},
          onAddExpense: () {},
          onOpenExpenseTracker: () {},
        ),
      ),
    );

    // The CalmHeader renders a CalmAvatarBadge in place of the old settings
    // icon chip; tapping it triggers onOpenSettings.
    await tester.tap(find.byType(CalmAvatarBadge));
    await tester.pump();

    expect(called, 1);
  });

  testWidgets('Dashboard exposes quick actions and insights callback',
      (tester) async {
    var openTrackerCalled = 0;
    var openInsightsCalled = 0;

    await tester.pumpWidget(
      wrapWithTestApp(
        DashboardScreen(
          settings: const AppSettings(),
          summary: const BudgetSummary(
            totalGross: 1200,
            totalNetWithMeal: 1100,
            totalExpenses: 700,
            netLiquidity: 400,
          ),
          purchaseHistory: const PurchaseHistory(),
          dashboardConfig: const LocalDashboardConfig(),
          expenseHistory: const {},
          actualExpenses: const [],
          monthlyBudgets: const {},
          recurringExpenses: const [],
          actualExpenseHistory: const {},
          onOpenSettings: () {},
          onSaveSettings: (_) {},
          onSnapshotExpenses: () {},
          onAddExpense: () {},
          onOpenExpenseTracker: () => openTrackerCalled++,
          onOpenInsights: () => openInsightsCalled++,
        ),
      ),
    );

    // Calm treatment renders section eyebrows in upper-case; assert the
    // label is present regardless of casing, and that callbacks are still
    // wired correctly.
    expect(find.text('QUICK ACTIONS'), findsOneWidget);
    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.byIcon(Icons.insights_outlined), findsOneWidget);

    await tester.ensureVisible(find.text('Expense Tracker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expense Tracker'));
    await tester.pump();
    expect(openTrackerCalled, 1);

    await tester.ensureVisible(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pump();
    expect(openInsightsCalled, 1);
  });
}
