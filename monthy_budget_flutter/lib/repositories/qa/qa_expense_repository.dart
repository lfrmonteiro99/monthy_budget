import 'dart:io';

import '../../models/actual_expense.dart';
import '../../models/app_settings.dart';
import '../../models/expense_snapshot.dart';
import '../../models/monthly_budget.dart';
import '../../models/recurring_expense.dart';
import '../expense_repository.dart';
import '../local/qa_local_store.dart';
import 'qa_collections.dart';

/// Sqlite-backed stand-in for [SupabaseExpenseRepository].
///
/// Writes `toSupabase()` maps verbatim and reads them back through
/// `fromSupabase()`, so QA data goes through the same parsing code paths as
/// production rows.
class QaExpenseRepository implements ExpenseRepository {
  QaExpenseRepository(this._store, {required DateTime Function() now})
    : _now = now;

  final QaLocalStore _store;
  final DateTime Function() _now;

  @override
  Future<List<ActualExpense>> loadMonth(
    String householdId,
    String monthKey,
  ) async {
    final rows = await _store.query(QaCollections.actualExpenses, householdId);
    final expenses = rows
        .where((row) => row['month_key'] == monthKey)
        .map(ActualExpense.fromSupabase)
        .toList();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  @override
  Future<void> add(ActualExpense expense, String householdId) {
    return _store.put(
      QaCollections.actualExpenses,
      householdId,
      expense.id,
      expense.toSupabase(householdId),
    );
  }

  @override
  Future<void> addAll(List<ActualExpense> expenses, String householdId) {
    return _store.putAll(QaCollections.actualExpenses, householdId, {
      for (final expense in expenses) expense.id: expense.toSupabase(householdId),
    });
  }

  @override
  Future<void> addAllFromRecurring(
    List<ActualExpense> expenses,
    String householdId,
  ) async {
    // Supabase upserts with ignoreDuplicates — keep the existing row on conflict.
    for (final expense in expenses) {
      final existing = await _store.get(
        QaCollections.actualExpenses,
        householdId,
        expense.id,
      );
      if (existing != null) continue;
      await add(expense, householdId);
    }
  }

  /// [ExpenseRepository.update] carries no household id, so the row is located
  /// by scanning the collection — the QA dataset is small enough for that.
  @override
  Future<void> update(ActualExpense expense) async {
    final householdId = await _householdIdOf(
      QaCollections.actualExpenses,
      expense.id,
    );
    if (householdId == null) return;
    await _store.put(
      QaCollections.actualExpenses,
      householdId,
      expense.id,
      expense.toSupabase(householdId),
    );
  }

  /// No storage bucket in QA — echo back local paths so the attachment chips
  /// still render.
  @override
  Future<List<String>> uploadAttachments(
    List<File> files,
    String householdId,
    String expenseId,
  ) async {
    return files.map((file) => 'qa-attachment://$expenseId/${file.path}').toList();
  }

  @override
  Future<void> delete(String id) async {
    final householdId = await _householdIdOf(QaCollections.actualExpenses, id);
    if (householdId == null) return;
    await _store.delete(QaCollections.actualExpenses, householdId, id);
  }

  @override
  Future<Map<String, List<ActualExpense>>> loadHistory(
    String householdId, {
    int months = 12,
  }) async {
    final now = _now();
    final cutoff = DateTime(now.year, now.month - months + 1);
    final cutoffKey =
        '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}';

    final rows = await _store.query(QaCollections.actualExpenses, householdId);
    final expenses = rows
        .where((row) => (row['month_key'] as String).compareTo(cutoffKey) >= 0)
        .map(ActualExpense.fromSupabase)
        .toList();
    expenses.sort((a, b) => b.date.compareTo(a.date));

    final map = <String, List<ActualExpense>>{};
    for (final expense in expenses) {
      map.putIfAbsent(expense.monthKey, () => []).add(expense);
    }
    return map;
  }

  Future<String?> _householdIdOf(String collection, String docId) async {
    // Every QA payload carries household_id, mirroring the Supabase columns.
    final rows = await _store.queryAll(collection);
    for (final row in rows) {
      if (row['id'] == docId) return row['household_id'] as String?;
    }
    return null;
  }
}

class QaBudgetRepository implements BudgetRepository {
  QaBudgetRepository(this._store);

  final QaLocalStore _store;

  static String _docId(MonthlyBudget budget) =>
      '${budget.monthKey}|${budget.category}';

