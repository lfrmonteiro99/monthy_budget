import '../models/actual_expense.dart';

/// Pure filtering function for expense search.
///
/// Matches [query] against description, category name, and formatted amount.
/// Filters by [selectedCategories] (empty = no category filter).
/// Filters by [dateFrom] / [dateTo] (inclusive on both ends).
/// Returns results sorted by date descending.
List<ActualExpense> filterExpenses(
  List<ActualExpense> expenses, {
  String query = '',
  Set<String> selectedCategories = const {},
  DateTime? dateFrom,
  DateTime? dateTo,
}) {
  final q = query.toLowerCase().trim();

  final filtered = expenses.where((e) {
    // Text search: match description, category, or amount
    if (q.isNotEmpty) {
      final desc = (e.description ?? '').toLowerCase();
      final cat = e.category.toLowerCase();
      final amt = e.amount.toString();
      if (!desc.contains(q) && !cat.contains(q) && !amt.contains(q)) {
        return false;
      }
    }

    // Category chip filter
    if (selectedCategories.isNotEmpty) {
      if (!selectedCategories.contains(e.category)) return false;
    }

    // Date range filter
    if (dateFrom != null && e.date.isBefore(dateFrom)) return false;
    if (dateTo != null &&
        e.date.isAfter(dateTo.add(const Duration(days: 1)))) {
      return false;
    }

    return true;
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  return filtered;
}

/// Extracts all unique category names from a history map.
Set<String> extractCategories(Map<String, List<ActualExpense>> history) {
  return history.values.expand((l) => l).map((e) => e.category).toSet();
}
