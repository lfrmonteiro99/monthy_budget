import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/savings_goal.dart';
import 'package:monthly_management/models/shopping_item.dart';
import 'package:monthly_management/repositories/local/app_database.dart';
import 'package:monthly_management/repositories/local/qa_local_store.dart';
import 'package:monthly_management/repositories/qa/qa_repository_provider.dart';
import 'package:monthly_management/repositories/qa/qa_seed.dart';
import 'package:monthly_management/repositories/repository_factory.dart';
import 'package:monthly_management/services/actual_expense_service.dart';
import 'package:monthly_management/services/household_service.dart';
import 'package:monthly_management/services/monthly_budget_service.dart';
import 'package:monthly_management/services/savings_goal_service.dart';
import 'package:monthly_management/services/settings_service.dart';
import 'package:monthly_management/services/shopping_list_service.dart';

/// Exercises the RepositoryFactory seam end-to-end: with a QaRepositoryProvider
/// installed, the production services read the seeded sqlite data without any
/// constructor injection and without Supabase being initialised.
void main() {
  group('services backed by QaRepositoryProvider', () {
    const householdId = 'qa-household-0001';
    const userId = 'qa-user-0001';
    final now = DateTime(2026, 8, 17, 9, 30);
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    late AppDatabase database;
    late QaLocalStore store;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      store = QaLocalStore(database);
      await QaSeed(
        store: store,
        householdId: householdId,
        userId: userId,
        userEmail: 'qa.tester@example.com',
        now: now,
      ).runIfNeeded();

      RepositoryFactory.instance = QaRepositoryProvider(
        store: store,
        householdId: householdId,
        userId: userId,
        userEmail: 'qa.tester@example.com',
        now: () => now,
      );
    });

    tearDown(() async {
      RepositoryFactory.reset();
      await database.close();
    });

    test('ActualExpenseService returns the seeded expenses for the month',
        () async {
      final expenses = await ActualExpenseService().loadMonth(
        householdId,
        monthKey,
      );

      expect(expenses, isNotEmpty);
      expect(expenses.every((e) => e.monthKey == monthKey), isTrue);
      // Newest first, matching the Supabase repository's ordering.
      for (var i = 1; i < expenses.length; i++) {
        expect(
          expenses[i - 1].date.isBefore(expenses[i].date),
          isFalse,
          reason: 'expenses must be ordered newest-first',
        );
      }
    });

    test('ActualExpenseService history covers three months', () async {
      final history = await ActualExpenseService().loadHistory(householdId);
      expect(history.keys, hasLength(3));
    });

    test('MonthlyBudgetService returns the seeded envelope', () async {
      final budgets = await MonthlyBudgetService().loadMonth(
        householdId,
        monthKey,
      );
      expect(budgets, hasLength(10));
      expect(
        budgets.firstWhere((b) => b.category == 'alimentacao').amount,
        520,
      );
    });

    test('SettingsService returns settings the tax simulator can use',
        () async {
      final settings = await SettingsService().load(householdId);

      expect(settings.setupWizardCompleted, isTrue);
      expect(settings.personalInfo.dependentes, 2);
      expect(settings.salaries.where((s) => s.enabled), hasLength(2));
      expect(settings.expenses, isNotEmpty);
      expect(settings.incomeSources, isNotEmpty);
    });

    test('SavingsGoalService returns the seeded goals', () async {
      final goals = await SavingsGoalService().loadGoals(householdId);
      expect(goals, hasLength(QaSeed.expectedSavingsGoalCount));
      expect(goals.any((g) => g.isCompleted), isTrue);
    });

    test('SavingsGoalService.addContribution bumps the goal total', () async {
      final service = SavingsGoalService();
      final before = (await service.loadGoals(
        householdId,
      )).firstWhere((g) => g.id == 'qa-goal-ferias');

      await RepositoryFactory.instance.savings.addContribution(
        SavingsContributionFixture.build(now),
        householdId,
      );

      final after = (await service.loadGoals(
        householdId,
      )).firstWhere((g) => g.id == 'qa-goal-ferias');
      expect(after.currentAmount, before.currentAmount + 50);
    });

    test('HouseholdService resolves the seeded profile', () async {
      final profile = await HouseholdService().getProfile();

      expect(profile, isNotNull);
      expect(profile!.householdId, householdId);
      expect(profile.role, 'admin');
      expect(profile.householdName, QaSeed.householdName);
    });

    test('ShoppingListService streams the seeded list and every mutation',
        () async {
      final service = ShoppingListService();
      final emissions = <List<ShoppingItem>>[];
      final subscription = service.stream(householdId).listen(emissions.add);

      // Let the seeded snapshot arrive.
      await Future<void>.delayed(Duration.zero);
      expect(emissions, hasLength(1));
      expect(emissions.first, hasLength(QaSeed.expectedShoppingItemCount));

      final added = await service.add(
        ShoppingItem(
          id: 'ignored-by-repository',
          productName: 'Manteiga',
          store: 'Lidl',
          price: 2.29,
        ),
        householdId,
      );
      await Future<void>.delayed(Duration.zero);

      expect(added.productName, 'Manteiga');
      expect(emissions, hasLength(2));
      expect(
        emissions.last,
        hasLength(QaSeed.expectedShoppingItemCount + 1),
      );

      await service.toggle(added.id, true);
      await Future<void>.delayed(Duration.zero);
      expect(emissions, hasLength(3));
      expect(
        emissions.last.firstWhere((i) => i.id == added.id).checked,
        isTrue,
      );

      await subscription.cancel();
    });

    test('writes survive a fresh provider over the same store', () async {
      await ActualExpenseService().delete('qa-ae-000');

      RepositoryFactory.instance = QaRepositoryProvider(
        store: store,
        householdId: householdId,
        userId: userId,
        userEmail: 'qa.tester@example.com',
        now: () => now,
      );

      final history = await ActualExpenseService().loadHistory(householdId);
      final ids = history.values.expand((e) => e).map((e) => e.id);
      expect(ids, isNot(contains('qa-ae-000')));
    });
  });
}

/// Small helper so the contribution fixture stays out of the assertions.
class SavingsContributionFixture {
  static SavingsContribution build(DateTime now) => SavingsContribution(
    id: 'test-contrib-001',
    goalId: 'qa-goal-ferias',
    amount: 50,
    contributionDate: now,
  );
}
