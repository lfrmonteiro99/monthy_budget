import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/custom_category.dart';
import '../models/recurring_expense.dart';

/// Custom expense categories (#632 increment 5). Storage-only.
class CustomCategoriesNotifier extends Notifier<List<CustomCategory>> {
  @override
  List<CustomCategory> build() => const [];
  void set(List<CustomCategory> categories) => state = categories;
}

final customCategoriesProvider =
    NotifierProvider<CustomCategoriesNotifier, List<CustomCategory>>(
  CustomCategoriesNotifier.new,
);

/// Recurring expenses (#632 increment 5). Storage-only.
class RecurringExpensesNotifier extends Notifier<List<RecurringExpense>> {
  @override
  List<RecurringExpense> build() => const [];
  void set(List<RecurringExpense> expenses) => state = expenses;
}

final recurringExpensesProvider =
    NotifierProvider<RecurringExpensesNotifier, List<RecurringExpense>>(
  RecurringExpensesNotifier.new,
);

/// Per-category monthly budget map (#632 increment 5). Storage-only.
class MonthlyBudgetsNotifier extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() => const {};
  void set(Map<String, double> budgets) => state = budgets;
}

final monthlyBudgetsProvider =
    NotifierProvider<MonthlyBudgetsNotifier, Map<String, double>>(
  MonthlyBudgetsNotifier.new,
);
