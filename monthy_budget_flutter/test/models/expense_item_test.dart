import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/app_settings.dart';

void main() {
  group('ExpenseItem', () {
    group('copyWith isFixed toggle', () {
      test('switching from fixed to variable preserves amount', () {
        const expense = ExpenseItem(
          id: 'e1',
          label: 'Rent',
          amount: 700,
          category: 'habitacao',
          enabled: true,
          isFixed: true,
        );

        final toggled = expense.copyWith(isFixed: false);

        expect(toggled.isFixed, isFalse);
        expect(toggled.amount, 700.0);
        expect(toggled.label, 'Rent');
        expect(toggled.category, 'habitacao');
        expect(toggled.enabled, isTrue);
      });

      test('switching from variable to fixed preserves amount', () {
        const expense = ExpenseItem(
          id: 'e2',
          label: 'Groceries',
          amount: 350,
          category: 'alimentacao',
          enabled: true,
          isFixed: false,
        );

        final toggled = expense.copyWith(isFixed: true);

        expect(toggled.isFixed, isTrue);
        expect(toggled.amount, 350.0);
        expect(toggled.label, 'Groceries');
      });
    });

    group('JSON serialization with isFixed', () {
      test('round-trips isFixed=true', () {
        const expense = ExpenseItem(
          id: 'e3',
          label: 'Internet',
          amount: 40,
          category: 'telecomunicacoes',
          isFixed: true,
        );

        final json = expense.toJson();
        final decoded = ExpenseItem.fromJson(json);

        expect(decoded.isFixed, isTrue);
        expect(decoded.amount, 40.0);
        expect(decoded.label, 'Internet');
      });

      test('round-trips isFixed=false', () {
        const expense = ExpenseItem(
          id: 'e4',
          label: 'Entertainment',
          amount: 150,
          category: 'lazer',
          isFixed: false,
        );

        final json = expense.toJson();
        final decoded = ExpenseItem.fromJson(json);

        expect(decoded.isFixed, isFalse);
        expect(decoded.amount, 150.0);
      });

      test('missing isFixed in JSON defaults to true', () {
        final json = {
          'id': 'e5',
          'label': 'Test',
          'amount': 100,
          'category': 'outros',
          'enabled': true,
        };

        final decoded = ExpenseItem.fromJson(json);
        expect(decoded.isFixed, isTrue);
      });
    });

    group('AppSettings round-trip with isFixed', () {
      test('preserves isFixed across full settings serialization', () {
        final settings = AppSettings(
          expenses: const [
            ExpenseItem(
              id: 'rent',
              label: 'Rent',
              amount: 700,
              category: 'habitacao',
              isFixed: true,
            ),
            ExpenseItem(
              id: 'food',
              label: 'Food',
              amount: 300,
              category: 'alimentacao',
              isFixed: false,
            ),
          ],
        );

        final decoded = AppSettings.fromJsonString(settings.toJsonString());

        final rent = decoded.expenses.firstWhere((e) => e.id == 'rent');
        expect(rent.isFixed, isTrue);
        expect(rent.amount, 700.0);

        final food = decoded.expenses.firstWhere((e) => e.id == 'food');
        expect(food.isFixed, isFalse);
        expect(food.amount, 300.0);
      });

      test('toggling isFixed in expense list preserves all amounts', () {
        const original = [
          ExpenseItem(
            id: 'e1',
            label: 'Rent',
            amount: 700,
            category: 'habitacao',
            isFixed: true,
          ),
          ExpenseItem(
            id: 'e2',
            label: 'Food',
            amount: 300,
            category: 'alimentacao',
            isFixed: true,
          ),
        ];

        // Simulate toggling e1 from fixed to variable
        final updated = original
            .map((e) => e.id == 'e1' ? e.copyWith(isFixed: false) : e)
            .toList();

        final settings = AppSettings(expenses: updated);
        final decoded = AppSettings.fromJsonString(settings.toJsonString());

        final e1 = decoded.expenses.firstWhere((e) => e.id == 'e1');
        expect(e1.isFixed, isFalse);
        expect(e1.amount, 700.0, reason: 'Amount must be preserved after type switch');

        final e2 = decoded.expenses.firstWhere((e) => e.id == 'e2');
        expect(e2.isFixed, isTrue);
        expect(e2.amount, 300.0, reason: 'Unmodified expense must remain unchanged');
      });
    });
  });
}
