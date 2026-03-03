import '../models/app_settings.dart';
import '../models/budget_category_view.dart';
import '../models/recurring_expense.dart';

List<BudgetCategoryView> buildCategoryViews(
  List<ExpenseItem> expenses,
  List<RecurringExpense> recurringExpenses,
) {
  // Group recurring expenses by category
  final byCategory = <String, List<RecurringExpense>>{};
  for (final re in recurringExpenses) {
    byCategory.putIfAbsent(re.category, () => []).add(re);
  }

  // Build views for each budget category
  final views = <BudgetCategoryView>[];
  final matchedCategories = <String>{};

  for (final item in expenses) {
    final catName = item.category.name;
    final bills = byCategory[catName] ?? [];
    matchedCategories.add(catName);
    views.add(BudgetCategoryView(
      budgetItem: item,
      recurringBills: bills,
    ));
  }

  // Orphan recurring expenses (no matching budget category) — group under outros
  final orphans = <RecurringExpense>[];
  for (final entry in byCategory.entries) {
    if (!matchedCategories.contains(entry.key)) {
      orphans.addAll(entry.value);
    }
  }

  if (orphans.isNotEmpty) {
    // Find existing "outros" view and append orphans
    final outrosIdx = views.indexWhere(
      (v) => v.budgetItem.category == ExpenseCategory.outros,
    );
    if (outrosIdx >= 0) {
      final existing = views[outrosIdx];
      views[outrosIdx] = BudgetCategoryView(
        budgetItem: existing.budgetItem,
        recurringBills: [...existing.recurringBills, ...orphans],
      );
    }
    // If no "outros" category exists, orphans are silently ignored.
    // They'll still show in the standalone recurring screen if accessed.
  }

  return views;
}
