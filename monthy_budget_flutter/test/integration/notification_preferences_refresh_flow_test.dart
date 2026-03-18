import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_management/models/notification_preferences.dart';
import 'package:monthly_management/services/local_config_service.dart';
import 'package:monthly_management/services/notification_service.dart';

void main() {
  late LocalConfigService localConfigService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    localConfigService = LocalConfigService();
  });

  group('notification preferences refresh flow', () {
    test('saved preferences produce the expected refresh decision', () async {
      final prefs = NotificationPreferences(
        billReminders: true,
        budgetAlerts: true,
        budgetAlertThreshold: 80,
        mealPlanReminders: true,
        dailyExpenseReminder: false,
        preferredHour: 18,
        preferredMinute: 45,
        customReminders: const [
          CustomReminder(
            id: 'water',
            title: 'Water',
            body: 'Hydrate',
            hour: 14,
            minute: 0,
            repeat: ReminderRepeat.daily,
          ),
        ],
      );

      await localConfigService.saveNotificationPreferences(prefs);
      final restored = await localConfigService.loadNotificationPreferences();

      final decision = NotificationService.buildRefreshDecision(
        prefs: restored,
        budgetUsagePercent: 85,
        hasMealPlan: false,
        topCategoryName: 'Food',
        topCategoryUsagePercent: 70,
      );

      expect(decision.scheduleBillReminders, isTrue);
      expect(decision.scheduleDailyExpenseReminder, isFalse);
      expect(decision.scheduleMealPlanReminder, isTrue);
      expect(decision.customReminderCount, 1);
      expect(decision.shouldShowBudgetAlert, isTrue);
      expect(decision.shouldResetBudgetAlertTrigger, isFalse);
      expect(decision.budgetAlertUsagePercent, 85);
      expect(decision.budgetAlertCategoryName, isNull);
    });

    test(
      'existing budget alerts are suppressed until spending drops',
      () async {
        final prefs = NotificationPreferences(
          budgetAlerts: true,
          budgetAlertThreshold: 75,
        );

        await localConfigService.saveNotificationPreferences(prefs);
        final restored = await localConfigService.loadNotificationPreferences();

        final suppressed = NotificationService.buildRefreshDecision(
          prefs: restored,
          budgetUsagePercent: 82,
          hasMealPlan: true,
          budgetAlertAlreadyTriggered: true,
        );
        expect(suppressed.shouldShowBudgetAlert, isFalse);
        expect(suppressed.shouldResetBudgetAlertTrigger, isFalse);

        final reset = NotificationService.buildRefreshDecision(
          prefs: restored,
          budgetUsagePercent: 50,
          hasMealPlan: true,
          budgetAlertAlreadyTriggered: true,
        );
        expect(reset.shouldShowBudgetAlert, isFalse);
        expect(reset.shouldResetBudgetAlertTrigger, isTrue);
      },
    );
  });
}
