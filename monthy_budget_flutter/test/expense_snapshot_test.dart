import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/expense_snapshot.dart';

void main() {
  group('ExpenseSnapshot.fromJson', () {
    test('maps required fields', () {
      final snapshot = ExpenseSnapshot.fromJson(const {
        'expense_id': 'food',
        'label': 'Food',
        'category': 'alimentacao',
        'amount': 123.45,
        'enabled': false,
      });

      expect(snapshot.expenseId, 'food');
      expect(snapshot.label, 'Food');
      expect(snapshot.category, 'alimentacao');
      expect(snapshot.amount, 123.45);
      expect(snapshot.enabled, isFalse);
    });

    test('enabled defaults to true when omitted', () {
      final snapshot = ExpenseSnapshot.fromJson(const {
        'expense_id': 'rent',
        'label': 'Rent',
        'category': 'habitacao',
        'amount': 700,
      });

      expect(snapshot.enabled, isTrue);
    });
  });
}
