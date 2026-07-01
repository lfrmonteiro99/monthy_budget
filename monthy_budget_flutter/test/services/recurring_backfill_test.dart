import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/recurring_expense.dart';
import 'package:monthly_management/repositories/expense_repository.dart';
import 'package:monthly_management/services/recurring_expense_service.dart';

// ---------- fake repositories ----------

class FakeRecurringRepository implements RecurringExpenseRepository {
  final List<RecurringExpense> _expenses;
  final Set<String> _runMonths;

  FakeRecurringRepository({
    List<RecurringExpense>? expenses,
    Set<String>? runMonths,
  })  : _expenses = expenses ?? [],
        _runMonths = runMonths ?? {};

  @override
  Future<List<RecurringExpense>> load(String householdId) async => _expenses;

  @override
  Future<void> save(RecurringExpense expense, String householdId) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<bool> hasRunForMonth(String householdId, String monthKey) async =>
      _runMonths.contains(monthKey);

  @override
  Future<void> markRunForMonth(String householdId, String monthKey) async =>
      _runMonths.add(monthKey);

  @override
  Future<List<String>> loadRunMonths(String householdId) async =>
      _runMonths.toList();
}

class FakeExpenseRepository implements ExpenseRepository {
  final List<ActualExpense> inserted = [];
  int addAllFromRecurringCalls = 0;

  @override
  Future<List<ActualExpense>> loadMonth(String householdId, String monthKey) async => [];

  @override
  Future<void> add(ActualExpense expense, String householdId) async =>
      inserted.add(expense);

  @override
  Future<void> addAll(List<ActualExpense> expenses, String householdId) async =>
      inserted.addAll(expenses);

  @override
  Future<void> addAllFromRecurring(
      List<ActualExpense> expenses, String householdId) async {
    addAllFromRecurringCalls++;
    // Idempotent: only insert if ID not already present
    for (final e in expenses) {
      if (!inserted.any((i) => i.id == e.id)) {
        inserted.add(e);
      }
    }
  }

  @override
  Future<void> update(ActualExpense expense) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<String>> uploadAttachments(
      List<File> files, String householdId, String expenseId) async =>
      [];

  @override
  Future<Map<String, List<ActualExpense>>> loadHistory(String householdId,
          {int months = 12}) async =>
      {};
}

// ---------- helpers ----------

RecurringExpense _rent({String id = 'r1', int dayOfMonth = 1}) =>
    RecurringExpense(
      id: id,
      category: 'Housing',
      amount: 800.0,
      description: 'Rent',
      dayOfMonth: dayOfMonth,
      isActive: true,
    );

// ---------- tests ----------

void main() {
  group('RecurringExpenseService — backfill', () {
    test('no prior runs: only current month is populated', () async {
      final recRepo = FakeRecurringRepository(expenses: [_rent()]);
      final expRepo = FakeExpenseRepository();
      final service = RecurringExpenseService(
        recurringRepository: recRepo,
        expenseRepository: expRepo,
      );

      final created = await service.backfillToMonth('hh1', '2026-03');

      expect(created.length, 1);
      expect(created.first.monthKey, '2026-03');
      expect(recRepo._runMonths, contains('2026-03'));
    });

    test('one skipped month: both gap and current are populated', () async {
      final recRepo = FakeRecurringRepository(
        expenses: [_rent()],
        runMonths: {'2026-01'},
      );
      final expRepo = FakeExpenseRepository();
      final service = RecurringExpenseService(
        recurringRepository: recRepo,
        expenseRepository: expRepo,
      );

      // Current is 2026-03; last run was 2026-01 → gap is 2026-02 and 2026-03
      final created = await service.backfillToMonth('hh1', '2026-03');

      expect(created.length, 2, reason: 'Feb + Mar should be populated');
      final months = created.map((e) => e.monthKey).toSet();
      expect(months, containsAll(['2026-02', '2026-03']));
      expect(recRepo._runMonths, containsAll(['2026-01', '2026-02', '2026-03']));
    });

    test('two skipped months: all three gap months populated', () async {
      final recRepo = FakeRecurringRepository(
        expenses: [_rent()],
        runMonths: {'2026-01'},
      );
      final expRepo = FakeExpenseRepository();
      final service = RecurringExpenseService(
        recurringRepository: recRepo,
        expenseRepository: expRepo,
      );

      final created = await service.backfillToMonth('hh1', '2026-04');

      expect(created.length, 3,
          reason: 'Feb, Mar, Apr must all be populated');
      final months = created.map((e) => e.monthKey).toSet();
      expect(months, containsAll(['2026-02', '2026-03', '2026-04']));
    });

    test('already up to date: no new expenses created', () async {
      final recRepo = FakeRecurringRepository(
        expenses: [_rent()],
        runMonths: {'2026-03'},
      );
      final expRepo = FakeExpenseRepository();
      final service = RecurringExpenseService(
        recurringRepository: recRepo,
        expenseRepository: expRepo,
      );

      final created = await service.backfillToMonth('hh1', '2026-03');

      expect(created, isEmpty);
    });
  });

  group('RecurringExpenseService — idempotent IDs', () {
    test('expense ID includes monthKey, not a timestamp', () async {
      final recRepo = FakeRecurringRepository(expenses: [_rent(id: 'rent42')]);
      final expRepo = FakeExpenseRepository();
      final service = RecurringExpenseService(
        recurringRepository: recRepo,
        expenseRepository: expRepo,
      );

      final created = await service.populateMonthIfNeeded('hh1', '2026-03');

      expect(created.first.id, 'exp_rec_rent42_2026-03');
    });

    test('concurrent populate calls produce no duplicates (idempotent)', () async {
      final recRepo = FakeRecurringRepository(expenses: [_rent(id: 'r1')]);
      final expRepo = FakeExpenseRepository();
      final service = RecurringExpenseService(
        recurringRepository: recRepo,
        expenseRepository: expRepo,
      );

      // Simulate race: call twice in parallel (both see hasRunForMonth=false
      // before either marks it). addAllFromRecurring must be idempotent.
      await Future.wait([
        service.populateMonthIfNeeded('hh1', '2026-03'),
        service.populateMonthIfNeeded('hh1', '2026-03'),
      ]);

      final ids = expRepo.inserted.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length,
          reason: 'No duplicate expense IDs after concurrent populate');
      expect(expRepo.inserted.length, 1,
          reason: 'Only one expense inserted despite concurrent calls');
    });
  });
}
