import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/services/revenuecat_service.dart';
import 'package:monthly_management/services/subscription_service.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('RevenueCatService.getRemoteTier — offline / unavailable guard', () {
    test('returns null in simulate mode (unknown, not free)', () async {
      // revenueCatSimulateMode is true in tests — must yield null, not free.
      final tier = await RevenueCatService.getRemoteTier();
      expect(tier, isNull,
          reason:
              'unavailable RC must return null so callers skip the sync, '
              'not downgrade to free');
    });
  });

  group('SubscriptionService.syncFromRemoteTier — downgrade guard', () {
    late SubscriptionService service;

    setUp(() => service = SubscriptionService());

    test('does NOT downgrade when remoteTier is null (unknown / offline)', () async {
      SharedPreferences.setMockInitialValues({});
      final premium = SubscriptionState(
        tier: SubscriptionTier.family,
        trialUsed: true,
        trialStartDate: DateTime(2026, 1, 1),
      );

      final result = await service.syncFromRemoteTier(premium, null);

      expect(result.tier, SubscriptionTier.family,
          reason: 'null remote tier = unknown; must keep existing premium tier');
      expect(result, same(premium),
          reason: 'no state change and no persistence should happen');
    });

    test('applies upgrade when remoteTier is non-free', () async {
      SharedPreferences.setMockInitialValues({});
      final freeTrial = SubscriptionState(
        tier: SubscriptionTier.free,
        trialUsed: false,
        trialStartDate: DateTime(2026, 1, 1),
      );

      final result = await service.syncFromRemoteTier(freeTrial, SubscriptionTier.family);

      expect(result.tier, SubscriptionTier.family);
      expect(result.trialUsed, isTrue);
    });

    test('applies downgrade when remoteTier is explicitly free', () async {
      SharedPreferences.setMockInitialValues({});
      final premium = SubscriptionState(
        tier: SubscriptionTier.family,
        trialUsed: true,
        trialStartDate: DateTime(2026, 1, 1),
      );

      final result = await service.syncFromRemoteTier(premium, SubscriptionTier.free);

      expect(result.tier, SubscriptionTier.free,
          reason: 'explicit confirmed free = real downgrade, must apply');
    });

    test('clears downgrade latch when syncing from free back to premium', () async {
      SharedPreferences.setMockInitialValues({
        'downgrade_applied': true, // latch set by a previous (possibly false) downgrade
      });
      final freeState = SubscriptionState(
        tier: SubscriptionTier.free,
        trialUsed: true,
        trialStartDate: DateTime(2026, 1, 1),
      );

      await service.syncFromRemoteTier(freeState, SubscriptionTier.family);

      final latchStillSet = await service.isDowngradeApplied();
      expect(latchStillSet, isFalse,
          reason:
              'when RC confirms premium, the downgrade latch must be cleared '
              'so categories/goals are re-enabled');
    });

    test('no-op when tier is already equal to remoteTier', () async {
      SharedPreferences.setMockInitialValues({});
      final premium = SubscriptionState(
        tier: SubscriptionTier.family,
        trialUsed: true,
        trialStartDate: DateTime(2026, 1, 1),
      );

      final result = await service.syncFromRemoteTier(premium, SubscriptionTier.family);

      expect(result, same(premium));
    });
  });
}
