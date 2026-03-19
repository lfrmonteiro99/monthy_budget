import '../models/actual_expense.dart';
import '../models/recurring_expense.dart';
import '../repositories/expense_repository.dart';

class RecurringExpenseService {
  final RecurringExpenseRepository _recurringRepository;
  final ExpenseRepository _expenseRepository;

  RecurringExpenseService({
    RecurringExpenseRepository? recurringRepository,
    ExpenseRepository? expenseRepository,
  }) : _recurringRepository =
           recurringRepository ?? SupabaseRecurringExpenseRepository(),
       _expenseRepository = expenseRepository ?? SupabaseExpenseRepository();

  Future<List<RecurringExpense>> load(String householdId) {
    return _recurringRepository.load(householdId);
  }

  Future<void> save(RecurringExpense expense, String householdId) {
    return _recurringRepository.save(expense, householdId);
  }

  Future<void> delete(String id) {
    return _recurringRepository.delete(id);
  }

  Future<List<ActualExpense>> populateMonthIfNeeded(
    String householdId,
    String monthKey,
  ) async {
    final alreadyRan = await _recurringRepository.hasRunForMonth(
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
      await _expenseRepository.addAll(created, householdId);
    }
    await _recurringRepository.markRunForMonth(householdId, monthKey);

    return created;
  }
}
