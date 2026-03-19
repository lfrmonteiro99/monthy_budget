import 'dart:io';

import '../exceptions/app_exceptions.dart';
import '../models/actual_expense.dart';
import '../repositories/expense_repository.dart';

class ActualExpenseService {
  ExpenseRepository? _repository;

  ActualExpenseService({ExpenseRepository? repository})
    : _repository = repository;

  ExpenseRepository get _resolvedRepository =>
      _repository ??= SupabaseExpenseRepository();

  Future<List<ActualExpense>> loadMonth(String householdId, String monthKey) async {
    try {
      return await _resolvedRepository.loadMonth(householdId, monthKey);
    } catch (e, stack) {
      throw DataException('Failed to load expenses for $monthKey', e, stack);
    }
  }

  Future<void> add(ActualExpense expense, String householdId) async {
    try {
      await _resolvedRepository.add(expense, householdId);
    } catch (e, stack) {
      throw DataException('Failed to add expense', e, stack);
    }
  }

  Future<void> update(ActualExpense expense) async {
    try {
      await _resolvedRepository.update(expense);
    } catch (e, stack) {
      throw DataException('Failed to update expense ${expense.id}', e, stack);
    }
  }

  Future<List<String>> uploadAttachments(
    List<File> files,
    String householdId,
    String expenseId,
  ) {
    return _resolvedRepository.uploadAttachments(files, householdId, expenseId);
  }

  Future<void> delete(String id) async {
    try {
      await _resolvedRepository.delete(id);
    } catch (e, stack) {
      throw DataException('Failed to delete expense $id', e, stack);
    }
  }

  Future<Map<String, List<ActualExpense>>> loadHistory(
    String householdId, {
    int months = 12,
  }) async {
    try {
      return await _resolvedRepository.loadHistory(householdId, months: months);
    } catch (e, stack) {
      throw DataException('Failed to load expense history', e, stack);
    }
  }
}
