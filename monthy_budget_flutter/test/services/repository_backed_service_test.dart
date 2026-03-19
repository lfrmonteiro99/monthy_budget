import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/exceptions/app_exceptions.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/monthly_budget.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/models/recurring_expense.dart';
import 'package:monthly_management/repositories/expense_repository.dart';
import 'package:monthly_management/repositories/shopping_repository.dart';
import 'package:monthly_management/services/actual_expense_service.dart';
import 'package:monthly_management/services/monthly_budget_service.dart';
import 'package:monthly_management/services/purchase_history_service.dart';
import 'package:monthly_management/services/recurring_expense_service.dart';

void main() {
  group('Repository-backed services', () {
    test('ActualExpenseService uses injected repository for loadMonth', () async {
      final expense = ActualExpense(
        id: 'exp-1',
        category: 'food',
        amount: 24.5,
        date: DateTime(2026, 3, 7),
        monthKey: '2026-03',
      );
      final repository = InMemoryExpenseRepository(expenses: [expense]);
      final service = ActualExpenseService(repository: repository);

      final result = await service.loadMonth('house-1', '2026-03');

      expect(result, [expense]);
      expect(repository.lastLoadMonthArgs, ('house-1', '2026-03'));
    });

    test('ActualExpenseService wraps repository failures', () async {
      final repository = InMemoryExpenseRepository()..throwOnAdd = true;
      final service = ActualExpenseService(repository: repository);
      final expense = ActualExpense(
        id: 'exp-2',
        category: 'transport',
        amount: 10,
        date: DateTime(2026, 3, 8),
        monthKey: '2026-03',
      );

      await expectLater(
        service.add(expense, 'house-1'),
        throwsA(isA<DataException>()),
      );
    });

    test('MonthlyBudgetService saves through injected repository', () async {
      final repository = InMemoryBudgetRepository();
      final service = MonthlyBudgetService(repository: repository);
      final budget = MonthlyBudget(
        id: 'budget-1',
        category: 'food',
        amount: 300,
        monthKey: '2026-03',
      );

      await service.save(budget, 'house-1');

      expect(repository.savedBudgets, [budget]);
      expect(repository.savedHouseholdIds, ['house-1']);
    });

    test('MonthlyBudgetService skips repository when saveAll gets empty list', () async {
      final repository = InMemoryBudgetRepository();
      final service = MonthlyBudgetService(repository: repository);

      await service.saveAll(const [], 'house-1');

      expect(repository.saveAllCalls, 0);
    });

    test('RecurringExpenseService populates month via repositories', () async {
      final recurringRepository = InMemoryRecurringExpenseRepository(
        expenses: [
          RecurringExpense(
            id: 'rec-1',
            category: 'rent',
            amount: 900,
            dayOfMonth: 31,
          ),
        ],
      );
      final expenseRepository = InMemoryExpenseRepository();
      final service = RecurringExpenseService(
        recurringRepository: recurringRepository,
        expenseRepository: expenseRepository,
      );

      final created = await service.populateMonthIfNeeded('house-1', '2026-02');

      expect(created, hasLength(1));
      expect(created.single.category, 'rent');
      expect(created.single.amount, 900);
      expect(created.single.date, DateTime(2026, 2, 28));
      expect(created.single.isFromRecurring, true);
      expect(expenseRepository.addedBatches.single, created);
      expect(recurringRepository.markedRuns, [('house-1', '2026-02')]);
    });

    test('RecurringExpenseService does nothing when month already ran', () async {
      final recurringRepository = InMemoryRecurringExpenseRepository(
        alreadyRanMonths: {'house-1|2026-03'},
        expenses: [
          RecurringExpense(
            id: 'rec-2',
            category: 'utilities',
            amount: 80,
          ),
        ],
      );
      final expenseRepository = InMemoryExpenseRepository();
      final service = RecurringExpenseService(
        recurringRepository: recurringRepository,
        expenseRepository: expenseRepository,
      );

      final created = await service.populateMonthIfNeeded('house-1', '2026-03');

      expect(created, isEmpty);
      expect(expenseRepository.addedBatches, isEmpty);
      expect(recurringRepository.markedRuns, isEmpty);
    });

    test('PurchaseHistoryService loads through injected repository', () async {
      final record = PurchaseRecord(
        id: 'purchase-1',
        date: DateTime(2026, 3, 10),
        amount: 47.8,
        itemCount: 3,
        items: const ['milk', 'bread'],
      );
      final repository = InMemoryPurchaseRepository(
        history: PurchaseHistory(records: [record]),
      );
      final service = PurchaseHistoryService(repository: repository);

      final history = await service.load('house-1');

      expect(history.records, [record]);
      expect(repository.loadedHouseholds, ['house-1']);
    });
  });
}

