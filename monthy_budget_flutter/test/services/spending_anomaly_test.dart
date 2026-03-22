import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/services/spending_anomaly_service.dart';

ActualExpense _expense(String category, double amount, String monthKey) {
  return ActualExpense(
    id: '${category}_$monthKey',
    category: category,
    amount: amount,
    date: DateTime(2026, 3, 1),
    monthKey: monthKey,
  );
}

void main() {
  group('SpendingAnomalyService', () {
    test('detects category spending 2x the 3-month average', () {
      final history = <String, List<ActualExpense>>{
        '2026-03': [_expense('Leisure', 200, '2026-03')],
        '2026-02': [_expense('Leisure', 100, '2026-02')],
        '2026-01': [_expense('Leisure', 100, '2026-01')],
        '2025-12': [_expense('Leisure', 100, '2025-12')],
      };

      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: history,
        currentMonthKey: '2026-03',
      );

      expect(anomalies, hasLength(1));
      expect(anomalies.first.category, 'Leisure');
      expect(anomalies.first.deviationPercent, closeTo(100, 1));
    });

    test('does not flag category within 30%', () {
      final history = <String, List<ActualExpense>>{
        '2026-03': [_expense('Transport', 120, '2026-03')],
        '2026-02': [_expense('Transport', 100, '2026-02')],
        '2026-01': [_expense('Transport', 100, '2026-01')],
        '2025-12': [_expense('Transport', 100, '2025-12')],
      };

      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: history,
        currentMonthKey: '2026-03',
      );

      expect(anomalies, isEmpty);
    });

    test('returns empty when no history', () {
      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: {},
        currentMonthKey: '2026-03',
      );
      expect(anomalies, isEmpty);
    });

    test('returns empty when fewer than 3 prior months', () {
      final history = <String, List<ActualExpense>>{
        '2026-03': [_expense('Food', 500, '2026-03')],
        '2026-02': [_expense('Food', 100, '2026-02')],
      };

      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: history,
        currentMonthKey: '2026-03',
      );

      expect(anomalies, isEmpty);
    });

    test('sorts multiple anomalies by deviation descending', () {
      final history = <String, List<ActualExpense>>{
        '2026-03': [
          _expense('Leisure', 300, '2026-03'),
          _expense('Dining', 200, '2026-03'),
        ],
        '2026-02': [
          _expense('Leisure', 100, '2026-02'),
          _expense('Dining', 100, '2026-02'),
        ],
        '2026-01': [
          _expense('Leisure', 100, '2026-01'),
          _expense('Dining', 100, '2026-01'),
        ],
        '2025-12': [
          _expense('Leisure', 100, '2025-12'),
          _expense('Dining', 100, '2025-12'),
        ],
      };

      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: history,
        currentMonthKey: '2026-03',
      );

      expect(anomalies, hasLength(2));
      expect(anomalies.first.category, 'Leisure');
      expect(anomalies.last.category, 'Dining');
    });

    test('skips categories with no prior history', () {
      final history = <String, List<ActualExpense>>{
        '2026-03': [_expense('NewCategory', 500, '2026-03')],
        '2026-02': [_expense('Food', 100, '2026-02')],
        '2026-01': [_expense('Food', 100, '2026-01')],
        '2025-12': [_expense('Food', 100, '2025-12')],
      };

      final anomalies = SpendingAnomalyService.detectAnomalies(
        actualExpenseHistory: history,
        currentMonthKey: '2026-03',
      );

      expect(anomalies, isEmpty);
    });
  });
}
