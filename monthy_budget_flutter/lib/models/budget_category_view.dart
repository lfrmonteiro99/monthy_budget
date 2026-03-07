import 'app_settings.dart';
import 'recurring_expense.dart';

class BudgetCategoryView {
  final ExpenseItem budgetItem;
  final List<RecurringExpense> recurringBills;

  const BudgetCategoryView({
    required this.budgetItem,
    this.recurringBills = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetCategoryView &&
          budgetItem == other.budgetItem &&
          recurringBills.length == other.recurringBills.length;

  @override
  int get hashCode => Object.hash(budgetItem, recurringBills.length);

  double get totalRecurringAmount => recurringBills
      .where((b) => b.isActive)
      .fold(0.0, (sum, b) => sum + b.amount);

  double get remainingVariableBudget => budgetItem.amount - totalRecurringAmount;

  bool get hasRecurringBills => recurringBills.isNotEmpty;

  bool get billsExceedBudget => totalRecurringAmount > budgetItem.amount;

  int get activeBillCount => recurringBills.where((b) => b.isActive).length;
}
