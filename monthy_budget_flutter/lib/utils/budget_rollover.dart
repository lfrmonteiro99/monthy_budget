import '../models/actual_expense.dart';
import '../models/app_settings.dart';

/// Pure calculation utility for budget rollover / carryover between months.
///
/// Computes per-category rollover amounts based on the difference between
/// the previous month's budget and actual spend, for categories that have
/// [ExpenseItem.rolloverEnabled] set to `true`.
class BudgetRollover {
  BudgetRollover._();

  /// Returns a map of category -> rollover amount for the current month.
  ///
  /// Positive values mean underspend (extra budget carried forward).
  /// Negative values mean overspend (budget reduced this month).
  ///
  /// Only categories where at least one enabled [ExpenseItem] has
  /// `rolloverEnabled == true` are included.
  ///
  /// [expenseItems] are the user's configured budget line items.
  /// [previousMonthActuals] are the actual expenses from the previous month.
  /// [previousMonthBudgetOverrides] are monthly budget overrides for the
  /// previous month (from [MonthlyBudget] records), keyed by category name.
  static Map<String, double> computeRollovers({
    required List<ExpenseItem> expenseItems,
    required List<ActualExpense> previousMonthActuals,
    required Map<String, double> previousMonthBudgetOverrides,
  }) {
    // Determine which categories have rollover enabled
    // and compute the default budget per category.
    final rolloverCategories = <String>{};
    final defaultBudgetByCategory = <String, double>{};

    for (final item in expenseItems) {
      if (!item.enabled) continue;
      if (item.rolloverEnabled) {
        rolloverCategories.add(item.category);
      }
      defaultBudgetByCategory[item.category] =
          (defaultBudgetByCategory[item.category] ?? 0) + item.amount;
    }

    if (rolloverCategories.isEmpty) return const {};

    // Sum actual spend per category from previous month
    final actualByCategory = <String, double>{};
    for (final expense in previousMonthActuals) {
      actualByCategory[expense.category] =
          (actualByCategory[expense.category] ?? 0) + expense.amount;
    }

    final result = <String, double>{};
    for (final category in rolloverCategories) {
      final budgeted = previousMonthBudgetOverrides[category] ??
          defaultBudgetByCategory[category] ??
          0;
      final actual = actualByCategory[category] ?? 0;
      final rollover = budgeted - actual;

      // Skip zero rollover to keep the map clean
      if (rollover != 0) {
        result[category] = rollover;
      }
    }

    return result;
  }

  /// Returns the monthKey for the month before [monthKey].
  ///
  /// [monthKey] must be in the format `YYYY-MM`.
  static String previousMonthKey(String monthKey) {
    final parts = monthKey.split('-');
    var year = int.parse(parts[0]);
    var month = int.parse(parts[1]);

    month -= 1;
    if (month < 1) {
      month = 12;
      year -= 1;
    }

    return '$year-${month.toString().padLeft(2, '0')}';
  }
}
