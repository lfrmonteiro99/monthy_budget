import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/notification_preferences.dart';

void main() {
  group('NotificationPreferences', () {
    test('copyWith updates only provided fields', () {
      final prefs = NotificationPreferences(
        billReminders: false,
        billReminderDaysBefore: 1,
        budgetAlerts: false,
      );

      final updated = prefs.copyWith(
        billReminders: true,
        budgetAlertThreshold: 90,
      );

      expect(updated.billReminders, isTrue);
      expect(updated.billReminderDaysBefore, 1);
      expect(updated.budgetAlertThreshold, 90);
      expect(updated.budgetAlerts, isFalse);
    });

    test('serializes and deserializes custom reminders', () {
      final prefs = NotificationPreferences(
        billReminders: true,
        customReminders: [
          CustomReminder(
            id: 'r1',
            title: 'Pay rent',
            body: 'Due soon',
            hour: 8,
            minute: 30,
            repeat: ReminderRepeat.weekly,
            repeatDays: [1, 3, 5],
          ),
        ],
      );

      final decoded =
          NotificationPreferences.fromJsonString(prefs.toJsonString());

      expect(decoded.billReminders, isTrue);
      expect(decoded.customReminders.length, 1);
      expect(decoded.customReminders.first.repeat, ReminderRepeat.weekly);
      expect(decoded.customReminders.first.repeatDays, [1, 3, 5]);
    });

    test('preferred time defaults to 9:00 for backward compatibility', () {
      final json = '{"billReminders":true,"billReminderDaysBefore":2}';
      final prefs = NotificationPreferences.fromJsonString(json);

      expect(prefs.preferredHour, 9);
      expect(prefs.preferredMinute, 0);
    });

    test('preferred time roundtrips through serialization', () {
      final prefs = NotificationPreferences(
        preferredHour: 18,
        preferredMinute: 30,
      );

      final decoded =
          NotificationPreferences.fromJsonString(prefs.toJsonString());

      expect(decoded.preferredHour, 18);
      expect(decoded.preferredMinute, 30);
    });

    test('copyWith updates preferred time', () {
      final prefs = NotificationPreferences();
      final updated = prefs.copyWith(preferredHour: 20, preferredMinute: 15);

      expect(updated.preferredHour, 20);
      expect(updated.preferredMinute, 15);
      expect(updated.billReminders, isFalse); // unchanged
    });

    test('CustomReminder.fromJson falls back for unknown repeat value', () {
      final reminder = CustomReminder.fromJson(const {
        'id': 'x',
        'title': 'Title',
        'body': 'Body',
        'repeat': 'invalid_repeat',
      });

      expect(reminder.repeat, ReminderRepeat.none);
      expect(reminder.hour, 9);
      expect(reminder.minute, 0);
    });
  });
}
