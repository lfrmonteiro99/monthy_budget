import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/services/export_service.dart';

void main() {
  late ExportService service;

  setUp(() {
    service = ExportService();
  });

  group('generateCsv', () {
    test('produces header + rows sorted by date descending', () {
      final expenses = [
        ActualExpense(
          id: 'e1',
          category: 'alimentacao',
          amount: 50.0,
          date: DateTime(2026, 3, 1),
          monthKey: '2026-03',
        ),
        ActualExpense(
          id: 'e2',
          category: 'lazer',
          amount: 25.0,
          date: DateTime(2026, 3, 15),
          monthKey: '2026-03',
        ),
      ];

      final csv = service.generateCsv(
        expenses: expenses,
        categoryLabelMap: (c) => c.toUpperCase(),
        headerRow: ['Date', 'Category', 'Description', 'Amount'],
      );

      final lines = csv.split('\n').map((l) => l.trimRight()).toList();
      expect(lines.length, 3); // header + 2 rows
      expect(lines[0], 'Date,Category,Description,Amount');
      // Most recent first
      expect(lines[1], contains('2026-03-15'));
      expect(lines[2], contains('2026-03-01'));
    });

    test('returns only header when no expenses', () {
      final csv = service.generateCsv(
        expenses: [],
        categoryLabelMap: (c) => c,
        headerRow: ['Date', 'Category', 'Description', 'Amount'],
      );

      final lines = csv.split('\n');
      expect(lines.length, 1);
      expect(lines[0], 'Date,Category,Description,Amount');
    });
  });

  group('generateMonthlySummaryCsv', () {
    final budgetSummary = BudgetSummary(
      totalNetWithMeal: 2000.0,
      totalGross: 2500.0,
      totalNet: 1900.0,
      totalMealAllowance: 100.0,
      totalIRS: 400.0,
      totalSS: 275.0,
      totalDeductions: 675.0,
      totalExpenses: 1500.0,
      netLiquidity: 500.0,
      savingsRate: 0.25,
    );

    final categorySummaries = [
      const CategoryBudgetSummary(
        category: 'alimentacao',
        budgeted: 400.0,
        actual: 350.0,
      ),
      const CategoryBudgetSummary(
        category: 'transportes',
        budgeted: 200.0,
        actual: 250.0,
      ),
      const CategoryBudgetSummary(
        category: 'lazer',
        budgeted: 100.0,
        actual: 80.0,
      ),
    ];

    final expenses = [
      ActualExpense(
        id: 'e1',
        category: 'alimentacao',
        amount: 150.0,
        date: DateTime(2026, 3, 5),
        description: 'Groceries',
        monthKey: '2026-03',
      ),
      ActualExpense(
        id: 'e2',
        category: 'alimentacao',
        amount: 200.0,
        date: DateTime(2026, 3, 12),
        description: 'Restaurant',
        monthKey: '2026-03',
      ),
      ActualExpense(
        id: 'e3',
        category: 'transportes',
        amount: 250.0,
        date: DateTime(2026, 3, 1),
        description: 'Fuel',
        monthKey: '2026-03',
      ),
      ActualExpense(
        id: 'e4',
        category: 'lazer',
        amount: 80.0,
        date: DateTime(2026, 3, 20),
        description: 'Cinema',
        monthKey: '2026-03',
      ),
    ];

    test('contains income section with net income', () {
      final csv = service.generateMonthlySummaryCsv(
        monthLabel: 'March 2026',
        budgetSummary: budgetSummary,
        categorySummaries: categorySummaries,
        expenses: expenses,
        categoryLabelMap: (c) => c.toUpperCase(),
        formatCurrency: (v) => '${v.toStringAsFixed(2)} EUR',
        sectionIncome: 'Income',
        sectionBudgetVsActual: 'Budget vs Actual',
        sectionExpenses: 'Expense Detail',
        sectionSummary: 'Monthly Summary',
        headerCategory: 'Category',
        headerBudgeted: 'Budgeted',
        headerActual: 'Actual',
        headerRemaining: 'Remaining',
        headerDate: 'Date',
        headerDescription: 'Description',
        headerAmount: 'Amount',
        labelTotalIncome: 'Total Net Income',
        labelGrossIncome: 'Gross Income',
        labelDeductions: 'Deductions',
        labelTotalExpenses: 'Total Expenses',
        labelNetLiquidity: 'Net Liquidity',
        labelSavingsRate: 'Savings Rate',
        labelTotal: 'Total',
      );

      expect(csv, contains('Income'));
      expect(csv, contains('Total Net Income'));
      expect(csv, contains('2000.00 EUR'));
      expect(csv, contains('Gross Income'));
      expect(csv, contains('2500.00 EUR'));
    });

    test('contains budget vs actual section per category', () {
      final csv = service.generateMonthlySummaryCsv(
        monthLabel: 'March 2026',
        budgetSummary: budgetSummary,
        categorySummaries: categorySummaries,
        expenses: expenses,
        categoryLabelMap: (c) => c.toUpperCase(),
        formatCurrency: (v) => '${v.toStringAsFixed(2)} EUR',
        sectionIncome: 'Income',
        sectionBudgetVsActual: 'Budget vs Actual',
        sectionExpenses: 'Expense Detail',
        sectionSummary: 'Monthly Summary',
        headerCategory: 'Category',
        headerBudgeted: 'Budgeted',
        headerActual: 'Actual',
        headerRemaining: 'Remaining',
        headerDate: 'Date',
        headerDescription: 'Description',
        headerAmount: 'Amount',
        labelTotalIncome: 'Total Net Income',
        labelGrossIncome: 'Gross Income',
        labelDeductions: 'Deductions',
        labelTotalExpenses: 'Total Expenses',
        labelNetLiquidity: 'Net Liquidity',
        labelSavingsRate: 'Savings Rate',
        labelTotal: 'Total',
      );

      expect(csv, contains('Budget vs Actual'));
      expect(csv, contains('ALIMENTACAO'));
      expect(csv, contains('400.00 EUR'));
      expect(csv, contains('350.00 EUR'));
      expect(csv, contains('TRANSPORTES'));
      // Total row
      expect(csv, contains('Total'));
      expect(csv, contains('700.00 EUR')); // 400+200+100
    });

    test('contains expense detail rows sorted newest first', () {
      final csv = service.generateMonthlySummaryCsv(
        monthLabel: 'March 2026',
        budgetSummary: budgetSummary,
        categorySummaries: categorySummaries,
        expenses: expenses,
        categoryLabelMap: (c) => c.toUpperCase(),
        formatCurrency: (v) => '${v.toStringAsFixed(2)} EUR',
        sectionIncome: 'Income',
        sectionBudgetVsActual: 'Budget vs Actual',
        sectionExpenses: 'Expense Detail',
        sectionSummary: 'Monthly Summary',
        headerCategory: 'Category',
        headerBudgeted: 'Budgeted',
        headerActual: 'Actual',
        headerRemaining: 'Remaining',
        headerDate: 'Date',
        headerDescription: 'Description',
        headerAmount: 'Amount',
        labelTotalIncome: 'Total Net Income',
        labelGrossIncome: 'Gross Income',
        labelDeductions: 'Deductions',
        labelTotalExpenses: 'Total Expenses',
        labelNetLiquidity: 'Net Liquidity',
        labelSavingsRate: 'Savings Rate',
        labelTotal: 'Total',
      );

      expect(csv, contains('Expense Detail'));
      expect(csv, contains('Cinema'));
      expect(csv, contains('Groceries'));

      // Check order: March 20 should appear before March 12 (descending)
      final cinemaIdx = csv.indexOf('2026-03-20');
      final restaurantIdx = csv.indexOf('2026-03-12');
      final groceriesIdx = csv.indexOf('2026-03-05');
      expect(cinemaIdx, lessThan(restaurantIdx));
      expect(restaurantIdx, lessThan(groceriesIdx));
    });

    test('contains summary section with savings rate', () {
      final csv = service.generateMonthlySummaryCsv(
        monthLabel: 'March 2026',
        budgetSummary: budgetSummary,
        categorySummaries: categorySummaries,
        expenses: expenses,
        categoryLabelMap: (c) => c.toUpperCase(),
        formatCurrency: (v) => '${v.toStringAsFixed(2)} EUR',
        sectionIncome: 'Income',
        sectionBudgetVsActual: 'Budget vs Actual',
        sectionExpenses: 'Expense Detail',
        sectionSummary: 'Monthly Summary',
        headerCategory: 'Category',
        headerBudgeted: 'Budgeted',
        headerActual: 'Actual',
        headerRemaining: 'Remaining',
        headerDate: 'Date',
        headerDescription: 'Description',
        headerAmount: 'Amount',
        labelTotalIncome: 'Total Net Income',
        labelGrossIncome: 'Gross Income',
        labelDeductions: 'Deductions',
        labelTotalExpenses: 'Total Expenses',
        labelNetLiquidity: 'Net Liquidity',
        labelSavingsRate: 'Savings Rate',
        labelTotal: 'Total',
      );

      expect(csv, contains('Monthly Summary'));
      expect(csv, contains('Savings Rate'));
      expect(csv, contains('25.00%'));
      expect(csv, contains('Net Liquidity'));
      expect(csv, contains('500.00 EUR'));
    });

    test('handles empty expenses gracefully', () {
      final csv = service.generateMonthlySummaryCsv(
        monthLabel: 'March 2026',
        budgetSummary: budgetSummary,
        categorySummaries: const [],
        expenses: const [],
        categoryLabelMap: (c) => c.toUpperCase(),
        formatCurrency: (v) => '${v.toStringAsFixed(2)} EUR',
        sectionIncome: 'Income',
        sectionBudgetVsActual: 'Budget vs Actual',
        sectionExpenses: 'Expense Detail',
        sectionSummary: 'Monthly Summary',
        headerCategory: 'Category',
        headerBudgeted: 'Budgeted',
        headerActual: 'Actual',
        headerRemaining: 'Remaining',
        headerDate: 'Date',
        headerDescription: 'Description',
        headerAmount: 'Amount',
        labelTotalIncome: 'Total Net Income',
        labelGrossIncome: 'Gross Income',
        labelDeductions: 'Deductions',
        labelTotalExpenses: 'Total Expenses',
        labelNetLiquidity: 'Net Liquidity',
        labelSavingsRate: 'Savings Rate',
        labelTotal: 'Total',
      );

      // Should still produce income + summary sections
      expect(csv, contains('Income'));
      expect(csv, contains('Monthly Summary'));
      expect(csv, contains('Budget vs Actual'));
    });

    test('month label appears at top of CSV', () {
      final csv = service.generateMonthlySummaryCsv(
        monthLabel: 'March 2026',
        budgetSummary: budgetSummary,
        categorySummaries: categorySummaries,
        expenses: expenses,
        categoryLabelMap: (c) => c.toUpperCase(),
        formatCurrency: (v) => '${v.toStringAsFixed(2)} EUR',
        sectionIncome: 'Income',
        sectionBudgetVsActual: 'Budget vs Actual',
        sectionExpenses: 'Expense Detail',
        sectionSummary: 'Monthly Summary',
        headerCategory: 'Category',
        headerBudgeted: 'Budgeted',
        headerActual: 'Actual',
        headerRemaining: 'Remaining',
        headerDate: 'Date',
        headerDescription: 'Description',
        headerAmount: 'Amount',
        labelTotalIncome: 'Total Net Income',
        labelGrossIncome: 'Gross Income',
        labelDeductions: 'Deductions',
        labelTotalExpenses: 'Total Expenses',
        labelNetLiquidity: 'Net Liquidity',
        labelSavingsRate: 'Savings Rate',
        labelTotal: 'Total',
      );

      final lines = csv.split('\n');
      expect(lines[0], contains('March 2026'));
    });
  });
}
