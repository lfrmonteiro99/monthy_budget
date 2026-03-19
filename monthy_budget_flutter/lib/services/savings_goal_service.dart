import '../models/savings_goal.dart';
import '../repositories/savings_repository.dart';

class SavingsGoalService {
  SavingsRepository? _repository;

  SavingsGoalService({SavingsRepository? repository})
    : _repository = repository;

  SavingsRepository get _resolvedRepository =>
      _repository ??= SupabaseSavingsRepository();

  Future<List<SavingsGoal>> loadGoals(String householdId) {
    return _resolvedRepository.loadGoals(householdId);
  }

  Future<void> saveGoal(SavingsGoal goal, String householdId) {
    return _resolvedRepository.saveGoal(goal, householdId);
  }

  Future<void> deleteGoal(String id) {
    return _resolvedRepository.deleteGoal(id);
  }

  Future<List<SavingsContribution>> loadContributions(String goalId) {
    return _resolvedRepository.loadContributions(goalId);
  }

  Future<SavingsGoal> addContribution(
    SavingsContribution contribution,
    String householdId,
  ) {
    return _resolvedRepository.addContribution(contribution, householdId);
  }

  Future<Map<String, List<SavingsContribution>>> loadAllContributions(
    String householdId, {
    int? recentMonths,
  }) {
    return _resolvedRepository.loadAllContributions(
      householdId,
      recentMonths: recentMonths,
    );
  }

  Future<void> deleteContribution(
    SavingsContribution contribution,
    String householdId,
  ) {
    return _resolvedRepository.deleteContribution(contribution, householdId);
  }
}
