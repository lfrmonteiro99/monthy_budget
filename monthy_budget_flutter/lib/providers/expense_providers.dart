import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/actual_expense.dart';
import '../models/expense_snapshot.dart';

/// Actual expenses for the viewed month (#632 increment 9). Storage-only;
/// CRUD + persistence (ActualExpenseService) stays in AppHome.
class ActualExpensesNotifier extends Notifier<List<ActualExpense>> {
  @override
  List<ActualExpense> build() => const [];
  void set(List<ActualExpense> v) => state = v;
}

final actualExpensesProvider =
    NotifierProvider<ActualExpensesNotifier, List<ActualExpense>>(
  ActualExpensesNotifier.new,
);

/// Cached per-month expense history.
class ActualExpenseHistoryNotifier
    extends Notifier<Map<String, List<ActualExpense>>> {
  @override
  Map<String, List<ActualExpense>> build() => const {};
  void set(Map<String, List<ActualExpense>> v) => state = v;
}

final actualExpenseHistoryProvider =
    NotifierProvider<ActualExpenseHistoryNotifier,
        Map<String, List<ActualExpense>>>(
  ActualExpenseHistoryNotifier.new,
);

/// Per-month expense snapshots (trends).
class ExpenseHistoryNotifier
    extends Notifier<Map<String, List<ExpenseSnapshot>>> {
  @override
  Map<String, List<ExpenseSnapshot>> build() => const {};
  void set(Map<String, List<ExpenseSnapshot>> v) => state = v;
}

final expenseHistoryProvider =
    NotifierProvider<ExpenseHistoryNotifier,
        Map<String, List<ExpenseSnapshot>>>(
  ExpenseHistoryNotifier.new,
);
