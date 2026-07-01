import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/services/notification_service.dart';

void main() {
  group('NotificationService.trialReminderWouldFire', () {
    test('returns false when trialEndDate is null', () {
      expect(
        NotificationService.trialReminderWouldFire(null),
        isFalse,
      );
    });

    test('returns true when reminder date is in the future', () {
      final endDate = DateTime.now().add(const Duration(days: 15));
      expect(
        NotificationService.trialReminderWouldFire(endDate),
        isTrue,
      );
    });

    test('returns false when trial ends before daysBeforeExpiry threshold', () {
      final endDate = DateTime.now().add(const Duration(days: 5));
      expect(
        NotificationService.trialReminderWouldFire(endDate, daysBeforeExpiry: 10),
        isFalse,
      );
    });

    test('returns false when trial has already ended', () {
      final endDate = DateTime.now().subtract(const Duration(days: 2));
      expect(
        NotificationService.trialReminderWouldFire(endDate),
        isFalse,
      );
    });

    test('threshold is configurable via daysBeforeExpiry', () {
      final endDate = DateTime.now().add(const Duration(days: 2));
      expect(
        NotificationService.trialReminderWouldFire(endDate, daysBeforeExpiry: 1),
        isTrue,
      );
    });
  });

  group('NotificationService.buildTrialExpiryBody', () {
    test('shows excess categories and goals', () {
      final body = NotificationService.buildTrialExpiryBody(
        daysBeforeExpiry: 10,
        activeCategories: 12,
        activeSavingsGoals: 3,
        maxFreeCategories: 8,
        maxFreeSavingsGoals: 1,
      );
      expect(body,
          'Your trial ends in 10 days. 4 categories and 2 savings goals will be paused on the free plan.');
    });

    test('shows only excess categories', () {
      final body = NotificationService.buildTrialExpiryBody(
        daysBeforeExpiry: 10,
        activeCategories: 10,
        activeSavingsGoals: 1,
        maxFreeCategories: 8,
        maxFreeSavingsGoals: 1,
      );
      expect(body,
          'Your trial ends in 10 days. 2 categories will be paused on the free plan.');
    });

    test('shows only excess goals', () {
      final body = NotificationService.buildTrialExpiryBody(
        daysBeforeExpiry: 10,
        activeCategories: 5,
        activeSavingsGoals: 4,
        maxFreeCategories: 8,
        maxFreeSavingsGoals: 1,
      );
      expect(body,
          'Your trial ends in 10 days. 3 savings goals will be paused on the free plan.');
    });

    test('generic message when no excess items', () {
      final body = NotificationService.buildTrialExpiryBody(
        daysBeforeExpiry: 10,
        activeCategories: 5,
        activeSavingsGoals: 1,
        maxFreeCategories: 8,
        maxFreeSavingsGoals: 1,
      );
      expect(body,
          'Your trial ends in 10 days. Upgrade to keep all premium features.');
    });

    test('uses correct daysBeforeExpiry value', () {
      final body = NotificationService.buildTrialExpiryBody(
        daysBeforeExpiry: 3,
        activeCategories: 5,
        activeSavingsGoals: 1,
        maxFreeCategories: 8,
        maxFreeSavingsGoals: 1,
      );
      expect(body, contains('3 days'));
    });

    test('clamps excess to zero when under limits', () {
      final body = NotificationService.buildTrialExpiryBody(
        daysBeforeExpiry: 10,
        activeCategories: 0,
        activeSavingsGoals: 0,
        maxFreeCategories: 8,
        maxFreeSavingsGoals: 1,
      );
      expect(body, contains('Upgrade to keep all premium features'));
    });
  });
}
