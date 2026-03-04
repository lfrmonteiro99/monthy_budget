import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/actual_expense.dart';
import 'package:orcamento_mensal/models/expense_snapshot.dart';
import 'package:orcamento_mensal/screens/expense_trends_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('shows empty-state text when there is no data', (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        const ExpenseTrendsScreen(
          actualExpenseHistory: {},
          expenseHistory: {},
        ),
      ),
    );

    expect(find.text('Not enough data to show trends.'), findsOneWidget);
  });

  testWidgets('renders overview and category sections with data',
      (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        ExpenseTrendsScreen(
          actualExpenseHistory: {
            '2026-02': [
              ActualExpense(
                id: 'a1',
                category: 'alimentacao',
                amount: 120,
                date: DateTime(2026, 2, 10),
                monthKey: '2026-02',
              ),
            ],
          },
          expenseHistory: const {
            '2026-02': [
              ExpenseSnapshot(
                expenseId: 'food',
                label: 'Food',
                category: 'alimentacao',
                amount: 200,
                enabled: true,
              ),
            ],
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('OVERVIEW'), findsOneWidget);
    expect(find.text('BY CATEGORY'), findsOneWidget);
  });
}
