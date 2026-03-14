import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/utils/budget_streaks.dart';

void main() {
  String monthKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}';

  group('calculateStreaks', () {
    test('returns zero streaks for empty history', () {
      final result = calculateStreaks(
        actualExpenseHistory: const {},
        expenses: const [],
        totalNetIncome: 0,
        purchaseHistory: const PurchaseHistory(),
      );

      expect(result.bronze.count, 0);
      expect(result.silver.count, 0);
      expect(result.gold.count, 0);
    });

    test('counts bronze, silver and gold when month is fully under budget', () {
      final now = DateTime.now();
      final prev = DateTime(now.year, now.month - 1, 1);
      final prevKey = monthKey(prev);

      final result = calculateStreaks(
        actualExpenseHistory: {
          prevKey: [
            ActualExpense(
              id: '1',
              category: 'alimentacao',
              amount: 80,
              date: prev,
              monthKey: prevKey,
            ),
            ActualExpense(
              id: '2',
              category: 'habitacao',
              amount: 300,
              date: prev,
              monthKey: prevKey,
            ),
          ],
        },
        expenses: const [
          ExpenseItem(
            id: 'food',
            category: ExpenseCategory.alimentacao,
            amount: 100,
          ),
          ExpenseItem(
            id: 'home',
            category: ExpenseCategory.habitacao,
            amount: 400,
          ),
        ],
        totalNetIncome: 1200,
        purchaseHistory: const PurchaseHistory(),
      );

      expect(result.bronze.count, 1);
      expect(result.silver.count, 1);
      expect(result.gold.count, 1);
    });

    test('food purchases can break gold streak while bronze/silver remain', () {
      final now = DateTime.now();
      final prev = DateTime(now.year, now.month - 1, 1);
      final prevKey = monthKey(prev);

      final result = calculateStreaks(
        actualExpenseHistory: {
          prevKey: [
            ActualExpense(
              id: '1',
              category: 'alimentacao',
              amount: 80,
              date: prev,
              monthKey: prevKey,
            ),
            ActualExpense(
              id: '2',
              category: 'habitacao',
              amount: 300,
              date: prev,
              monthKey: prevKey,
            ),
          ],
        },
        expenses: const [
          ExpenseItem(
            id: 'food',
            category: ExpenseCategory.alimentacao,
            amount: 100,
          ),
          ExpenseItem(
            id: 'home',
            category: ExpenseCategory.habitacao,
            amount: 400,
          ),
        ],
        totalNetIncome: 1200,
        purchaseHistory: PurchaseHistory(
          records: [
            PurchaseRecord(
              id: 'p1',
              date: DateTime(prev.year, prev.month, 5),
              amount: 50,
              itemCount: 2,
            ),
          ],
        ),
      );

      expect(result.bronze.count, 1);
      expect(result.silver.count, 1);
      expect(result.gold.count, 0);
    });
  });
}
