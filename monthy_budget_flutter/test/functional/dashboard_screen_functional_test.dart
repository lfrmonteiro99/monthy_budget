import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/screens/dashboard_screen.dart';
import 'package:monthly_management/utils/formatters.dart';
import 'package:monthly_management/widgets/calm/calm_list_tile.dart';

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

  testWidgets('Dashboard gear icon triggers onOpenSettings callback when data exists',
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

    // Settings is now an avatar (GestureDetector) — find via its Tooltip.
    await tester.tap(find.byTooltip('Open settings'));
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

  testWidgets('Summary cards drill into income / tax simulator / savings goals',
      (tester) async {
    var openIncomeCalled = 0;
    var openTaxSimulatorCalled = 0;
    var openSavingsCalled = 0;

    await tester.pumpWidget(
      wrapWithTestApp(
        DashboardScreen(
          settings: const AppSettings(),
          summary: const BudgetSummary(
            totalGross: 1500,
            totalNetWithMeal: 1300,
            totalExpenses: 800,
            totalDeductions: 200,
            totalIRS: 150,
            totalSS: 50,
            netLiquidity: 500,
            savingsRate: 0.33,
          ),
          purchaseHistory: const PurchaseHistory(),
          dashboardConfig: const LocalDashboardConfig(
            showSummaryCards: true,
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
          onOpenSettings: () {},
          onSaveSettings: (_) {},
          onSnapshotExpenses: () {},
          onAddExpense: () {},
          onOpenExpenseTracker: () {},
          onOpenIncome: () => openIncomeCalled++,
          onOpenTaxSimulator: () => openTaxSimulatorCalled++,
          onOpenSavingsGoals: () => openSavingsCalled++,
        ),
      ),
    );

    await tester.pumpAndSettle();

    Future<void> tapByLabel(String label) async {
      final finder = find.text(label);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pump();
    }

    await tapByLabel('Gross Income');
    expect(openIncomeCalled, 1);

    await tapByLabel('Net Income');
    expect(openIncomeCalled, 2);

    await tapByLabel('Deductions');
    expect(openTaxSimulatorCalled, 1);

    await tapByLabel('Savings Rate');
    expect(openSavingsCalled, 1);
  });

  testWidgets('Top Categories row taps drill into expense tracker',
      (tester) async {
    var openTrackerCalled = 0;

    await tester.pumpWidget(
      wrapWithTestApp(
        DashboardScreen(
          settings: const AppSettings(),
          summary: const BudgetSummary(
            totalGross: 1000,
            totalNetWithMeal: 1000,
            totalExpenses: 50,
            netLiquidity: 950,
          ),
          purchaseHistory: const PurchaseHistory(),
          dashboardConfig: const LocalDashboardConfig(
            showHeroCard: false,
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
            showCashFlowForecast: false,
            showBurnRate: false,
            showSavingsRate: false,
            showCoachInsight: false,
            showQuickActions: false,
            showSpendingAnomalies: false,
          ),
          expenseHistory: const {},
          actualExpenses: [
            ActualExpense(
              id: 'e1',
              category: 'lazer',
              amount: 50,
              date: DateTime(2026, 4, 15),
              monthKey: '2026-04',
            ),
          ],
          monthlyBudgets: const {},
          recurringExpenses: const [],
          actualExpenseHistory: const {},
          onOpenSettings: () {},
          onSaveSettings: (_) {},
          onSnapshotExpenses: () {},
          onAddExpense: () {},
          onOpenExpenseTracker: () => openTrackerCalled++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tile = find.byType(CalmListTile);
    expect(tile, findsWidgets);
    await tester.ensureVisible(tile.first);
    await tester.pumpAndSettle();
    await tester.tap(tile.first);
    await tester.pump();

    expect(openTrackerCalled, 1);
  });

  testWidgets('Budget vs Actual category row drills into expense tracker',
      (tester) async {
    var openTrackerCalled = 0;

    await tester.pumpWidget(
      wrapWithTestApp(
        DashboardScreen(
          settings: const AppSettings(
            expenses: [
              ExpenseItem(
                id: 'e1',
                label: 'Rent',
                amount: 100,
                category: 'lazer',
              ),
            ],
          ),
          summary: const BudgetSummary(
            totalGross: 1000,
            totalNetWithMeal: 1000,
            totalExpenses: 0,
            netLiquidity: 1000,
          ),
          purchaseHistory: const PurchaseHistory(),
          dashboardConfig: const LocalDashboardConfig(
            showHeroCard: false,
            showSummaryCards: false,
            showSalaryBreakdown: false,
            showBudgetVsActual: true,
            showPurchaseHistory: false,
            showCharts: false,
            showStressIndex: false,
            showMonthReview: false,
            showUpcomingBills: false,
            showTaxDeductions: false,
            showSavingsGoals: false,
            showExpensesBreakdown: false,
            showBudgetStreaks: false,
            showCashFlowForecast: false,
            showBurnRate: false,
            showTopCategories: false,
            showSavingsRate: false,
            showCoachInsight: false,
            showQuickActions: false,
            showSpendingAnomalies: false,
          ),
          expenseHistory: const {},
          actualExpenses: const [],
          monthlyBudgets: const {'lazer': 100},
          recurringExpenses: const [],
          actualExpenseHistory: const {},
          onOpenSettings: () {},
          onSaveSettings: (_) {},
          onSnapshotExpenses: () {},
          onAddExpense: () {},
          onOpenExpenseTracker: () => openTrackerCalled++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The Budget vs Actual card renders one slice per visible category. Tap on
    // its localized category label.
    final label = find.text('Leisure');
    expect(label, findsWidgets);
    await tester.ensureVisible(label.first);
    await tester.pumpAndSettle();
    await tester.tap(label.first);
    await tester.pump();

    expect(openTrackerCalled, 1);
  });

  testWidgets('Purchase history inline row opens all-purchases sheet',
      (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        DashboardScreen(
          settings: const AppSettings(),
          summary: const BudgetSummary(
            totalGross: 1000,
            totalNetWithMeal: 1000,
            totalExpenses: 0,
            netLiquidity: 1000,
          ),
          purchaseHistory: PurchaseHistory(records: [
            PurchaseRecord(
              id: 'p1',
              date: DateTime(2026, 4, 15),
              amount: 12.5,
              itemCount: 1,
            ),
          ]),
          dashboardConfig: const LocalDashboardConfig(
            showHeroCard: false,
            showSummaryCards: false,
            showSalaryBreakdown: false,
            showBudgetVsActual: false,
            showPurchaseHistory: true,
            showCharts: false,
            showStressIndex: false,
            showMonthReview: false,
            showUpcomingBills: false,
            showTaxDeductions: false,
            showSavingsGoals: false,
            showExpensesBreakdown: false,
            showBudgetStreaks: false,
            showCashFlowForecast: false,
            showBurnRate: false,
            showTopCategories: false,
            showSavingsRate: false,
            showCoachInsight: false,
            showQuickActions: false,
            showSpendingAnomalies: false,
          ),
          expenseHistory: const {},
          actualExpenses: const [],
          monthlyBudgets: const {},
          recurringExpenses: const [],
          actualExpenseHistory: const {},
          onOpenSettings: () {},
          onSaveSettings: (_) {},
          onSnapshotExpenses: () {},
          onAddExpense: () {},
          onOpenExpenseTracker: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final row = find.text('1 product');
    expect(row, findsWidgets);
    await tester.ensureVisible(row.first);
    await tester.pumpAndSettle();
    await tester.tap(row.first);
    await tester.pumpAndSettle();

    // Bottom sheet renders its title.
    expect(find.text('All Purchases'), findsOneWidget);
  });

  testWidgets('Monthly Expenses Breakdown row opens recurring expenses',
      (tester) async {
    var openRecurringCalled = 0;

    await tester.pumpWidget(
      wrapWithTestApp(
        DashboardScreen(
          settings: const AppSettings(
            expenses: [
              ExpenseItem(
                id: 'e1',
                label: 'BreakdownRowProbe',
                amount: 42,
                category: 'habitacao',
              ),
            ],
          ),
          summary: const BudgetSummary(
            totalGross: 1000,
            totalNetWithMeal: 1000,
            // Match the seeded ExpenseItem.amount so the breakdown card
            // passes the `summary.totalExpenses > 0` gate at
            // dashboard_screen.dart:484.
            totalExpenses: 42,
            netLiquidity: 958,
          ),
          purchaseHistory: const PurchaseHistory(),
          dashboardConfig: const LocalDashboardConfig(
            showHeroCard: false,
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
            showExpensesBreakdown: true,
            showBudgetStreaks: false,
            showCashFlowForecast: false,
            showBurnRate: false,
            showTopCategories: false,
            showSavingsRate: false,
            showCoachInsight: false,
            showQuickActions: false,
            showSpendingAnomalies: false,
          ),
          expenseHistory: const {},
          actualExpenses: const [],
          monthlyBudgets: const {},
          recurringExpenses: const [],
          actualExpenseHistory: const {},
          onOpenSettings: () {},
          onSaveSettings: (_) {},
          onSnapshotExpenses: () {},
          onAddExpense: () {},
          onOpenExpenseTracker: () {},
          onOpenRecurringExpenses: () => openRecurringCalled++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final row = find.text('BreakdownRowProbe');
    expect(row, findsOneWidget);
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pump();

    expect(openRecurringCalled, 1);
  });

  // Regression coverage for #1217: the Hero card (Resumo Financeiro /
  // Liquidez Mensal) used to source "gasto" from summary.totalExpenses,
  // which is the BUDGETED total, not the real expenses shown by the
  // Budget vs Actual block — see dashboard_screen.dart's _buildHero.
  group('Hero spent/liquidity mirrors Budget vs Actual real total (#1217)',
      () {
    final l10n = SEn();

    Widget buildDashboard({
      required double budgeted,
      required List<ActualExpense> actualExpenses,
    }) {
      return wrapWithTestApp(
        DashboardScreen(
          settings: AppSettings(
            expenses: [
              ExpenseItem(
                id: 'e1',
                label: 'Renda',
                amount: budgeted,
                category: 'habitacao',
              ),
            ],
          ),
          summary: BudgetSummary(
            totalGross: 3000,
            totalNetWithMeal: 3000,
            // Deliberately the BUDGETED figures — this is exactly the
            // shape of the bug: BudgetSummary carries planned amounts,
            // not the real expenses lançadas no Expense Tracker.
            totalExpenses: budgeted,
            netLiquidity: 3000 - budgeted,
          ),
          purchaseHistory: const PurchaseHistory(),
          dashboardConfig: const LocalDashboardConfig(
            showSalaryBreakdown: false,
            showPurchaseHistory: false,
            showCharts: false,
            showStressIndex: false,
            showMonthReview: false,
            showUpcomingBills: false,
            showTaxDeductions: false,
            showSavingsGoals: false,
            showExpensesBreakdown: false,
            showBudgetStreaks: false,
            showCashFlowForecast: false,
            showBurnRate: false,
            showTopCategories: false,
            showSavingsRate: false,
            showCoachInsight: false,
            showQuickActions: false,
            showSpendingAnomalies: false,
            showSummaryCards: false,
            showBudgetVsActual: true,
          ),
          expenseHistory: const {},
          actualExpenses: actualExpenses,
          monthlyBudgets: const {},
          recurringExpenses: const [],
          actualExpenseHistory: const {},
          onOpenSettings: () {},
          onSaveSettings: (_) {},
          onSnapshotExpenses: () {},
          onAddExpense: () {},
          onOpenExpenseTracker: () {},
        ),
      );
    }

    testWidgets('real > budgeted: Hero shows the real total, not budgeted',
        (tester) async {
      const budgeted = 1945.00;
      const actual = 2189.85;
      final now = DateTime.now();

      await tester.pumpWidget(buildDashboard(
        budgeted: budgeted,
        actualExpenses: [
          ActualExpense(
            id: 'a1',
            category: 'habitacao',
            amount: actual,
            date: DateTime(now.year, now.month, 10),
            monthKey: '${now.year}-${now.month.toString().padLeft(2, '0')}',
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Hero "spent" label: must be the REAL total (2 189,85 €), matching
      // the Budget vs Actual "Actual" total, not the budgeted total.
      expect(
        find.text(l10n.dashboardHeroSpentLabel(formatCurrency(actual))),
        findsOneWidget,
      );
      expect(
        find.text(l10n.dashboardHeroSpentLabel(formatCurrency(budgeted))),
        findsNothing,
      );
      expect(
        find.text('${l10n.expenseTrackerActual}: ${formatCurrency(actual)}'),
        findsOneWidget,
      );

      // Hero amount (Liquidez Mensal) = totalNetWithMeal - REAL total.
      expect(find.text(formatCurrency(3000 - actual)), findsOneWidget);
      expect(find.text(formatCurrency(3000 - budgeted)), findsNothing);
    });

    testWidgets('real < budgeted: not hardcoded to "real always bigger"',
        (tester) async {
      const budgeted = 2000.00;
      const actual = 500.00;
      final now = DateTime.now();

      await tester.pumpWidget(buildDashboard(
        budgeted: budgeted,
        actualExpenses: [
          ActualExpense(
            id: 'a1',
            category: 'habitacao',
            amount: actual,
            date: DateTime(now.year, now.month, 10),
            monthKey: '${now.year}-${now.month.toString().padLeft(2, '0')}',
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.dashboardHeroSpentLabel(formatCurrency(actual))),
        findsOneWidget,
      );
      expect(
        find.text(l10n.dashboardHeroSpentLabel(formatCurrency(budgeted))),
        findsNothing,
      );
      expect(find.text(formatCurrency(3000 - actual)), findsOneWidget);
    });

    testWidgets('empty actualExpenses: Hero shows 0 spent, not the budget',
        (tester) async {
      const budgeted = 1945.00;

      await tester.pumpWidget(buildDashboard(
        budgeted: budgeted,
        actualExpenses: const [],
      ));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.dashboardHeroSpentLabel(formatCurrency(0))),
        findsOneWidget,
      );
      expect(
        find.text(l10n.dashboardHeroSpentLabel(formatCurrency(budgeted))),
        findsNothing,
      );
      expect(find.text(formatCurrency(3000)), findsOneWidget);
    });
  });

  // Regression coverage for #1218: 'Top Categorias' summed only
  // actualExpenses for 'alimentacao', while 'Orçamento vs Real' also merged
  // purchaseHistory.spentInMonth(...) into the same category — same page,
  // two different totals for the same concept.
  group('Top Categories mirrors Budget vs Actual real total for alimentacao (#1218)',
      () {
    final l10n = SEn();
    final now = DateTime.now();

    Widget buildDashboard({
      required List<ActualExpense> actualExpenses,
      required PurchaseHistory purchaseHistory,
    }) {
      return wrapWithTestApp(
        DashboardScreen(
          settings: const AppSettings(),
          summary: const BudgetSummary(
            totalGross: 3000,
            totalNetWithMeal: 3000,
            totalExpenses: 775.00,
            netLiquidity: 2225.00,
          ),
          purchaseHistory: purchaseHistory,
          dashboardConfig: const LocalDashboardConfig(
            showHeroCard: false,
            showSummaryCards: false,
            showSalaryBreakdown: false,
            showBudgetVsActual: true,
            showPurchaseHistory: false,
            showCharts: false,
            showStressIndex: false,
            showMonthReview: false,
            showUpcomingBills: false,
            showTaxDeductions: false,
            showSavingsGoals: false,
            showExpensesBreakdown: false,
            showBudgetStreaks: false,
            showCashFlowForecast: false,
            showBurnRate: false,
            showTopCategories: true,
            showSavingsRate: false,
            showCoachInsight: false,
            showQuickActions: false,
            showSpendingAnomalies: false,
          ),
          expenseHistory: const {},
          actualExpenses: actualExpenses,
          monthlyBudgets: const {},
          recurringExpenses: const [],
          actualExpenseHistory: const {},
          onOpenSettings: () {},
          onSaveSettings: (_) {},
          onSnapshotExpenses: () {},
          onAddExpense: () {},
          onOpenExpenseTracker: () {},
        ),
      );
    }

    testWidgets(
        'transactions + supermarket purchases: both cards show the merged total',
        (tester) async {
      await tester.pumpWidget(buildDashboard(
        actualExpenses: [
          ActualExpense(
            id: 'a1',
            category: 'alimentacao',
            amount: 585.60,
            date: DateTime(now.year, now.month, 5),
            monthKey: '${now.year}-${now.month.toString().padLeft(2, '0')}',
          ),
        ],
        purchaseHistory: PurchaseHistory(records: [
          PurchaseRecord(
            id: 'p1',
            date: DateTime(now.year, now.month, 12),
            amount: 189.40,
            itemCount: 6,
          ),
        ]),
      ));
      await tester.pumpAndSettle();

      // Top Categorias must show the SAME merged total (585,60 + 189,40 =
      // 775,00) that Orçamento vs Real already shows for 'alimentacao' —
      // before the fix, Top Categorias only summed actualExpenses (585,60 €).
      expect(find.text(formatCurrency(775.00)), findsOneWidget); // Top Categorias subtitle
      expect(
        find.text('${l10n.expenseTrackerActual}: ${formatCurrency(775.00)}'),
        findsOneWidget,
      ); // Orçamento vs Real total row
      expect(find.text(formatCurrency(585.60)), findsNothing);
      expect(
        find.text('${l10n.expenseTrackerActual}: ${formatCurrency(585.60)}'),
        findsNothing,
      );
    });

    testWidgets(
        'no supermarket purchases this month: Top Categories unaffected (no regression)',
        (tester) async {
      await tester.pumpWidget(buildDashboard(
        actualExpenses: [
          ActualExpense(
            id: 'a1',
            category: 'alimentacao',
            amount: 585.60,
            date: DateTime(now.year, now.month, 5),
            monthKey: '${now.year}-${now.month.toString().padLeft(2, '0')}',
          ),
        ],
        purchaseHistory: const PurchaseHistory(),
      ));
      await tester.pumpAndSettle();

      // purchaseHistory.spentInMonth() == 0 → both cards must show exactly
      // the transaction total, unchanged from current behaviour.
      expect(find.text(formatCurrency(585.60)), findsOneWidget); // Top Categorias
      expect(
        find.text('${l10n.expenseTrackerActual}: ${formatCurrency(585.60)}'),
        findsOneWidget,
      ); // Orçamento vs Real
    });
  });
}
