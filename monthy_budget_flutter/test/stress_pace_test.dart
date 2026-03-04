import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/app_settings.dart';
import 'package:orcamento_mensal/models/budget_summary.dart';
import 'package:orcamento_mensal/models/purchase_record.dart';
import 'package:orcamento_mensal/utils/stress_index.dart';

void main() {
  group('checkBudgetPace', () {
    test('returns ok when spending is on pace', () {
      final result = checkBudgetPace(
        budget: 300,
        spent: 90,
        now: DateTime(2026, 3, 10),
      );

      expect(result.isOverPace, isFalse);
      expect(result.severity, 'ok');
      expect(result.daysElapsed, 10);
      expect(result.daysRemaining, 21);
    });

    test('returns danger when pace is significantly above expected', () {
      final result = checkBudgetPace(
        budget: 300,
        spent: 250,
        now: DateTime(2026, 3, 10),
      );

      expect(result.isOverPace, isTrue);
      expect(result.severity, 'danger');
      expect(result.projectedOverspend, greaterThan(0));
    });
  });

  group('calculateStressIndex extra scenarios', () {
    test('food factor can fail when food ratio exceeds threshold', () {
      final now = DateTime.now();
      final history = PurchaseHistory(
        records: [
          PurchaseRecord(
            id: 'p1',
            date: DateTime(now.year, now.month, 1),
            amount: 180,
            itemCount: 4,
          ),
        ],
      );

      const settings = AppSettings(
        expenses: [
          ExpenseItem(
            id: 'food',
            label: 'Food',
            category: ExpenseCategory.alimentacao,
            amount: 200,
            enabled: true,
          ),
        ],
      );

      final result = calculateStressIndex(
        summary: const BudgetSummary(
          savingsRate: 0.15,
          netLiquidity: 250,
          totalNetWithMeal: 2000,
          totalExpenses: 1300,
        ),
        purchaseHistory: history,
        settings: settings,
      );

      final food = result.factors.firstWhere((f) => f.type == StressFactorType.food);
      expect(food.ok, isFalse);
      expect(food.valueLabel, isNotEmpty);
    });

    test('stability factor reports high when expenses ratio is large', () {
      final result = calculateStressIndex(
        summary: const BudgetSummary(
          savingsRate: 0.0,
          netLiquidity: 50,
          totalNetWithMeal: 1000,
          totalExpenses: 900,
        ),
        purchaseHistory: const PurchaseHistory(),
        settings: const AppSettings(),
      );

      final stability =
          result.factors.firstWhere((f) => f.type == StressFactorType.stability);
      expect(stability.ok, isFalse);
      expect(stability.valueLabel, 'high');
    });
  });
}
