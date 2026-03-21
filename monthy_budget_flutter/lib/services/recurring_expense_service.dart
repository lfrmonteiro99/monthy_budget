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
      if (active.isEmpty) return [];

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
            id: 'exp_rec_${recurringExpense.id}_${DateTime.now().millisecondsSinceEpoch}',
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
        await _resolvedExpenseRepository.addAll(created, householdId);
      }
      await _resolvedRecurringRepository.markRunForMonth(
          householdId, monthKey);

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
}
