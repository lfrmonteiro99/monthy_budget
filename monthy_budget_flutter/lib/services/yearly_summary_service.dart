import '../models/actual_expense.dart';
import '../models/budget_summary.dart';

/// Aggregated yearly report for a single calendar year.
class YearlySummaryReport {
  final int year;
  final double totalIncome;
  final double totalExpenses;
  final double netSavings;

  /// Category -> total spent across the year.
  final Map<String, double> categoryTotals;

  /// Category -> month-index (0..11) -> amount spent.
  final Map<String, List<double>> categoryTrends;

  /// Month label (monthKey) of the best month (highest net savings).
  final String? bestMonth;

  /// Month label (monthKey) of the worst month (lowest net savings).
  final String? worstMonth;

  final double bestMonthNet;
  final double worstMonthNet;

  const YearlySummaryReport({
    required this.year,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netSavings,
    required this.categoryTotals,
    required this.categoryTrends,
    this.bestMonth,
    this.worstMonth,
    this.bestMonthNet = 0,
    this.worstMonthNet = 0,
  });

  double get savingsRate =>
      totalIncome > 0 ? (netSavings / totalIncome) * 100 : 0;
}

/// Pure-logic service that produces a yearly summary report.
class YearlySummaryService {
  YearlySummaryService._();

  /// Build a [YearlySummaryReport] for [year].
  ///
  /// [monthlyIncomes] maps monthKey (e.g. '2025-01') to total net income
  /// for that month. Only keys matching [year] are used.
  ///
  /// [expenses] is the full list of [ActualExpense]; only those matching
  /// [year] are included.
  static YearlySummaryReport generate({
    required int year,
    required Map<String, double> monthlyIncomes,
    required List<ActualExpense> expenses,
  }) {
    final yearPrefix = '$year-';

    // Filter expenses for the target year
    final yearExpenses =
        expenses.where((e) => e.monthKey.startsWith(yearPrefix)).toList();

    // Filter incomes for the target year
    final yearIncomes = <String, double>{};
    for (final entry in monthlyIncomes.entries) {
      if (entry.key.startsWith(yearPrefix)) {
        yearIncomes[entry.key] = entry.value;
      }
    }

    // Total income
    final totalIncome =
        yearIncomes.values.fold<double>(0, (sum, v) => sum + v);

    // Expenses by month and category
    final expensesByMonth = <String, double>{};
    final categoryTotals = <String, double>{};
    final categoryByMonthIndex = <String, List<double>>{};

    for (final e in yearExpenses) {
      expensesByMonth[e.monthKey] =
          (expensesByMonth[e.monthKey] ?? 0) + e.amount;
      categoryTotals[e.category] =
          (categoryTotals[e.category] ?? 0) + e.amount;

      // Month index: 0 = January
      final monthIndex = int.parse(e.monthKey.substring(5, 7)) - 1;
      categoryByMonthIndex
          .putIfAbsent(e.category, () => List.filled(12, 0.0));
      categoryByMonthIndex[e.category]![monthIndex] += e.amount;
    }

    final totalExpenses =
        expensesByMonth.values.fold<double>(0, (sum, v) => sum + v);
    final netSavings = totalIncome - totalExpenses;

    // Best / worst months by net (income - expenses)
    String? bestMonth;
    String? worstMonth;
    double bestNet = double.negativeInfinity;
    double worstNet = double.infinity;

    // Consider all 12 months of the year for which we have any data
    final allMonthKeys = <String>{
      ...yearIncomes.keys,
      ...expensesByMonth.keys,
    };

    for (final mk in allMonthKeys) {
      final income = yearIncomes[mk] ?? 0;
      final expense = expensesByMonth[mk] ?? 0;
      final net = income - expense;

      if (net > bestNet) {
        bestNet = net;
        bestMonth = mk;
      }
      if (net < worstNet) {
        worstNet = net;
        worstMonth = mk;
      }
    }

    return YearlySummaryReport(
      year: year,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netSavings: netSavings,
      categoryTotals: categoryTotals,
      categoryTrends: categoryByMonthIndex,
      bestMonth: bestMonth,
      worstMonth: worstMonth,
      bestMonthNet: bestNet.isFinite ? bestNet : 0,
      worstMonthNet: worstNet.isFinite ? worstNet : 0,
    );
  }
}
