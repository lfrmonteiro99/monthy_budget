import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/app_settings.dart';
import 'package:orcamento_mensal/models/recurring_expense.dart';
import 'package:orcamento_mensal/utils/budget_category_builder.dart';

void main() {
  group('buildCategoryViews', () {
    test('attaches matching recurring bills to each category', () {
      final views = buildCategoryViews(
        const [
          ExpenseItem(
            id: 'food',
            category: ExpenseCategory.alimentacao,
            amount: 300,
          ),
          ExpenseItem(
            id: 'home',
            category: ExpenseCategory.habitacao,
            amount: 700,
          ),
        ],
        [
          RecurringExpense(
            id: 'r1',
            category: 'alimentacao',
            amount: 50,
            isActive: true,
          ),
          RecurringExpense(
            id: 'r2',
            category: 'habitacao',
            amount: 650,
            isActive: true,
          ),
        ],
      );

      final food = views.firstWhere(
        (v) => v.budgetItem.category == ExpenseCategory.alimentacao,
      );
      final home = views.firstWhere(
        (v) => v.budgetItem.category == ExpenseCategory.habitacao,
      );

      expect(food.recurringBills.length, 1);
      expect(home.recurringBills.length, 1);
      expect(home.totalRecurringAmount, 650);
      expect(home.billsExceedBudget, isFalse);
    });

    test('orphans are merged into outros when it exists', () {
      final views = buildCategoryViews(
        const [
          ExpenseItem(
            id: 'other',
            category: ExpenseCategory.outros,
            amount: 100,
          ),
        ],
        [
          RecurringExpense(
            id: 'r1',
            category: 'categoria_inexistente',
            amount: 30,
            isActive: true,
          ),
        ],
      );

      final outros =
          views.firstWhere((v) => v.budgetItem.category == ExpenseCategory.outros);
      expect(outros.recurringBills.length, 1);
      expect(outros.hasRecurringBills, isTrue);
    });

    test('orphans are ignored when outros does not exist', () {
      final views = buildCategoryViews(
        const [
          ExpenseItem(
            id: 'food',
            category: ExpenseCategory.alimentacao,
            amount: 300,
          ),
        ],
        [
          RecurringExpense(
            id: 'r1',
            category: 'unknown',
            amount: 10,
          ),
        ],
      );

      expect(views.single.recurringBills, isEmpty);
    });
  });
}
