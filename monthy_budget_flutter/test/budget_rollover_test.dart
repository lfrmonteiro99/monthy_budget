import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/monthly_budget.dart';
import 'package:monthly_management/utils/budget_rollover.dart';

import 'helpers/test_helpers.dart';

void main() {
  group('ExpenseItem.rolloverEnabled', () {
    test('defaults to false', () {
      final item = makeExpense();
      expect(item.rolloverEnabled, isFalse);
    });

    test('can be set to true via constructor', () {
      final item = ExpenseItem(
        id: 'e1',
        label: 'Food',
        amount: 300,
        category: 'alimentacao',
        rolloverEnabled: true,
      );
      expect(item.rolloverEnabled, isTrue);
    });

    test('copyWith preserves rolloverEnabled when not overridden', () {
      final item = ExpenseItem(
        id: 'e1',
        label: 'Food',
        amount: 300,
        category: 'alimentacao',
        rolloverEnabled: true,
      );
      final copy = item.copyWith(amount: 350);
      expect(copy.rolloverEnabled, isTrue);
      expect(copy.amount, 350);
    });

    test('copyWith can toggle rolloverEnabled', () {
      final item = makeExpense();
      expect(item.rolloverEnabled, isFalse);
      final toggled = item.copyWith(rolloverEnabled: true);
      expect(toggled.rolloverEnabled, isTrue);
    });

    test('toJson includes rolloverEnabled', () {
      final item = ExpenseItem(
        id: 'e1',
        label: 'Test',
        amount: 100,
        category: 'outros',
        rolloverEnabled: true,
      );
      final json = item.toJson();
      expect(json['rolloverEnabled'], isTrue);
    });

    test('fromJson reads rolloverEnabled', () {
      final item = ExpenseItem.fromJson({
        'id': 'e1',
        'label': 'Test',
        'amount': 100,
        'category': 'outros',
        'rolloverEnabled': true,
      });
      expect(item.rolloverEnabled, isTrue);
    });

    test('fromJson defaults rolloverEnabled to false when absent', () {
      final item = ExpenseItem.fromJson({
        'id': 'e1',
        'label': 'Test',
        'amount': 100,
        'category': 'outros',
      });
      expect(item.rolloverEnabled, isFalse);
    });
  });

  group('BudgetRollover.computeRollovers', () {
    test('underspend of 20 carries +20 to next month', () {
      // Previous month: budgeted 200, spent 180 => underspend 20
      final expenses = [
        const ExpenseItem(
          id: 'food',
          category: 'alimentacao',
          amount: 200,
          rolloverEnabled: true,
        ),
      ];
      final prevActuals = [
        ActualExpense(
          id: 'a1',
          category: 'alimentacao',
          amount: 180,
          date: DateTime(2026, 2, 10),
          monthKey: '2026-02',
        ),
      ];

      final rollovers = BudgetRollover.computeRollovers(
        expenseItems: expenses,
        previousMonthActuals: prevActuals,
        previousMonthBudgetOverrides: const {},
      );

      expect(rollovers['alimentacao'], 20.0);
    });

    test('overspend of 30 carries -30 to next month', () {
      // Previous month: budgeted 200, spent 230 => overspend 30
      final expenses = [
        const ExpenseItem(
          id: 'food',
          category: 'alimentacao',
          amount: 200,
          rolloverEnabled: true,
        ),
      ];
      final prevActuals = [
        ActualExpense(
          id: 'a1',
          category: 'alimentacao',
          amount: 230,
          date: DateTime(2026, 2, 10),
          monthKey: '2026-02',
        ),
      ];

      final rollovers = BudgetRollover.computeRollovers(
        expenseItems: expenses,
        previousMonthActuals: prevActuals,
        previousMonthBudgetOverrides: const {},
      );

      expect(rollovers['alimentacao'], -30.0);
    });

    test('rollover disabled returns no carryover', () {
      final expenses = [
        const ExpenseItem(
          id: 'food',
          category: 'alimentacao',
          amount: 200,
          rolloverEnabled: false,
        ),
      ];
      final prevActuals = [
        ActualExpense(
          id: 'a1',
          category: 'alimentacao',
          amount: 180,
          date: DateTime(2026, 2, 10),
          monthKey: '2026-02',
        ),
      ];

      final rollovers = BudgetRollover.computeRollovers(
        expenseItems: expenses,
        previousMonthActuals: prevActuals,
        previousMonthBudgetOverrides: const {},
      );

      expect(rollovers.containsKey('alimentacao'), isFalse);
    });

    test('per-category toggle: only enabled categories carry over', () {
      final expenses = [
        const ExpenseItem(
          id: 'food',
          category: 'alimentacao',
          amount: 200,
          rolloverEnabled: true,
        ),
        const ExpenseItem(
          id: 'transport',
          category: 'transportes',
          amount: 100,
          rolloverEnabled: false,
        ),
      ];
      final prevActuals = [
        ActualExpense(
          id: 'a1',
          category: 'alimentacao',
          amount: 150,
          date: DateTime(2026, 2, 10),
          monthKey: '2026-02',
        ),
        ActualExpense(
          id: 'a2',
          category: 'transportes',
          amount: 60,
          date: DateTime(2026, 2, 15),
          monthKey: '2026-02',
        ),
      ];

      final rollovers = BudgetRollover.computeRollovers(
        expenseItems: expenses,
        previousMonthActuals: prevActuals,
        previousMonthBudgetOverrides: const {},
      );

      expect(rollovers['alimentacao'], 50.0);
      expect(rollovers.containsKey('transportes'), isFalse);
    });

    test('uses monthly budget overrides when available', () {
      // Default amount is 200 but override is 250 for prev month
      final expenses = [
        const ExpenseItem(
          id: 'food',
          category: 'alimentacao',
          amount: 200,
          rolloverEnabled: true,
        ),
      ];
      final prevActuals = [
        ActualExpense(
          id: 'a1',
          category: 'alimentacao',
          amount: 220,
          date: DateTime(2026, 2, 10),
          monthKey: '2026-02',
        ),
      ];

      final rollovers = BudgetRollover.computeRollovers(
        expenseItems: expenses,
        previousMonthActuals: prevActuals,
        previousMonthBudgetOverrides: const {'alimentacao': 250},
      );

      // Override budget 250, spent 220 => underspend 30
      expect(rollovers['alimentacao'], 30.0);
    });

    test('multiple expenses in same category are summed for budget', () {
      final expenses = [
        const ExpenseItem(
          id: 'food1',
          category: 'alimentacao',
          amount: 100,
          rolloverEnabled: true,
        ),
        const ExpenseItem(
          id: 'food2',
          category: 'alimentacao',
          amount: 150,
          rolloverEnabled: true,
        ),
      ];
      final prevActuals = [
        ActualExpense(
          id: 'a1',
          category: 'alimentacao',
          amount: 200,
          date: DateTime(2026, 2, 10),
          monthKey: '2026-02',
        ),
      ];

      final rollovers = BudgetRollover.computeRollovers(
        expenseItems: expenses,
        previousMonthActuals: prevActuals,
        previousMonthBudgetOverrides: const {},
      );

      // Budget 100+150=250, spent 200 => underspend 50
      expect(rollovers['alimentacao'], 50.0);
    });

    test('disabled expense items are excluded from budget', () {
      final expenses = [
        const ExpenseItem(
          id: 'food',
          category: 'alimentacao',
          amount: 200,
          rolloverEnabled: true,
          enabled: false,
        ),
      ];
      final prevActuals = [
        ActualExpense(
          id: 'a1',
          category: 'alimentacao',
          amount: 100,
          date: DateTime(2026, 2, 10),
          monthKey: '2026-02',
        ),
      ];

      final rollovers = BudgetRollover.computeRollovers(
        expenseItems: expenses,
        previousMonthActuals: prevActuals,
        previousMonthBudgetOverrides: const {},
      );

      // Disabled item: no rollover
      expect(rollovers.containsKey('alimentacao'), isFalse);
    });

    test('zero budget with no spend returns empty map', () {
      final expenses = [
        const ExpenseItem(
          id: 'food',
          category: 'alimentacao',
          amount: 0,
          rolloverEnabled: true,
        ),
      ];

      final rollovers = BudgetRollover.computeRollovers(
        expenseItems: expenses,
        previousMonthActuals: const [],
        previousMonthBudgetOverrides: const {},
      );

      // 0 budget, 0 spent => 0 rollover, not included
      expect(rollovers.containsKey('alimentacao'), isFalse);
    });
  });

  group('CategoryBudgetSummary with rollover', () {
    test('rollover amount is added to budgeted amount', () {
      final summaries = CategoryBudgetSummary.buildSummaries(
        const [
          ExpenseItem(
            id: 'food',
            category: 'alimentacao',
            amount: 300,
          ),
        ],
        [
          ActualExpense(
            id: '1',
            category: 'alimentacao',
            amount: 100,
            date: DateTime(2026, 3, 10),
            monthKey: '2026-03',
          ),
        ],
        rolloverAmounts: const {'alimentacao': 20.0},
        now: DateTime(2026, 3, 10),
      );

      final food = summaries.firstWhere((s) => s.category == 'alimentacao');
      // 300 base + 20 rollover = 320 effective budget
      expect(food.budgeted, 320);
      expect(food.actual, 100);
    });

    test('negative rollover reduces budgeted amount', () {
      final summaries = CategoryBudgetSummary.buildSummaries(
        const [
          ExpenseItem(
            id: 'food',
            category: 'alimentacao',
            amount: 300,
          ),
        ],
        [
          ActualExpense(
            id: '1',
            category: 'alimentacao',
            amount: 100,
            date: DateTime(2026, 3, 10),
            monthKey: '2026-03',
          ),
        ],
        rolloverAmounts: const {'alimentacao': -30.0},
        now: DateTime(2026, 3, 10),
      );

      final food = summaries.firstWhere((s) => s.category == 'alimentacao');
      // 300 base - 30 rollover = 270 effective budget
      expect(food.budgeted, 270);
    });

    test('negative rollover does not reduce budget below zero', () {
      final summaries = CategoryBudgetSummary.buildSummaries(
        const [
          ExpenseItem(
            id: 'food',
            category: 'alimentacao',
            amount: 20,
          ),
        ],
        const [],
        rolloverAmounts: const {'alimentacao': -50.0},
        now: DateTime(2026, 3, 10),
      );

      final food = summaries.firstWhere((s) => s.category == 'alimentacao');
      // 20 base - 50 rollover = clamped to 0
      expect(food.budgeted, 0);
    });
  });

  group('BudgetRollover.previousMonthKey', () {
    test('returns previous month for mid-year month', () {
      expect(BudgetRollover.previousMonthKey('2026-03'), '2026-02');
    });

    test('wraps to December of previous year for January', () {
      expect(BudgetRollover.previousMonthKey('2026-01'), '2025-12');
    });

    test('handles single-digit months', () {
      expect(BudgetRollover.previousMonthKey('2026-10'), '2026-09');
    });
  });
}
