import 'dart:io';

import '../exceptions/app_exceptions.dart';
import '../models/actual_expense.dart';
import '../repositories/expense_repository.dart';

class ActualExpenseService {
  final ExpenseRepository _repository;

  ActualExpenseService({ExpenseRepository? repository})
    : _repository = repository ?? SupabaseExpenseRepository();

  Future<List<ActualExpense>> loadMonth(String householdId, String monthKey) async {
    try {
      return await _repository.loadMonth(householdId, monthKey);
    } catch (e, stack) {
      throw DataException('Failed to load expenses for $monthKey', e, stack);
    }
  }

  Future<void> add(ActualExpense expense, String householdId) async {
    try {
      await _repository.add(expense, householdId);
    } catch (e, stack) {
      throw DataException('Failed to add expense', e, stack);
    }
  }

  Future<void> update(ActualExpense expense) async {
    try {
      await _repository.update(expense);
    } catch (e, stack) {
      throw DataException('Failed to update expense ${expense.id}', e, stack);
    }
  }

  Future<List<String>> uploadAttachments(
    List<File> files,
    String householdId,
    String expenseId,
  ) {
    return _repository.uploadAttachments(files, householdId, expenseId);
  }

  Future<void> delete(String id) async {
    try {
      await _repository.delete(id);
    } catch (e, stack) {
      throw DataException('Failed to delete expense $id', e, stack);
    }
  }

  Future<Map<String, List<ActualExpense>>> loadHistory(
    String householdId, {
    int months = 12,
  }) async {
    try {
      return await _repository.loadHistory(householdId, months: months);
    } catch (e, stack) {
      throw DataException('Failed to load expense history', e, stack);
    }
  }
}
