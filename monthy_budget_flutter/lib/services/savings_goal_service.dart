import '../models/savings_goal.dart';
import '../repositories/savings_repository.dart';

class SavingsGoalService {
  final SavingsRepository _repository;

  SavingsGoalService({SavingsRepository? repository})
    : _repository = repository ?? SupabaseSavingsRepository();

  Future<List<SavingsGoal>> loadGoals(String householdId) {
    return _repository.loadGoals(householdId);
  }

  Future<void> saveGoal(SavingsGoal goal, String householdId) {
    return _repository.saveGoal(goal, householdId);
  }

  Future<void> deleteGoal(String id) {
    return _repository.deleteGoal(id);
  }

  Future<List<SavingsContribution>> loadContributions(String goalId) {
    return _repository.loadContributions(goalId);
  }

  Future<SavingsGoal> addContribution(
    SavingsContribution contribution,
    String householdId,
  ) {
    return _repository.addContribution(contribution, householdId);
  }

  Future<Map<String, List<SavingsContribution>>> loadAllContributions(
    String householdId, {
    int? recentMonths,
  }) {
    return _repository.loadAllContributions(
      householdId,
      recentMonths: recentMonths,
    );
  }

  Future<void> deleteContribution(
    SavingsContribution contribution,
    String householdId,
  ) {
    return _repository.deleteContribution(contribution, householdId);
  }
}
