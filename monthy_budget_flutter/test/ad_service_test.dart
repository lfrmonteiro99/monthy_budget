import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/services/ad_service.dart';

void main() {
  group('AdService.shouldShowAds', () {
    setUp(() {
      AdService.setAdsAvailableForTesting(true);
    });

    tearDown(() {
      AdService.setAdsAvailableForTesting(false);
    });

    test('returns false during active trial', () {
      final state = SubscriptionState(
        trialStartDate: DateTime.now(),
      );
      expect(AdService.shouldShowAds(state), false);
    });

    test('returns true for free tier after trial', () {
      final state = SubscriptionState(
        trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      expect(AdService.shouldShowAds(state), true);
    });

    test('returns true for free tier with trialUsed', () {
      final state = SubscriptionState(
        trialStartDate: DateTime.now(),
        trialUsed: true,
      );
      expect(AdService.shouldShowAds(state), true);
    });

    test('returns false for premium tier', () {
      final state = SubscriptionState(
        tier: SubscriptionTier.premium,
        trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        trialUsed: true,
      );
      expect(AdService.shouldShowAds(state), false);
    });

    test('returns false for family tier', () {
      final state = SubscriptionState(
        tier: SubscriptionTier.family,
        trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        trialUsed: true,
      );
      expect(AdService.shouldShowAds(state), false);
    });

    test('returns false when ads not available', () {
      AdService.setAdsAvailableForTesting(false);
      final state = SubscriptionState(
        trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        trialUsed: true,
      );
      expect(AdService.shouldShowAds(state), false);
    });
  });
}
