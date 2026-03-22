import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/expense_snapshot.dart';

void main() {
  group('ExpenseSnapshot', () {
    test('constructor assigns all fields', () {
      const snapshot = ExpenseSnapshot(
        expenseId: 'exp_1',
        label: 'Rent',
        category: 'habitacao',
        amount: 500.0,
        enabled: true,
      );
      expect(snapshot.expenseId, 'exp_1');
      expect(snapshot.label, 'Rent');
      expect(snapshot.category, 'habitacao');
      expect(snapshot.amount, 500.0);
      expect(snapshot.enabled, true);
    });

    group('equality', () {
      test('equal when all fields match', () {
        const a = ExpenseSnapshot(
          expenseId: 'exp_1',
          label: 'Rent',
          category: 'habitacao',
          amount: 500.0,
          enabled: true,
        );
        const b = ExpenseSnapshot(
          expenseId: 'exp_1',
          label: 'Rent',
          category: 'habitacao',
          amount: 500.0,
          enabled: true,
        );
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('not equal when amount differs', () {
        const a = ExpenseSnapshot(
          expenseId: 'exp_1',
          label: 'Rent',
          category: 'habitacao',
          amount: 500.0,
          enabled: true,
        );
        const b = ExpenseSnapshot(
          expenseId: 'exp_1',
          label: 'Rent',
          category: 'habitacao',
          amount: 600.0,
          enabled: true,
        );
        expect(a, isNot(equals(b)));
      });

      test('not equal when enabled differs', () {
        const a = ExpenseSnapshot(
          expenseId: 'exp_1',
          label: 'Rent',
          category: 'habitacao',
          amount: 500.0,
          enabled: true,
        );
        const b = ExpenseSnapshot(
          expenseId: 'exp_1',
          label: 'Rent',
          category: 'habitacao',
          amount: 500.0,
          enabled: false,
        );
        expect(a, isNot(equals(b)));
      });

      test('not equal to different type', () {
        const a = ExpenseSnapshot(
          expenseId: 'exp_1',
          label: 'Rent',
          category: 'habitacao',
          amount: 500.0,
          enabled: true,
        );
        expect(a == 'not a snapshot', isFalse);
      });

      test('identical objects are equal', () {
        const a = ExpenseSnapshot(
          expenseId: 'exp_1',
          label: 'Rent',
          category: 'habitacao',
          amount: 500.0,
          enabled: true,
        );
        expect(identical(a, a), isTrue);
        expect(a, equals(a));
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct map', () {
        const snapshot = ExpenseSnapshot(
          expenseId: 'exp_1',
          label: 'Electricity',
          category: 'energia',
          amount: 80.0,
          enabled: true,
        );
        final json = snapshot.toJson();
        expect(json['expense_id'], 'exp_1');
        expect(json['label'], 'Electricity');
        expect(json['category'], 'energia');
        expect(json['amount'], 80.0);
        expect(json['enabled'], true);
      });

      test('fromJson parses correctly', () {
        final json = {
          'expense_id': 'exp_2',
          'label': 'Water',
          'category': 'agua',
          'amount': 30.5,
          'enabled': false,
        };
        final snapshot = ExpenseSnapshot.fromJson(json);
        expect(snapshot.expenseId, 'exp_2');
        expect(snapshot.label, 'Water');
        expect(snapshot.category, 'agua');
        expect(snapshot.amount, 30.5);
        expect(snapshot.enabled, false);
      });

      test('fromJson defaults enabled to true when missing', () {
        final json = {
          'expense_id': 'exp_3',
          'label': 'Test',
          'category': 'outros',
          'amount': 10,
        };
        final snapshot = ExpenseSnapshot.fromJson(json);
        expect(snapshot.enabled, true);
      });

      test('roundtrip toJson -> fromJson preserves data', () {
        const original = ExpenseSnapshot(
          expenseId: 'exp_rt',
          label: 'Roundtrip',
          category: 'transportes',
          amount: 99.99,
          enabled: false,
        );
        final json = original.toJson();
        final restored = ExpenseSnapshot.fromJson(json);
        expect(restored, equals(original));
      });
    });
  });
}