  @override
  Future<List<MonthlyBudget>> loadMonth(
    String householdId,
    String monthKey,
  ) async {
    final rows = await _store.query(QaCollections.monthlyBudgets, householdId);
    return rows
        .where((row) => row['month_key'] == monthKey)
        .map(MonthlyBudget.fromSupabase)
        .toList();
  }

  @override
  Future<void> save(MonthlyBudget budget, String householdId) {
    return _store.put(
      QaCollections.monthlyBudgets,
      householdId,
      _docId(budget),
      budget.toSupabase(householdId),
    );
  }

  @override
  Future<void> saveAll(List<MonthlyBudget> budgets, String householdId) {
    return _store.putAll(QaCollections.monthlyBudgets, householdId, {
      for (final budget in budgets)
        _docId(budget): budget.toSupabase(householdId),
    });
  }

  @override
  Future<void> deleteMonth(
    String householdId,
    String monthKey,
    String category,
  ) {
    return _store.delete(
      QaCollections.monthlyBudgets,
      householdId,
      '$monthKey|$category',
    );
  }
}

class QaRecurringExpenseRepository implements RecurringExpenseRepository {
  QaRecurringExpenseRepository(this._store);

  final QaLocalStore _store;

  @override
  Future<List<RecurringExpense>> load(String householdId) async {
    final rows = await _store.query(
      QaCollections.recurringExpenses,
      householdId,
    );
    final expenses = rows.map(RecurringExpense.fromSupabase).toList();
    expenses.sort((a, b) => a.category.compareTo(b.category));
    return expenses;
  }

  @override
  Future<void> save(RecurringExpense expense, String householdId) {
    return _store.put(
      QaCollections.recurringExpenses,
      householdId,
      expense.id,
      expense.toSupabase(householdId),
    );
  }

  @override
  Future<void> delete(String id) async {
    final rows = await _store.queryAll(QaCollections.recurringExpenses);
    for (final row in rows) {
      if (row['id'] != id) continue;
      await _store.delete(
        QaCollections.recurringExpenses,
        row['household_id'] as String,
        id,
      );
      return;
    }
  }

  @override
  Future<bool> hasRunForMonth(String householdId, String monthKey) async {
    final row = await _store.get(
      QaCollections.recurringExpenseRuns,
      householdId,
      monthKey,
    );
    return row != null;
  }

  @override
  Future<void> markRunForMonth(String householdId, String monthKey) {
    return _store.put(QaCollections.recurringExpenseRuns, householdId, monthKey, {
      'household_id': householdId,
      'month_key': monthKey,
    });
  }

  @override
  Future<List<String>> loadRunMonths(String householdId) async {
    final rows = await _store.query(
      QaCollections.recurringExpenseRuns,
      householdId,
    );
    return rows.map((row) => row['month_key'] as String).toList();
  }
}

class QaExpenseSnapshotRepository implements ExpenseSnapshotRepository {
  QaExpenseSnapshotRepository(this._store, {required DateTime Function() now})
    : _now = now;

  final QaLocalStore _store;
  final DateTime Function() _now;

  @override
  Future<void> snapshotIfNeeded(
    String householdId,
    String month,
    List<ExpenseItem> expenses,
  ) async {
    for (final expense in expenses) {
      final docId = '$month|${expense.id}';
      final current = await _store.get(
        QaCollections.expenseSnapshots,
        householdId,
        docId,
      );
      final unchanged =
          current != null &&
          (current['amount'] as num).toDouble() == expense.amount &&
          current['enabled'] == expense.enabled;
      if (unchanged) continue;
      await _store.put(QaCollections.expenseSnapshots, householdId, docId, {
        'household_id': householdId,
        'month': month,
        'expense_id': expense.id,
        'label': expense.label,
        'category': expense.category,
        'amount': expense.amount,
        'enabled': expense.enabled,
      });
    }
  }

  @override
  Future<Map<String, List<ExpenseSnapshot>>> loadHistory(
    String householdId, {
    int months = 12,
  }) async {
    final now = _now();
    final cutoff = DateTime(now.year, now.month - months + 1);
    final cutoffKey =
        '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}';

    final rows = await _store.query(QaCollections.expenseSnapshots, householdId)
      ..sort(
        (a, b) => (a['month'] as String).compareTo(b['month'] as String),
      );

    final result = <String, List<ExpenseSnapshot>>{};
    for (final row in rows) {
      final month = row['month'] as String;
      if (month.compareTo(cutoffKey) < 0) continue;
      result.putIfAbsent(month, () => []).add(ExpenseSnapshot.fromJson(row));
    }
    return result;
  }
}
