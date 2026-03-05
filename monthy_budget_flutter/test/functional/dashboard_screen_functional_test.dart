import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/app_settings.dart';
import 'package:orcamento_mensal/models/budget_summary.dart';
import 'package:orcamento_mensal/models/local_dashboard_config.dart';
import 'package:orcamento_mensal/models/purchase_record.dart';
import 'package:orcamento_mensal/screens/dashboard_screen.dart';

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

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(called, 1);
  });

  testWidgets('Dashboard settings icon triggers callback when data exists',
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

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();

    expect(called, 1);
  });

  testWidgets('Focused dashboard exposes quick actions and insights callback',
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
          focusedMode: true,
          onOpenInsights: () => openInsightsCalled++,
        ),
      ),
    );

    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.byIcon(Icons.insights_outlined), findsOneWidget);

    await tester.tap(find.text('Expense Tracker'));
    await tester.pump();
    expect(openTrackerCalled, 1);

    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pump();
    expect(openInsightsCalled, 1);
  });
}
