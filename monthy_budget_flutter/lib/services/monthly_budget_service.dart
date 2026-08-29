import '../exceptions/app_exceptions.dart';
import '../models/monthly_budget.dart';
import '../repositories/expense_repository.dart';
import '../repositories/repository_factory.dart';
import 'log_service.dart';

class MonthlyBudgetService {
  BudgetRepository? _repository;

  MonthlyBudgetService({BudgetRepository? repository})
    : _repository = repository;

  BudgetRepository get _resolvedRepository =>
      _repository ??= RepositoryFactory.instance.budget;

  Future<List<MonthlyBudget>> loadMonth(String householdId, String monthKey) async {
    try {
      return await _resolvedRepository.loadMonth(householdId, monthKey);
    } catch (e, stack) {
      LogService.error(
        'Failed to load monthly budgets for $monthKey',
        error: e,
        stackTrace: stack,
        category: 'service.monthly_budget',
      );
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
      LogService.error(
        'Failed to save monthly budget',
        error: e,
        stackTrace: stack,
        category: 'service.monthly_budget',
      );
      throw DataException('Failed to save monthly budget', e, stack);
    }
  }

  Future<void> saveAll(List<MonthlyBudget> budgets, String householdId) async {
    if (budgets.isEmpty) return;
    try {
      await _resolvedRepository.saveAll(budgets, householdId);
    } catch (e, stack) {
      LogService.error(
        'Failed to save monthly budgets',
        error: e,
        stackTrace: stack,
        category: 'service.monthly_budget',
      );
      throw DataException('Failed to save monthly budgets', e, stack);
    }
  }

  /// Replaces every override for [monthKey] with exactly [budgets]: categories
  /// present get upserted, categories that existed before but are absent from
  /// [budgets] get their old row deleted. [saveAll] alone cannot express this
  /// — it is upsert-only, so a category the caller stopped sending (e.g. the
  /// user removed the override in the UI) was silently left behind (#1320).
  Future<void> saveMonth(
    String householdId,
    String monthKey,
    Map<String, double> budgets,
  ) async {
    try {
      final existing = await _resolvedRepository.loadMonth(
        householdId,
        monthKey,
      );
      final removedCategories = existing
          .map((budget) => budget.category)
          .where((category) => !budgets.containsKey(category));
      for (final category in removedCategories) {
        await _resolvedRepository.deleteMonth(householdId, monthKey, category);
      }

      final toSave = budgets.entries
          .map(
            (entry) => MonthlyBudget.create(
              category: entry.key,
              amount: entry.value,
              monthKey: monthKey,
            ),
          )
          .toList();
      await _resolvedRepository.saveAll(toSave, householdId);
    } catch (e, stack) {
      LogService.error(
        'Failed to save monthly budgets for $monthKey',
        error: e,
        stackTrace: stack,
        category: 'service.monthly_budget',
      );
      throw DataException(
        'Failed to save monthly budgets for $monthKey',
        e,
        stack,
      );
    }
  }
}
