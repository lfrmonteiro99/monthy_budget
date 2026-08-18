import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/app_shell.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/screens/dashboard_screen.dart';
import 'package:monthly_management/utils/formatters.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final expense = ActualExpense(
    id: 'e1',
    category: 'housing',
    amount: 685.0,
    date: DateTime(2026, 8, 1),
    monthKey: '2026-08',
  );

  Widget buildDashboard({required Locale locale}) => wrapWithTestApp(
        DashboardScreen(
          settings: const AppSettings(),
          summary: const BudgetSummary(totalGross: 2000, totalExpenses: 685),
          purchaseHistory: const PurchaseHistory(),
          dashboardConfig: const LocalDashboardConfig(),
          expenseHistory: const {},
          actualExpenses: [expense],
          monthlyBudgets: const {'housing': 685.0},
          recurringExpenses: const [],
          actualExpenseHistory: const {},
          onOpenSettings: () {},
          onSaveSettings: (_) {},
          onSnapshotExpenses: () {},
          onAddExpense: () {},
          onOpenExpenseTracker: () {},
        ),
        controller: AppShellController(locale: locale),
      );

  final amount = formatCurrency(685.0); // '685,00 €' — currency format
  // is fixed to Country.pt regardless of app locale; only the separator
  // word between the two amounts is what this issue is about.

  group('#1226 Top Categories subtitle — no hardcoded PT word', () {
    testWidgets('en locale shows "of" separator, not the PT "de"',
        (tester) async {
      await tester.pumpWidget(buildDashboard(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('$amount of $amount'), findsOneWidget);
      expect(find.text('$amount de $amount'), findsNothing);
    });

    testWidgets('pt locale keeps "de" separator (no regression)',
        (tester) async {
      await tester.pumpWidget(buildDashboard(locale: const Locale('pt')));
      await tester.pumpAndSettle();

      expect(find.text('$amount de $amount'), findsOneWidget);
    });

    testWidgets('es locale uses the translated dashboardHeroBudgetLabel',
        (tester) async {
      await tester.pumpWidget(buildDashboard(locale: const Locale('es')));
      await tester.pumpAndSettle();

      expect(find.text('$amount de $amount'), findsOneWidget);
    });

    testWidgets('fr locale uses the translated dashboardHeroBudgetLabel',
        (tester) async {
      await tester.pumpWidget(buildDashboard(locale: const Locale('fr')));
      await tester.pumpAndSettle();

      expect(find.text('$amount de $amount'), findsOneWidget);
    });

    testWidgets(
        'no budget set (budgetAmount <= 0) shows bare amount, no suffix word at all',
        (tester) async {
      final noBudgetExpense = ActualExpense(
        id: 'e2',
        category: 'housing',
        amount: 685.0,
        date: DateTime(2026, 8, 1),
        monthKey: '2026-08',
      );
      await tester.pumpWidget(wrapWithTestApp(
        DashboardScreen(
          settings: const AppSettings(),
          summary:
              const BudgetSummary(totalGross: 2000, totalExpenses: 685),
          purchaseHistory: const PurchaseHistory(),
          dashboardConfig: const LocalDashboardConfig(),
          expenseHistory: const {},
          actualExpenses: [noBudgetExpense],
          monthlyBudgets: const {}, // no budget for 'housing' -> budgetAmount == 0
          recurringExpenses: const [],
          actualExpenseHistory: const {},
          onOpenSettings: () {},
          onSaveSettings: (_) {},
          onSnapshotExpenses: () {},
          onAddExpense: () {},
          onOpenExpenseTracker: () {},
        ),
        controller: AppShellController(locale: const Locale('en')),
      ));
      await tester.pumpAndSettle();

      expect(find.text(amount), findsOneWidget);
      expect(find.text('$amount of $amount'), findsNothing);
      expect(find.text('$amount de $amount'), findsNothing);
    });
  });
}
