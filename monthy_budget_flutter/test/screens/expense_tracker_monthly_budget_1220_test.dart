import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/screens/expense_tracker_screen.dart';
import 'package:monthly_management/widgets/expense/expense_alerts_card.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

void main() {
  // Reproduces the QA finding (#1220): the Início screen applies the monthly
  // budget override (monthlyBudgets), but Despesas read the budget only from
  // settings.expenses — so the same category showed two different budgets
  // (Lazer 120 € vs 58 €, Energia 100 € vs 94,40 €). The Alertas card must
  // show the monthly-adjusted budget.
  testWidgets(
    'Alertas card shows the monthly-adjusted budget, not the settings default (#1220)',
    (tester) async {
      final settings = makeSettings(
        expenses: [
          makeExpense(id: 'exp_1', category: 'habitacao', amount: 200),
        ],
      );
      final actual = makeActualExpense(
        id: 'ae_1',
        category: 'habitacao',
        amount: 600,
      );

      await tester.pumpWidget(
        wrapWithTestApp(
          ExpenseTrackerScreen(
            settings: settings,
            expenses: [actual],
            householdId: 'house-1',
            onAdd: (_) async {},
            onUpdate: (_) async {},
            onDelete: (_) async {},
            onLoadMonth: (_) async => [actual],
            monthlyBudgets: const {'habitacao': 500},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Alertas row subtitle is "Budget {budgeted} · Spent {actual}". With
      // the override it must read 500,00 € — not the settings default 200 €.
      final inAlertsCard = find.descendant(
        of: find.byType(ExpenseAlertsCard),
        matching: find.textContaining('500,00'),
      );
      expect(inAlertsCard, findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ExpenseAlertsCard),
          matching: find.textContaining('200,00'),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'without monthlyBudgets the Alertas card keeps the settings budget (#1220)',
    (tester) async {
      final settings = makeSettings(
        expenses: [
          makeExpense(id: 'exp_1', category: 'habitacao', amount: 200),
        ],
      );
      final actual = makeActualExpense(
        id: 'ae_1',
        category: 'habitacao',
        amount: 250,
      );

      await tester.pumpWidget(
        wrapWithTestApp(
          ExpenseTrackerScreen(
            settings: settings,
            expenses: [actual],
            householdId: 'house-1',
            onAdd: (_) async {},
            onUpdate: (_) async {},
            onDelete: (_) async {},
            onLoadMonth: (_) async => [actual],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(ExpenseAlertsCard),
          matching: find.textContaining('200,00'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ExpenseAlertsCard),
          matching: find.textContaining('500,00'),
        ),
        findsNothing,
      );
    },
  );
}