class InMemoryExpenseRepository implements ExpenseRepository {
  InMemoryExpenseRepository({List<ActualExpense>? expenses})
    : _expenses = List<ActualExpense>.from(expenses ?? const []);

  final List<ActualExpense> _expenses;
  final List<List<ActualExpense>> addedBatches = [];
  (String, String)? lastLoadMonthArgs;
  bool throwOnAdd = false;

  @override
  Future<void> add(ActualExpense expense, String householdId) async {
    if (throwOnAdd) {
      throw StateError('add failed');
    }
    _expenses.add(expense);
  }

  @override
  Future<void> addAll(List<ActualExpense> expenses, String householdId) async {
    addedBatches.add(List<ActualExpense>.from(expenses));
    _expenses.addAll(expenses);
  }

  @override
  Future<void> delete(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
  }

  @override
  Future<Map<String, List<ActualExpense>>> loadHistory(
    String householdId, {
    int months = 12,
  }) async {
    final result = <String, List<ActualExpense>>{};
    for (final expense in _expenses) {
      result.putIfAbsent(expense.monthKey, () => []).add(expense);
    }
    return result;
  }

  @override
  Future<List<ActualExpense>> loadMonth(String householdId, String monthKey) async {
    lastLoadMonthArgs = (householdId, monthKey);
    return _expenses.where((expense) => expense.monthKey == monthKey).toList();
  }

  @override
  Future<void> update(ActualExpense expense) async {
    final index = _expenses.indexWhere((item) => item.id == expense.id);
    if (index >= 0) {
      _expenses[index] = expense;
    }
  }

  @override
  Future<List<String>> uploadAttachments(
    List<File> files,
    String householdId,
    String expenseId,
  ) async {
    return files.map((file) => file.path).toList();
  }
}

class InMemoryBudgetRepository implements BudgetRepository {
  final List<MonthlyBudget> savedBudgets = [];
  final List<String> savedHouseholdIds = [];
  int saveAllCalls = 0;

  @override
  Future<List<MonthlyBudget>> loadMonth(String householdId, String monthKey) async {
    return savedBudgets.where((budget) => budget.monthKey == monthKey).toList();
  }

  @override
  Future<void> save(MonthlyBudget budget, String householdId) async {
    savedBudgets.add(budget);
    savedHouseholdIds.add(householdId);
  }

  @override
  Future<void> saveAll(List<MonthlyBudget> budgets, String householdId) async {
    saveAllCalls += 1;
    savedBudgets.addAll(budgets);
    savedHouseholdIds.addAll(List<String>.filled(budgets.length, householdId));
  }
}

class InMemoryRecurringExpenseRepository implements RecurringExpenseRepository {
  InMemoryRecurringExpenseRepository({
    List<RecurringExpense>? expenses,
    Set<String>? alreadyRanMonths,
  }) : _expenses = List<RecurringExpense>.from(expenses ?? const []),
       _alreadyRanMonths = Set<String>.from(alreadyRanMonths ?? const {});

  final List<RecurringExpense> _expenses;
  final Set<String> _alreadyRanMonths;
  final List<(String, String)> markedRuns = [];

  @override
  Future<void> delete(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
  }

  @override
  Future<bool> hasRunForMonth(String householdId, String monthKey) async {
    return _alreadyRanMonths.contains('$householdId|$monthKey');
  }

  @override
  Future<List<RecurringExpense>> load(String householdId) async {
    return List<RecurringExpense>.from(_expenses);
  }

  @override
  Future<void> markRunForMonth(String householdId, String monthKey) async {
    _alreadyRanMonths.add('$householdId|$monthKey');
    markedRuns.add((householdId, monthKey));
  }

  @override
  Future<void> save(RecurringExpense expense, String householdId) async {
    _expenses.add(expense);
  }
}

class InMemoryPurchaseRepository implements PurchaseRepository {
  InMemoryPurchaseRepository({PurchaseHistory? history})
    : _history = history ?? const PurchaseHistory();

  final PurchaseHistory _history;
  final List<String> loadedHouseholds = [];

  @override
  Future<PurchaseHistory> load(String householdId) async {
    loadedHouseholds.add(householdId);
    return _history;
  }

  @override
  Future<void> saveRecord(PurchaseRecord record, String householdId) async {}
}
