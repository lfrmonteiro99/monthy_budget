import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/services/spending_anomaly_service.dart';

void main() {
  String monthKey(int year, int month) =>
      '$year-${month.toString().padLeft(2, '0')}';

  /// Helper: build months of history for a category with given amounts.
  Map<String, List<ActualExpense>> buildHistory({
    required String category,
    required List<double> monthlyAmounts,
    int startYear = 2026,
    int startMonth = 1,
  }) {
    final history = <String, List<ActualExpense>>{};
    for (var i = 0; i < monthlyAmounts.length; i++) {
      var m = startMonth + i;
      var y = startYear;
      while (m > 12) {
        m -= 12;
        y++;
      }
      final key = monthKey(y, m);
      history[key] = [
        ActualExpense(
          id: 'e_${category}_$i',
          category: category,
          amount: monthlyAmounts[i],
          date: DateTime(y, m, 15),
          monthKey: key,
        ),
      ];
    }
    return history;
  }

  /// Merges multiple history maps into one.
  Map<String, List<ActualExpense>> mergeHistories(
    List<Map<String, List<ActualExpense>>> histories,
  ) {
    final merged = <String, List<ActualExpense>>{};
    for (final h in histories) {
      for (final entry in h.entries) {
        merged.putIfAbsent(entry.key, () => []).addAll(entry.value);
      }
    }
    return merged;
  }

  group('SpendingAnomalyService.detectAnomalies', () {
    test('category spending 2x the 3-month average is flagged', () {
      // 3-month history: Jan=100, Feb=100, Mar=100 -> avg=100
      // Current month (Apr): 200 -> deviation = 100% > 30%
      final history = buildHistory(
        category: 'alimentacao',
        monthlyAmounts: [100, 100, 100, 200],
        startYear: 2026,
        startMonth: 1,
      );
      final currentMonthKey = monthKey(2026, 4);

      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: history,
        currentMonthKey: currentMonthKey,
      );

      expect(anomalies, hasLength(1));
      expect(anomalies.first.category, 'alimentacao');
      expect(anomalies.first.currentAmount, 200);
      expect(anomalies.first.averageAmount, 100);
      expect(anomalies.first.deviationPercent, closeTo(100.0, 0.01));
    });

    test('category spending within 30% of average is NOT flagged', () {
      // 3-month history: Jan=100, Feb=100, Mar=100 -> avg=100
      // Current month (Apr): 120 -> deviation = 20% <= 30%
      final history = buildHistory(
        category: 'alimentacao',
        monthlyAmounts: [100, 100, 100, 120],
        startYear: 2026,
        startMonth: 1,
      );
      final currentMonthKey = monthKey(2026, 4);

      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: history,
        currentMonthKey: currentMonthKey,
      );

      expect(anomalies, isEmpty);
    });

    test('no history returns no anomalies', () {
      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: const {},
        currentMonthKey: '2026-04',
      );

      expect(anomalies, isEmpty);
    });

    test('fewer than 3 months of history returns no anomalies', () {
      // Only 2 months of history + current month
      final history = buildHistory(
        category: 'alimentacao',
        monthlyAmounts: [100, 100, 500],
        startYear: 2026,
        startMonth: 2,
      );
      final currentMonthKey = monthKey(2026, 4);

      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: history,
        currentMonthKey: currentMonthKey,
      );

      expect(anomalies, isEmpty);
    });

    test('exactly at 30% deviation boundary is NOT flagged', () {
      // avg=100, current=130 -> deviation = 30% exactly -> not flagged (>30% required)
      final history = buildHistory(
        category: 'habitacao',
        monthlyAmounts: [100, 100, 100, 130],
        startYear: 2026,
        startMonth: 1,
      );
      final currentMonthKey = monthKey(2026, 4);

      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: history,
        currentMonthKey: currentMonthKey,
      );

      expect(anomalies, isEmpty);
    });

    test('just above 30% deviation is flagged', () {
      // avg=100, current=131 -> deviation = 31% > 30%
      final history = buildHistory(
        category: 'habitacao',
        monthlyAmounts: [100, 100, 100, 131],
        startYear: 2026,
        startMonth: 1,
      );
      final currentMonthKey = monthKey(2026, 4);

      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: history,
        currentMonthKey: currentMonthKey,
      );

      expect(anomalies, hasLength(1));
      expect(anomalies.first.deviationPercent, closeTo(31.0, 0.01));
    });

    test('multiple categories with mixed anomalies', () {
      // alimentacao: avg=100, current=200 -> flagged (100%)
      // habitacao: avg=500, current=510 -> not flagged (2%)
      // transporte: avg=50, current=80 -> flagged (60%)
      final history = mergeHistories([
        buildHistory(
          category: 'alimentacao',
          monthlyAmounts: [100, 100, 100, 200],
          startMonth: 1,
        ),
        buildHistory(
          category: 'habitacao',
          monthlyAmounts: [500, 500, 500, 510],
          startMonth: 1,
        ),
        buildHistory(
          category: 'transporte',
          monthlyAmounts: [50, 50, 50, 80],
          startMonth: 1,
        ),
      ]);
      final currentMonthKey = monthKey(2026, 4);

      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: history,
        currentMonthKey: currentMonthKey,
      );

      expect(anomalies, hasLength(2));
      final categories = anomalies.map((a) => a.category).toSet();
      expect(categories, containsAll(['alimentacao', 'transporte']));
    });

    test('anomalies are sorted by deviation descending', () {
      final history = mergeHistories([
        buildHistory(
          category: 'alimentacao',
          monthlyAmounts: [100, 100, 100, 200],
          startMonth: 1,
        ),
        buildHistory(
          category: 'transporte',
          monthlyAmounts: [50, 50, 50, 100],
          startMonth: 1,
        ),
      ]);
      final currentMonthKey = monthKey(2026, 4);

      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: history,
        currentMonthKey: currentMonthKey,
      );

      expect(anomalies, hasLength(2));
      expect(anomalies.first.deviationPercent >= anomalies.last.deviationPercent, isTrue);
    });

    test('zero average (no spending in prior months) is not flagged', () {
      final history = <String, List<ActualExpense>>{
        '2026-01': [
          ActualExpense(
            id: 'e1',
            category: 'habitacao',
            amount: 500,
            date: DateTime(2026, 1, 15),
            monthKey: '2026-01',
          ),
        ],
        '2026-02': [
          ActualExpense(
            id: 'e2',
            category: 'habitacao',
            amount: 500,
            date: DateTime(2026, 2, 15),
            monthKey: '2026-02',
          ),
        ],
        '2026-03': [
          ActualExpense(
            id: 'e3',
            category: 'habitacao',
            amount: 500,
            date: DateTime(2026, 3, 15),
            monthKey: '2026-03',
          ),
        ],
        '2026-04': [
          ActualExpense(
            id: 'e4',
            category: 'lazer',
            amount: 200,
            date: DateTime(2026, 4, 15),
            monthKey: '2026-04',
          ),
        ],
      };

      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: history,
        currentMonthKey: '2026-04',
      );

      // lazer has 0 avg -> not flagged; habitacao not in current month -> not flagged
      expect(anomalies, isEmpty);
    });

    test('uses only 3 most recent months before current for average', () {
      // 5 months: Jan=10, Feb=20, Mar=300, Apr=300, May(current)=200
      // Prior 3 months: Feb, Mar, Apr -> (20 + 300 + 300) / 3 = 206.67
      // Current = 200 -> deviation = (200-206.67)/206.67 = -3.2% -> not flagged
      final history = buildHistory(
        category: 'alimentacao',
        monthlyAmounts: [10, 20, 300, 300, 200],
        startYear: 2026,
        startMonth: 1,
      );
      final currentMonthKey = monthKey(2026, 5);

      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: history,
        currentMonthKey: currentMonthKey,
      );

      expect(anomalies, isEmpty);
    });
  });
}
