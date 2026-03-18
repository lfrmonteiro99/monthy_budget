import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/services/subscription_service.dart';

void main() {
  late SubscriptionService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = SubscriptionService();
  });

  group('subscription feature gating flow', () {
    test('trial bootstrap unlocks premium and family features', () async {
      final state = await service.load();

      expect(state.isTrialActive, isTrue);
      expect(state.canAccess(PremiumFeature.aiCoach), isTrue);
      expect(state.canAccess(PremiumFeature.taxSimulator), isTrue);
      expect(state.canAccess(PremiumFeature.unlimitedSavingsGoals), isTrue);
    });

    test('upgrade and downgrade transitions change gated access', () async {
      var state = await service.load();

      state = await service.upgradeTo(state, SubscriptionTier.premium);
      expect(state.canAccess(PremiumFeature.aiCoach), isTrue);
      expect(state.canAccess(PremiumFeature.taxSimulator), isFalse);

      state = await service.upgradeTo(state, SubscriptionTier.family);
      expect(state.canAccess(PremiumFeature.taxSimulator), isTrue);
      expect(state.canAccess(PremiumFeature.householdSharing), isTrue);

      state = await service.downgrade(state);
      expect(state.canAccess(PremiumFeature.aiCoach), isFalse);
      expect(state.canAccess(PremiumFeature.taxSimulator), isFalse);

      final restored = await service.load();
      expect(restored.tier, SubscriptionTier.free);
      expect(restored.trialUsed, isTrue);
      expect(restored.canAccess(PremiumFeature.mealPlanner), isFalse);
    });
  });
}
