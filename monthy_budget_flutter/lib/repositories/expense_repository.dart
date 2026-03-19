import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/actual_expense.dart';
import '../models/app_settings.dart';
import '../models/expense_snapshot.dart';
import '../models/monthly_budget.dart';
import '../models/recurring_expense.dart';
import '../services/log_service.dart';

abstract class ExpenseRepository {
  Future<List<ActualExpense>> loadMonth(String householdId, String monthKey);
  Future<void> add(ActualExpense expense, String householdId);
  Future<void> addAll(List<ActualExpense> expenses, String householdId);
  Future<void> update(ActualExpense expense);
  Future<List<String>> uploadAttachments(
    List<File> files,
    String householdId,
    String expenseId,
  );
  Future<void> delete(String id);
  Future<Map<String, List<ActualExpense>>> loadHistory(
    String householdId, {
    int months = 12,
  });
}

class SupabaseExpenseRepository implements ExpenseRepository {
  final SupabaseClient _client;

  SupabaseExpenseRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<List<ActualExpense>> loadMonth(String householdId, String monthKey) async {
    final rows = await _client
        .from('actual_expenses')
        .select()
        .eq('household_id', householdId)
        .eq('month_key', monthKey)
        .order('expense_date', ascending: false);

    return (rows as List<dynamic>)
        .map((r) => ActualExpense.fromSupabase(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> add(ActualExpense expense, String householdId) {
    return _client.from('actual_expenses').insert(expense.toSupabase(householdId));
  }

  @override
  Future<void> addAll(List<ActualExpense> expenses, String householdId) async {
    if (expenses.isEmpty) return;
    await _client.from('actual_expenses').insert(
      expenses.map((expense) => expense.toSupabase(householdId)).toList(),
    );
  }

  @override
  Future<void> update(ActualExpense expense) {
    return _client
        .from('actual_expenses')
        .update({
          'category': expense.category,
          'amount': expense.amount,
          'expense_date':
              '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}',
          'description': expense.description,
          'month_key': expense.monthKey,
          'attachment_urls': expense.attachmentUrls,
          'location_lat': expense.locationLat,
          'location_lng': expense.locationLng,
          'location_address': expense.locationAddress,
        })
        .eq('id', expense.id);
  }

  @override
  Future<List<String>> uploadAttachments(
    List<File> files,
    String householdId,
    String expenseId,
  ) async {
    if (files.isEmpty) return [];

    final urls = <String>[];
    const bucket = 'expense-attachments';

    for (final file in files) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final storagePath = '$householdId/$expenseId/$fileName';

      try {
        await _client.storage
            .from(bucket)
            .upload(
              storagePath,
              file,
              fileOptions: const FileOptions(upsert: true),
            );
        final publicUrl = _client.storage.from(bucket).getPublicUrl(storagePath);
        urls.add(publicUrl);
      } catch (e) {
        LogService.error(
          'Failed to upload attachment',
          error: e,
          category: 'service.expense_attachments',
          data: {'file_name': fileName},
        );
      }
    }

    return urls;
  }

  @override
  Future<void> delete(String id) {
    return _client.from('actual_expenses').delete().eq('id', id);
  }

  @override
  Future<Map<String, List<ActualExpense>>> loadHistory(
    String householdId, {
    int months = 12,
  }) async {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - months + 1);
    final cutoffKey = '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}';

    final rows = await _client
        .from('actual_expenses')
        .select()
        .eq('household_id', householdId)
        .gte('month_key', cutoffKey)
        .order('expense_date', ascending: false);

    final expenses = (rows as List<dynamic>)
        .map((r) => ActualExpense.fromSupabase(r as Map<String, dynamic>))
        .toList();

    final map = <String, List<ActualExpense>>{};
    for (final expense in expenses) {
      map.putIfAbsent(expense.monthKey, () => []).add(expense);
    }
    return map;
  }
}

abstract class BudgetRepository {
  Future<List<MonthlyBudget>> loadMonth(String householdId, String monthKey);
  Future<void> save(MonthlyBudget budget, String householdId);
  Future<void> saveAll(List<MonthlyBudget> budgets, String householdId);
}

class SupabaseBudgetRepository implements BudgetRepository {
  final SupabaseClient _client;

  SupabaseBudgetRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<List<MonthlyBudget>> loadMonth(String householdId, String monthKey) async {
    final rows = await _client
        .from('monthly_budgets')
        .select()
        .eq('household_id', householdId)
        .eq('month_key', monthKey);

    return rows.map((r) => MonthlyBudget.fromSupabase(r)).toList();
  }

  @override
  Future<void> save(MonthlyBudget budget, String householdId) {
    return _client.from('monthly_budgets').upsert(
      budget.toSupabase(householdId),
      onConflict: 'household_id,month_key,category',
    );
  }

  @override
  Future<void> saveAll(List<MonthlyBudget> budgets, String householdId) async {
    if (budgets.isEmpty) return;
    await _client.from('monthly_budgets').upsert(
      budgets.map((budget) => budget.toSupabase(householdId)).toList(),
      onConflict: 'household_id,month_key,category',
    );
  }
}

abstract class RecurringExpenseRepository {
  Future<List<RecurringExpense>> load(String householdId);
  Future<void> save(RecurringExpense expense, String householdId);
  Future<void> delete(String id);
  Future<bool> hasRunForMonth(String householdId, String monthKey);
  Future<void> markRunForMonth(String householdId, String monthKey);
}

class SupabaseRecurringExpenseRepository implements RecurringExpenseRepository {
  final SupabaseClient _client;

  SupabaseRecurringExpenseRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<List<RecurringExpense>> load(String householdId) async {
    final rows = await _client
        .from('recurring_expenses')
        .select()
        .eq('household_id', householdId)
        .order('category');

    return (rows as List<dynamic>)
        .map((r) => RecurringExpense.fromSupabase(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(RecurringExpense expense, String householdId) {
    return _client
        .from('recurring_expenses')
        .upsert(expense.toSupabase(householdId));
  }

  @override
  Future<void> delete(String id) {
    return _client.from('recurring_expenses').delete().eq('id', id);
  }

  @override
  Future<bool> hasRunForMonth(String householdId, String monthKey) async {
    final existing = await _client
        .from('recurring_expense_runs')
        .select()
        .eq('household_id', householdId)
        .eq('month_key', monthKey)
        .maybeSingle();
    return existing != null;
  }

  @override
  Future<void> markRunForMonth(String householdId, String monthKey) {
    return _client.from('recurring_expense_runs').insert({
      'household_id': householdId,
      'month_key': monthKey,
    });
  }
}

abstract class ExpenseSnapshotRepository {
  Future<void> snapshotIfNeeded(
    String householdId,
    String month,
    List<ExpenseItem> expenses,
  );
  Future<Map<String, List<ExpenseSnapshot>>> loadHistory(
    String householdId, {
    int months = 12,
  });
}

class SupabaseExpenseSnapshotRepository implements ExpenseSnapshotRepository {
  final SupabaseClient _client;

  SupabaseExpenseSnapshotRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<void> snapshotIfNeeded(
    String householdId,
    String month,
    List<ExpenseItem> expenses,
  ) async {
    final existing = await _client
        .from('expense_snapshots')
        .select('expense_id, amount, enabled')
        .eq('household_id', householdId)
        .eq('month', month);

    final existingMap = <String, Map<String, dynamic>>{};
    for (final row in existing) {
      existingMap[row['expense_id'] as String] = row;
    }

    final toUpsert = <Map<String, dynamic>>[];
    for (final expense in expenses) {
      final current = existingMap[expense.id];
      if (current == null ||
          (current['amount'] as num).toDouble() != expense.amount ||
          (current['enabled'] as bool) != expense.enabled) {
        toUpsert.add({
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

    if (toUpsert.isNotEmpty) {
      await _client
          .from('expense_snapshots')
          .upsert(toUpsert, onConflict: 'household_id,month,expense_id');
    }
  }

  @override
  Future<Map<String, List<ExpenseSnapshot>>> loadHistory(
    String householdId, {
    int months = 12,
  }) async {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - months + 1);
    final cutoffKey = '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}';

    final rows = await _client
        .from('expense_snapshots')
        .select()
        .eq('household_id', householdId)
        .gte('month', cutoffKey)
        .order('month', ascending: true);

    final result = <String, List<ExpenseSnapshot>>{};
    for (final row in rows) {
      final month = row['month'] as String;
      result.putIfAbsent(month, () => []);
      result[month]!.add(ExpenseSnapshot.fromJson(row));
    }
    return result;
  }
}
