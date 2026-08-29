import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/screens/dashboard_screen.dart';
import 'package:monthly_management/theme/app_colors.dart';
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

  // Regression coverage for #1234: Velocidade de Gasto (Burn Rate) derived
  // "spent" from summary.totalExpenses — the BUDGETED total — so it never
  // moved when a real expense was added. The Hero was fixed in #1217, the
  // burn rate card was left behind. It must use the same real total computed
  // once in build() from categoryBudgetSummaries.
  group('Burn Rate card uses real expenses, not budgeted (#1234)', () {
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
            // Deliberately the BUDGETED figures — this is exactly the shape
            // of the bug: BudgetSummary carries planned amounts, not the real
            // expenses lançadas no Expense Tracker.
            totalExpenses: budgeted,
            netLiquidity: 3000 - budgeted,
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
            showTopCategories: false,
            showSavingsRate: false,
            showCoachInsight: false,
            showQuickActions: false,
            showSpendingAnomalies: false,
            showBurnRate: true,
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
        'real > budgeted: MÉDIA/DIA, DISP./DIA and the progress bar follow the real total',
        (tester) async {
      const budgeted = 1945.00;
      const actual = 2189.85;
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final daysPassed = now.day;
      final daysRemaining = daysInMonth - daysPassed;

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

      // MÉDIA/DIA derives from the REAL spent total, not the budgeted one.
      expect(
        find.text(formatCurrency(actual / daysPassed)),
        findsOneWidget,
      );
      expect(
        find.text(formatCurrency(budgeted / daysPassed)),
        findsNothing,
      );

      // DISP./DIA derives from the REAL remaining (income - real spent).
      if (daysRemaining > 0) {
        expect(
          find.text(formatCurrency((3000 - actual) / daysRemaining)),
          findsOneWidget,
        );
        expect(
          find.text(formatCurrency((3000 - budgeted) / daysRemaining)),
          findsNothing,
        );
      }

      // Progress bar = spent/totalBudget on the real total.
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator).first,
      );
      expect(progress.value, closeTo(actual / 3000, 0.0001));
    });

    testWidgets(
        'empty actualExpenses: MÉDIA/DIA is 0,00 € and the bar is empty — not the budget',
        (tester) async {
      const budgeted = 1945.00;
      final now = DateTime.now();
      final daysPassed = now.day;

      await tester.pumpWidget(buildDashboard(
        budgeted: budgeted,
        actualExpenses: const [],
      ));
      await tester.pumpAndSettle();

      expect(find.text(formatCurrency(0)), findsOneWidget);
      expect(
        find.text(formatCurrency(budgeted / daysPassed)),
        findsNothing,
      );

      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator).first,
      );
      expect(progress.value, closeTo(0, 0.0001));
    });
  });

  // Regression coverage for #1234: the dedicated Taxa de Poupança card and
  // the savings tile of the summary grid derived rate/"poupado" from
  // summary.savingsRate/netLiquidity — BUDGETED figures — so they never
  // moved when a real expense was added. Same fix as the Hero (#1217): the
  // real total computed in build() must win.
  group('Savings Rate cards use real expenses, not budgeted (#1234)', () {
    final l10n = SEn();

    Widget buildDashboard({
      required double budgeted,
      required List<ActualExpense> actualExpenses,
      double totalNetWithMeal = 3000,
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
            totalGross: totalNetWithMeal,
            totalNetWithMeal: totalNetWithMeal,
            // Deliberately the BUDGETED figures — the pre-fix source for the
            // savings cards.
            totalExpenses: budgeted,
            netLiquidity: totalNetWithMeal - budgeted,
            savingsRate: (totalNetWithMeal - budgeted) / totalNetWithMeal,
          ),
          purchaseHistory: const PurchaseHistory(),
          dashboardConfig: const LocalDashboardConfig(
            showHeroCard: false,
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
            showCashFlowForecast: false,
            showTopCategories: false,
            showBurnRate: false,
            showSavingsRate: true,
            showCoachInsight: true,
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
          onOpenCoach: () {},
        ),
      );
    }

    testWidgets(
        'real > budgeted: dedicated card and summary tile show the real rate/saved',
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

      // Both the dedicated card and the summary tile scale ×100 — 2 widgets.
      expect(
        find.text(formatPercentage((3000 - actual) / 3000)),
        findsNWidgets(2),
      );
      expect(
        find.text(formatPercentage((3000 - budgeted) / 3000)),
        findsNothing,
      );

      // "Poupado este mês" derives from the real net liquidity.
      expect(
        find.text(l10n.dashboardSavingsRateSaved(
            formatCurrency(3000 - actual))),
        findsOneWidget,
      );
      expect(
        find.text(l10n.dashboardSavingsRateSaved(
            formatCurrency(3000 - budgeted))),
        findsNothing,
      );

      // Summary tile sublabel shows the REAL expenses, not the budget.
      expect(
        find.text(l10n.dashboardExpensesAmount(formatCurrency(actual))),
        findsOneWidget,
      );
      expect(
        find.text(l10n.dashboardExpensesAmount(formatCurrency(budgeted))),
        findsNothing,
      );
    });

    testWidgets(
        'empty actualExpenses: no real spend → 100% savings, 0 € spent, not the budget',
        (tester) async {
      const budgeted = 1945.00;
      const income = 3000.00;

      await tester.pumpWidget(buildDashboard(
        budgeted: budgeted,
        actualExpenses: const [],
      ));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.dashboardSavingsRateSaved(formatCurrency(income))),
        findsOneWidget,
      );
      expect(
        find.text(
            l10n.dashboardSavingsRateSaved(formatCurrency(income - budgeted))),
        findsNothing,
      );
      expect(
        find.text(l10n.dashboardExpensesAmount(formatCurrency(0))),
        findsOneWidget,
      );
      expect(
        find.text(l10n.dashboardExpensesAmount(formatCurrency(budgeted))),
        findsNothing,
      );
    });

    testWidgets(
        'coach tip follows the REAL rate: budgeted says >20% savings, real spend drops it below 10%',
        (tester) async {
      const budgeted = 200.00; // budgeted rate ≈ 80% → "good savings"
      const income = 1000.00;
      const realSpend = 950.00; // real rate = 5% → "low savings"
      final now = DateTime.now();

      await tester.pumpWidget(buildDashboard(
        budgeted: budgeted,
        totalNetWithMeal: income,
        actualExpenses: [
          ActualExpense(
            id: 'a1',
            category: 'habitacao',
            amount: realSpend,
            date: DateTime(now.year, now.month, 10),
            monthKey: '${now.year}-${now.month.toString().padLeft(2, '0')}',
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // The dedicated + summary cards show the real 5%, not the budgeted 80%.
      expect(find.text(formatPercentage(0.05)), findsNWidgets(2));
      expect(find.text(formatPercentage(0.80)), findsNothing);

      // Coach must warn about the real low savings, not praise the budgeted rate.
      expect(find.text(l10n.dashboardCoachLowSavings), findsOneWidget);
      expect(find.text(l10n.dashboardCoachGoodSavings), findsNothing);
    });
  });

  group(
      'Savings Rate dedicated card & coach tip scale fraction ×100 (#1219)',
      () {
    final l10n = SEn();

    // totalNetWithMeal is 1000, so a required rate r maps to real spend
    // (1 - r) × 1000 — the rate is now DERIVED from actualExpenses (#1234),
    // not read from the synthetic summary.savingsRate (which is budgeted and
    // would never move with a real expense).
    Widget buildSavingsDashboard({required double actualSpend}) {
      final now = DateTime.now();
      return wrapWithTestApp(
        DashboardScreen(
          settings: const AppSettings(),
          summary: BudgetSummary(
            totalGross: 1500,
            totalNetWithMeal: 1000,
            // BUDGETED figures — deliberately different from the real spend
            // injected per test, so the card can only be right if it reads
            // actualExpenses (#1234).
            totalExpenses: 550,
            totalDeductions: 200,
            totalIRS: 150,
            totalSS: 50,
            netLiquidity: 450,
            savingsRate: 0.45,
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
            showQuickActions: false,
            showSpendingAnomalies: false,
            showSummaryCards: false,
            showBudgetVsActual: false,
            showSavingsRate: true,
            showCoachInsight: true,
          ),
          expenseHistory: const {},
          actualExpenses: [
            ActualExpense(
              id: 'ae1',
              category: 'habitacao',
              amount: actualSpend,
              date: DateTime(now.year, now.month, 10),
              monthKey: '${now.year}-${now.month.toString().padLeft(2, '0')}',
            ),
          ],
          monthlyBudgets: const {},
          recurringExpenses: const [],
          actualExpenseHistory: const {},
          onOpenSettings: () {},
          onSaveSettings: (_) {},
          onSnapshotExpenses: () {},
          onAddExpense: () {},
          onOpenExpenseTracker: () {},
          onOpenCoach: () {},
        ),
      );
    }

    testWidgets(
        'savingsRate 0.449: dedicated card shows the ×100 percentage (not the raw fraction 0.4%) and the good-savings coach tip',
        (tester) async {
      await tester.pumpWidget(buildSavingsDashboard(actualSpend: 551));
      await tester.pumpAndSettle();

      // The defect: the dedicated card rendered the raw fraction (0.4%),
      // while the summary card / Coach / export all scale ×100 at display.
      expect(find.text('0.4%'), findsNothing);
      expect(find.text(formatPercentage(0.449)), findsOneWidget);
      // Coach tip must be the good-savings one, not the false low-savings alarm.
      expect(find.text(l10n.dashboardCoachGoodSavings), findsOneWidget);
      expect(find.text(l10n.dashboardCoachLowSavings), findsNothing);
    });

    testWidgets(
        'savingsRate 0.08: dedicated card shows 8.0% and the low-savings tip (pre-existing behaviour preserved)',
        (tester) async {
      await tester.pumpWidget(buildSavingsDashboard(actualSpend: 920));
      await tester.pumpAndSettle();

      expect(find.text(formatPercentage(0.08)), findsOneWidget);
      expect(find.text(l10n.dashboardCoachLowSavings), findsOneWidget);
      expect(find.text(l10n.dashboardCoachGoodSavings), findsNothing);
    });

    testWidgets(
        'value colour follows the rate in points: 0.449 → ok, 0.15 → warn, 0.08 → bad',
        (tester) async {
      Color? colorOf(String text) =>
          tester.widget<Text>(find.text(text)).style?.color;

      await tester.pumpWidget(buildSavingsDashboard(actualSpend: 551));
      await tester.pumpAndSettle();
      expect(colorOf(formatPercentage(0.449)),
          AppColors.ok(tester.element(find.text(formatPercentage(0.449)))));

      await tester.pumpWidget(buildSavingsDashboard(actualSpend: 850));
      await tester.pumpAndSettle();
      expect(colorOf(formatPercentage(0.15)),
          AppColors.warn(tester.element(find.text(formatPercentage(0.15)))));

      await tester.pumpWidget(buildSavingsDashboard(actualSpend: 920));
      await tester.pumpAndSettle();
      expect(colorOf(formatPercentage(0.08)),
          AppColors.bad(tester.element(find.text(formatPercentage(0.08)))));
    });

    testWidgets(
        'boundary 0.20: exact good-savings threshold → ok colour and good-savings tip',
        (tester) async {
      await tester.pumpWidget(buildSavingsDashboard(actualSpend: 800));
      await tester.pumpAndSettle();

      expect(find.text(formatPercentage(0.20)), findsOneWidget);
      expect(
        tester.widget<Text>(find.text(formatPercentage(0.20))).style?.color,
        AppColors.ok(tester.element(find.text(formatPercentage(0.20)))),
      );
      expect(find.text(l10n.dashboardCoachGoodSavings), findsOneWidget);
    });

    testWidgets(
        'boundary 0.10: exact low-savings threshold → warn colour, no low-savings alarm (tip is strictly "below 10%")',
        (tester) async {
      await tester.pumpWidget(buildSavingsDashboard(actualSpend: 900));
      await tester.pumpAndSettle();

      expect(find.text(formatPercentage(0.10)), findsOneWidget);
      expect(
        tester.widget<Text>(find.text(formatPercentage(0.10))).style?.color,
        AppColors.warn(tester.element(find.text(formatPercentage(0.10)))),
      );
      expect(find.text(l10n.dashboardCoachLowSavings), findsNothing);
      expect(find.text(l10n.dashboardCoachGoodSavings), findsNothing);
    });

    testWidgets(
        'negative savingsRate -0.05: shows the negative ×100 percentage in red (not clamped to 0, not a fraction)',
        (tester) async {
      await tester.pumpWidget(buildSavingsDashboard(actualSpend: 1050));
      await tester.pumpAndSettle();

      expect(find.text('-0.1%'), findsNothing); // the buggy fraction rendering
      expect(find.text(formatPercentage(-0.05)), findsOneWidget);
      expect(
        tester.widget<Text>(find.text(formatPercentage(-0.05))).style?.color,
        AppColors.bad(tester.element(find.text(formatPercentage(-0.05)))),
      );
    });
  });

  group('onSnapshotExpenses is not re-armed on every build (#1236)', () {
    // hasData=true (totalGross > 0) is the precondition that arms the
    // postFrameCallback in DashboardScreen.build(). Every field below is
    // held constant across pumps — nothing here changes the widget's
    // observable state, only the widget *instance* changes, which is
    // exactly what happens in production when a parent (DashboardContainer/
    // AppHome) rebuilds without the underlying month/data changing.
    Widget buildIdleDashboard(VoidCallback onSnapshotExpenses) {
      return wrapWithTestApp(
        DashboardScreen(
          settings: const AppSettings(),
          summary: const BudgetSummary(
            totalGross: 1000,
            totalNetWithMeal: 1000,
            totalExpenses: 500,
            netLiquidity: 500,
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
          onSnapshotExpenses: onSnapshotExpenses,
          onAddExpense: () {},
          onOpenExpenseTracker: () {},
        ),
      );
    }

    testWidgets(
        'sitting idle across several rebuilds calls onSnapshotExpenses at most once for the same month',
        (tester) async {
      var callCount = 0;

      // Simulate several idle rebuilds of the same DashboardScreen instance
      // (same monthKey, same data) — as would happen if a sibling provider
      // ticks while the user sits on the tab without interacting.
      for (var i = 0; i < 5; i++) {
        await tester.pumpWidget(buildIdleDashboard(() => callCount++));
        await tester.pump();
      }

      expect(
        callCount,
        1,
        reason:
            'onSnapshotExpenses must fire once per distinct monthKey, not once per build/frame',
      );
    });
  });
}
