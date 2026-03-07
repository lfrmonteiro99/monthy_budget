import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/recurring_expense.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('RecurringExpense', () {
    test('constructor defaults', () {
      final expense = RecurringExpense(
        id: 're_1',
        category: 'energia',
        amount: 80.0,
      );

      expect(expense.id, 're_1');
      expect(expense.category, 'energia');
      expect(expense.amount, 80.0);
      expect(expense.description, isNull);
      expect(expense.dayOfMonth, isNull);
      expect(expense.isActive, true);
    });

    test('constructor with all fields', () {
      final expense = RecurringExpense(
        id: 're_full',
        category: 'habitacao',
        amount: 700,
        description: 'Mortgage',
        dayOfMonth: 5,
        isActive: false,
      );

      expect(expense.description, 'Mortgage');
      expect(expense.dayOfMonth, 5);
      expect(expense.isActive, false);
    });

    group('fromSupabase', () {
      test('with all fields present', () {
        final map = {
          'id': 're_sup',
          'category': 'telecomunicacoes',
          'amount': 35.0,
          'description': 'Internet',
          'day_of_month': 10,
          'is_active': true,
        };

        final expense = RecurringExpense.fromSupabase(map);

        expect(expense.id, 're_sup');
        expect(expense.category, 'telecomunicacoes');
        expect(expense.amount, 35.0);
        expect(expense.description, 'Internet');
        expect(expense.dayOfMonth, 10);
        expect(expense.isActive, true);
      });

      test('with null optional fields', () {
        final map = {
          'id': 're_null',
          'category': 'agua',
          'amount': 25,
          'description': null,
          'day_of_month': null,
          'is_active': null,
        };

        final expense = RecurringExpense.fromSupabase(map);

        expect(expense.description, isNull);
        expect(expense.dayOfMonth, isNull);
        expect(expense.isActive, true); // defaults to true when null
      });

      test('parses amount from int to double', () {
        final map = {
          'id': 're_int',
          'category': 'saude',
          'amount': 50,
        };

        final expense = RecurringExpense.fromSupabase(map);
        expect(expense.amount, isA<double>());
        expect(expense.amount, 50.0);
      });
    });

    group('toSupabase', () {
      test('includes all fields and household_id', () {
        final expense = makeRecurringExpense(
          id: 're_out',
          category: 'energia',
          amount: 90,
          description: 'Electricity',
          dayOfMonth: 15,
          isActive: true,
        );

        final map = expense.toSupabase('hh_xyz');

        expect(map['id'], 're_out');
        expect(map['household_id'], 'hh_xyz');
        expect(map['category'], 'energia');
        expect(map['amount'], 90.0);
        expect(map['description'], 'Electricity');
        expect(map['day_of_month'], 15);
        expect(map['is_active'], true);
      });

      test('includes null fields', () {
        final expense = RecurringExpense(
          id: 're_nil',
          category: 'outros',
          amount: 10,
        );

        final map = expense.toSupabase('hh_1');

        expect(map['description'], isNull);
        expect(map['day_of_month'], isNull);
        expect(map['is_active'], true);
      });
    });

    group('copyWith', () {
      test('preserves all fields when no args given', () {
        final original = makeRecurringExpense(
          description: 'Water bill',
          dayOfMonth: 20,
        );
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.category, original.category);
        expect(copy.amount, original.amount);
        expect(copy.description, original.description);
        expect(copy.dayOfMonth, original.dayOfMonth);
        expect(copy.isActive, original.isActive);
      });

      test('updates single field', () {
        final original = makeRecurringExpense();
        final copy = original.copyWith(amount: 999.0);

        expect(copy.amount, 999.0);
        expect(copy.id, original.id);
        expect(copy.category, original.category);
      });

      test('updates multiple fields', () {
        final original = makeRecurringExpense();
        final copy = original.copyWith(
          category: 'lazer',
          amount: 50,
          isActive: false,
        );

        expect(copy.category, 'lazer');
        expect(copy.amount, 50.0);
        expect(copy.isActive, false);
        expect(copy.id, original.id);
      });

      test('updates description', () {
        final original = makeRecurringExpense(description: 'Old');
        final copy = original.copyWith(description: 'New');
        expect(copy.description, 'New');
      });

      test('updates dayOfMonth', () {
        final original = makeRecurringExpense(dayOfMonth: 1);
        final copy = original.copyWith(dayOfMonth: 28);
        expect(copy.dayOfMonth, 28);
      });
    });
  });
}
