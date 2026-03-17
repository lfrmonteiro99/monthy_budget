import 'package:supabase_flutter/supabase_flutter.dart';
import '../exceptions/app_exceptions.dart';
import '../models/monthly_budget.dart';

class MonthlyBudgetService {
  final _client = Supabase.instance.client;

  Future<List<MonthlyBudget>> loadMonth(
      String householdId, String monthKey) async {
    try {
      final rows = await _client
          .from('monthly_budgets')
          .select()
          .eq('household_id', householdId)
          .eq('month_key', monthKey);

      return rows.map((r) => MonthlyBudget.fromSupabase(r)).toList();
    } catch (e, stack) {
      throw DataException(
          'Failed to load monthly budgets for $monthKey', e, stack);
    }
  }

  Future<void> save(MonthlyBudget budget, String householdId) async {
    try {
      await _client.from('monthly_budgets').upsert(
        budget.toSupabase(householdId),
        onConflict: 'household_id,month_key,category',
      );
    } catch (e, stack) {
      throw DataException('Failed to save monthly budget', e, stack);
    }
  }

  Future<void> saveAll(
      List<MonthlyBudget> budgets, String householdId) async {
    if (budgets.isEmpty) return;
    try {
      await _client.from('monthly_budgets').upsert(
        budgets.map((b) => b.toSupabase(householdId)).toList(),
        onConflict: 'household_id,month_key,category',
      );
    } catch (e, stack) {
      throw DataException('Failed to save monthly budgets', e, stack);
    }
  }
}
