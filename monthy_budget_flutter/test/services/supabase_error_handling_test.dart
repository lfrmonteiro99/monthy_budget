import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/exceptions/app_exceptions.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/expense_snapshot.dart';
import 'package:monthly_management/models/monthly_budget.dart';
import 'package:monthly_management/models/product.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/models/recurring_expense.dart';
import 'package:monthly_management/models/savings_goal.dart';
import 'package:monthly_management/models/shopping_item.dart';
import 'package:monthly_management/repositories/auth_repository.dart';
import 'package:monthly_management/repositories/expense_repository.dart';
import 'package:monthly_management/repositories/household_repository.dart';
import 'package:monthly_management/repositories/product_repository.dart';
import 'package:monthly_management/repositories/savings_repository.dart';
import 'package:monthly_management/repositories/shopping_repository.dart';
import 'package:monthly_management/services/actual_expense_service.dart';
import 'package:monthly_management/services/expense_snapshot_service.dart';
import 'package:monthly_management/services/household_service.dart';
import 'package:monthly_management/services/products_service.dart';
import 'package:monthly_management/services/recurring_expense_service.dart';
import 'package:monthly_management/services/savings_goal_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState, User;

// ---------------------------------------------------------------------------
// Throwing fakes — every method throws to verify the service catches
// ---------------------------------------------------------------------------

class ThrowingExpenseRepository implements ExpenseRepository {
  final Object error;
  ThrowingExpenseRepository([this.error = const _FakeError('repo failure')]);

  @override
  Future<List<ActualExpense>> loadMonth(String h, String m) => throw error;
  @override
  Future<void> add(ActualExpense e, String h) => throw error;
  @override
  Future<void> addAll(List<ActualExpense> e, String h) => throw error;
  @override
  Future<void> update(ActualExpense e) => throw error;
  @override
  Future<List<String>> uploadAttachments(
          List<File> f, String h, String e) =>
      throw error;
  @override
  Future<void> delete(String id) => throw error;
  @override
  Future<Map<String, List<ActualExpense>>> loadHistory(String h,
          {int months = 12}) =>
      throw error;
}

class ThrowingRecurringExpenseRepository implements RecurringExpenseRepository {
  final Object error;
  ThrowingRecurringExpenseRepository(
      [this.error = const _FakeError('repo failure')]);

  @override
  Future<List<RecurringExpense>> load(String h) => throw error;
  @override
  Future<void> save(RecurringExpense e, String h) => throw error;
  @override
  Future<void> delete(String id) => throw error;
  @override
  Future<bool> hasRunForMonth(String h, String m) => throw error;
  @override
  Future<void> markRunForMonth(String h, String m) => throw error;
}

class ThrowingSavingsRepository implements SavingsRepository {
  final Object error;
  ThrowingSavingsRepository([this.error = const _FakeError('repo failure')]);

  @override
  Future<List<SavingsGoal>> loadGoals(String h) => throw error;
  @override
  Future<void> saveGoal(SavingsGoal g, String h) => throw error;
  @override
  Future<void> deleteGoal(String id) => throw error;
  @override
  Future<List<SavingsContribution>> loadContributions(String g) => throw error;
  @override
  Future<SavingsGoal> addContribution(SavingsContribution c, String h) =>
      throw error;
  @override
  Future<Map<String, List<SavingsContribution>>> loadAllContributions(String h,
          {int? recentMonths}) =>
      throw error;
  @override
  Future<void> deleteContribution(SavingsContribution c, String h) =>
      throw error;
}

class ThrowingProductRepository implements ProductRepository {
  final Object error;
  ThrowingProductRepository([this.error = const _FakeError('repo failure')]);

  @override
  Future<List<Product>> load() => throw error;
}

class ThrowingHouseholdRepository implements HouseholdRepository {
  final Object error;
  ThrowingHouseholdRepository([this.error = const _FakeError('repo failure')]);

  @override
  Future<Map<String, dynamic>?> getProfileRow(String u) => throw error;
  @override
  Future<List<Map<String, dynamic>>> getAssociatedMemberRows(String h) =>
      throw error;
  @override
  Future<Map<String, dynamic>> createHousehold(String n) => throw error;
  @override
  Future<Map<String, dynamic>> joinHousehold(String c) => throw error;
  @override
  Future<void> saveInviteCode({
    required String householdId,
    required String code,
    required String createdBy,
    required DateTime expiresAt,
  }) =>
      throw error;
}

class ThrowingExpenseSnapshotRepository implements ExpenseSnapshotRepository {
  final Object error;
  ThrowingExpenseSnapshotRepository(
      [this.error = const _FakeError('repo failure')]);

  @override
  Future<void> snapshotIfNeeded(
          String h, String m, List<ExpenseItem> e) =>
      throw error;
  @override
  Future<Map<String, List<ExpenseSnapshot>>> loadHistory(String h,
          {int months = 12}) =>
      throw error;
}

class FakeAuthRepository implements AuthRepository {
  final String? userId;
  FakeAuthRepository({this.userId = 'user-1'});

  @override
  User? get currentUser => null;
  @override
  String? get currentUserId => userId;
  @override
  String? get currentSessionAccessToken => null;
  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();
  @override
  Future<void> signIn(String email, String password) async {}
  @override
  Future<void> signUp(String email, String password) async {}
  @override
  Future<void> signOut() async {}
}

class _FakeError implements Exception {
  final String message;
  const _FakeError(this.message);
  @override
  String toString() => '_FakeError: $message';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RecurringExpenseService error handling', () {
    late RecurringExpenseService service;

    setUp(() {
      service = RecurringExpenseService(
        recurringRepository: ThrowingRecurringExpenseRepository(),
        expenseRepository: ThrowingExpenseRepository(),
      );
    });

