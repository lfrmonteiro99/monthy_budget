import '../exceptions/app_exceptions.dart';
import '../models/actual_expense.dart';
import '../models/recurring_expense.dart';
import '../repositories/expense_repository.dart';
import 'log_service.dart';

class RecurringExpenseService {
  RecurringExpenseRepository? _recurringRepository;
  ExpenseRepository? _expenseRepository;

  RecurringExpenseService({
    RecurringExpenseRepository? recurringRepository,
    ExpenseRepository? expenseRepository,
  }) : _recurringRepository = recurringRepository,
       _expenseRepository = expenseRepository;

  RecurringExpenseRepository get _resolvedRecurringRepository =>
      _recurringRepository ??= SupabaseRecurringExpenseRepository();

  ExpenseRepository get _resolvedExpenseRepository =>
      _expenseRepository ??= SupabaseExpenseRepository();

  Future<List<RecurringExpense>> load(String householdId) async {
    try {
      return await _resolvedRecurringRepository.load(householdId);
    } catch (e, stack) {
      LogService.error(
        'Failed to load recurring expenses',
        error: e,
        stackTrace: stack,
        category: 'service.recurring_expense',
      );
      throw DataException('Failed to load recurring expenses', e, stack);
    }
  }

  Future<void> save(RecurringExpense expense, String householdId) async {
    try {
      await _resolvedRecurringRepository.save(expense, householdId);
    } catch (e, stack) {
      LogService.error(
        'Failed to save recurring expense ${expense.id}',
        error: e,
        stackTrace: stack,
        category: 'service.recurring_expense',
      );
      throw DataException(
          'Failed to save recurring expense ${expense.id}', e, stack);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _resolvedRecurringRepository.delete(id);
    } catch (e, stack) {
      LogService.error(
        'Failed to delete recurring expense $id',
        error: e,
        stackTrace: stack,
        category: 'service.recurring_expense',
      );
      throw DataException('Failed to delete recurring expense $id', e, stack);
    }
  }

  Future<List<ActualExpense>> populateMonthIfNeeded(
    String householdId,
    String monthKey,
  ) async {
    try {
      final alreadyRan = await _resolvedRecurringRepository.hasRunForMonth(
        householdId,
        monthKey,
      );
      if (alreadyRan) return [];

      final recurring = await _resolvedRecurringRepository.load(householdId);
      final active = recurring.where((expense) => expense.isActive).toList();
      if (active.isEmpty) {
        // Mark run even if empty so we don't query again next month
        await _resolvedRecurringRepository.markRunForMonth(householdId, monthKey);
        return [];
      }

      final parts = monthKey.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      final created = <ActualExpense>[];
      for (final recurringExpense in active) {
        final day = recurringExpense.dayOfMonth ?? 1;
        final maxDay = DateTime(year, month + 1, 0).day;
        final safeDay = day.clamp(1, maxDay);
        final date = DateTime(year, month, safeDay);

        created.add(
          ActualExpense(
            // Deterministic ID: collision on re-run = idempotent upsert-ignore
            id: 'exp_rec_${recurringExpense.id}_$monthKey',
            category: recurringExpense.category,
            amount: recurringExpense.amount,
            date: date,
            description: recurringExpense.description,
            monthKey: monthKey,
            recurringExpenseId: recurringExpense.id,
            isFromRecurring: true,
          ),
        );
      }

      if (created.isNotEmpty) {
        await _resolvedExpenseRepository.addAllFromRecurring(
            created, householdId);
      }
      await _resolvedRecurringRepository.markRunForMonth(householdId, monthKey);

      return created;
    } catch (e, stack) {
      if (e is DataException) rethrow;
      LogService.error(
        'Failed to populate month $monthKey',
        error: e,
        stackTrace: stack,
        category: 'service.recurring_expense',
      );
      throw DataException('Failed to populate month $monthKey', e, stack);
    }
  }

  /// Populates all gap months from the last run through [currentMonthKey].
  /// Safe to call on every app launch — already-run months are skipped.
  Future<List<ActualExpense>> backfillToMonth(
    String householdId,
    String currentMonthKey,
  ) async {
    try {
      final runMonths =
          await _resolvedRecurringRepository.loadRunMonths(householdId);

      final List<String> gaps;
      if (runMonths.isEmpty) {
        gaps = [currentMonthKey];
      } else {
        final sorted = runMonths.toList()..sort();
        final lastRun = sorted.last;
        if (lastRun == currentMonthKey) return [];
        // All months after lastRun up to and including currentMonthKey
        gaps = _monthsBetween(lastRun, currentMonthKey).skip(1).toList();
      }

      final all = <ActualExpense>[];
      for (final month in gaps) {
        final created = await populateMonthIfNeeded(householdId, month);
        all.addAll(created);
      }
      return all;
    } catch (e, stack) {
      if (e is DataException) rethrow;
      LogService.error(
        'Failed to backfill recurring expenses to $currentMonthKey',
        error: e,
        stackTrace: stack,
        category: 'service.recurring_expense',
      );
      throw DataException(
          'Failed to backfill recurring expenses to $currentMonthKey', e, stack);
    }
  }

  /// Returns all month keys from [fromMonthKey] to [toMonthKey] inclusive,
  /// in ascending order. Format: "YYYY-MM".
  static List<String> _monthsBetween(String fromMonthKey, String toMonthKey) {
    final fp = fromMonthKey.split('-');
    var year = int.parse(fp[0]);
    var month = int.parse(fp[1]);
    final tp = toMonthKey.split('-');
    final toYear = int.parse(tp[0]);
    final toMonth = int.parse(tp[1]);

    final months = <String>[];
    while (year < toYear || (year == toYear && month <= toMonth)) {
      months.add('$year-${month.toString().padLeft(2, '0')}');
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }
    return months;
  }
}
