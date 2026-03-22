import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/services/yearly_summary_service.dart';

void main() {
  ActualExpense _expense(
    String category,
    double amount,
    int year,
    int month, {
    int day = 15,
  }) {
    final mk = '$year-${month.toString().padLeft(2, '0')}';
    return ActualExpense(
      id: 'e_${category}_${year}_$month',
      category: category,
      amount: amount,
      date: DateTime(year, month, day),
      monthKey: mk,
    );
  }

  group('YearlySummaryService.generate', () {
    test('computes total income, expenses and net savings', () {
      final incomes = {
        '2025-01': 3000.0,
        '2025-02': 3000.0,
        '2025-03': 3000.0,
      };
      final expenses = [
        _expense('alimentacao', 500, 2025, 1),
        _expense('habitacao', 800, 2025, 1),
        _expense('alimentacao', 600, 2025, 2),
        _expense('habitacao', 800, 2025, 2),
        _expense('alimentacao', 550, 2025, 3),
        _expense('habitacao', 800, 2025, 3),
      ];

      final report = YearlySummaryService.generate(
        year: 2025,
        monthlyIncomes: incomes,
        expenses: expenses,
      );

      expect(report.totalIncome, 9000);
      expect(report.totalExpenses, 4050);
      expect(report.netSavings, 4950);
      expect(report.savingsRate, closeTo(55.0, 0.1));
    });

    test('aggregates category totals correctly', () {
      final incomes = {'2025-06': 2000.0};
      final expenses = [
        _expense('alimentacao', 200, 2025, 6),
        _expense('alimentacao', 150, 2025, 6),
        _expense('lazer', 100, 2025, 6),
      ];

      final report = YearlySummaryService.generate(
        year: 2025,
        monthlyIncomes: incomes,
        expenses: expenses,
      );

      expect(report.categoryTotals['alimentacao'], 350);
      expect(report.categoryTotals['lazer'], 100);
      expect(report.categoryTotals.containsKey('habitacao'), isFalse);
    });

    test('builds 12-month category trends', () {
      final incomes = {
        '2025-01': 2000.0,
        '2025-06': 2000.0,
      };
      final expenses = [
        _expense('alimentacao', 300, 2025, 1),
        _expense('alimentacao', 400, 2025, 6),
      ];

      final report = YearlySummaryService.generate(
        year: 2025,
        monthlyIncomes: incomes,
        expenses: expenses,
      );

      final trend = report.categoryTrends['alimentacao']!;
      expect(trend.length, 12);
      expect(trend[0], 300); // January (index 0)
      expect(trend[5], 400); // June (index 5)
      expect(trend[11], 0); // December (index 11)
    });

    test('identifies best and worst months', () {
      final incomes = {
        '2025-01': 3000.0,
        '2025-02': 3000.0,
        '2025-03': 3000.0,
      };
      final expenses = [
        _expense('alimentacao', 500, 2025, 1), // net = 2500
        _expense('alimentacao', 2800, 2025, 2), // net = 200
        _expense('alimentacao', 1000, 2025, 3), // net = 2000
      ];

      final report = YearlySummaryService.generate(
        year: 2025,
        monthlyIncomes: incomes,
        expenses: expenses,
      );

      expect(report.bestMonth, '2025-01');
      expect(report.bestMonthNet, 2500);
      expect(report.worstMonth, '2025-02');
      expect(report.worstMonthNet, 200);
    });

    test('filters out data from other years', () {
      final incomes = {
        '2025-01': 3000.0,
        '2024-12': 5000.0, // should be excluded
      };
      final expenses = [
        _expense('alimentacao', 500, 2025, 1),
        _expense('alimentacao', 9999, 2024, 12), // should be excluded
      ];

      final report = YearlySummaryService.generate(
        year: 2025,
        monthlyIncomes: incomes,
        expenses: expenses,
      );

      expect(report.totalIncome, 3000);
      expect(report.totalExpenses, 500);
      expect(report.netSavings, 2500);
    });

    test('empty data produces zero report', () {
      final report = YearlySummaryService.generate(
        year: 2025,
        monthlyIncomes: {},
        expenses: [],
      );

      expect(report.totalIncome, 0);
      expect(report.totalExpenses, 0);
      expect(report.netSavings, 0);
      expect(report.savingsRate, 0);
      expect(report.bestMonth, isNull);
      expect(report.worstMonth, isNull);
      expect(report.categoryTotals, isEmpty);
      expect(report.categoryTrends, isEmpty);
    });
  });
}
