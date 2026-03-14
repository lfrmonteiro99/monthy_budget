import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/utils/stress_index.dart';

void main() {
  group('calculateStressIndex', () {
    const goodSummary = BudgetSummary(
      savingsRate: 0.20,
      netLiquidity: 400.0,
      totalNetWithMeal: 2000,
      totalExpenses: 1000,
    );
    const emptyHistory = PurchaseHistory();
    const settings = AppSettings(
      expenses: [
        ExpenseItem(
          id: 'food',
          label: 'Alimentação',
          amount: 400,
          category: 'alimentacao',
          enabled: true,
        ),
      ],
    );

    test('score is between 0 and 100', () {
      final result = calculateStressIndex(
        summary: goodSummary,
        purchaseHistory: emptyHistory,
        settings: settings,
      );
      expect(result.score, inInclusiveRange(0, 100));
    });

    test('label is Excelente when score >= 80', () {
      const perfectSummary = BudgetSummary(
        savingsRate: 0.25,
        netLiquidity: 500,
        totalNetWithMeal: 2000,
        totalExpenses: 0,
      );
      final result = calculateStressIndex(
        summary: perfectSummary,
        purchaseHistory: emptyHistory,
        settings: settings,
      );
      expect(result.score, 100);
      expect(result.level, StressLevel.excellent);
    });

    test('label is Crítico when score < 40', () {
      const badSummary = BudgetSummary(
        savingsRate: 0,
        netLiquidity: 0,
        totalNetWithMeal: 1000,
        totalExpenses: 1000,
      );
      final result = calculateStressIndex(
        summary: badSummary,
        purchaseHistory: PurchaseHistory(records: [
          PurchaseRecord(
            id: 'r1',
            date: DateTime(2026, 2, 1),
            amount: 500,
            itemCount: 5,
          ),
        ]),
        settings: settings,
      );
      expect(result.score, lessThan(40));
      expect(result.level, StressLevel.critical);
    });

    test('delta is null when no previous month in history', () {
      final result = calculateStressIndex(
        summary: goodSummary,
        purchaseHistory: emptyHistory,
        settings: settings,
      );
      expect(result.delta, isNull);
    });

    test('delta is computed when previous month exists in history', () {
      final now = DateTime.now();
      final pm = now.month == 1 ? 12 : now.month - 1;
      final py = now.month == 1 ? now.year - 1 : now.year;
      final prevKey = '$py-${pm.toString().padLeft(2, '0')}';
      final settingsWithHistory = AppSettings(
        expenses: settings.expenses,
        stressHistory: {prevKey: 60},
      );
      final result = calculateStressIndex(
        summary: goodSummary,
        purchaseHistory: emptyHistory,
        settings: settingsWithHistory,
      );
      expect(result.delta, isNotNull);
      expect(result.previousScore, 60);
    });

    test('food factor is N/D when no food budget configured', () {
      const noFoodSettings = AppSettings();
      final result = calculateStressIndex(
        summary: goodSummary,
        purchaseHistory: emptyHistory,
        settings: noFoodSettings,
      );
      final foodFactor = result.factors
          .firstWhere((f) => f.type == StressFactorType.food);
      expect(foodFactor.valueLabel, '');
    });
  });
}
