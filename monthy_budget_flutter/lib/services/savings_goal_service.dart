import '../exceptions/app_exceptions.dart';
import '../models/savings_goal.dart';
import '../repositories/savings_repository.dart';
import 'log_service.dart';

class SavingsGoalService {
  SavingsRepository? _repository;

  SavingsGoalService({SavingsRepository? repository})
    : _repository = repository;

  SavingsRepository get _resolvedRepository =>
      _repository ??= SupabaseSavingsRepository();

  Future<List<SavingsGoal>> loadGoals(String householdId) async {
    try {
      return await _resolvedRepository.loadGoals(householdId);
    } catch (e, stack) {
      LogService.error(
        'Failed to load savings goals',
        error: e,
        stackTrace: stack,
        category: 'service.savings_goal',
      );
      throw DataException('Failed to load savings goals', e, stack);
    }
  }

  Future<void> saveGoal(SavingsGoal goal, String householdId) async {
    try {
      await _resolvedRepository.saveGoal(goal, householdId);
    } catch (e, stack) {
      LogService.error(
        'Failed to save savings goal ${goal.id}',
        error: e,
        stackTrace: stack,
        category: 'service.savings_goal',
      );
      throw DataException('Failed to save savings goal ${goal.id}', e, stack);
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await _resolvedRepository.deleteGoal(id);
    } catch (e, stack) {
      LogService.error(
        'Failed to delete savings goal $id',
        error: e,
        stackTrace: stack,
        category: 'service.savings_goal',
      );
      throw DataException('Failed to delete savings goal $id', e, stack);
    }
  }

  Future<List<SavingsContribution>> loadContributions(String goalId) async {
    try {
      return await _resolvedRepository.loadContributions(goalId);
    } catch (e, stack) {
      LogService.error(
        'Failed to load contributions for goal $goalId',
        error: e,
        stackTrace: stack,
        category: 'service.savings_goal',
      );
      throw DataException(
          'Failed to load contributions for goal $goalId', e, stack);
    }
  }

  Future<SavingsGoal> addContribution(
    SavingsContribution contribution,
    String householdId,
  ) async {
    try {
      return await _resolvedRepository.addContribution(
          contribution, householdId);
    } catch (e, stack) {
      LogService.error(
        'Failed to add contribution ${contribution.id}',
        error: e,
        stackTrace: stack,
        category: 'service.savings_goal',
      );
      throw DataException(
          'Failed to add contribution ${contribution.id}', e, stack);
    }
  }

  Future<Map<String, List<SavingsContribution>>> loadAllContributions(
    String householdId, {
    int? recentMonths,
  }) async {
    try {
      return await _resolvedRepository.loadAllContributions(
        householdId,
        recentMonths: recentMonths,
      );
    } catch (e, stack) {
      LogService.error(
        'Failed to load all contributions',
        error: e,
        stackTrace: stack,
        category: 'service.savings_goal',
      );
      throw DataException('Failed to load all contributions', e, stack);
    }
  }

  Future<void> deleteContribution(
    SavingsContribution contribution,
    String householdId,
  ) async {
    try {
      await _resolvedRepository.deleteContribution(contribution, householdId);
    } catch (e, stack) {
      LogService.error(
        'Failed to delete contribution ${contribution.id}',
        error: e,
        stackTrace: stack,
        category: 'service.savings_goal',
      );
      throw DataException(
          'Failed to delete contribution ${contribution.id}', e, stack);
    }
  }
}
