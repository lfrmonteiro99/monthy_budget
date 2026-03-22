import '../models/actual_expense.dart';

/// Represents a spending anomaly for a single category.
class SpendingAnomaly {
  final String category;
  final double currentAmount;
  final double averageAmount;

  /// Percentage deviation from the rolling average (always positive when flagged).
  final double deviationPercent;

  const SpendingAnomaly({
    required this.category,
    required this.currentAmount,
    required this.averageAmount,
    required this.deviationPercent,
  });
}

/// Pure-logic service to detect spending anomalies.
///
/// An anomaly is flagged when a category's spending in the current month
/// deviates by more than 30% from its 3-month rolling average.
class SpendingAnomalyService {
  SpendingAnomalyService._();

  static const _requiredHistoryMonths = 3;
  static const _deviationThreshold = 30.0;

  /// Detect categories whose current-month spending deviates >30%
  /// from their 3-month rolling average.
  ///
  /// [actualExpenseHistory] maps monthKey (e.g. '2026-04') to expenses.
  /// [currentMonthKey] is the month to evaluate (e.g. '2026-04').
  static List<SpendingAnomaly> detectAnomalies({
    required Map<String, List<ActualExpense>> actualExpenseHistory,
    required String currentMonthKey,
  }) {
    if (actualExpenseHistory.isEmpty) return const [];

    // Get current month expenses
    final currentExpenses = actualExpenseHistory[currentMonthKey];
    if (currentExpenses == null || currentExpenses.isEmpty) return const [];

    // Aggregate current month spending by category
    final currentByCategory = <String, double>{};
    for (final e in currentExpenses) {
      currentByCategory[e.category] =
          (currentByCategory[e.category] ?? 0) + e.amount;
    }

    // Find the 3 most recent months before current month
    final priorMonthKeys = actualExpenseHistory.keys
        .where((k) => k != currentMonthKey && k.compareTo(currentMonthKey) < 0)
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (priorMonthKeys.length < _requiredHistoryMonths) return const [];

    final windowKeys = priorMonthKeys.take(_requiredHistoryMonths).toList();

    // Aggregate historical spending by category for the 3-month window
    final historicalByCategory = <String, double>{};
    for (final key in windowKeys) {
      final expenses = actualExpenseHistory[key] ?? [];
      for (final e in expenses) {
        historicalByCategory[e.category] =
            (historicalByCategory[e.category] ?? 0) + e.amount;
      }
    }

    // Detect anomalies
    final anomalies = <SpendingAnomaly>[];
    for (final entry in currentByCategory.entries) {
      final category = entry.key;
      final currentAmount = entry.value;
      final historicalTotal = historicalByCategory[category];

      // Skip categories with no prior history
      if (historicalTotal == null || historicalTotal <= 0) continue;

      final average = historicalTotal / _requiredHistoryMonths;
      if (average <= 0) continue;

      final deviation = ((currentAmount - average) / average) * 100;
      if (deviation > _deviationThreshold) {
        anomalies.add(SpendingAnomaly(
          category: category,
          currentAmount: currentAmount,
          averageAmount: average,
          deviationPercent: deviation,
        ));
      }
    }

    // Sort by deviation descending (highest anomaly first)
    anomalies.sort((a, b) => b.deviationPercent.compareTo(a.deviationPercent));

    return anomalies;
  }
}
