import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/actual_expense.dart';
import 'package:orcamento_mensal/models/recurring_expense.dart';
import 'package:orcamento_mensal/models/savings_goal.dart';
import 'package:orcamento_mensal/models/shopping_item.dart';

void main() {
  group('ShoppingItem mapping', () {
    test('maps to and from Supabase format', () {
      final item = ShoppingItem(
        id: 'id1',
        productName: 'Milk',
        store: 'Store',
        price: 2.5,
        unitPrice: '2.50/L',
        checked: true,
      );

      final supa = item.toSupabase('hh1');
      expect(supa['household_id'], 'hh1');
      expect(supa['product_name'], 'Milk');
      expect(supa['checked'], isTrue);

      final parsed = ShoppingItem.fromSupabase({
        'id': 'id1',
        'product_name': 'Milk',
        'store': 'Store',
        'price': 2.5,
        'unit_price': '2.50/L',
        'checked': true,
      });

      expect(parsed.id, 'id1');
      expect(parsed.productName, 'Milk');
      expect(parsed.checked, isTrue);
    });
  });

  group('ActualExpense mapping', () {
    test('toSupabase includes recurring fields when present', () {
      final expense = ActualExpense(
        id: 'e1',
        category: 'alimentacao',
        amount: 20,
        date: DateTime(2026, 3, 2),
        description: 'Lunch',
        monthKey: '2026-03',
        recurringExpenseId: 'r1',
        isFromRecurring: true,
      );

      final map = expense.toSupabase('hh1');
      expect(map['household_id'], 'hh1');
      expect(map['recurring_expense_id'], 'r1');
      expect(map['is_from_recurring'], isTrue);
    });

    test('copyWith recomputes month key when date changes', () {
      final original = ActualExpense(
        id: 'e1',
        category: 'alimentacao',
        amount: 20,
        date: DateTime(2026, 3, 2),
        monthKey: '2026-03',
      );
      final moved = original.copyWith(date: DateTime(2026, 4, 1));
      expect(moved.monthKey, '2026-04');
    });
  });

  group('RecurringExpense mapping', () {
    test('maps roundtrip with default isActive', () {
      final model = RecurringExpense.fromSupabase({
        'id': 'r1',
        'category': 'habitacao',
        'amount': 700,
        'description': 'Rent',
        'day_of_month': 1,
      });

      expect(model.isActive, isTrue);
      final map = model.toSupabase('hh1');
      expect(map['household_id'], 'hh1');
      expect(map['day_of_month'], 1);
    });
  });

  group('SavingsGoal and SavingsContribution mapping', () {
    test('computes goal progress helpers', () {
      final goal = SavingsGoal(
        id: 'g1',
        name: 'Emergency',
        targetAmount: 1000,
        currentAmount: 400,
      );

      expect(goal.progress, 0.4);
      expect(goal.remaining, 600);
      expect(goal.isCompleted, isFalse);
    });

    test('toSupabase formats deadline date', () {
      final goal = SavingsGoal(
        id: 'g1',
        name: 'Emergency',
        targetAmount: 1000,
        currentAmount: 400,
        deadline: DateTime(2026, 11, 9),
      );

      final map = goal.toSupabase('hh1');
      expect(map['deadline'], '2026-11-09');
    });

    test('contribution toSupabase uses YYYY-MM-DD', () {
      final contribution = SavingsContribution(
        id: 'c1',
        goalId: 'g1',
        amount: 100,
        contributionDate: DateTime(2026, 3, 7),
      );

      final map = contribution.toSupabase('hh1');
      expect(map['household_id'], 'hh1');
      expect(map['contribution_date'], '2026-03-07');
    });
  });
}
