import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/app_settings.dart';

void main() {
  group('CategoryBudgetSummary.buildSummaries', () {
    test('includes food purchase history in alimentacao actual', () {
      final summaries = CategoryBudgetSummary.buildSummaries(
        const [
          ExpenseItem(
            id: 'food',
            category: ExpenseCategory.alimentacao,
            amount: 300,
          ),
        ],
        [
          ActualExpense(
            id: '1',
            category: 'alimentacao',
            amount: 80,
            date: DateTime(2026, 3, 2),
            monthKey: '2026-03',
          ),
        ],
        foodPurchaseSpent: 50,
        now: DateTime(2026, 3, 10),
      );

      final food = summaries.firstWhere((s) => s.category == 'alimentacao');
      expect(food.actual, 130);
      expect(food.budgeted, 300);
      expect(food.isOver, isFalse);
    });

    test('creates custom category when there is actual without budget', () {
      final summaries = CategoryBudgetSummary.buildSummaries(
        const [],
        [
          ActualExpense(
            id: '1',
            category: 'transportes',
            amount: 40,
            date: DateTime(2026, 3, 5),
            monthKey: '2026-03',
          ),
        ],
      );

      final transport = summaries.firstWhere((s) => s.category == 'transportes');
      expect(transport.budgeted, 0);
      expect(transport.actual, 40);
      expect(transport.isCustom, isTrue);
    });

    test('uses variable monthly budget overrides', () {
      final summaries = CategoryBudgetSummary.buildSummaries(
        const [
          ExpenseItem(
            id: 'var_food',
            category: ExpenseCategory.alimentacao,
            isFixed: false,
            amount: 999,
          ),
        ],
        const [],
        monthlyBudgets: const {'alimentacao': 220},
      );

      final food = summaries.firstWhere((s) => s.category == 'alimentacao');
      expect(food.budgeted, 220);
    });
  });
}
