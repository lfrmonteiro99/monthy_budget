import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/monthly_budget.dart';

void main() {
  group('MonthlyBudget', () {
    test('constructor assigns all fields', () {
      final budget = MonthlyBudget(
        id: 'mb_1',
        category: 'habitacao',
        amount: 750.0,
        monthKey: '2026-03',
      );

      expect(budget.id, 'mb_1');
      expect(budget.category, 'habitacao');
      expect(budget.amount, 750.0);
      expect(budget.monthKey, '2026-03');
    });

    test('constructor with zero amount', () {
      final budget = MonthlyBudget(
        id: 'mb_zero',
        category: 'lazer',
        amount: 0,
        monthKey: '2026-01',
      );
      expect(budget.amount, 0);
    });

    group('create factory', () {
      test('generates id with timestamp prefix', () {
        final budget = MonthlyBudget.create(
          category: 'energia',
          amount: 100.0,
          monthKey: '2026-02',
        );

        expect(budget.id, startsWith('mb_'));
        expect(budget.id, endsWith('_energia'));
        // id format: mb_{timestamp}_energia
        final parts = budget.id.split('_');
        expect(parts.length, 3);
        // The middle part should be a numeric timestamp
        expect(int.tryParse(parts[1]), isNotNull);
      });

      test('assigns category and amount correctly', () {
        final budget = MonthlyBudget.create(
          category: 'alimentacao',
          amount: 300.0,
          monthKey: '2026-05',
        );

        expect(budget.category, 'alimentacao');
        expect(budget.amount, 300.0);
        expect(budget.monthKey, '2026-05');
      });

      test('two calls produce different ids', () {
        final b1 = MonthlyBudget.create(
          category: 'saude',
          amount: 50,
          monthKey: '2026-01',
        );
        // Small delay not needed; millisecondsSinceEpoch should differ or at
        // minimum the category suffix is enough to disambiguate in the same ms.
        final b2 = MonthlyBudget.create(
          category: 'lazer',
          amount: 60,
          monthKey: '2026-01',
        );
        // Different categories guarantee different ids even if same ms.
        expect(b1.id, isNot(b2.id));
      });
    });

    group('fromSupabase', () {
      test('parses all fields from a map', () {
        final map = {
          'id': 'mb_123_habitacao',
          'category': 'habitacao',
          'amount': 800,
          'month_key': '2026-03',
        };

        final budget = MonthlyBudget.fromSupabase(map);

        expect(budget.id, 'mb_123_habitacao');
        expect(budget.category, 'habitacao');
        expect(budget.amount, 800.0);
        expect(budget.monthKey, '2026-03');
      });

      test('parses amount from int to double', () {
        final map = {
          'id': 'mb_1',
          'category': 'energia',
          'amount': 100,
          'month_key': '2026-01',
        };

        final budget = MonthlyBudget.fromSupabase(map);
        expect(budget.amount, isA<double>());
        expect(budget.amount, 100.0);
      });

      test('parses amount from double', () {
        final map = {
          'id': 'mb_1',
          'category': 'energia',
          'amount': 99.99,
          'month_key': '2026-01',
        };

        final budget = MonthlyBudget.fromSupabase(map);
        expect(budget.amount, 99.99);
      });
    });

    group('toSupabase', () {
      test('includes household_id and all fields', () {
        final budget = MonthlyBudget(
          id: 'mb_1',
          category: 'transportes',
          amount: 200.0,
          monthKey: '2026-04',
        );

        final map = budget.toSupabase('hh_abc');

        expect(map['id'], 'mb_1');
        expect(map['household_id'], 'hh_abc');
        expect(map['category'], 'transportes');
        expect(map['amount'], 200.0);
        expect(map['month_key'], '2026-04');
        expect(map.length, 5);
      });
    });

    group('copyWith', () {
      final original = MonthlyBudget(
        id: 'mb_orig',
        category: 'alimentacao',
        amount: 400.0,
        monthKey: '2026-01',
      );

      test('preserves unchanged fields when no args given', () {
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.category, original.category);
        expect(copy.amount, original.amount);
        expect(copy.monthKey, original.monthKey);
      });

      test('updates id only', () {
        final copy = original.copyWith(id: 'mb_new');
        expect(copy.id, 'mb_new');
        expect(copy.category, original.category);
        expect(copy.amount, original.amount);
        expect(copy.monthKey, original.monthKey);
      });

      test('updates category only', () {
        final copy = original.copyWith(category: 'lazer');
        expect(copy.id, original.id);
        expect(copy.category, 'lazer');
      });

      test('updates amount only', () {
        final copy = original.copyWith(amount: 999.0);
        expect(copy.amount, 999.0);
        expect(copy.category, original.category);
      });

      test('updates monthKey only', () {
        final copy = original.copyWith(monthKey: '2026-12');
        expect(copy.monthKey, '2026-12');
        expect(copy.amount, original.amount);
      });

      test('updates multiple fields at once', () {
        final copy = original.copyWith(
          category: 'saude',
          amount: 150.0,
          monthKey: '2026-06',
        );
        expect(copy.id, original.id);
        expect(copy.category, 'saude');
        expect(copy.amount, 150.0);
        expect(copy.monthKey, '2026-06');
      });
    });
  });
}
