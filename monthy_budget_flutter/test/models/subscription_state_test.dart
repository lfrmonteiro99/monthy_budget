import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/subscription_state.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('SubscriptionTier enum', () {
    test('has exactly 3 values', () {
      expect(SubscriptionTier.values.length, 3);
    });

    test('contains free, premium, family', () {
      expect(SubscriptionTier.values,
          containsAll([SubscriptionTier.free, SubscriptionTier.premium, SubscriptionTier.family]));
    });
  });

  group('PremiumFeature enum', () {
    test('has expected values', () {
      expect(PremiumFeature.values.length, 15);
      expect(PremiumFeature.values, contains(PremiumFeature.aiCoach));
      expect(PremiumFeature.values, contains(PremiumFeature.householdSharing));
      expect(PremiumFeature.values, contains(PremiumFeature.unlimitedSavingsGoals));
    });
  });

  group('featureTierRequirements', () {
    test('map has entry for every PremiumFeature', () {
      for (final feature in PremiumFeature.values) {
        expect(featureTierRequirements.containsKey(feature), true,
            reason: '${feature.name} should have a tier requirement');
      }
    });

    test('premium features map to premium tier', () {
      expect(featureTierRequirements[PremiumFeature.aiCoach], SubscriptionTier.premium);
      expect(featureTierRequirements[PremiumFeature.mealPlanner], SubscriptionTier.premium);
      expect(featureTierRequirements[PremiumFeature.exportData], SubscriptionTier.premium);
      expect(featureTierRequirements[PremiumFeature.noAds], SubscriptionTier.premium);
      expect(featureTierRequirements[PremiumFeature.expenseTrends], SubscriptionTier.premium);
      expect(featureTierRequirements[PremiumFeature.unlimitedSavingsGoals], SubscriptionTier.premium);
    });

    test('family features map to family tier', () {
      expect(featureTierRequirements[PremiumFeature.householdSharing], SubscriptionTier.family);
      expect(featureTierRequirements[PremiumFeature.taxSimulator], SubscriptionTier.family);
      expect(featureTierRequirements[PremiumFeature.stressIndex], SubscriptionTier.family);
      expect(featureTierRequirements[PremiumFeature.monthReview], SubscriptionTier.family);
      expect(featureTierRequirements[PremiumFeature.dashboardCustomization], SubscriptionTier.family);
      expect(featureTierRequirements[PremiumFeature.allThemes], SubscriptionTier.family);
    });
  });

  group('SubscriptionState', () {
    SubscriptionState makeState({
      SubscriptionTier tier = SubscriptionTier.free,
      DateTime? trialStartDate,
      bool trialUsed = false,
      Set<String> featuresExplored = const {},
    }) {
      return SubscriptionState(
        tier: tier,
        trialStartDate: trialStartDate ?? DateTime.now(),
        trialUsed: trialUsed,
        featuresExplored: featuresExplored,
      );
    }

    group('isTrialActive', () {
      test('true within 14 days of trial start', () {
        final state = makeState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 5)),
        );
        expect(state.isTrialActive, true);
      });

      test('true on day 0', () {
        final state = makeState(trialStartDate: DateTime.now());
        expect(state.isTrialActive, true);
      });

      test('false after 14 days', () {
        final state = makeState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 15)),
        );
        expect(state.isTrialActive, false);
      });

      test('false exactly at 14 days', () {
        final state = makeState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 14)),
        );
        expect(state.isTrialActive, false);
      });

      test('false when trialUsed is true regardless of date', () {
        final state = makeState(
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );
        expect(state.isTrialActive, false);
      });
    });

    group('trialDaysRemaining', () {
      test('returns correct remaining days', () {
        final state = makeState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 5)),
        );
        expect(state.trialDaysRemaining, 9);
      });

      test('returns 0 when expired', () {
        final state = makeState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 20)),
        );
        expect(state.trialDaysRemaining, 0);
      });

      test('returns 14 on day 0', () {
        final state = makeState(trialStartDate: DateTime.now());
        expect(state.trialDaysRemaining, 14);
      });

      test('returns 0 when trialUsed', () {
        final state = makeState(
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );
        expect(state.trialDaysRemaining, 0);
      });
    });

    group('hasPremiumAccess', () {
      test('true for premium tier', () {
        final state = makeState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(state.hasPremiumAccess, true);
      });

      test('true for family tier', () {
        final state = makeState(
          tier: SubscriptionTier.family,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(state.hasPremiumAccess, true);
      });

      test('true during active trial (free tier)', () {
        final state = makeState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now(),
        );
        expect(state.hasPremiumAccess, true);
      });

      test('false for free tier with expired trial', () {
        final state = makeState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(state.hasPremiumAccess, false);
      });
    });

    group('hasFamilyAccess', () {
      test('true for family tier', () {
        final state = makeState(
          tier: SubscriptionTier.family,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(state.hasFamilyAccess, true);
      });

      test('false for premium tier without trial', () {
        final state = makeState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(state.hasFamilyAccess, false);
      });

      test('true during active trial', () {
        final state = makeState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now(),
        );
        expect(state.hasFamilyAccess, true);
      });

      test('false for free tier with expired trial', () {
        final state = makeState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(state.hasFamilyAccess, false);
      });
    });

    group('canAccess', () {
      test('trial active grants access to all features', () {
        final state = makeState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now(),
        );

        for (final feature in PremiumFeature.values) {
          expect(state.canAccess(feature), true,
              reason: '${feature.name} should be accessible during trial');
        }
      });

      test('free tier without trial cannot access premium features', () {
        final state = makeState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        expect(state.canAccess(PremiumFeature.aiCoach), false);
        expect(state.canAccess(PremiumFeature.mealPlanner), false);
        expect(state.canAccess(PremiumFeature.noAds), false);
      });

      test('free tier without trial cannot access family features', () {
        final state = makeState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        expect(state.canAccess(PremiumFeature.householdSharing), false);
        expect(state.canAccess(PremiumFeature.taxSimulator), false);
      });

      test('premium tier can access premium features', () {
        final state = makeState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        expect(state.canAccess(PremiumFeature.aiCoach), true);
        expect(state.canAccess(PremiumFeature.mealPlanner), true);
        expect(state.canAccess(PremiumFeature.exportData), true);
        expect(state.canAccess(PremiumFeature.noAds), true);
      });

      test('premium tier cannot access family features', () {
        final state = makeState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        expect(state.canAccess(PremiumFeature.householdSharing), false);
        expect(state.canAccess(PremiumFeature.taxSimulator), false);
        expect(state.canAccess(PremiumFeature.stressIndex), false);
      });

      test('family tier can access all features', () {
        final state = makeState(
          tier: SubscriptionTier.family,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        for (final feature in PremiumFeature.values) {
          expect(state.canAccess(feature), true,
              reason: '${feature.name} should be accessible for family tier');
        }
      });
    });

    group('feature exploration', () {
      test('featuresExploredCount', () {
        final state = makeState(
          featuresExplored: {'dashboard', 'ai_coach', 'export'},
        );
        expect(state.featuresExploredCount, 3);
      });

      test('featuresExploredCount is 0 for empty set', () {
        final state = makeState();
        expect(state.featuresExploredCount, 0);
      });

      test('explorationProgress as fraction', () {
        final total = SubscriptionState.discoverableFeatures.length;
        final state = makeState(
          featuresExplored: {'dashboard', 'ai_coach'},
        );
        expect(state.explorationProgress, 2 / total);
      });

      test('explorationProgress is 0 for empty', () {
        final state = makeState();
        expect(state.explorationProgress, 0.0);
      });

      test('explorationProgress is 1.0 when all explored', () {
        final state = makeState(
          featuresExplored: SubscriptionState.discoverableFeatures.toSet(),
        );
        expect(state.explorationProgress, 1.0);
      });

      test('nextFeatureToDiscover returns first unexplored', () {
        final state = makeState(featuresExplored: {'dashboard'});
        expect(state.nextFeatureToDiscover, 'ai_coach');
      });

      test('nextFeatureToDiscover returns null when all explored', () {
        final state = makeState(
          featuresExplored: SubscriptionState.discoverableFeatures.toSet(),
        );
        expect(state.nextFeatureToDiscover, isNull);
      });

      test('nextFeatureToDiscover returns first when none explored', () {
        final state = makeState();
        expect(state.nextFeatureToDiscover, 'dashboard');
      });
    });

    group('copyWith', () {
      test('preserves all fields when no args', () {
        final original = makeState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime(2026, 1, 1),
          trialUsed: true,
          featuresExplored: {'dashboard'},
        );
        final copy = original.copyWith();

        expect(copy.tier, original.tier);
        expect(copy.trialStartDate, original.trialStartDate);
        expect(copy.trialUsed, original.trialUsed);
        expect(copy.featuresExplored, original.featuresExplored);
      });

      test('updates tier only', () {
        final original = makeState(tier: SubscriptionTier.free);
        final copy = original.copyWith(tier: SubscriptionTier.family);
        expect(copy.tier, SubscriptionTier.family);
      });

      test('updates featuresExplored', () {
        final original = makeState(featuresExplored: {'a'});
        final copy = original.copyWith(featuresExplored: {'a', 'b', 'c'});
        expect(copy.featuresExplored, {'a', 'b', 'c'});
      });
    });

    group('toJson / fromJson roundtrip', () {
      test('roundtrips correctly', () {
        final original = SubscriptionState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime(2026, 2, 1),
          trialUsed: true,
          featuresExplored: {'dashboard', 'ai_coach'},
        );

        final json = original.toJson();
        final restored = SubscriptionState.fromJson(json);

        expect(restored.tier, original.tier);
        expect(restored.trialStartDate, original.trialStartDate);
        expect(restored.trialUsed, original.trialUsed);
        expect(restored.featuresExplored, original.featuresExplored);
      });

      test('fromJson with missing fields uses defaults', () {
        final json = <String, dynamic>{};
        final state = SubscriptionState.fromJson(json);

        expect(state.tier, SubscriptionTier.free);
        expect(state.trialUsed, false);
        expect(state.featuresExplored, isEmpty);
      });

      test('fromJson with unknown tier defaults to free', () {
        final json = {
          'tier': 'unknown_tier',
          'trialStartDate': DateTime.now().toIso8601String(),
        };
        final state = SubscriptionState.fromJson(json);
        expect(state.tier, SubscriptionTier.free);
      });
    });

    group('fromJsonString / toJsonString roundtrip', () {
      test('roundtrips correctly', () {
        final original = SubscriptionState(
          tier: SubscriptionTier.family,
          trialStartDate: DateTime(2026, 3, 1),
          trialUsed: false,
          featuresExplored: {'meal_planner', 'savings_goals'},
        );

        final jsonStr = original.toJsonString();
        final restored = SubscriptionState.fromJsonString(jsonStr);

        expect(restored.tier, original.tier);
        expect(restored.trialStartDate, original.trialStartDate);
        expect(restored.trialUsed, original.trialUsed);
        expect(restored.featuresExplored, original.featuresExplored);
      });
    });

    test('trialUsed blocks trial even with fresh date', () {
      final state = SubscriptionState(
        tier: SubscriptionTier.free,
        trialStartDate: DateTime.now(),
        trialUsed: true,
      );

      expect(state.isTrialActive, false);
      expect(state.trialDaysRemaining, 0);
      expect(state.hasPremiumAccess, false);
      expect(state.canAccess(PremiumFeature.aiCoach), false);
    });
  });
}
