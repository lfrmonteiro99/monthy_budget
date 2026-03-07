import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/app_settings.dart';
import 'package:orcamento_mensal/models/savings_goal.dart';
import 'package:orcamento_mensal/services/downgrade_service.dart';

void main() {
  group('DowngradeService static helpers', () {
    test('activeCategories counts enabled expenses', () {
      final expenses = [
        const ExpenseItem(id: '1', enabled: true),
        const ExpenseItem(id: '2', enabled: true),
        const ExpenseItem(id: '3', enabled: false),
      ];
      expect(DowngradeService.activeCategories(expenses), 2);
    });

    test('pausedCategories counts disabled expenses', () {
      final expenses = [
        const ExpenseItem(id: '1', enabled: true),
        const ExpenseItem(id: '2', enabled: false),
        const ExpenseItem(id: '3', enabled: false),
      ];
      expect(DowngradeService.pausedCategories(expenses), 2);
    });

    test('excessCategories returns 0 when under limit', () {
      final expenses = List.generate(
          5, (i) => ExpenseItem(id: '$i', enabled: true));
      expect(DowngradeService.excessCategories(expenses), 0);
    });

    test('excessCategories returns correct count when over limit', () {
      final expenses = List.generate(
          12, (i) => ExpenseItem(id: '$i', enabled: true));
      expect(DowngradeService.excessCategories(expenses), 4);
    });

    test('activeSavingsGoals counts active goals', () {
      final goals = [
        SavingsGoal(id: '1', name: 'A', targetAmount: 100, isActive: true),
        SavingsGoal(id: '2', name: 'B', targetAmount: 200, isActive: false),
        SavingsGoal(id: '3', name: 'C', targetAmount: 300, isActive: true),
      ];
      expect(DowngradeService.activeSavingsGoals(goals), 2);
    });

    test('excessSavingsGoals returns correct count', () {
      final goals = [
        SavingsGoal(id: '1', name: 'A', targetAmount: 100, isActive: true),
        SavingsGoal(id: '2', name: 'B', targetAmount: 200, isActive: true),
        SavingsGoal(id: '3', name: 'C', targetAmount: 300, isActive: true),
      ];
      expect(DowngradeService.excessSavingsGoals(goals), 2);
    });

    test('hasExcessItems detects excess categories', () {
      final expenses = List.generate(
          10, (i) => ExpenseItem(id: '$i', enabled: true));
      final goals = <SavingsGoal>[];
      expect(DowngradeService.hasExcessItems(expenses, goals), true);
    });

    test('hasExcessItems returns false when under limits', () {
      final expenses = List.generate(
          8, (i) => ExpenseItem(id: '$i', enabled: true));
      final goals = [
        SavingsGoal(id: '1', name: 'A', targetAmount: 100, isActive: true),
      ];
      expect(DowngradeService.hasExcessItems(expenses, goals), false);
    });

    test('maxFreeCategories is 8', () {
      expect(DowngradeService.maxFreeCategories, 8);
    });

    test('maxFreeSavingsGoals is 1', () {
      expect(DowngradeService.maxFreeSavingsGoals, 1);
    });
  });
}
