import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recurring_expense.dart';
import '../models/actual_expense.dart';

class RecurringExpenseService {
  final _client = Supabase.instance.client;

  Future<List<RecurringExpense>> load(String householdId) async {
    final rows = await _client
        .from('recurring_expenses')
        .select()
        .eq('household_id', householdId)
        .order('category');

    return (rows as List<dynamic>)
        .map((r) =>
            RecurringExpense.fromSupabase(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(RecurringExpense expense, String householdId) async {
    await _client
        .from('recurring_expenses')
        .upsert(expense.toSupabase(householdId));
  }

  Future<void> delete(String id) async {
    await _client.from('recurring_expenses').delete().eq('id', id);
  }

  /// Creates ActualExpenses from active recurring templates for a given month
  /// if they haven't been populated yet.
  Future<List<ActualExpense>> populateMonthIfNeeded(
    String householdId,
    String monthKey,
  ) async {
    // Check if already ran for this month
    final existing = await _client
        .from('recurring_expense_runs')
        .select()
        .eq('household_id', householdId)
        .eq('month_key', monthKey)
        .maybeSingle();

    if (existing != null) return [];

    // Load active recurring expenses
    final recurring = await load(householdId);
    final active = recurring.where((r) => r.isActive).toList();
    if (active.isEmpty) return [];

    // Parse month key
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    // Create actual expenses
    final created = <ActualExpense>[];
    for (final r in active) {
      final day = r.dayOfMonth ?? 1;
      final maxDay = DateTime(year, month + 1, 0).day;
      final safeDay = day.clamp(1, maxDay);
      final date = DateTime(year, month, safeDay);

      final expense = ActualExpense(
        id: 'exp_rec_${r.id}_${DateTime.now().millisecondsSinceEpoch}',
        category: r.category,
        amount: r.amount,
        date: date,
        description: r.description,
        monthKey: monthKey,
        recurringExpenseId: r.id,
        isFromRecurring: true,
      );
      created.add(expense);
    }

    // Insert all in batch
    if (created.isNotEmpty) {
      await _client.from('actual_expenses').insert(
          created.map((e) => e.toSupabase(householdId)).toList());
    }

    // Mark as ran
    await _client.from('recurring_expense_runs').insert({
      'household_id': householdId,
      'month_key': monthKey,
    });

    return created;
  }
}
