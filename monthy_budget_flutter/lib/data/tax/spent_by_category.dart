import '../../models/actual_expense.dart';
import '../../models/purchase_record.dart';

/// Aggregates the year's spend per category, feeding the IRS deduction
/// summary on the Despesas screen and the Dashboard deduction card.
///
/// [actualExpenses] is the current month's expenses — the source of truth for
/// the current month, since it reflects in-memory additions before the history
/// is reloaded. [actualExpenseHistory] holds past months and, after a reload,
/// the current month too; the current month is skipped there to avoid
/// double-counting (#1314).
Map<String, double> computeSpentByCategory({
  required List<ActualExpense> actualExpenses,
  required Map<String, List<ActualExpense>> actualExpenseHistory,
  required PurchaseHistory purchaseHistory,
  required int year,
  required String currentMonthKey,
}) {
  final spentByCategory = <String, double>{};
  for (final entry in actualExpenseHistory.entries) {
    // The current month is always covered by [actualExpenses]; after a
    // reload the history map also contains it, so counting it here too would
    // double-count every current-month expense (#1314).
    if (entry.key == currentMonthKey) continue;
    final parts = entry.key.split('-');
    if (parts.length < 2) continue;
    final entryYear = int.tryParse(parts[0]);
    if (entryYear != year) continue;
    for (final expense in entry.value) {
      spentByCategory[expense.category] =
          (spentByCategory[expense.category] ?? 0) + expense.amount;
    }
  }
  for (final expense in actualExpenses) {
    if (expense.date.year == year) {
      spentByCategory[expense.category] =
          (spentByCategory[expense.category] ?? 0) + expense.amount;
    }
  }
  final foodSpent = purchaseHistory.records
      .where((r) => r.date.year == year)
      .fold(0.0, (s, r) => s + r.amount);
  if (foodSpent > 0) {
    spentByCategory['alimentacao'] =
        (spentByCategory['alimentacao'] ?? 0) + foodSpent;
  }
  return spentByCategory;
}
