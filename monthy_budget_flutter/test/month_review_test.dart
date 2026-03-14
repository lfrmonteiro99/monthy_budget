import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/expense_snapshot.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/utils/month_review.dart';

void main() {
  group('buildMonthReview', () {
    test('returns null when outside review window', () {
      final result = buildMonthReview(
        expenseHistory: const {},
        currentExpenses: const [],
        purchaseHistory: const PurchaseHistory(),
        now: DateTime(2026, 3, 8),
        monthLabelBuilder: (_, _) => 'x',
      );

      expect(result, isNull);
    });

    test('builds review with deviations and suggestions', () {
      final review = buildMonthReview(
        expenseHistory: const {
          '2026-02': [
            ExpenseSnapshot(
              expenseId: 'food',
              label: 'Food',
              category: 'alimentacao',
              amount: 200,
              enabled: true,
            ),
            ExpenseSnapshot(
              expenseId: 'rent',
              label: 'Rent',
              category: 'habitacao',
              amount: 700,
              enabled: true,
            ),
          ],
        },
        currentExpenses: const [
          ExpenseItem(
            id: 'food',
            label: 'Food',
            amount: 260,
            category: 'alimentacao',
          ),
          ExpenseItem(
            id: 'rent',
            label: 'Rent',
            amount: 700,
            category: 'habitacao',
          ),
        ],
        purchaseHistory: PurchaseHistory(
          records: [
            PurchaseRecord(
              id: 'p1',
              date: DateTime(2026, 2, 12),
              amount: 250,
              itemCount: 8,
            ),
          ],
        ),
        now: DateTime(2026, 3, 4),
        monthLabelBuilder: (m, y) => '$m/$y',
      );

      expect(review, isNotNull);
      expect(review!.monthLabel, '2/2026');
      expect(review.totalPlanned, 900);
      expect(review.totalActual, 960);
      expect(review.foodBudget, 200);
      expect(review.foodActual, 250);
      expect(review.deviations, isNotEmpty);
      expect(review.suggestions, isNotEmpty);
    });
  });
}
