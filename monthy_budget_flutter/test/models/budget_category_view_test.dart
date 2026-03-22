import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/budget_category_view.dart';
import 'package:monthly_management/models/recurring_expense.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BudgetCategoryView', () {
    test('totalRecurringAmount sums active bills only', () {
      final view = BudgetCategoryView(
        budgetItem: makeExpense(amount: 500, category: 'habitacao'),
        recurringBills: [
          RecurringExpense(
            id: 're_1', category: 'habitacao', amount: 200, isActive: true,
          ),
          RecurringExpense(
            id: 're_2', category: 'habitacao', amount: 100, isActive: false,
          ),
          RecurringExpense(
            id: 're_3', category: 'habitacao', amount: 150, isActive: true,
          ),
        ],
      );
      expect(view.totalRecurringAmount, 350.0);
    });

    test('totalRecurringAmount is 0 with no bills', () {
      final view = BudgetCategoryView(
        budgetItem: makeExpense(amount: 300),
      );
      expect(view.totalRecurringAmount, 0.0);
    });

    test('remainingVariableBudget subtracts recurring from budget', () {
      final view = BudgetCategoryView(
        budgetItem: makeExpense(amount: 500),
        recurringBills: [
          RecurringExpense(
            id: 're_1', category: 'habitacao', amount: 300, isActive: true,
          ),
        ],
      );
      expect(view.remainingVariableBudget, 200.0);
    });

    test('remainingVariableBudget can be negative', () {
      final view = BudgetCategoryView(
        budgetItem: makeExpense(amount: 100),
        recurringBills: [
          RecurringExpense(
            id: 're_1', category: 'habitacao', amount: 300, isActive: true,
          ),
        ],
      );
      expect(view.remainingVariableBudget, -200.0);
    });

    test('hasRecurringBills returns true when list is non-empty', () {
      final with_ = BudgetCategoryView(
        budgetItem: makeExpense(),
        recurringBills: [
          RecurringExpense(id: 're_1', category: 'a', amount: 10),
        ],
      );
      expect(with_.hasRecurringBills, true);

      final without = BudgetCategoryView(budgetItem: makeExpense());
      expect(without.hasRecurringBills, false);
    });

    test('billsExceedBudget when recurring sum > budget amount', () {
      final exceeds = BudgetCategoryView(
        budgetItem: makeExpense(amount: 100),
        recurringBills: [
          RecurringExpense(
            id: 're_1', category: 'a', amount: 60, isActive: true,
          ),
          RecurringExpense(
            id: 're_2', category: 'a', amount: 50, isActive: true,
          ),
        ],
      );
      expect(exceeds.billsExceedBudget, true);

      final fits = BudgetCategoryView(
        budgetItem: makeExpense(amount: 200),
        recurringBills: [
          RecurringExpense(
            id: 're_1', category: 'a', amount: 60, isActive: true,
          ),
        ],
      );
      expect(fits.billsExceedBudget, false);
    });

    test('activeBillCount counts only active bills', () {
      final view = BudgetCategoryView(
        budgetItem: makeExpense(),
        recurringBills: [
          RecurringExpense(
            id: 're_1', category: 'a', amount: 10, isActive: true,
          ),
          RecurringExpense(
            id: 're_2', category: 'a', amount: 20, isActive: false,
          ),
          RecurringExpense(
            id: 're_3', category: 'a', amount: 30, isActive: true,
          ),
        ],
      );
      expect(view.activeBillCount, 2);
    });

    group('equality', () {
      test('equal when budgetItem and list length match', () {
        final item = makeExpense(id: 'e1', amount: 100, category: 'food');
        final bills = [
          RecurringExpense(id: 're_1', category: 'food', amount: 50),
        ];
        final a = BudgetCategoryView(budgetItem: item, recurringBills: bills);
        final b = BudgetCategoryView(budgetItem: item, recurringBills: bills);
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('not equal when different bill counts', () {
        final item = makeExpense(id: 'e1', amount: 100, category: 'food');
        final a = BudgetCategoryView(
          budgetItem: item,
          recurringBills: [
            RecurringExpense(id: 're_1', category: 'food', amount: 50),
          ],
        );
        final b = BudgetCategoryView(budgetItem: item);
        expect(a, isNot(equals(b)));
      });
    });
  });
}
