import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/subscription_state.dart';

void main() {
  group('SubscriptionTier enum', () {
    test('has exactly 3 values', () {
      expect(SubscriptionTier.values.length, 3);
    });

    test('contains free, premium, family', () {
      expect(SubscriptionTier.values,
          containsAll([SubscriptionTier.free, SubscriptionTier.premium, SubscriptionTier.family]));
    });

    test('.name returns expected serialization strings', () {
      expect(SubscriptionTier.free.name, 'free');
      expect(SubscriptionTier.premium.name, 'premium');
      expect(SubscriptionTier.family.name, 'family');
    });

    test('index order is free < premium < family', () {
      expect(SubscriptionTier.free.index, lessThan(SubscriptionTier.premium.index));
      expect(SubscriptionTier.premium.index, lessThan(SubscriptionTier.family.index));
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

  group('CoachMode enum', () {
    test('contains eco, plus, pro', () {
      expect(
        CoachMode.values,
        containsAll([CoachMode.eco, CoachMode.plus, CoachMode.pro]),
      );
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
      expect(featureTierRequirements[PremiumFeature.unlimitedCategories], SubscriptionTier.premium);
      expect(featureTierRequirements[PremiumFeature.billReminders], SubscriptionTier.premium);
      expect(featureTierRequirements[PremiumFeature.shoppingListSync], SubscriptionTier.premium);
      expect(featureTierRequirements[PremiumFeature.noAds], SubscriptionTier.premium);
      expect(featureTierRequirements[PremiumFeature.expenseTrends], SubscriptionTier.premium);
      expect(featureTierRequirements[PremiumFeature.unlimitedSavingsGoals], SubscriptionTier.premium);
    });

    test('has exactly 9 premium and 6 family features', () {
      final premiumCount = featureTierRequirements.values
          .where((t) => t == SubscriptionTier.premium)
          .length;
      final familyCount = featureTierRequirements.values
          .where((t) => t == SubscriptionTier.family)
          .length;
      expect(premiumCount, 9);
      expect(familyCount, 6);
      expect(premiumCount + familyCount, PremiumFeature.values.length);
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

  group('constants', () {
    test('trialDays is 21', () {
      expect(SubscriptionState.trialDays, 21);
    });

    test('trialExtensionDays is 7', () {
      expect(SubscriptionState.trialExtensionDays, 7);
    });

    test('discoverableFeatures has 9 entries in expected order', () {
      expect(SubscriptionState.discoverableFeatures, [
        'dashboard',
        'ai_coach',
        'meal_planner',
        'expense_tracker',
        'savings_goals',
        'shopping_list',
        'grocery_browser',
        'export',
        'tax_simulator',
      ]);
    });
  });

  group('SubscriptionState', () {
    SubscriptionState makeState({
      SubscriptionTier tier = SubscriptionTier.free,
      DateTime? trialStartDate,
      bool trialUsed = false,
      Set<String> featuresExplored = const {},
      int aiCredits = 0,
      CoachMode preferredCoachMode = CoachMode.plus,
    }) {
      return SubscriptionState(
        tier: tier,
        trialStartDate: trialStartDate ?? DateTime.now(),
        trialUsed: trialUsed,
        featuresExplored: featuresExplored,
        aiCredits: aiCredits,
        preferredCoachMode: preferredCoachMode,
      );
    }

    group('constructor defaults', () {
      test('tier defaults to free', () {
        final state = SubscriptionState(trialStartDate: DateTime.now());
        expect(state.tier, SubscriptionTier.free);
      });

      test('trialUsed defaults to false', () {
        final state = SubscriptionState(trialStartDate: DateTime.now());
        expect(state.trialUsed, false);
      });

      test('featuresExplored defaults to empty set', () {
        final state = SubscriptionState(trialStartDate: DateTime.now());
        expect(state.featuresExplored, isEmpty);
        expect(state.featuresExplored, isA<Set<String>>());
      });
    });

    group('tier hierarchy invariant', () {
      test('hasFamilyAccess implies hasPremiumAccess for family tier', () {
        final state = makeState(
          tier: SubscriptionTier.family,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(state.hasFamilyAccess, true);
        expect(state.hasPremiumAccess, true);
      });

      test('hasFamilyAccess implies hasPremiumAccess during trial', () {
        final state = makeState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now(),
        );
        expect(state.hasFamilyAccess, true);
        expect(state.hasPremiumAccess, true);
      });

      test('hasPremiumAccess does NOT imply hasFamilyAccess for premium tier', () {
        final state = makeState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(state.hasPremiumAccess, true);
        expect(state.hasFamilyAccess, false);
      });

      test('invariant holds for all tiers: hasFamilyAccess → hasPremiumAccess', () {
        for (final tier in SubscriptionTier.values) {
          final state = makeState(
            tier: tier,
            trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
            trialUsed: true,
          );
          if (state.hasFamilyAccess) {
            expect(state.hasPremiumAccess, true,
                reason: '${tier.name}: hasFamilyAccess should imply hasPremiumAccess');
          }
        }
      });
    });

    group('justDowngraded', () {
      test('true when trialUsed and free tier', () {
        final state = makeState(
          tier: SubscriptionTier.free,
          trialUsed: true,
        );
        expect(state.justDowngraded, true);
      });

      test('false when trialUsed but premium tier', () {
        final state = makeState(
          tier: SubscriptionTier.premium,
          trialUsed: true,
        );
        expect(state.justDowngraded, false);
      });

      test('false when trial not used', () {
        final state = makeState(
          tier: SubscriptionTier.free,
          trialUsed: false,
        );
        expect(state.justDowngraded, false);
      });

      test('false during active trial', () {
        final state = makeState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now(),
          trialUsed: false,
        );
        expect(state.justDowngraded, false);
      });
    });

    group('isTrialActive', () {
      test('true within 21 days of trial start', () {
        final state = makeState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 5)),
        );
        expect(state.isTrialActive, true);
      });

      test('true on day 0', () {
        final state = makeState(trialStartDate: DateTime.now());
        expect(state.isTrialActive, true);
      });

      test('false after 21 days', () {
        final state = makeState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 22)),
        );
        expect(state.isTrialActive, false);
      });

      test('true on day 20 (last active day)', () {
        final state = makeState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 20)),
        );
        expect(state.isTrialActive, true);
      });

      test('false exactly at 21 days', () {
        final state = makeState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 21)),
        );
        expect(state.isTrialActive, false);
      });

      test('true for paid tier with active trial window', () {
        final state = makeState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now(),
        );
        expect(state.isTrialActive, true);
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
        expect(state.trialDaysRemaining, 16);
      });

      test('returns 0 when expired', () {
        final state = makeState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 25)),
        );
        expect(state.trialDaysRemaining, 0);
      });

      test('returns 21 on day 0', () {
        final state = makeState(trialStartDate: DateTime.now());
        expect(state.trialDaysRemaining, 21);
      });

      test('returns 0 when trialUsed', () {
        final state = makeState(
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );
        expect(state.trialDaysRemaining, 0);
      });

      test('clamps to max 21 even with future trialStartDate', () {
        final state = makeState(
          trialStartDate: DateTime.now().add(const Duration(days: 5)),
        );
        // remaining = 21 - (-5) = 26, clamped to 21
        expect(state.trialDaysRemaining, 21);
      });

      test('returns 1 on day 20', () {
        final state = makeState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 20)),
        );
        expect(state.trialDaysRemaining, 1);
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

      test('true for premium tier even when trialUsed', () {
        final state = makeState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
          trialUsed: true,
        );
        expect(state.hasPremiumAccess, true);
      });

      test('true for family tier even when trialUsed', () {
        final state = makeState(
          tier: SubscriptionTier.family,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
          trialUsed: true,
        );
        expect(state.hasPremiumAccess, true);
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

      test('true for family tier even when trialUsed', () {
        final state = makeState(
          tier: SubscriptionTier.family,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
          trialUsed: true,
        );
        expect(state.hasFamilyAccess, true);
      });

      test('false for premium tier even when trialUsed', () {
        final state = makeState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
          trialUsed: true,
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

      test('exhaustive: premium tier accesses all premium but no family features', () {
        final state = makeState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        for (final feature in PremiumFeature.values) {
          final required = featureTierRequirements[feature]!;
          if (required == SubscriptionTier.premium) {
            expect(state.canAccess(feature), true,
                reason: '${feature.name} should be accessible for premium tier');
          } else if (required == SubscriptionTier.family) {
            expect(state.canAccess(feature), false,
                reason: '${feature.name} should NOT be accessible for premium tier');
          }
        }
      });

      test('exhaustive: free tier (no trial) accesses no premium/family features', () {
        final state = makeState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        for (final feature in PremiumFeature.values) {
          expect(state.canAccess(feature), false,
              reason: '${feature.name} should NOT be accessible for free tier without trial');
        }
      });

      test('canAccess with trialUsed still allows paid tier features', () {
        final state = makeState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );

        expect(state.canAccess(PremiumFeature.aiCoach), true);
        expect(state.canAccess(PremiumFeature.exportData), true);
        // But not family features
        expect(state.canAccess(PremiumFeature.householdSharing), false);
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

      test('nextFeatureToDiscover skips explored and returns first gap', () {
        // Explored dashboard and meal_planner but NOT ai_coach
        final state = makeState(
          featuresExplored: {'dashboard', 'meal_planner'},
        );
        expect(state.nextFeatureToDiscover, 'ai_coach');
      });

      test('features outside discoverableFeatures do not affect progress', () {
        final state = makeState(
          featuresExplored: {'unknown_feature', 'another_unknown'},
        );
        // Count includes unknown features but progress is capped by discoverableFeatures.length
        expect(state.featuresExploredCount, 2);
        expect(state.explorationProgress, 2 / SubscriptionState.discoverableFeatures.length);
        // nextFeatureToDiscover still returns first discoverable
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

      test('updates trialStartDate only', () {
        final original = makeState(
          trialStartDate: DateTime(2026, 1, 1),
          tier: SubscriptionTier.premium,
        );
        final copy = original.copyWith(trialStartDate: DateTime(2026, 6, 15));
        expect(copy.trialStartDate, DateTime(2026, 6, 15));
        expect(copy.tier, SubscriptionTier.premium);
      });

      test('updates trialUsed only', () {
        final original = makeState(trialUsed: false);
        final copy = original.copyWith(trialUsed: true);
        expect(copy.trialUsed, true);
        expect(copy.tier, original.tier);
      });

      test('does not mutate original', () {
        final original = makeState(
          tier: SubscriptionTier.free,
          featuresExplored: {'dashboard'},
        );
        original.copyWith(
          tier: SubscriptionTier.family,
          featuresExplored: {'dashboard', 'ai_coach', 'export'},
        );
        expect(original.tier, SubscriptionTier.free);
        expect(original.featuresExplored, {'dashboard'});
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

      test('toJson produces expected keys and types', () {
        final state = SubscriptionState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime(2026, 3, 1),
          trialUsed: true,
          featuresExplored: {'dashboard'},
          aiCredits: 120,
          preferredCoachMode: CoachMode.pro,
        );

        final json = state.toJson();

        expect(json['tier'], 'premium');
        expect(json['trialStartDate'], isA<String>());
        expect(json['trialUsed'], true);
        expect(json['featuresExplored'], isA<List>());
        expect(json['featuresExplored'], contains('dashboard'));
        expect(json['aiCredits'], 120);
        expect(json['preferredCoachMode'], 'pro');
        expect(json['trialStarterCreditsGranted'], false);
        expect(json['trialExtensionUsed'], false);
        expect(json.keys.length, 8);
      });

      test('fromJson with empty featuresExplored list', () {
        final json = {
          'tier': 'free',
          'trialStartDate': DateTime.now().toIso8601String(),
          'trialUsed': false,
          'featuresExplored': <dynamic>[],
        };
        final state = SubscriptionState.fromJson(json);
        expect(state.featuresExplored, isEmpty);
        expect(state.aiCredits, 0);
        expect(state.preferredCoachMode, CoachMode.plus);
        expect(state.trialStarterCreditsGranted, false);
      });

      test('fromJson with null featuresExplored', () {
        final json = {
          'tier': 'premium',
          'trialStartDate': DateTime.now().toIso8601String(),
          'trialUsed': true,
          'featuresExplored': null,
        };
        final state = SubscriptionState.fromJson(json);
        expect(state.featuresExplored, isEmpty);
        expect(state.aiCredits, 0);
        expect(state.preferredCoachMode, CoachMode.plus);
        expect(state.trialStarterCreditsGranted, false);
      });

      test('fromJson with null trialUsed defaults to false', () {
        final json = {
          'tier': 'free',
          'trialStartDate': DateTime.now().toIso8601String(),
          'trialUsed': null,
        };
        final state = SubscriptionState.fromJson(json);
        expect(state.trialUsed, false);
      });

      test('roundtrips all three tiers correctly', () {
        for (final tier in SubscriptionTier.values) {
          final original = SubscriptionState(
            tier: tier,
            trialStartDate: DateTime(2026, 1, 1),
          );
          final restored = SubscriptionState.fromJson(original.toJson());
          expect(restored.tier, tier, reason: '${tier.name} should roundtrip');
        }
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

    group('access after tier transitions (via copyWith)', () {
      test('free → premium: gains premium features, still no family', () {
        final expired = DateTime.now().subtract(const Duration(days: 30));
        final free = makeState(
          tier: SubscriptionTier.free,
          trialStartDate: expired,
          trialUsed: true,
        );
        expect(free.canAccess(PremiumFeature.aiCoach), false);
        expect(free.canAccess(PremiumFeature.householdSharing), false);

        final premium = free.copyWith(tier: SubscriptionTier.premium);
        expect(premium.canAccess(PremiumFeature.aiCoach), true);
        expect(premium.canAccess(PremiumFeature.householdSharing), false);
      });

      test('premium → family: gains family features', () {
        final expired = DateTime.now().subtract(const Duration(days: 30));
        final premium = makeState(
          tier: SubscriptionTier.premium,
          trialStartDate: expired,
          trialUsed: true,
        );
        expect(premium.canAccess(PremiumFeature.aiCoach), true);
        expect(premium.canAccess(PremiumFeature.householdSharing), false);

        final family = premium.copyWith(tier: SubscriptionTier.family);
        expect(family.canAccess(PremiumFeature.aiCoach), true);
        expect(family.canAccess(PremiumFeature.householdSharing), true);
      });

      test('family → free: loses all gated features', () {
        final expired = DateTime.now().subtract(const Duration(days: 30));
        final family = makeState(
          tier: SubscriptionTier.family,
          trialStartDate: expired,
          trialUsed: true,
        );
        expect(family.canAccess(PremiumFeature.aiCoach), true);
        expect(family.canAccess(PremiumFeature.householdSharing), true);

        final free = family.copyWith(tier: SubscriptionTier.free);
        expect(free.canAccess(PremiumFeature.aiCoach), false);
        expect(free.canAccess(PremiumFeature.householdSharing), false);
      });

      test('full cycle: free → premium → family → free', () {
        final expired = DateTime.now().subtract(const Duration(days: 30));
        var state = makeState(
          tier: SubscriptionTier.free,
          trialStartDate: expired,
          trialUsed: true,
        );

        // free: no access
        for (final f in PremiumFeature.values) {
          expect(state.canAccess(f), false, reason: 'free: ${f.name}');
        }

        // → premium
        state = state.copyWith(tier: SubscriptionTier.premium);
        for (final f in PremiumFeature.values) {
          final req = featureTierRequirements[f]!;
          if (req == SubscriptionTier.premium) {
            expect(state.canAccess(f), true, reason: 'premium: ${f.name}');
          } else {
            expect(state.canAccess(f), false, reason: 'premium: ${f.name}');
          }
        }

        // → family
        state = state.copyWith(tier: SubscriptionTier.family);
        for (final f in PremiumFeature.values) {
          expect(state.canAccess(f), true, reason: 'family: ${f.name}');
        }

        // → free again
        state = state.copyWith(tier: SubscriptionTier.free);
        for (final f in PremiumFeature.values) {
          expect(state.canAccess(f), false, reason: 'free again: ${f.name}');
        }
      });

      test('canAccess is idempotent (calling multiple times gives same result)', () {
        final state = makeState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
          trialUsed: true,
        );

        final first = state.canAccess(PremiumFeature.aiCoach);
        final second = state.canAccess(PremiumFeature.aiCoach);
        final third = state.canAccess(PremiumFeature.aiCoach);

        expect(first, true);
        expect(second, true);
        expect(third, true);
      });
    });

    group('trial extension', () {
      test('effectiveTrialDays is 21 without extension', () {
        final state = makeState();
        expect(state.effectiveTrialDays, 21);
      });

      test('effectiveTrialDays is 28 with extension', () {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 21)),
          trialExtensionUsed: true,
        );
        expect(state.effectiveTrialDays, 28);
      });

      test('isTrialActive true during extension period', () {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 23)),
          trialExtensionUsed: true,
        );
        expect(state.isTrialActive, true);
      });

      test('isTrialActive false after extension period', () {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 29)),
          trialExtensionUsed: true,
        );
        expect(state.isTrialActive, false);
      });

      test('trialDaysRemaining accounts for extension', () {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 23)),
          trialExtensionUsed: true,
        );
        expect(state.trialDaysRemaining, 5);
      });

      test('canExtendTrial true when trial expired and extension not used', () {
        final state = makeState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 22)),
        );
        expect(state.canExtendTrial, true);
      });

      test('canExtendTrial false when extension already used', () {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 22)),
          trialExtensionUsed: true,
        );
        expect(state.canExtendTrial, false);
      });

      test('canExtendTrial false when trial still active', () {
        final state = makeState(
          trialStartDate: DateTime.now(),
        );
        expect(state.canExtendTrial, false);
      });

      test('canExtendTrial false when trialUsed', () {
        final state = makeState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 22)),
          trialUsed: true,
        );
        expect(state.canExtendTrial, false);
      });

      test('trialExtensionUsed roundtrips through JSON', () {
        final original = SubscriptionState(
          trialStartDate: DateTime(2026, 1, 1),
          trialExtensionUsed: true,
        );
        final restored = SubscriptionState.fromJson(original.toJson());
        expect(restored.trialExtensionUsed, true);
      });

      test('trialExtensionUsed defaults to false in fromJson', () {
        final json = {
          'tier': 'free',
          'trialStartDate': DateTime.now().toIso8601String(),
        };
        final state = SubscriptionState.fromJson(json);
        expect(state.trialExtensionUsed, false);
      });
    });

    group('coach mode resolution', () {
      test('uses requested premium mode when credits are sufficient', () {
        final state = makeState(aiCredits: 10, preferredCoachMode: CoachMode.plus);
        final resolution = state.resolveCoachMode(requestedMode: CoachMode.pro);

        expect(resolution.requestedMode, CoachMode.pro);
        expect(resolution.effectiveMode, CoachMode.pro);
        expect(resolution.usedFallback, false);
        expect(resolution.estimatedCreditCost, 5);
      });

      test('falls back to eco when credits are insufficient', () {
        final state = makeState(aiCredits: 1, preferredCoachMode: CoachMode.pro);
        final resolution = state.resolveCoachMode(requestedMode: CoachMode.pro);

        expect(resolution.effectiveMode, CoachMode.eco);
        expect(resolution.usedFallback, true);
        expect(resolution.reason, 'insufficient_credits');
        expect(resolution.estimatedCreditCost, 0);
      });

      test('eco always costs zero', () {
        final state = makeState(aiCredits: 0, preferredCoachMode: CoachMode.pro);
        final resolution = state.resolveCoachMode(requestedMode: CoachMode.eco);

        expect(resolution.effectiveMode, CoachMode.eco);
        expect(resolution.usedFallback, false);
        expect(resolution.estimatedCreditCost, 0);
      });
    });
  });
}
