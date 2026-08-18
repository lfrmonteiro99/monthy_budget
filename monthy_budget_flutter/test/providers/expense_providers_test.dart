import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/expense_snapshot.dart';
import 'package:monthly_management/providers/expense_providers.dart';

void main() {
  group('expenseHistoryProvider (#1236)', () {
    ExpenseSnapshot snapshot() => const ExpenseSnapshot(
          expenseId: 'exp1',
          label: 'Renda',
          category: 'casa',
          amount: 500,
          enabled: true,
        );

    test('set() with content deep-equal to current state does not notify',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var notifications = 0;
      container.listen<Map<String, List<ExpenseSnapshot>>>(
        expenseHistoryProvider,
        (_, _) => notifications++,
        fireImmediately: false,
      );

      // Two DIFFERENT Map/List instances, but with identical content — this
      // mirrors what _snapshotExpenses() produces on every reload: a freshly
      // deserialised history that happens to match what's already loaded.
      container
          .read(expenseHistoryProvider.notifier)
          .set({'2026-08': [snapshot()]});
      container
          .read(expenseHistoryProvider.notifier)
          .set({'2026-08': [snapshot()]});

      expect(notifications, 1,
          reason:
              'second set() carries no new information and must not notify listeners');
    });

    test('set() with genuinely different content still notifies', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var notifications = 0;
      container.listen<Map<String, List<ExpenseSnapshot>>>(
        expenseHistoryProvider,
        (_, _) => notifications++,
        fireImmediately: false,
      );

      container
          .read(expenseHistoryProvider.notifier)
          .set({'2026-08': [snapshot()]});
      container.read(expenseHistoryProvider.notifier).set({
        '2026-08': [snapshot()],
        '2026-09': [snapshot()],
      });

      expect(notifications, 2,
          reason: 'a real content change must still reach listeners');
    });
  });

  group('actualExpenseHistoryProvider (#1236)', () {
    ActualExpense expense() => ActualExpense(
          id: 'e1',
          category: 'casa',
          amount: 100,
          date: DateTime(2026, 8, 1),
          monthKey: '2026-08',
        );

    test('set() with content deep-equal to current state does not notify',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var notifications = 0;
      container.listen<Map<String, List<ActualExpense>>>(
        actualExpenseHistoryProvider,
        (_, _) => notifications++,
        fireImmediately: false,
      );

      container
          .read(actualExpenseHistoryProvider.notifier)
          .set({'2026-08': [expense()]});
      container
          .read(actualExpenseHistoryProvider.notifier)
          .set({'2026-08': [expense()]});

      expect(notifications, 1);
    });
  });

  group('actualExpensesProvider (#1236)', () {
    ActualExpense expense() => ActualExpense(
          id: 'e1',
          category: 'casa',
          amount: 100,
          date: DateTime(2026, 8, 1),
          monthKey: '2026-08',
        );

    test('set() with content deep-equal to current state does not notify',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var notifications = 0;
      container.listen<List<ActualExpense>>(
        actualExpensesProvider,
        (_, _) => notifications++,
        fireImmediately: false,
      );

      container.read(actualExpensesProvider.notifier).set([expense()]);
      container.read(actualExpensesProvider.notifier).set([expense()]);

      expect(notifications, 1);
    });
  });
}
