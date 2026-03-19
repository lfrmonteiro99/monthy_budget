import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/savings_goal.dart';

abstract class SavingsRepository {
  Future<List<SavingsGoal>> loadGoals(String householdId);
  Future<void> saveGoal(SavingsGoal goal, String householdId);
  Future<void> deleteGoal(String id);
  Future<List<SavingsContribution>> loadContributions(String goalId);
  Future<SavingsGoal> addContribution(
    SavingsContribution contribution,
    String householdId,
  );
  Future<Map<String, List<SavingsContribution>>> loadAllContributions(
    String householdId, {
    int? recentMonths,
  });
  Future<void> deleteContribution(
    SavingsContribution contribution,
    String householdId,
  );
}

class SupabaseSavingsRepository implements SavingsRepository {
  final SupabaseClient _client;

  SupabaseSavingsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<List<SavingsGoal>> loadGoals(String householdId) async {
    final rows = await _client
        .from('savings_goals')
        .select()
        .eq('household_id', householdId)
        .order('name');

    return (rows as List<dynamic>)
        .map((row) => SavingsGoal.fromSupabase(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveGoal(SavingsGoal goal, String householdId) {
    return _client.from('savings_goals').upsert(goal.toSupabase(householdId));
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _client.from('savings_contributions').delete().eq('goal_id', id);
    await _client.from('savings_goals').delete().eq('id', id);
  }

  @override
  Future<List<SavingsContribution>> loadContributions(String goalId) async {
    final rows = await _client
        .from('savings_contributions')
        .select()
        .eq('goal_id', goalId)
        .order('contribution_date', ascending: false);

    return (rows as List<dynamic>)
        .map((row) => SavingsContribution.fromSupabase(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SavingsGoal> addContribution(
    SavingsContribution contribution,
    String householdId,
  ) async {
    final result = await _client.rpc('add_savings_contribution', params: {
      'p_id': contribution.id,
      'p_household_id': householdId,
      'p_goal_id': contribution.goalId,
      'p_amount': contribution.amount,
      'p_contribution_date':
          '${contribution.contributionDate.year}-${contribution.contributionDate.month.toString().padLeft(2, '0')}-${contribution.contributionDate.day.toString().padLeft(2, '0')}',
      'p_note': contribution.note,
    });

    return SavingsGoal.fromSupabase(result as Map<String, dynamic>);
  }

  @override
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
    final result = <String, List<SavingsContribution>>{};
    for (final row in (rows as List<dynamic>)) {
      final contribution =
          SavingsContribution.fromSupabase(row as Map<String, dynamic>);
      (result[contribution.goalId] ??= []).add(contribution);
    }
    return result;
  }

  @override
  Future<void> deleteContribution(
    SavingsContribution contribution,
    String householdId,
  ) {
    return _client.rpc('delete_savings_contribution', params: {
      'p_contribution_id': contribution.id,
      'p_goal_id': contribution.goalId,
      'p_household_id': householdId,
    });
  }
}
