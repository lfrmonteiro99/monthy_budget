import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/repositories/local/app_database.dart';
import 'package:monthly_management/repositories/local/qa_local_store.dart';
import 'package:monthly_management/repositories/qa/qa_collections.dart';
import 'package:monthly_management/repositories/qa/qa_seed.dart';

void main() {
  group('QaSeed', () {
    const householdId = 'qa-household-0001';
    const userId = 'qa-user-0001';
    // Mid-month so no clamped day silently rolls into the next month.
    final now = DateTime(2026, 8, 17, 9, 30);

    late AppDatabase database;
    late QaLocalStore store;
    late QaSeed seed;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      store = QaLocalStore(database);
      seed = QaSeed(
        store: store,
        householdId: householdId,
        userId: userId,
        userEmail: 'qa.tester@example.com',
        now: now,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('writes the expected row counts', () async {
      expect(await seed.runIfNeeded(), isTrue);

      Future<int> count(String collection) async =>
          (await store.query(collection, householdId)).length;

      expect(await count(QaCollections.households), 1);
      expect(await count(QaCollections.profiles), 2);
      expect(await count(QaCollections.householdSettings), 1);
      expect(await count(QaCollections.householdFavorites), 1);
      expect(await count(QaCollections.customCategories), 2);
      // 3 months × 10 budget categories.
      expect(await count(QaCollections.monthlyBudgets), 30);
      expect(
        await count(QaCollections.actualExpenses),
        QaSeed.expectedExpenseCount,
      );
      expect(
        await count(QaCollections.recurringExpenses),
        QaSeed.expectedRecurringCount,
      );
      expect(await count(QaCollections.recurringExpenseRuns), 3);
      // 3 months × 8 planned fixed expenses.
      expect(await count(QaCollections.expenseSnapshots), 24);
      expect(
        await count(QaCollections.savingsGoals),
        QaSeed.expectedSavingsGoalCount,
      );
      expect(await count(QaCollections.savingsContributions), 6);
      expect(
        await count(QaCollections.shoppingItems),
        QaSeed.expectedShoppingItemCount,
      );
      expect(await count(QaCollections.purchaseRecords), 3);
      expect(await count(QaCollections.coachInsights), 2);
      expect(await count(QaCollections.activityEvents), 5);
      expect(await store.queryAll(QaCollections.products), hasLength(6));
      expect(await store.queryAll(QaCollections.merchants), hasLength(2));
    });

    test('is idempotent — a second run writes nothing new', () async {
      expect(await seed.runIfNeeded(), isTrue);
      final before = await store.query(
        QaCollections.actualExpenses,
        householdId,
      );

      expect(await seed.runIfNeeded(), isFalse);
      final after = await store.query(QaCollections.actualExpenses, householdId);

      expect(after, hasLength(before.length));
    });

    test('spreads expenses across the current and two prior months', () async {
      await seed.runIfNeeded();
      final rows = await store.query(QaCollections.actualExpenses, householdId);
      final monthKeys = rows.map((r) => r['month_key'] as String).toSet();

      expect(monthKeys, {'2026-06', '2026-07', '2026-08'});
    });

    test('leaves at least one category over budget in the current month',
        () async {
      await seed.runIfNeeded();

      final budgets = await store.query(
        QaCollections.monthlyBudgets,
        householdId,
      );
      final expenses = await store.query(
        QaCollections.actualExpenses,
        householdId,
      );

      const monthKey = '2026-08';
      final budgeted = <String, double>{};
      for (final row in budgets) {
        if (row['month_key'] != monthKey) continue;
        budgeted[row['category'] as String] = (row['amount'] as num).toDouble();
      }
      final spent = <String, double>{};
      for (final row in expenses) {
        if (row['month_key'] != monthKey) continue;
        final category = row['category'] as String;
        spent[category] =
            (spent[category] ?? 0) + (row['amount'] as num).toDouble();
      }

      final overspent = spent.entries
          .where((e) => e.value > (budgeted[e.key] ?? double.infinity))
          .map((e) => e.key)
          .toSet();

      expect(overspent, contains('alimentacao'));
      expect(overspent, contains('lazer'));
    });

    test('produces savings goals in on-track, behind and completed states',
        () async {
      await seed.runIfNeeded();
      final rows = await store.query(QaCollections.savingsGoals, householdId);

      final progress = {
        for (final row in rows)
          row['id'] as String: (row['current_amount'] as num).toDouble() /
              (row['target_amount'] as num).toDouble(),
      };

      expect(progress['qa-goal-portatil'], 1.0);
      expect(progress['qa-goal-fundo'], greaterThan(0.5));
      expect(progress['qa-goal-ferias'], lessThan(0.2));
    });

    test('leaves the shopping list partially checked', () async {
      await seed.runIfNeeded();
      final rows = await store.query(QaCollections.shoppingItems, householdId);
      final checked = rows.where((r) => r['checked'] == true).length;

      expect(checked, greaterThan(0));
      expect(checked, lessThan(rows.length));
    });

    test('is deterministic — same clock produces the same payloads', () async {
      await seed.runIfNeeded();
      final first = await store.query(QaCollections.actualExpenses, householdId);

      final secondDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      final secondStore = QaLocalStore(secondDatabase);
      await QaSeed(
        store: secondStore,
        householdId: householdId,
        userId: userId,
        userEmail: 'qa.tester@example.com',
        now: now,
      ).runIfNeeded();
      final second = await secondStore.query(
        QaCollections.actualExpenses,
        householdId,
      );
      await secondDatabase.close();

      expect(second, equals(first));
    });
  });
}