    test('load() wraps errors in DataException', () {
      expect(
        () => service.load('hh-1'),
        throwsA(isA<DataException>()),
      );
    });

    test('save() wraps errors in DataException', () {
      final expense = RecurringExpense(
        id: 'rec-1',
        category: 'rent',
        amount: 900,
      );
      expect(
        () => service.save(expense, 'hh-1'),
        throwsA(isA<DataException>()),
      );
    });

    test('delete() wraps errors in DataException', () {
      expect(
        () => service.delete('rec-1'),
        throwsA(isA<DataException>()),
      );
    });

    test('populateMonthIfNeeded() wraps errors in DataException', () {
      expect(
        () => service.populateMonthIfNeeded('hh-1', '2026-03'),
        throwsA(isA<DataException>()),
      );
    });
  });

  group('SavingsGoalService error handling', () {
    late SavingsGoalService service;

    setUp(() {
      service = SavingsGoalService(
        repository: ThrowingSavingsRepository(),
      );
    });

    test('loadGoals() wraps errors in DataException', () {
      expect(
        () => service.loadGoals('hh-1'),
        throwsA(isA<DataException>()),
      );
    });

    test('saveGoal() wraps errors in DataException', () {
      final goal = SavingsGoal(
        id: 'goal-1',
        name: 'Vacation',
        targetAmount: 2000,
      );
      expect(
        () => service.saveGoal(goal, 'hh-1'),
        throwsA(isA<DataException>()),
      );
    });

    test('deleteGoal() wraps errors in DataException', () {
      expect(
        () => service.deleteGoal('goal-1'),
        throwsA(isA<DataException>()),
      );
    });

    test('loadContributions() wraps errors in DataException', () {
      expect(
        () => service.loadContributions('goal-1'),
        throwsA(isA<DataException>()),
      );
    });

    test('addContribution() wraps errors in DataException', () {
      final contribution = SavingsContribution(
        id: 'c-1',
        goalId: 'goal-1',
        amount: 100,
        contributionDate: DateTime(2026, 3, 15),
      );
      expect(
        () => service.addContribution(contribution, 'hh-1'),
        throwsA(isA<DataException>()),
      );
    });

    test('loadAllContributions() wraps errors in DataException', () {
      expect(
        () => service.loadAllContributions('hh-1'),
        throwsA(isA<DataException>()),
      );
    });

    test('deleteContribution() wraps errors in DataException', () {
      final contribution = SavingsContribution(
        id: 'c-1',
        goalId: 'goal-1',
        amount: 100,
        contributionDate: DateTime(2026, 3, 15),
      );
      expect(
        () => service.deleteContribution(contribution, 'hh-1'),
        throwsA(isA<DataException>()),
      );
    });
  });

  group('ProductsService error handling', () {
    test('load() wraps errors in DataException', () {
      final service = ProductsService(
        repository: ThrowingProductRepository(),
      );
      expect(
        () => service.load(),
        throwsA(isA<DataException>()),
      );
    });
  });

  group('HouseholdService error handling', () {
    late HouseholdService service;

    setUp(() {
      service = HouseholdService(
        authRepository: FakeAuthRepository(),
        repository: ThrowingHouseholdRepository(),
      );
    });

    test('getProfile() wraps errors in DataException', () {
      expect(
        () => service.getProfile(),
        throwsA(isA<DataException>()),
      );
    });

    test('getAssociatedMembers() wraps errors in DataException', () {
      expect(
        () => service.getAssociatedMembers('hh-1'),
        throwsA(isA<DataException>()),
      );
    });

    test('createHousehold() wraps errors in DataException', () {
      expect(
        () => service.createHousehold('My House'),
        throwsA(isA<DataException>()),
      );
    });

    test('joinHousehold() wraps errors in DataException', () {
      expect(
        () => service.joinHousehold('ABC123'),
        throwsA(isA<DataException>()),
      );
    });

    test('generateInviteCode() wraps errors in DataException', () {
      expect(
        () => service.generateInviteCode('hh-1'),
        throwsA(isA<DataException>()),
      );
    });
  });

  group('ExpenseSnapshotService error handling', () {
    late ExpenseSnapshotService service;

    setUp(() {
      service = ExpenseSnapshotService(
        repository: ThrowingExpenseSnapshotRepository(),
      );
    });

    test('snapshotIfNeeded() wraps errors in DataException', () {
      expect(
        () => service.snapshotIfNeeded('hh-1', '2026-03', const []),
        throwsA(isA<DataException>()),
      );
    });

    test('loadHistory() wraps errors in DataException', () {
      expect(
        () => service.loadHistory('hh-1'),
        throwsA(isA<DataException>()),
      );
    });
  });

  group('ActualExpenseService error handling', () {
    test('uploadAttachments() wraps errors in DataException', () {
      final service = ActualExpenseService(
        repository: ThrowingExpenseRepository(),
      );
      expect(
        () => service.uploadAttachments([], 'hh-1', 'exp-1'),
        throwsA(isA<DataException>()),
      );
    });
  });

  group('DataException preserves original error and stack trace', () {
    test('thrown DataException contains original error', () async {
      final original = StateError('network timeout');
      final repo = ThrowingRecurringExpenseRepository(original);
      final service = RecurringExpenseService(
        recurringRepository: repo,
        expenseRepository: ThrowingExpenseRepository(),
      );

      try {
        await service.load('hh-1');
        fail('Expected DataException');
      } on DataException catch (e) {
        expect(e.originalError, same(original));
        expect(e.stackTrace, isNotNull);
        expect(e.message, contains('recurring expenses'));
      }
    });
  });
}
