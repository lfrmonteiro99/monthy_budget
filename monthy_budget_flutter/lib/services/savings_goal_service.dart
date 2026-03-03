import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/savings_goal.dart';

class SavingsGoalService {
  final _client = Supabase.instance.client;

  // ── Goals ──────────────────────────────────────────────────────────────

  Future<List<SavingsGoal>> loadGoals(String householdId) async {
    final rows = await _client
        .from('savings_goals')
        .select()
        .eq('household_id', householdId)
        .order('name');

    return (rows as List<dynamic>)
        .map((r) => SavingsGoal.fromSupabase(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveGoal(SavingsGoal goal, String householdId) async {
    await _client
        .from('savings_goals')
        .upsert(goal.toSupabase(householdId));
  }

  Future<void> deleteGoal(String id) async {
    // Contributions should cascade-delete via FK in Supabase,
    // but clean up explicitly for safety.
    await _client.from('savings_contributions').delete().eq('goal_id', id);
    await _client.from('savings_goals').delete().eq('id', id);
  }

  // ── Contributions ──────────────────────────────────────────────────────

  Future<List<SavingsContribution>> loadContributions(String goalId) async {
    final rows = await _client
        .from('savings_contributions')
        .select()
        .eq('goal_id', goalId)
        .order('contribution_date', ascending: false);

    return (rows as List<dynamic>)
        .map((r) =>
            SavingsContribution.fromSupabase(r as Map<String, dynamic>))
        .toList();
  }

  /// Inserts a contribution and updates the goal's current_amount atomically
  /// (read-modify-write since we don't have a Supabase RPC for this).
  Future<SavingsGoal> addContribution(
    SavingsContribution contribution,
    String householdId,
  ) async {
    // Insert contribution
    await _client
        .from('savings_contributions')
        .insert(contribution.toSupabase(householdId));

    // Read current goal
    final goalRow = await _client
        .from('savings_goals')
        .select()
        .eq('id', contribution.goalId)
        .single();

    final goal = SavingsGoal.fromSupabase(goalRow);
    final updatedAmount = goal.currentAmount + contribution.amount;

    // Update goal's current_amount
    await _client.from('savings_goals').update({
      'current_amount': updatedAmount,
    }).eq('id', goal.id);

    return goal.copyWith(currentAmount: updatedAmount);
  }

  /// Load contributions for all goals in a household, optionally limited to recent months.
  Future<Map<String, List<SavingsContribution>>> loadAllContributions(
    String householdId, {
    int? recentMonths,
  }) async {
    var query = _client
        .from('savings_contributions')
        .select()
        .eq('household_id', householdId);

    if (recentMonths != null) {
      final cutoff = DateTime.now().subtract(Duration(days: recentMonths * 31));
      query = query.gte('contribution_date', cutoff.toIso8601String());
    }

    final rows = await query.order('contribution_date', ascending: false);
    final map = <String, List<SavingsContribution>>{};
    for (final r in (rows as List<dynamic>)) {
      final c = SavingsContribution.fromSupabase(r as Map<String, dynamic>);
      (map[c.goalId] ??= []).add(c);
    }
    return map;
  }

  Future<void> deleteContribution(
    SavingsContribution contribution,
  ) async {
    await _client
        .from('savings_contributions')
        .delete()
        .eq('id', contribution.id);

    // Subtract from goal's current_amount
    final goalRow = await _client
        .from('savings_goals')
        .select()
        .eq('id', contribution.goalId)
        .single();

    final goal = SavingsGoal.fromSupabase(goalRow);
    final updatedAmount = (goal.currentAmount - contribution.amount).clamp(0.0, double.infinity);

    await _client.from('savings_goals').update({
      'current_amount': updatedAmount,
    }).eq('id', goal.id);
  }
}
