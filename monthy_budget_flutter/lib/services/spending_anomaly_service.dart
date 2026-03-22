import '../models/actual_expense.dart';

class SpendingAnomaly {
  final String category;
  final double currentAmount;
  final double rollingAverage;
  final double deviationPercent;

  const SpendingAnomaly({
    required this.category,
    required this.currentAmount,
    required this.rollingAverage,
    required this.deviationPercent,
  });
}

class SpendingAnomalyDetector {
  static const double _threshold = 0.30;
  static const int _windowMonths = 3;

  static List<SpendingAnomaly> detect({
    required List<ActualExpense> currentMonthExpenses,
    required List<ActualExpense> historicalExpenses,
    required String currentMonthKey,
  }) {
    if (historicalExpenses.isEmpty) return [];

    final currentByCategory = _groupByCategory(currentMonthExpenses);

    final history = historicalExpenses
        .where((e) => e.monthKey != currentMonthKey)
        .toList();
    if (history.isEmpty) return [];

    final monthKeys = history.map((e) => e.monthKey).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    final recentMonthKeys = monthKeys.take(_windowMonths).toSet();

    final recentHistory = history
        .where((e) => recentMonthKeys.contains(e.monthKey))
        .toList();
    if (recentHistory.isEmpty) return [];

    final historyByCategory = _groupByCategory(recentHistory);
    final monthCount = recentMonthKeys.length;

    final anomalies = <SpendingAnomaly>[];

    for (final entry in currentByCategory.entries) {
      final category = entry.key;
      final currentTotal = entry.value;
      final historyTotal = historyByCategory[category] ?? 0;
      final average = historyTotal / monthCount;

      if (average <= 0) continue;

      final deviation = (currentTotal - average) / average;
      if (deviation > _threshold) {
        anomalies.add(SpendingAnomaly(
          category: category,
          currentAmount: currentTotal,
          rollingAverage: average,
          deviationPercent: deviation * 100,
        ));
      }
    }

    anomalies.sort((a, b) => b.deviationPercent.compareTo(a.deviationPercent));
    return anomalies;
  }

  static Map<String, double> _groupByCategory(List<ActualExpense> expenses) {
    final map = <String, double>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }
}
