import '../models/actual_expense.dart';
import '../models/recurring_expense.dart';
import '../repositories/expense_repository.dart';

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

  Future<List<RecurringExpense>> load(String householdId) {
    return _resolvedRecurringRepository.load(householdId);
  }

  Future<void> save(RecurringExpense expense, String householdId) {
    return _resolvedRecurringRepository.save(expense, householdId);
  }

  Future<void> delete(String id) {
    return _resolvedRecurringRepository.delete(id);
  }

  Future<List<ActualExpense>> populateMonthIfNeeded(
    String householdId,
    String monthKey,
  ) async {
    final alreadyRan = await _resolvedRecurringRepository.hasRunForMonth(
      householdId,
      monthKey,
    );
    if (alreadyRan) return [];

    final recurring = await load(householdId);
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
    await _resolvedRecurringRepository.markRunForMonth(householdId, monthKey);

    return created;
  }
}
