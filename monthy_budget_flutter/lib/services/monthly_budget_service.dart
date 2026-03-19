import '../exceptions/app_exceptions.dart';
import '../models/monthly_budget.dart';
import '../repositories/expense_repository.dart';

class MonthlyBudgetService {
  BudgetRepository? _repository;

  MonthlyBudgetService({BudgetRepository? repository})
    : _repository = repository;

  BudgetRepository get _resolvedRepository =>
      _repository ??= SupabaseBudgetRepository();

  Future<List<MonthlyBudget>> loadMonth(String householdId, String monthKey) async {
    try {
      return await _resolvedRepository.loadMonth(householdId, monthKey);
    } catch (e, stack) {
      throw DataException(
        'Failed to load monthly budgets for $monthKey',
        e,
        stack,
      );
    }
  }

  Future<void> save(MonthlyBudget budget, String householdId) async {
    try {
      await _resolvedRepository.save(budget, householdId);
    } catch (e, stack) {
      throw DataException('Failed to save monthly budget', e, stack);
    }
  }

  Future<void> saveAll(List<MonthlyBudget> budgets, String householdId) async {
    if (budgets.isEmpty) return;
    try {
      await _resolvedRepository.saveAll(budgets, householdId);
    } catch (e, stack) {
      throw DataException('Failed to save monthly budgets', e, stack);
    }
  }
}
