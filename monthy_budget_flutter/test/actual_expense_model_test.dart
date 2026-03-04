import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/actual_expense.dart';

void main() {
  group('ActualExpense model', () {
    test('create builds monthKey from date', () {
      final expense = ActualExpense.create(
        category: 'alimentacao',
        amount: 42,
        date: DateTime(2026, 5, 12),
      );

      expect(expense.monthKey, '2026-05');
      expect(expense.id, startsWith('exp_'));
    });

    test('fromSupabase parses optional recurring fields', () {
      final expense = ActualExpense.fromSupabase({
        'id': 'e1',
        'category': 'habitacao',
        'amount': 700,
        'expense_date': '2026-03-01',
        'description': 'Rent',
        'month_key': '2026-03',
        'recurring_expense_id': 'r1',
        'is_from_recurring': true,
      });

      expect(expense.id, 'e1');
      expect(expense.recurringExpenseId, 'r1');
      expect(expense.isFromRecurring, isTrue);
    });

    test('copyWith keeps existing monthKey if date unchanged', () {
      final expense = ActualExpense(
        id: 'e1',
        category: 'saude',
        amount: 30,
        date: DateTime(2026, 3, 10),
        monthKey: '2026-03',
      );

      final updated = expense.copyWith(amount: 35);
      expect(updated.monthKey, '2026-03');
      expect(updated.amount, 35);
    });
  });
}
