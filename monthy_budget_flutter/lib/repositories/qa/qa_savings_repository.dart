import '../../models/savings_goal.dart';
import '../local/qa_local_store.dart';
import '../savings_repository.dart';
import 'qa_collections.dart';

class QaSavingsRepository implements SavingsRepository {
  QaSavingsRepository(this._store, {required DateTime Function() now})
    : _now = now;

  final QaLocalStore _store;
  final DateTime Function() _now;

  @override
  Future<List<SavingsGoal>> loadGoals(String householdId) async {
    final rows = await _store.query(QaCollections.savingsGoals, householdId);
    final goals = rows.map(SavingsGoal.fromSupabase).toList();
    goals.sort((a, b) => a.name.compareTo(b.name));
    return goals;
  }

  @override
  Future<void> saveGoal(SavingsGoal goal, String householdId) {
    return _store.put(
      QaCollections.savingsGoals,
      householdId,
      goal.id,
      goal.toSupabase(householdId),
    );
  }

  @override
  Future<void> deleteGoal(String id) async {
    final householdId = await _householdIdOfGoal(id);
    if (householdId == null) return;
    await _store.deleteWhere(
      QaCollections.savingsContributions,
      householdId,
      (row) => row['goal_id'] == id,
    );
    await _store.delete(QaCollections.savingsGoals, householdId, id);
  }

  @override
  Future<List<SavingsContribution>> loadContributions(String goalId) async {
    final rows = await _store.queryAll(QaCollections.savingsContributions);
    final contributions = rows
        .where((row) => row['goal_id'] == goalId)
        .map(SavingsContribution.fromSupabase)
        .toList();
    contributions.sort(
      (a, b) => b.contributionDate.compareTo(a.contributionDate),
    );
    return contributions;
  }

  /// Mirrors the `add_savings_contribution` RPC: inserts the contribution,
  /// bumps the goal's running total and returns the updated goal.
  @override
  Future<SavingsGoal> addContribution(
    SavingsContribution contribution,
    String householdId,
  ) async {
    await _store.put(
      QaCollections.savingsContributions,
      householdId,
      contribution.id,
      contribution.toSupabase(householdId),
    );

    final goalRow = await _store.get(
      QaCollections.savingsGoals,
      householdId,
      contribution.goalId,
    );
    if (goalRow == null) {
      throw StateError('QA savings goal ${contribution.goalId} not found');
    }
    final goal = SavingsGoal.fromSupabase(goalRow);
    final updated = goal.copyWith(
      currentAmount: goal.currentAmount + contribution.amount,
    );
    await saveGoal(updated, householdId);
    return updated;
  }

  /// Mirrors the `delete_savings_contribution` RPC.
  @override
  Future<void> deleteContribution(
    SavingsContribution contribution,
    String householdId,
  ) async {
    await _store.delete(
      QaCollections.savingsContributions,
      householdId,
      contribution.id,
    );

    final goalRow = await _store.get(
      QaCollections.savingsGoals,
      householdId,
      contribution.goalId,
    );
    if (goalRow == null) return;
    final goal = SavingsGoal.fromSupabase(goalRow);
    final reduced = (goal.currentAmount - contribution.amount).clamp(
      0.0,
      double.maxFinite,
    );
    await saveGoal(goal.copyWith(currentAmount: reduced), householdId);
  }

  @override
  Future<Map<String, List<SavingsContribution>>> loadAllContributions(
    String householdId, {
    int? recentMonths,
  }) async {
    final rows = await _store.query(
      QaCollections.savingsContributions,
      householdId,
    );
    var contributions = rows.map(SavingsContribution.fromSupabase).toList();

    if (recentMonths != null) {
      final cutoff = _now().subtract(Duration(days: recentMonths * 31));
      contributions = contributions
          .where((c) => !c.contributionDate.isBefore(cutoff))
          .toList();
    }
    contributions.sort(
      (a, b) => b.contributionDate.compareTo(a.contributionDate),
    );

    final result = <String, List<SavingsContribution>>{};
    for (final contribution in contributions) {
      (result[contribution.goalId] ??= []).add(contribution);
    }
    return result;
  }

  Future<String?> _householdIdOfGoal(String goalId) async {
    final rows = await _store.queryAll(QaCollections.savingsGoals);
    for (final row in rows) {
      if (row['id'] == goalId) return row['household_id'] as String?;
    }
    return null;
  }
}
