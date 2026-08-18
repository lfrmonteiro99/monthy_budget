import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/actual_expense.dart';
import '../models/expense_snapshot.dart';

/// Deep equality for the map-of-list shapes used by the notifiers below.
/// [ExpenseSnapshot] and [ActualExpense] already implement value `==`, so
/// this correctly treats two freshly-loaded-but-identical snapshots/maps as
/// equal instead of always differing by default `Map`/`List` identity.
const _deepEquals = DeepCollectionEquality();

/// Actual expenses for the viewed month (#632 increment 9). Storage-only;
/// CRUD + persistence (ActualExpenseService) stays in AppHome.
class ActualExpensesNotifier extends Notifier<List<ActualExpense>> {
  @override
  List<ActualExpense> build() => const [];
  void set(List<ActualExpense> v) {
    // #1236: skip the write (and therefore the notification) when the new
    // list is deep-equal to what's already stored — otherwise any
    // unconditional caller re-triggers a full rebuild of every listener for
    // no observable change, which is how the dashboard render loop happened.
    if (_deepEquals.equals(state, v)) return;
    state = v;
  }
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
  void set(Map<String, List<ActualExpense>> v) {
    if (_deepEquals.equals(state, v)) return;
    state = v;
  }
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
  void set(Map<String, List<ExpenseSnapshot>> v) {
    if (_deepEquals.equals(state, v)) return;
    state = v;
  }
}

final expenseHistoryProvider =
    NotifierProvider<ExpenseHistoryNotifier,
        Map<String, List<ExpenseSnapshot>>>(
  ExpenseHistoryNotifier.new,
);
