import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/data/tax/spent_by_category.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/purchase_record.dart';

void main() {
  const year = 2026;
  const currentMonthKey = '2026-08';

  ActualExpense expense({
    required String category,
    required double amount,
    required DateTime date,
  }) =>
      ActualExpense.create(category: category, amount: amount, date: date);

  group('computeSpentByCategory', () {
    test(
        'counts a current-month expense once when it is in both history and '
        'actualExpenses (post-reload state)', () {
      final transportes = expense(
        category: 'transportes',
        amount: 77.77,
        date: DateTime(2026, 8, 10),
      );
      // Post-reload: the history map already includes the current month
      // (loaded from Supabase with the new expense) and actualExpenses holds
      // the same persisted expense. The expense must be counted exactly once.
      final spent = computeSpentByCategory(
        actualExpenses: [transportes],
        actualExpenseHistory: {
          currentMonthKey: [transportes],
        },
        purchaseHistory: const PurchaseHistory(),
        year: year,
        currentMonthKey: currentMonthKey,
      );
      expect(spent['transportes'], closeTo(77.77, 0.001));
    });

    test(
        'counts a just-added expense once when history does not yet include '
        'the current month (pre-reload state)', () {
      final transportes = expense(
        category: 'transportes',
        amount: 77.77,
        date: DateTime(2026, 8, 10),
      );
      final spent = computeSpentByCategory(
        actualExpenses: [transportes],
        actualExpenseHistory: const {},
        purchaseHistory: const PurchaseHistory(),
        year: year,
        currentMonthKey: currentMonthKey,
      );
      expect(spent['transportes'], closeTo(77.77, 0.001));
    });

    test('still counts past months of the same year from history', () {
      final julyTransportes = expense(
        category: 'transportes',
        amount: 30,
        date: DateTime(2026, 7, 5),
      );
      final spent = computeSpentByCategory(
        actualExpenses: const [],
        actualExpenseHistory: {
          '2026-07': [julyTransportes],
        },
        purchaseHistory: const PurchaseHistory(),
        year: year,
        currentMonthKey: currentMonthKey,
      );
      expect(spent['transportes'], closeTo(30, 0.001));
    });

    test('excludes months of a different year from history', () {
      final dec2025 = expense(
        category: 'transportes',
        amount: 40,
        date: DateTime(2025, 12, 20),
      );
      final spent = computeSpentByCategory(
        actualExpenses: const [],
        actualExpenseHistory: {
          '2025-12': [dec2025],
        },
        purchaseHistory: const PurchaseHistory(),
        year: year,
        currentMonthKey: currentMonthKey,
      );
      expect(spent['transportes'], isNull);
    });

    test('skips malformed history keys', () {
      final orphan = expense(
        category: 'saude',
        amount: 10,
        date: DateTime(2026, 8, 1),
      );
      final spent = computeSpentByCategory(
        actualExpenses: const [],
        actualExpenseHistory: {
          'not-a-month-key': [orphan],
        },
        purchaseHistory: const PurchaseHistory(),
        year: year,
        currentMonthKey: currentMonthKey,
      );
      expect(spent['saude'], isNull);
    });

    test('filters actualExpenses from a different year', () {
      final lastYear = expense(
        category: 'saude',
        amount: 10,
        date: DateTime(2025, 12, 1),
      );
      final spent = computeSpentByCategory(
        actualExpenses: [lastYear],
        actualExpenseHistory: const {},
        purchaseHistory: const PurchaseHistory(),
        year: year,
        currentMonthKey: currentMonthKey,
      );
      expect(spent['saude'], isNull);
    });

    test('merges food purchase history into alimentacao for the year', () {
      final spent = computeSpentByCategory(
        actualExpenses: const [],
        actualExpenseHistory: const {},
        purchaseHistory: PurchaseHistory(records: [
          PurchaseRecord(
            id: 'p1',
            date: DateTime(2026, 8, 5),
            amount: 50,
            itemCount: 3,
          ),
          PurchaseRecord(
            id: 'p2',
            date: DateTime(2025, 12, 31),
            amount: 999,
            itemCount: 1,
          ),
        ]),
        year: year,
        currentMonthKey: currentMonthKey,
      );
      expect(spent['alimentacao'], closeTo(50, 0.001));
    });

    test(
        'drops the current month from history when actualExpenses is empty '
        '(actualExpenses is the source of truth for the current month)', () {
      final transportes = expense(
        category: 'transportes',
        amount: 77.77,
        date: DateTime(2026, 8, 10),
      );
      final spent = computeSpentByCategory(
        actualExpenses: const [],
        actualExpenseHistory: {
          currentMonthKey: [transportes],
        },
        purchaseHistory: const PurchaseHistory(),
        year: year,
        currentMonthKey: currentMonthKey,
      );
      expect(spent['transportes'], isNull);
    });
  });
}
