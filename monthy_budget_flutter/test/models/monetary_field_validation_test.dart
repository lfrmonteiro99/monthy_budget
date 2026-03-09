import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/actual_expense.dart';
import 'package:orcamento_mensal/models/monthly_budget.dart';
import 'package:orcamento_mensal/models/notification_preferences.dart';
import 'package:orcamento_mensal/models/savings_goal.dart';
import 'package:orcamento_mensal/models/shopping_item.dart';

void main() {
  group('ActualExpense monetary validation', () {
    test('constructor rejects negative amount', () {
      expect(
        () => ActualExpense(
          id: 'e1',
          category: 'lazer',
          amount: -1,
          date: DateTime(2026, 3, 1),
          monthKey: '2026-03',
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('constructor accepts zero amount', () {
      final e = ActualExpense(
        id: 'e1',
        category: 'lazer',
        amount: 0,
        date: DateTime(2026, 3, 1),
        monthKey: '2026-03',
      );
      expect(e.amount, 0);
    });

    test('fromSupabase clamps negative amount to 0', () {
      final e = ActualExpense.fromSupabase({
        'id': 'e1',
        'category': 'lazer',
        'amount': -50.0,
        'expense_date': '2026-03-01',
        'description': null,
        'month_key': '2026-03',
      });
      expect(e.amount, 0);
    });

    test('fromSupabase preserves valid amount', () {
      final e = ActualExpense.fromSupabase({
        'id': 'e1',
        'category': 'lazer',
        'amount': 42.5,
        'expense_date': '2026-03-01',
        'description': null,
        'month_key': '2026-03',
      });
      expect(e.amount, 42.5);
    });
  });

  group('MonthlyBudget monetary validation', () {
    test('constructor rejects negative amount', () {
      expect(
        () => MonthlyBudget(
          id: 'mb_1',
          category: 'habitacao',
          amount: -10,
          monthKey: '2026-03',
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('constructor accepts zero amount', () {
      final b = MonthlyBudget(
        id: 'mb_1',
        category: 'habitacao',
        amount: 0,
        monthKey: '2026-03',
      );
      expect(b.amount, 0);
    });

    test('fromSupabase clamps negative amount to 0', () {
      final b = MonthlyBudget.fromSupabase({
        'id': 'mb_1',
        'category': 'habitacao',
        'amount': -100,
        'month_key': '2026-03',
      });
      expect(b.amount, 0);
    });

    test('fromSupabase preserves valid amount', () {
      final b = MonthlyBudget.fromSupabase({
        'id': 'mb_1',
        'category': 'habitacao',
        'amount': 750.0,
        'month_key': '2026-03',
      });
      expect(b.amount, 750.0);
    });
  });

  group('SavingsGoal monetary validation', () {
    test('constructor rejects negative targetAmount', () {
      expect(
        () => SavingsGoal(
          id: 'sg_1',
          name: 'Fund',
          targetAmount: -500,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('constructor rejects negative currentAmount', () {
      expect(
        () => SavingsGoal(
          id: 'sg_1',
          name: 'Fund',
          targetAmount: 1000,
          currentAmount: -1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('constructor accepts zero for both amounts', () {
      final g = SavingsGoal(
        id: 'sg_1',
        name: 'Fund',
        targetAmount: 0,
        currentAmount: 0,
      );
      expect(g.targetAmount, 0);
      expect(g.currentAmount, 0);
    });

    test('fromSupabase clamps negative targetAmount to 0', () {
      final g = SavingsGoal.fromSupabase({
        'id': 'sg_1',
        'name': 'Fund',
        'target_amount': -1000,
        'current_amount': 500,
      });
      expect(g.targetAmount, 0);
      expect(g.currentAmount, 500.0);
    });

    test('fromSupabase clamps negative currentAmount to 0', () {
      final g = SavingsGoal.fromSupabase({
        'id': 'sg_1',
        'name': 'Fund',
        'target_amount': 1000,
        'current_amount': -200,
      });
      expect(g.targetAmount, 1000.0);
      expect(g.currentAmount, 0);
    });

    test('fromSupabase preserves valid amounts', () {
      final g = SavingsGoal.fromSupabase({
        'id': 'sg_1',
        'name': 'Fund',
        'target_amount': 5000,
        'current_amount': 2500,
      });
      expect(g.targetAmount, 5000.0);
      expect(g.currentAmount, 2500.0);
    });

    test('fromSupabase clamps both when both negative', () {
      final g = SavingsGoal.fromSupabase({
        'id': 'sg_1',
        'name': 'Fund',
        'target_amount': -100,
        'current_amount': -50,
      });
      expect(g.targetAmount, 0);
      expect(g.currentAmount, 0);
    });
  });

  group('SavingsContribution monetary validation', () {
    test('constructor rejects negative amount', () {
      expect(
        () => SavingsContribution(
          id: 'sc_1',
          goalId: 'sg_1',
          amount: -100,
          contributionDate: DateTime(2026, 3, 1),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('constructor accepts zero amount', () {
      final c = SavingsContribution(
        id: 'sc_1',
        goalId: 'sg_1',
        amount: 0,
        contributionDate: DateTime(2026, 3, 1),
      );
      expect(c.amount, 0);
    });

    test('fromSupabase clamps negative amount to 0', () {
      final c = SavingsContribution.fromSupabase({
        'id': 'sc_1',
        'goal_id': 'sg_1',
        'amount': -50,
        'contribution_date': '2026-03-01',
        'note': null,
      });
      expect(c.amount, 0);
    });
  });

  group('ShoppingItem monetary validation', () {
    test('constructor rejects negative price', () {
      expect(
        () => ShoppingItem(
          productName: 'Milk',
          store: 'Lidl',
          price: -1.50,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('constructor accepts zero price', () {
      final item = ShoppingItem(
        productName: 'Free Sample',
        store: 'Lidl',
        price: 0,
      );
      expect(item.price, 0);
    });

    test('fromJson clamps negative price to 0', () {
      final item = ShoppingItem.fromJson({
        'productName': 'Milk',
        'store': 'Lidl',
        'price': -5.0,
      });
      expect(item.price, 0);
    });

    test('fromJson clamps negative cheapestKnownPrice to 0', () {
      final item = ShoppingItem.fromJson({
        'productName': 'Milk',
        'store': 'Lidl',
        'price': 1.0,
        'cheapestKnownPrice': -2.0,
      });
      expect(item.cheapestKnownPrice, 0);
    });

    test('fromJson preserves null cheapestKnownPrice', () {
      final item = ShoppingItem.fromJson({
        'productName': 'Milk',
        'store': 'Lidl',
        'price': 1.0,
      });
      expect(item.cheapestKnownPrice, isNull);
    });

    test('fromJson preserves valid prices', () {
      final item = ShoppingItem.fromJson({
        'productName': 'Milk',
        'store': 'Lidl',
        'price': 1.29,
        'cheapestKnownPrice': 0.99,
      });
      expect(item.price, 1.29);
      expect(item.cheapestKnownPrice, 0.99);
    });

    test('fromSupabase clamps negative price to 0', () {
      final item = ShoppingItem.fromSupabase({
        'id': 'uuid-1',
        'product_name': 'Milk',
        'store': 'Lidl',
        'price': -3.0,
      });
      expect(item.price, 0);
    });

    test('fromSupabase clamps negative cheapest_known_price to 0', () {
      final item = ShoppingItem.fromSupabase({
        'id': 'uuid-1',
        'product_name': 'Milk',
        'store': 'Lidl',
        'price': 1.0,
        'cheapest_known_price': -1.5,
      });
      expect(item.cheapestKnownPrice, 0);
    });

    test('fromSupabase preserves null cheapest_known_price', () {
      final item = ShoppingItem.fromSupabase({
        'id': 'uuid-1',
        'product_name': 'Milk',
        'store': 'Lidl',
        'price': 1.0,
      });
      expect(item.cheapestKnownPrice, isNull);
    });
  });

  group('NotificationPreferences budgetAlertThreshold validation', () {
    test('constructor rejects negative threshold', () {
      expect(
        () => NotificationPreferences(budgetAlertThreshold: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('constructor rejects threshold above 100', () {
      expect(
        () => NotificationPreferences(budgetAlertThreshold: 101),
        throwsA(isA<AssertionError>()),
      );
    });

    test('constructor accepts 0', () {
      final p = NotificationPreferences(budgetAlertThreshold: 0);
      expect(p.budgetAlertThreshold, 0);
    });

    test('constructor accepts 100', () {
      final p = NotificationPreferences(budgetAlertThreshold: 100);
      expect(p.budgetAlertThreshold, 100);
    });

    test('constructor accepts value in range', () {
      final p = NotificationPreferences(budgetAlertThreshold: 80);
      expect(p.budgetAlertThreshold, 80);
    });

    test('fromJsonString clamps negative threshold to 0', () {
      final p = NotificationPreferences.fromJsonString(
        '{"budgetAlertThreshold": -10}',
      );
      expect(p.budgetAlertThreshold, 0);
    });

    test('fromJsonString clamps threshold above 100 to 100', () {
      final p = NotificationPreferences.fromJsonString(
        '{"budgetAlertThreshold": 150}',
      );
      expect(p.budgetAlertThreshold, 100);
    });

    test('fromJsonString preserves valid threshold', () {
      final p = NotificationPreferences.fromJsonString(
        '{"budgetAlertThreshold": 75}',
      );
      expect(p.budgetAlertThreshold, 75);
    });

    test('fromJsonString defaults to 80 when missing', () {
      final p = NotificationPreferences.fromJsonString('{}');
      expect(p.budgetAlertThreshold, 80);
    });
  });
}
