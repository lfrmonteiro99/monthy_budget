import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/actual_expense.dart';
import 'package:orcamento_mensal/models/app_settings.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ActualExpense', () {
    test('constructor assigns all required and optional fields', () {
      final date = DateTime(2026, 3, 15);
      final expense = ActualExpense(
        id: 'exp_1',
        category: 'alimentacao',
        amount: 55.0,
        date: date,
        description: 'Groceries',
        monthKey: '2026-03',
        recurringExpenseId: 're_1',
        isFromRecurring: true,
      );

      expect(expense.id, 'exp_1');
      expect(expense.category, 'alimentacao');
      expect(expense.amount, 55.0);
      expect(expense.date, date);
      expect(expense.description, 'Groceries');
      expect(expense.monthKey, '2026-03');
      expect(expense.recurringExpenseId, 're_1');
      expect(expense.isFromRecurring, true);
    });

    test('constructor defaults for optional fields', () {
      final expense = ActualExpense(
        id: 'exp_2',
        category: 'lazer',
        amount: 20.0,
        date: DateTime(2026, 1, 1),
        monthKey: '2026-01',
      );

      expect(expense.description, isNull);
      expect(expense.recurringExpenseId, isNull);
      expect(expense.isFromRecurring, false);
    });

    group('create factory', () {
      test('generates monthKey from date', () {
        final expense = ActualExpense.create(
          category: 'saude',
          amount: 30.0,
          date: DateTime(2026, 7, 20),
        );

        expect(expense.monthKey, '2026-07');
        expect(expense.id, startsWith('exp_'));
      });

      test('generates monthKey with zero-padded month', () {
        final expense = ActualExpense.create(
          category: 'energia',
          amount: 80.0,
          date: DateTime(2026, 1, 5),
        );

        expect(expense.monthKey, '2026-01');
      });

      test('generates monthKey for December', () {
        final expense = ActualExpense.create(
          category: 'outros',
          amount: 10.0,
          date: DateTime(2025, 12, 31),
        );

        expect(expense.monthKey, '2025-12');
      });

      test('create with recurring fields', () {
        final expense = ActualExpense.create(
          category: 'habitacao',
          amount: 500.0,
          date: DateTime(2026, 2, 1),
          description: 'Rent payment',
          recurringExpenseId: 're_rent',
          isFromRecurring: true,
        );

        expect(expense.description, 'Rent payment');
        expect(expense.recurringExpenseId, 're_rent');
        expect(expense.isFromRecurring, true);
        expect(expense.monthKey, '2026-02');
      });

      test('create without optional fields', () {
        final expense = ActualExpense.create(
          category: 'lazer',
          amount: 25.0,
          date: DateTime(2026, 6, 10),
        );

        expect(expense.description, isNull);
        expect(expense.recurringExpenseId, isNull);
        expect(expense.isFromRecurring, false);
      });
    });

    group('fromSupabase', () {
      test('parses all fields including nullable ones', () {
        final map = {
          'id': 'exp_abc',
          'category': 'alimentacao',
          'amount': 42.5,
          'expense_date': '2026-03-10',
          'description': 'Weekly shop',
          'month_key': '2026-03',
          'recurring_expense_id': 're_shop',
          'is_from_recurring': true,
        };

        final expense = ActualExpense.fromSupabase(map);

        expect(expense.id, 'exp_abc');
        expect(expense.category, 'alimentacao');
        expect(expense.amount, 42.5);
        expect(expense.date, DateTime(2026, 3, 10));
        expect(expense.description, 'Weekly shop');
        expect(expense.monthKey, '2026-03');
        expect(expense.recurringExpenseId, 're_shop');
        expect(expense.isFromRecurring, true);
      });

      test('parses with null optional fields', () {
        final map = {
          'id': 'exp_xyz',
          'category': 'lazer',
          'amount': 15,
          'expense_date': '2026-01-20',
          'description': null,
          'month_key': '2026-01',
          'recurring_expense_id': null,
          'is_from_recurring': null,
        };

        final expense = ActualExpense.fromSupabase(map);

        expect(expense.description, isNull);
        expect(expense.recurringExpenseId, isNull);
        expect(expense.isFromRecurring, false);
      });

      test('parses amount from int', () {
        final map = {
          'id': 'exp_int',
          'category': 'saude',
          'amount': 100,
          'expense_date': '2026-02-14',
          'description': null,
          'month_key': '2026-02',
        };

        final expense = ActualExpense.fromSupabase(map);
        expect(expense.amount, isA<double>());
        expect(expense.amount, 100.0);
      });
    });

    group('toSupabase', () {
      test('omits recurring fields when null / false', () {
        final expense = ActualExpense(
          id: 'exp_1',
          category: 'energia',
          amount: 60.0,
          date: DateTime(2026, 3, 5),
          monthKey: '2026-03',
        );

        final map = expense.toSupabase('hh_123');

        expect(map['id'], 'exp_1');
        expect(map['household_id'], 'hh_123');
        expect(map['category'], 'energia');
        expect(map['amount'], 60.0);
        expect(map['expense_date'], '2026-03-05');
        expect(map['description'], isNull);
        expect(map['month_key'], '2026-03');
        expect(map.containsKey('recurring_expense_id'), false);
        expect(map.containsKey('is_from_recurring'), false);
      });

      test('includes recurring fields when set', () {
        final expense = ActualExpense(
          id: 'exp_2',
          category: 'habitacao',
          amount: 500.0,
          date: DateTime(2026, 1, 1),
          monthKey: '2026-01',
          recurringExpenseId: 're_rent',
          isFromRecurring: true,
        );

        final map = expense.toSupabase('hh_abc');

        expect(map['recurring_expense_id'], 're_rent');
        expect(map['is_from_recurring'], true);
      });

      test('formats date with zero-padded month and day', () {
        final expense = ActualExpense(
          id: 'exp_fmt',
          category: 'outros',
          amount: 10.0,
          date: DateTime(2026, 1, 3),
          monthKey: '2026-01',
        );

        final map = expense.toSupabase('hh_1');
        expect(map['expense_date'], '2026-01-03');
      });
    });

    group('copyWith', () {
      final original = ActualExpense(
        id: 'exp_orig',
        category: 'transportes',
        amount: 50.0,
        date: DateTime(2026, 3, 15),
        description: 'Gas',
        monthKey: '2026-03',
        recurringExpenseId: null,
        isFromRecurring: false,
      );

      test('recalculates monthKey when date changes', () {
        final copy = original.copyWith(date: DateTime(2026, 7, 20));

        expect(copy.date, DateTime(2026, 7, 20));
        expect(copy.monthKey, '2026-07');
      });

      test('preserves monthKey when date unchanged', () {
        final copy = original.copyWith(amount: 75.0);

        expect(copy.amount, 75.0);
        expect(copy.monthKey, '2026-03');
        expect(copy.date, original.date);
      });

      test('preserves all fields when no args given', () {
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.category, original.category);
        expect(copy.amount, original.amount);
        expect(copy.date, original.date);
        expect(copy.description, original.description);
        expect(copy.monthKey, original.monthKey);
        expect(copy.recurringExpenseId, original.recurringExpenseId);
        expect(copy.isFromRecurring, original.isFromRecurring);
      });

      test('updates multiple fields', () {
        final copy = original.copyWith(
          category: 'saude',
          amount: 200.0,
          isFromRecurring: true,
        );

        expect(copy.category, 'saude');
        expect(copy.amount, 200.0);
        expect(copy.isFromRecurring, true);
        expect(copy.id, original.id);
      });
    });
  });

  group('CategoryBudgetSummary', () {
    test('remaining calculation', () {
      const summary = CategoryBudgetSummary(
        category: 'energia',
        budgeted: 100.0,
        actual: 60.0,
      );
      expect(summary.remaining, 40.0);
    });

    test('remaining is negative when over budget', () {
      const summary = CategoryBudgetSummary(
        category: 'lazer',
        budgeted: 50.0,
        actual: 80.0,
      );
      expect(summary.remaining, -30.0);
    });

    test('progress clamped between 0 and 1.5', () {
      // Normal case
      const normal = CategoryBudgetSummary(
        category: 'a',
        budgeted: 100.0,
        actual: 50.0,
      );
      expect(normal.progress, 0.5);

      // Over 150% -> clamped to 1.5
      const over = CategoryBudgetSummary(
        category: 'b',
        budgeted: 100.0,
        actual: 200.0,
      );
      expect(over.progress, 1.5);

      // Zero budget -> progress is 0
      const zeroBudget = CategoryBudgetSummary(
        category: 'c',
        budgeted: 0.0,
        actual: 50.0,
      );
      expect(zeroBudget.progress, 0);

      // Zero actual
      const zeroActual = CategoryBudgetSummary(
        category: 'd',
        budgeted: 100.0,
        actual: 0.0,
      );
      expect(zeroActual.progress, 0.0);

      // Exactly at 1.5
      const exactly150 = CategoryBudgetSummary(
        category: 'e',
        budgeted: 100.0,
        actual: 150.0,
      );
      expect(exactly150.progress, 1.5);
    });

    test('isOver is true when actual exceeds budgeted', () {
      const over = CategoryBudgetSummary(
        category: 'a',
        budgeted: 100.0,
        actual: 101.0,
      );
      expect(over.isOver, true);

      const under = CategoryBudgetSummary(
        category: 'b',
        budgeted: 100.0,
        actual: 99.0,
      );
      expect(under.isOver, false);

      const equal = CategoryBudgetSummary(
        category: 'c',
        budgeted: 100.0,
        actual: 100.0,
      );
      expect(equal.isOver, false);
    });

    test('isCustom is true when budget is 0', () {
      const custom = CategoryBudgetSummary(
        category: 'custom',
        budgeted: 0.0,
        actual: 25.0,
      );
      expect(custom.isCustom, true);

      const notCustom = CategoryBudgetSummary(
        category: 'normal',
        budgeted: 100.0,
        actual: 25.0,
      );
      expect(notCustom.isCustom, false);
    });

    group('buildSummaries', () {
      test('with fixed expenses', () {
        final budgetItems = [
          makeExpense(
            id: 'e1',
            label: 'Rent',
            amount: 500,
            category: ExpenseCategory.habitacao,
            isFixed: true,
            enabled: true,
          ),
        ];
        final actuals = [
          makeActualExpense(
            id: 'ae_1',
            category: 'habitacao',
            amount: 500,
            date: DateTime(2026, 3, 1),
          ),
        ];

        final summaries = CategoryBudgetSummary.buildSummaries(
          budgetItems,
          actuals,
          now: DateTime(2026, 3, 15),
        );

        expect(summaries, isNotEmpty);
        final hab = summaries.firstWhere((s) => s.category == 'habitacao');
        expect(hab.budgeted, 500.0);
        expect(hab.actual, 500.0);
      });

      test('with food purchases merged into alimentacao', () {
        final budgetItems = [
          makeExpense(
            id: 'e_food',
            label: 'Food',
            amount: 300,
            category: ExpenseCategory.alimentacao,
            isFixed: true,
            enabled: true,
          ),
        ];
        final actuals = [
          makeActualExpense(
            id: 'ae_food',
            category: 'alimentacao',
            amount: 100,
            date: DateTime(2026, 3, 5),
          ),
        ];

        final summaries = CategoryBudgetSummary.buildSummaries(
          budgetItems,
          actuals,
          foodPurchaseSpent: 50.0,
          now: DateTime(2026, 3, 15),
        );

        final alim = summaries.firstWhere((s) => s.category == 'alimentacao');
        // actual 100 + foodPurchaseSpent 50 = 150
        expect(alim.actual, 150.0);
      });

      test('pace calculation produces ok, warning, and danger', () {
        // Budget 310, spend 200 by day 15 of 31-day month
        // dailyPace = 200/15 = 13.33
        // expectedPace = 310/31 = 10.0
        // paceRatio = 13.33/10 = 1.333 -> danger (>1.2)
        final budgetItems = [
          makeExpense(
            id: 'e_danger',
            label: 'High',
            amount: 310,
            category: ExpenseCategory.lazer,
            isFixed: true,
            enabled: true,
          ),
        ];
        final actuals = [
          makeActualExpense(
            id: 'ae_d',
            category: 'lazer',
            amount: 200,
            date: DateTime(2026, 3, 10),
          ),
        ];

        final summariesDanger = CategoryBudgetSummary.buildSummaries(
          budgetItems,
          actuals,
          now: DateTime(2026, 3, 15),
        );
        final dangerCat =
            summariesDanger.firstWhere((s) => s.category == 'lazer');
        expect(dangerCat.paceSeverity, 'danger');
        expect(dangerCat.isOverPace, true);

        // Budget 310, spend 100 by day 15 -> dailyPace=6.67, expected=10
        // paceRatio = 0.667 -> ok
        final actualsOk = [
          makeActualExpense(
            id: 'ae_ok',
            category: 'lazer',
            amount: 100,
            date: DateTime(2026, 3, 10),
          ),
        ];
        final summariesOk = CategoryBudgetSummary.buildSummaries(
          budgetItems,
          actualsOk,
          now: DateTime(2026, 3, 15),
        );
        final okCat = summariesOk.firstWhere((s) => s.category == 'lazer');
        expect(okCat.paceSeverity, 'ok');

        // Budget 310, spend 160 by day 15 -> dailyPace=10.67, expected=10.0
        // paceRatio = 1.067 -> warning (<=1.2)
        final actualsWarn = [
          makeActualExpense(
            id: 'ae_w',
            category: 'lazer',
            amount: 160,
            date: DateTime(2026, 3, 10),
          ),
        ];
        final summariesWarn = CategoryBudgetSummary.buildSummaries(
          budgetItems,
          actualsWarn,
          now: DateTime(2026, 3, 15),
        );
        final warnCat =
            summariesWarn.firstWhere((s) => s.category == 'lazer');
        expect(warnCat.paceSeverity, 'warning');
      });

      test('sorting: custom categories (budget=0) at end', () {
        final budgetItems = [
          makeExpense(
            id: 'e_hab',
            label: 'Rent',
            amount: 500,
            category: ExpenseCategory.habitacao,
            isFixed: true,
            enabled: true,
          ),
        ];
        // An actual expense in a category not budgeted -> custom
        final actuals = [
          makeActualExpense(
            id: 'ae_hab',
            category: 'habitacao',
            amount: 500,
            date: DateTime(2026, 3, 1),
          ),
          makeActualExpense(
            id: 'ae_extra',
            category: 'extra_category',
            amount: 100,
            date: DateTime(2026, 3, 5),
          ),
        ];

        final summaries = CategoryBudgetSummary.buildSummaries(
          budgetItems,
          actuals,
          now: DateTime(2026, 3, 15),
        );

        // The last entry should be the custom (unbudgeted) category
        final last = summaries.last;
        expect(last.isCustom, true);
        expect(last.category, 'extra_category');
      });

      test('disabled budget items are excluded', () {
        final budgetItems = [
          makeExpense(
            id: 'e_dis',
            label: 'Disabled',
            amount: 200,
            category: ExpenseCategory.saude,
            isFixed: true,
            enabled: false,
          ),
        ];

        final summaries = CategoryBudgetSummary.buildSummaries(
          budgetItems,
          [],
          now: DateTime(2026, 3, 15),
        );

        // Disabled items should not produce a budgeted category
        expect(summaries.where((s) => s.category == 'saude'), isEmpty);
      });

      test('variable expenses use monthlyBudgets map', () {
        final budgetItems = [
          makeExpense(
            id: 'e_var',
            label: 'Variable',
            amount: 0,
            category: ExpenseCategory.lazer,
            isFixed: false,
            enabled: true,
          ),
        ];

        final summaries = CategoryBudgetSummary.buildSummaries(
          budgetItems,
          [],
          monthlyBudgets: {'lazer': 250.0},
          now: DateTime(2026, 3, 15),
        );

        final lazer = summaries.firstWhere((s) => s.category == 'lazer');
        expect(lazer.budgeted, 250.0);
      });

      test('empty actuals and budget items produce empty summaries', () {
        final summaries = CategoryBudgetSummary.buildSummaries(
          [],
          [],
          now: DateTime(2026, 3, 15),
        );
        expect(summaries, isEmpty);
      });
    });
  });
}
