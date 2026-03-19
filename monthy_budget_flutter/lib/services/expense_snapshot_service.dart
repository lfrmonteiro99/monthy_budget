import '../models/app_settings.dart';
import '../models/expense_snapshot.dart';
import '../repositories/expense_repository.dart';

class ExpenseSnapshotService {
  final ExpenseSnapshotRepository _repository;

  ExpenseSnapshotService({ExpenseSnapshotRepository? repository})
    : _repository = repository ?? SupabaseExpenseSnapshotRepository();

  Future<void> snapshotIfNeeded(
    String householdId,
    String month,
    List<ExpenseItem> expenses,
  ) {
    return _repository.snapshotIfNeeded(householdId, month, expenses);
  }

  Future<Map<String, List<ExpenseSnapshot>>> loadHistory(
    String householdId, {
    int months = 12,
  }) {
    return _repository.loadHistory(householdId, months: months);
  }
}
