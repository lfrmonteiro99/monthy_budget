import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/expense_snapshot.dart';
import 'package:monthly_management/screens/expense_trends_screen.dart';

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
    // The month key MUST be derived from "now".
    //
    // ExpenseTrendsScreen._filteredMonthKeys() keeps only months at or after a
    // cutoff computed from DateTime.now() (the selected range, 6 months by
    // default). This test used to hardcode '2026-02', which sat inside that
    // window when the test was written and fell outside it on 2026-08-01 — from
    // then on the screen rendered its empty state and the assertions below
    // failed, with nothing in the code having changed. A test that starts
    // failing because time passed is worse than no test: it trains people to
    // ignore a red suite.
    final now = DateTime.now();
    final monthKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    await tester.pumpWidget(
      wrapWithTestApp(
        ExpenseTrendsScreen(
          actualExpenseHistory: {
            monthKey: [
              ActualExpense(
                id: 'a1',
                category: 'alimentacao',
                amount: 120,
                date: DateTime(now.year, now.month, 10),
                monthKey: monthKey,
              ),
            ],
          },
          expenseHistory: {
            monthKey: const [
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
