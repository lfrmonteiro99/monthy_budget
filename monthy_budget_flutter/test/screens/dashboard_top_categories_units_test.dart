import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/screens/dashboard_screen.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'package:monthly_management/utils/formatters.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final alimentacaoOver = ActualExpense(
    id: 'e1',
    category: 'alimentacao',
    amount: 300.0,
    date: DateTime(2026, 8, 1),
    monthKey: '2026-08',
  );
  final lazerNoBudget = ActualExpense(
    id: 'e2',
    category: 'lazer',
    amount: 100.0,
    date: DateTime(2026, 8, 1),
    monthKey: '2026-08',
  );
  final alimentacaoAtBudget = ActualExpense(
    id: 'e3',
    category: 'alimentacao',
    amount: 200.0,
    date: DateTime(2026, 8, 1),
    monthKey: '2026-08',
  );

  Widget buildDashboard({
    List<ActualExpense> expenses = const [],
    Map<String, double> budgets = const {},
    bool showBudgetVsActual = false,
    List<ExpenseItem> budgetItems = const [],
  }) {
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    return wrapWithTestApp(
      DashboardScreen(
        settings: AppSettings(expenses: budgetItems),
        summary: BudgetSummary(
          totalGross: 2000,
          totalNetWithMeal: 1800,
          totalExpenses: total,
        ),
        purchaseHistory: const PurchaseHistory(),
        // Everything off except the Top Categorias card (and optionally
        // Budget vs Actual), so trailing assertions are unambiguous.
        dashboardConfig: LocalDashboardConfig(
          showStressIndex: false,
          showMonthReview: false,
          showUpcomingBills: false,
          showBurnRate: false,
          showCashFlowForecast: false,
          showSavingsRate: false,
          showCoachInsight: false,
          showQuickActions: false,
          showBudgetVsActual: showBudgetVsActual,
          showBudgetStreaks: false,
          showSpendingAnomalies: false,
        ),
        expenseHistory: const {},
        actualExpenses: expenses,
        monthlyBudgets: budgets,
        recurringExpenses: const [],
        actualExpenseHistory: const {},
        onOpenSettings: () {},
        onSaveSettings: (_) {},
        onSnapshotExpenses: () {},
        onAddExpense: () {},
        onOpenExpenseTracker: () {},
        householdName: 'Casa Silva',
      ),
    );
  }

  group('#1330 Top Categorias trailing units', () {
    testWidgets(
        'over-budget category shows a percentage trailing, never a € surplus',
        (tester) async {
      await tester.pumpWidget(buildDashboard(
        expenses: [alimentacaoOver, lazerNoBudget],
        budgets: const {'alimentacao': 200.0},
      ));
      await tester.pumpAndSettle();

      // 300/400 spent = 75% — the over-budget row now shares the same
      // unit as every other row in the card.
      expect(find.text('75%'), findsOneWidget);
      // The two units (€ surplus vs %) must not coexist in the card.
      expect(find.text('+${formatCurrency(100.0)}'), findsNothing);
    });

    testWidgets('over-budget percentage is coloured AppColors.bad',
        (tester) async {
      await tester.pumpWidget(buildDashboard(
        expenses: [alimentacaoOver, lazerNoBudget],
        budgets: const {'alimentacao': 200.0},
      ));
      await tester.pumpAndSettle();

      final ctx = tester.element(find.text('75%'));
      final text = tester.widget<Text>(find.text('75%'));
      expect(text.style?.color, AppColors.bad(ctx));
    });

    testWidgets('within-budget row keeps percentage and default colour',
        (tester) async {
      await tester.pumpWidget(buildDashboard(
        expenses: [alimentacaoOver, lazerNoBudget],
        budgets: const {'alimentacao': 200.0},
      ));
      await tester.pumpAndSettle();

      // lazer has no budget -> 100/400 = 25%, default (ink) colour.
      expect(find.text('25%'), findsOneWidget);
      final ctx = tester.element(find.text('25%'));
      final text = tester.widget<Text>(find.text('25%'));
      expect(text.style?.color, isNot(AppColors.bad(ctx)));
    });

    testWidgets('category exactly at its budget is not flagged as over',
        (tester) async {
      await tester.pumpWidget(buildDashboard(
        expenses: [alimentacaoAtBudget, lazerNoBudget],
        budgets: const {'alimentacao': 200.0},
      ));
      await tester.pumpAndSettle();

      // 200/300 = 67% — value == budgetAmount must NOT count as over.
      expect(find.text('67%'), findsOneWidget);
      final ctx = tester.element(find.text('67%'));
      final text = tester.widget<Text>(find.text('67%'));
      expect(text.style?.color, isNot(AppColors.bad(ctx)));
    });

    testWidgets('subtitle keeps the € spent and € budget untouched',
        (tester) async {
      await tester.pumpWidget(buildDashboard(
        expenses: [alimentacaoOver, lazerNoBudget],
        budgets: const {'alimentacao': 200.0},
      ));
      await tester.pumpAndSettle();

      final spent = formatCurrency(300.0);
      final budget = formatCurrency(200.0);
      expect(find.text('$spent of $budget'), findsOneWidget);
    });

    testWidgets(
        'Budget vs Actual card still shows the over-budget surplus as negative red '
        '(regression guard for the canonical convention)', (tester) async {
      // lazer gets a budget (150) so it is NOT over here — otherwise it
      // would also show '-100,00 €' (100 actual vs 0 budget) and the finder
      // below would be ambiguous. Note: a monthlyBudgets entry only takes
      // effect for categories that exist in settings.expenses, so lazer
      // must be listed there too.
      await tester.pumpWidget(buildDashboard(
        expenses: [alimentacaoOver, lazerNoBudget],
        budgets: const {'alimentacao': 200.0, 'lazer': 150.0},
        showBudgetVsActual: true,
        budgetItems: const [
          ExpenseItem(
              id: 'a1', label: 'Alimentação', category: 'alimentacao'),
          ExpenseItem(id: 'l1', label: 'Lazer', category: 'lazer'),
        ],
      ));
      await tester.pumpAndSettle();

      // remaining = budgeted - actual = 200 - 300 = -100 -> rendered '-100,00 €'
      final negative = '-${formatCurrency(100.0)}';
      final ctx = tester.element(find.text(negative));
      final text = tester.widget<Text>(find.text(negative));
      expect(text.style?.color, AppColors.bad(ctx));
      expect(find.text(negative), findsOneWidget);
    });
  });
}
