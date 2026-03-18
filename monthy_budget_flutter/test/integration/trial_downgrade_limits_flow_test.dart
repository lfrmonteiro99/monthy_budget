import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/savings_goal.dart';
import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/services/downgrade_service.dart';
import 'package:monthly_management/services/notification_service.dart';
import 'package:monthly_management/services/subscription_service.dart';

import '../helpers/test_helpers.dart';

void main() {
  late SubscriptionService subscriptionService;
  late DowngradeService downgradeService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    subscriptionService = SubscriptionService();
    downgradeService = DowngradeService();
  });

  group('trial downgrade flow', () {
    test('downgrade pauses excess categories and savings goals', () async {
      final paidState = SubscriptionState(
        tier: SubscriptionTier.premium,
        trialStartDate: DateTime.now().subtract(const Duration(days: 40)),
        trialUsed: true,
      );
      await subscriptionService.save(paidState);

      final downgraded = await subscriptionService.downgrade(paidState);
      expect(downgraded.justDowngraded, isTrue);

      final startingSettings = makeSettings(
        expenses: List.generate(
          10,
          (index) => makeExpense(
            id: 'expense_$index',
            label: 'Expense $index',
            category: 'category_$index',
            amount: 25 + index.toDouble(),
          ),
        ),
      );
      final goals = [
        makeSavingsGoal(id: 'goal_1', name: 'Emergency', isActive: true),
        makeSavingsGoal(id: 'goal_2', name: 'Trip', isActive: true),
        makeSavingsGoal(id: 'goal_3', name: 'Laptop', isActive: true),
      ];

      AppSettings? savedSettings;
      final pausedGoals = <SavingsGoal>[];

      final changed = await downgradeService.applyFreeTierLimits(
        settings: startingSettings,
        goals: goals,
        onSaveSettings: (updated) => savedSettings = updated,
        householdId: 'household-1',
        onSaveGoal: (goal, _) async => pausedGoals.add(goal),
      );

      expect(changed, isTrue);
      expect(savedSettings, isNotNull);
      expect(
        savedSettings!.expenses.where((expense) => expense.enabled),
        hasLength(8),
      );
      expect(pausedGoals.where((goal) => goal.isActive), isEmpty);
      expect(pausedGoals, hasLength(2));

      final body = NotificationService.buildTrialExpiryBody(
        daysBeforeExpiry: 10,
        activeCategories: DowngradeService.activeCategories(
          startingSettings.expenses,
        ),
        activeSavingsGoals: DowngradeService.activeSavingsGoals(goals),
        maxFreeCategories: DowngradeService.maxFreeCategories,
        maxFreeSavingsGoals: DowngradeService.maxFreeSavingsGoals,
      );

      expect(body, contains('2 categories'));
      expect(body, contains('2 savings goals'));

      final restored = await subscriptionService.load();
      expect(restored.tier, SubscriptionTier.free);
      expect(restored.trialUsed, isTrue);
    });
  });
}
