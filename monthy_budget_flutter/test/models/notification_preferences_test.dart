import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/notification_preferences.dart';

void main() {
  group('CustomReminder', () {
    test('constructor with all fields', () {
      const r = CustomReminder(
        id: 'rem_1',
        title: 'Expenses',
        body: 'Log today',
        hour: 20,
        minute: 30,
        repeat: ReminderRepeat.daily,
        repeatDays: [1, 2, 3],
      );
      expect(r.id, 'rem_1');
      expect(r.title, 'Expenses');
      expect(r.body, 'Log today');
      expect(r.hour, 20);
      expect(r.minute, 30);
      expect(r.repeat, ReminderRepeat.daily);
      expect(r.repeatDays, [1, 2, 3]);
    });

    test('constructor defaults', () {
      const r = CustomReminder(id: 'rem_2', title: 'T', body: 'B');
      expect(r.hour, 9);
      expect(r.minute, 0);
      expect(r.repeat, ReminderRepeat.none);
      expect(r.repeatDays, isEmpty);
    });

    group('equality', () {
      test('equal with same fields', () {
        const a = CustomReminder(
          id: 'rem_1', title: 'T', body: 'B', hour: 10, minute: 30,
          repeat: ReminderRepeat.weekly,
        );
        const b = CustomReminder(
          id: 'rem_1', title: 'T', body: 'B', hour: 10, minute: 30,
          repeat: ReminderRepeat.weekly,
        );
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('not equal with different fields', () {
        const a = CustomReminder(id: 'rem_1', title: 'A', body: 'B');
        const b = CustomReminder(id: 'rem_1', title: 'X', body: 'B');
        expect(a, isNot(equals(b)));
      });
    });

    test('toJson / fromJson roundtrip', () {
      const original = CustomReminder(
        id: 'rem_rt',
        title: 'Bills',
        body: 'Pay bills',
        hour: 18,
        minute: 45,
        repeat: ReminderRepeat.monthly,
        repeatDays: [15],
      );
      final json = original.toJson();
      final restored = CustomReminder.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.body, original.body);
      expect(restored.hour, original.hour);
      expect(restored.minute, original.minute);
      expect(restored.repeat, original.repeat);
      expect(restored.repeatDays, original.repeatDays);
    });
  });

  group('NotificationPreferences', () {
    test('defaults', () {
      final prefs = NotificationPreferences();
      expect(prefs.dailyExpenseReminder, true);
      expect(prefs.billReminders, false);
      expect(prefs.billReminderDaysBefore, 1);
      expect(prefs.budgetAlerts, false);
      expect(prefs.budgetAlertThreshold, 80);
      expect(prefs.mealPlanReminders, false);
      expect(prefs.customReminders, isEmpty);
      expect(prefs.preferredHour, 9);
      expect(prefs.preferredMinute, 0);
    });

    group('equality', () {
      test('equal with same fields', () {
        final a = NotificationPreferences(
          dailyExpenseReminder: true,
          billReminders: true,
          billReminderDaysBefore: 3,
          budgetAlerts: true,
          budgetAlertThreshold: 90,
          mealPlanReminders: true,
          preferredHour: 20,
          preferredMinute: 15,
        );
        final b = NotificationPreferences(
          dailyExpenseReminder: true,
          billReminders: true,
          billReminderDaysBefore: 3,
          budgetAlerts: true,
          budgetAlertThreshold: 90,
          mealPlanReminders: true,
          preferredHour: 20,
          preferredMinute: 15,
        );
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('not equal when fields differ', () {
        final a = NotificationPreferences(budgetAlertThreshold: 80);
        final b = NotificationPreferences(budgetAlertThreshold: 90);
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('updates fields selectively', () {
        final original = NotificationPreferences(
          dailyExpenseReminder: true,
          budgetAlertThreshold: 80,
        );
        final copy = original.copyWith(
          dailyExpenseReminder: false,
          budgetAlertThreshold: 95,
          preferredHour: 21,
        );
        expect(copy.dailyExpenseReminder, false);
        expect(copy.budgetAlertThreshold, 95);
        expect(copy.preferredHour, 21);
        expect(copy.billReminders, original.billReminders);
      });

      test('preserves all fields when no args', () {
        final original = NotificationPreferences(
          billReminders: true,
          billReminderDaysBefore: 5,
          mealPlanReminders: true,
        );
        final copy = original.copyWith();
        expect(copy.billReminders, original.billReminders);
        expect(copy.billReminderDaysBefore, original.billReminderDaysBefore);
        expect(copy.mealPlanReminders, original.mealPlanReminders);
      });

      test('updates customReminders', () {
        final original = NotificationPreferences();
        const reminder = CustomReminder(id: 'r1', title: 'T', body: 'B');
        final copy = original.copyWith(customReminders: [reminder]);
        expect(copy.customReminders, hasLength(1));
        expect(copy.customReminders.first.id, 'r1');
      });
    });

    test('toJsonString / fromJsonString roundtrip', () {
      final original = NotificationPreferences(
        dailyExpenseReminder: false,
        billReminders: true,
        billReminderDaysBefore: 3,
        budgetAlerts: true,
        budgetAlertThreshold: 75,
        mealPlanReminders: true,
        preferredHour: 20,
        preferredMinute: 30,
        customReminders: const [
          CustomReminder(
            id: 'rem_1', title: 'Bills', body: 'Pay up',
            hour: 18, minute: 0, repeat: ReminderRepeat.weekly,
          ),
        ],
      );
      final jsonStr = original.toJsonString();
      final restored = NotificationPreferences.fromJsonString(jsonStr);
      expect(restored.dailyExpenseReminder, original.dailyExpenseReminder);
      expect(restored.billReminders, original.billReminders);
      expect(restored.billReminderDaysBefore, original.billReminderDaysBefore);
      expect(restored.budgetAlerts, original.budgetAlerts);
      expect(restored.budgetAlertThreshold, original.budgetAlertThreshold);
      expect(restored.mealPlanReminders, original.mealPlanReminders);
      expect(restored.preferredHour, original.preferredHour);
      expect(restored.preferredMinute, original.preferredMinute);
      expect(restored.customReminders, hasLength(1));
    });

    test('fromJson clamps budgetAlertThreshold to 0-100', () {
      final json = {
        'dailyExpenseReminder': true,
        'billReminders': false,
        'billReminderDaysBefore': 1,
        'budgetAlerts': false,
        'budgetAlertThreshold': 150,
        'mealPlanReminders': false,
        'customReminders': <dynamic>[],
        'preferredHour': 9,
        'preferredMinute': 0,
      };
      final prefs = NotificationPreferences.fromJson(json);
      expect(prefs.budgetAlertThreshold, 100);
    });

    test('fromJson with negative threshold clamps to 0', () {
      final json = {
        'dailyExpenseReminder': true,
        'billReminders': false,
        'billReminderDaysBefore': 1,
        'budgetAlerts': false,
        'budgetAlertThreshold': -10,
        'mealPlanReminders': false,
        'customReminders': <dynamic>[],
        'preferredHour': 9,
        'preferredMinute': 0,
      };
      final prefs = NotificationPreferences.fromJson(json);
      expect(prefs.budgetAlertThreshold, 0);
    });
  });
}
