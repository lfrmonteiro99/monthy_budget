import '../exceptions/app_exceptions.dart';
import '../models/app_settings.dart';
import '../models/expense_snapshot.dart';
import '../repositories/expense_repository.dart';
import 'log_service.dart';

class ExpenseSnapshotService {
  ExpenseSnapshotRepository? _repository;

  ExpenseSnapshotService({ExpenseSnapshotRepository? repository})
    : _repository = repository;

  ExpenseSnapshotRepository get _resolvedRepository =>
      _repository ??= SupabaseExpenseSnapshotRepository();

  Future<void> snapshotIfNeeded(
    String householdId,
    String month,
    List<ExpenseItem> expenses,
  ) async {
    try {
      await _resolvedRepository.snapshotIfNeeded(householdId, month, expenses);
    } catch (e, stack) {
      LogService.error(
        'Failed to snapshot expenses for $month',
        error: e,
        stackTrace: stack,
        category: 'service.expense_snapshot',
      );
      throw DataException('Failed to snapshot expenses for $month', e, stack);
    }
  }

  Future<Map<String, List<ExpenseSnapshot>>> loadHistory(
    String householdId, {
    int months = 12,
  }) async {
    try {
      return await _resolvedRepository.loadHistory(
          householdId, months: months);
    } catch (e, stack) {
      LogService.error(
        'Failed to load expense snapshot history',
        error: e,
        stackTrace: stack,
        category: 'service.expense_snapshot',
      );
      throw DataException(
          'Failed to load expense snapshot history', e, stack);
    }
  }
}
