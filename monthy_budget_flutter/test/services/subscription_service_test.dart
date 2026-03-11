import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orcamento_mensal/models/subscription_state.dart';
import 'package:orcamento_mensal/services/subscription_service.dart';

void main() {
  late SubscriptionService service;

  setUp(() {
    service = SubscriptionService();
  });

  group('SubscriptionService', () {
    group('load()', () {
      test('first launch creates new trial with trialStartDate ≈ now', () async {
        SharedPreferences.setMockInitialValues({});

        final state = await service.load();

        expect(state.tier, SubscriptionTier.free);
        expect(state.trialUsed, false);
        expect(state.featuresExplored, isEmpty);
        expect(state.isTrialActive, true);
        // trialStartDate should be within a few seconds of now
        expect(
          DateTime.now().difference(state.trialStartDate).inSeconds.abs(),
          lessThan(5),
        );
      });

      test('first launch persists the initial state', () async {
        SharedPreferences.setMockInitialValues({});

        await service.load();

        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getString('subscription_state');
        expect(stored, isNotNull);

        final restored = SubscriptionState.fromJsonString(stored!);
        expect(restored.tier, SubscriptionTier.free);
        expect(restored.isTrialActive, true);
      });

      test('subsequent launch deserializes existing state', () async {
        final existing = SubscriptionState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime(2026, 1, 1),
          trialUsed: true,
          featuresExplored: {'dashboard', 'ai_coach'},
        );
        SharedPreferences.setMockInitialValues({
          'subscription_state': existing.toJsonString(),
        });

        final state = await service.load();

        expect(state.tier, SubscriptionTier.premium);
        expect(state.trialUsed, true);
        expect(state.trialStartDate, DateTime(2026, 1, 1));
        expect(state.featuresExplored, {'dashboard', 'ai_coach'});
      });
    });

    group('save()', () {
      test('persists state to SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        final state = SubscriptionState(
          tier: SubscriptionTier.family,
          trialStartDate: DateTime(2026, 2, 15),
          trialUsed: true,
          featuresExplored: {'export', 'tax_simulator'},
        );

        await service.save(state);

        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getString('subscription_state');
        expect(stored, isNotNull);

        final restored = SubscriptionState.fromJsonString(stored!);
        expect(restored.tier, SubscriptionTier.family);
        expect(restored.trialUsed, true);
        expect(restored.trialStartDate, DateTime(2026, 2, 15));
        expect(restored.featuresExplored, {'export', 'tax_simulator'});
      });

      test('overwrites previous state', () async {
        final first = SubscriptionState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime(2026, 1, 1),
        );
        SharedPreferences.setMockInitialValues({
          'subscription_state': first.toJsonString(),
        });

        final updated = first.copyWith(tier: SubscriptionTier.premium);
        await service.save(updated);

        final prefs = await SharedPreferences.getInstance();
        final restored = SubscriptionState.fromJsonString(
          prefs.getString('subscription_state')!,
        );
        expect(restored.tier, SubscriptionTier.premium);
      });
    });

    group('markFeatureExplored()', () {
      test('adds new feature to explored set', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          featuresExplored: {'dashboard'},
        );

        final updated = await service.markFeatureExplored(state, 'ai_coach');

        expect(updated.featuresExplored, {'dashboard', 'ai_coach'});
      });

      test('returns same state if feature already explored', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          featuresExplored: {'dashboard', 'ai_coach'},
        );

        final updated = await service.markFeatureExplored(state, 'ai_coach');

        expect(identical(updated, state), true);
      });

      test('persists updated explored set', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          featuresExplored: {},
        );

        await service.markFeatureExplored(state, 'meal_planner');

        final prefs = await SharedPreferences.getInstance();
        final restored = SubscriptionState.fromJsonString(
          prefs.getString('subscription_state')!,
        );
        expect(restored.featuresExplored, contains('meal_planner'));
      });

      test('preserves all other fields', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime(2026, 2, 1),
          trialUsed: true,
          featuresExplored: {'dashboard'},
        );

        final updated = await service.markFeatureExplored(state, 'export');

        expect(updated.tier, SubscriptionTier.premium);
        expect(updated.trialStartDate, DateTime(2026, 2, 1));
        expect(updated.trialUsed, true);
      });
    });

    group('upgradeTo()', () {
      test('sets tier to premium and marks trialUsed', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        final updated =
            await service.upgradeTo(state, SubscriptionTier.premium);

        expect(updated.tier, SubscriptionTier.premium);
        expect(updated.trialUsed, true);
      });

      test('sets tier to family and marks trialUsed', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        final updated =
            await service.upgradeTo(state, SubscriptionTier.family);

        expect(updated.tier, SubscriptionTier.family);
        expect(updated.trialUsed, true);
      });

      test('persists upgraded state', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await service.upgradeTo(state, SubscriptionTier.premium);

        final prefs = await SharedPreferences.getInstance();
        final restored = SubscriptionState.fromJsonString(
          prefs.getString('subscription_state')!,
        );
        expect(restored.tier, SubscriptionTier.premium);
        expect(restored.trialUsed, true);
      });

      test('preserves featuresExplored and trialStartDate', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime(2026, 2, 1),
          featuresExplored: {'dashboard', 'ai_coach'},
        );

        final updated =
            await service.upgradeTo(state, SubscriptionTier.premium);

        expect(updated.trialStartDate, DateTime(2026, 2, 1));
        expect(updated.featuresExplored, {'dashboard', 'ai_coach'});
      });
    });

    group('downgrade()', () {
      test('sets tier to free and marks trialUsed', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );

        final updated = await service.downgrade(state);

        expect(updated.tier, SubscriptionTier.free);
        expect(updated.trialUsed, true);
      });

      test('persists downgraded state', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.family,
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );

        await service.downgrade(state);

        final prefs = await SharedPreferences.getInstance();
        final restored = SubscriptionState.fromJsonString(
          prefs.getString('subscription_state')!,
        );
        expect(restored.tier, SubscriptionTier.free);
        expect(restored.trialUsed, true);
      });

      test('trial remains used after downgrade (no re-trial)', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );

        final updated = await service.downgrade(state);

        expect(updated.isTrialActive, false);
        expect(updated.hasPremiumAccess, false);
      });

      test('preserves featuresExplored', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now(),
          trialUsed: true,
          featuresExplored: {'dashboard', 'export', 'ai_coach'},
        );

        final updated = await service.downgrade(state);

        expect(updated.featuresExplored, {'dashboard', 'export', 'ai_coach'});
      });
    });

    group('coach credits and mode', () {
      test('setPreferredCoachMode persists selected mode', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          preferredCoachMode: CoachMode.plus,
        );

        final updated = await service.setPreferredCoachMode(state, CoachMode.pro);
        expect(updated.preferredCoachMode, CoachMode.pro);

        final prefs = await SharedPreferences.getInstance();
        final restored = SubscriptionState.fromJsonString(
          prefs.getString('subscription_state')!,
        );
        expect(restored.preferredCoachMode, CoachMode.pro);
      });

      test('addAiCredits increases balance', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          aiCredits: 3,
        );

        final updated = await service.addAiCredits(state, 10);
        expect(updated.aiCredits, 13);
      });

      test('consumeAiCredits never goes below zero', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          aiCredits: 2,
        );

        final updated = await service.consumeAiCredits(state, 10);
        expect(updated.aiCredits, 0);
      });

      test('resolveAndConsumeCoachMode falls back to eco without debiting', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          aiCredits: 1,
          preferredCoachMode: CoachMode.pro,
        );

        final result = await service.resolveAndConsumeCoachMode(
          state,
          requestedMode: CoachMode.pro,
        );
        expect(result.resolution.effectiveMode, CoachMode.eco);
        expect(result.state.aiCredits, 1);
      });

      test('resolveAndConsumeCoachMode debits credits in plus/pro', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          aiCredits: 10,
          preferredCoachMode: CoachMode.plus,
        );

        final result = await service.resolveAndConsumeCoachMode(
          state,
          requestedMode: CoachMode.plus,
        );
        expect(result.resolution.effectiveMode, CoachMode.plus);
        expect(result.state.aiCredits, 8);
      });
    });

    group('credit cap (Feature #6)', () {
      test('addAiCredits caps at 150', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          aiCredits: 100,
        );

        final updated = await service.addAiCredits(state, 100);
        expect(updated.aiCredits, 150);
      });

      test('addAiCredits resets downgradeCardShown', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          aiCredits: 10,
          downgradeCardShown: true,
        );

        final updated = await service.addAiCredits(state, 5);
        expect(updated.downgradeCardShown, false);
      });

      test('addAiCredits does not exceed cap from zero', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          aiCredits: 0,
        );

        final updated = await service.addAiCredits(state, 200);
        expect(updated.aiCredits, 150);
      });

      test('addAiCredits allows exact cap', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          aiCredits: 100,
        );

        final updated = await service.addAiCredits(state, 50);
        expect(updated.aiCredits, 150);
      });
    });

    group('markDowngradeCardShown (Feature #1)', () {
      test('sets downgradeCardShown to true', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        final updated = await service.markDowngradeCardShown(state);
        expect(updated.downgradeCardShown, true);
      });

      test('persists the change', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await service.markDowngradeCardShown(state);

        final prefs = await SharedPreferences.getInstance();
        final restored = SubscriptionState.fromJsonString(
          prefs.getString('subscription_state')!,
        );
        expect(restored.downgradeCardShown, true);
      });
    });

    group('incrementConversationCount (Feature #2)', () {
      test('increments coachConversationCount', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          coachConversationCount: 0,
        );

        final updated = await service.incrementConversationCount(state);
        expect(updated.coachConversationCount, 1);
        expect(updated.endowmentPlusCompleted, false);
      });

      test('sets endowmentPlusCompleted when reaching 3', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          coachConversationCount: 2,
        );

        final updated = await service.incrementConversationCount(state);
        expect(updated.coachConversationCount, 3);
        expect(updated.endowmentPlusCompleted, true);
      });

      test('preserves endowmentPlusCompleted if already true', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          coachConversationCount: 5,
          endowmentPlusCompleted: true,
        );

        final updated = await service.incrementConversationCount(state);
        expect(updated.coachConversationCount, 6);
        expect(updated.endowmentPlusCompleted, true);
      });
    });

    group('endowment bypass in resolveAndConsumeCoachMode (Feature #2)', () {
      test('free Plus during endowment period', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
          trialUsed: true,
          aiCredits: 0,
          coachConversationCount: 0,
          endowmentPlusCompleted: false,
        );

        final result = await service.resolveAndConsumeCoachMode(
          state,
          requestedMode: CoachMode.plus,
        );
        expect(result.resolution.effectiveMode, CoachMode.plus);
        expect(result.resolution.estimatedCreditCost, 0);
        expect(result.state.aiCredits, 0);
      });

      test('no bypass for Pro during endowment', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
          trialUsed: true,
          aiCredits: 1,
          coachConversationCount: 0,
          endowmentPlusCompleted: false,
        );

        final result = await service.resolveAndConsumeCoachMode(
          state,
          requestedMode: CoachMode.pro,
        );
        expect(result.resolution.effectiveMode, CoachMode.eco);
        expect(result.resolution.usedFallback, true);
      });
    });

    group('trackRecommendation (Feature #3)', () {
      test('increments shown and accepted when accepted', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          recommendationsShown: 5,
          recommendationsAccepted: 2,
        );

        final updated =
            await service.trackRecommendation(state, accepted: true);
        expect(updated.recommendationsShown, 6);
        expect(updated.recommendationsAccepted, 3);
      });

      test('increments shown only when not accepted', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          recommendationsShown: 5,
          recommendationsAccepted: 2,
        );

        final updated =
            await service.trackRecommendation(state, accepted: false);
        expect(updated.recommendationsShown, 6);
        expect(updated.recommendationsAccepted, 2);
      });
    });

    group('session insight (Feature #4)', () {
      test('setSessionInsight stores insight and value', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        final updated = await service.setSessionInsight(
            state, 'otimização de despesas', '€47/mês');
        expect(updated.lastSessionInsight, 'otimização de despesas');
        expect(updated.lastSessionInsightValue, '€47/mês');
      });

      test('setSessionInsight with null value', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        final updated = await service.setSessionInsight(
            state, 'estratégia poupança', null);
        expect(updated.lastSessionInsight, 'estratégia poupança');
        expect(updated.lastSessionInsightValue, isNull);
      });

      test('trackSessionCompleted increments pro counter', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          totalProSessions: 2,
          totalPlusSessions: 3,
        );

        final updated =
            await service.trackSessionCompleted(state, CoachMode.pro);
        expect(updated.totalProSessions, 3);
        expect(updated.totalPlusSessions, 3);
      });

      test('trackSessionCompleted increments plus counter', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          totalProSessions: 2,
          totalPlusSessions: 3,
        );

        final updated =
            await service.trackSessionCompleted(state, CoachMode.plus);
        expect(updated.totalProSessions, 2);
        expect(updated.totalPlusSessions, 4);
      });

      test('trackSessionCompleted does not increment for eco', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          totalProSessions: 2,
          totalPlusSessions: 3,
        );

        final updated =
            await service.trackSessionCompleted(state, CoachMode.eco);
        expect(updated.totalProSessions, 2);
        expect(updated.totalPlusSessions, 3);
      });
    });

    group('micro action (Feature #5)', () {
      test('setLastMicroAction stores action and date', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        final updated =
            await service.setLastMicroAction(state, 'Move €15 para poupança');
        expect(updated.lastMicroAction, 'Move €15 para poupança');
        expect(updated.lastMicroActionDate, isNotNull);
      });

      test('clearLastMicroAction clears both fields', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          lastMicroAction: 'Some action',
          lastMicroActionDate: DateTime.now(),
        );

        final updated = await service.clearLastMicroAction(state);
        expect(updated.lastMicroAction, isNull);
        expect(updated.lastMicroActionDate, isNull);
      });

      test('clearLastMicroAction preserves other fields', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime(2026, 1, 1),
          trialUsed: true,
          aiCredits: 50,
          lastMicroAction: 'Some action',
          lastMicroActionDate: DateTime.now(),
          totalProSessions: 5,
        );

        final updated = await service.clearLastMicroAction(state);
        expect(updated.tier, SubscriptionTier.premium);
        expect(updated.aiCredits, 50);
        expect(updated.totalProSessions, 5);
        expect(updated.lastMicroAction, isNull);
      });
    });

    group('featureLabel()', () {
      test('returns correct labels for all known features', () {
        expect(SubscriptionService.featureLabel('dashboard'),
            'Budget Dashboard');
        expect(SubscriptionService.featureLabel('ai_coach'),
            'AI Financial Coach');
        expect(
            SubscriptionService.featureLabel('meal_planner'), 'Meal Planner');
        expect(SubscriptionService.featureLabel('expense_tracker'),
            'Expense Tracker');
        expect(
            SubscriptionService.featureLabel('savings_goals'), 'Savings Goals');
        expect(
            SubscriptionService.featureLabel('shopping_list'), 'Shopping List');
        expect(SubscriptionService.featureLabel('grocery_browser'),
            'Grocery Browser');
        expect(SubscriptionService.featureLabel('export'), 'Export Reports');
        expect(SubscriptionService.featureLabel('tax_simulator'),
            'Tax Simulator');
      });

      test('returns key as fallback for unknown feature', () {
        expect(
            SubscriptionService.featureLabel('unknown_feature'),
            'unknown_feature');
      });
    });

    group('featureIcon()', () {
      test('returns correct icons for all known features', () {
        expect(SubscriptionService.featureIcon('dashboard'), 'dashboard');
        expect(SubscriptionService.featureIcon('ai_coach'), 'psychology');
        expect(SubscriptionService.featureIcon('meal_planner'), 'restaurant');
        expect(
            SubscriptionService.featureIcon('expense_tracker'), 'receipt_long');
        expect(SubscriptionService.featureIcon('savings_goals'), 'savings');
        expect(SubscriptionService.featureIcon('shopping_list'),
            'shopping_basket');
        expect(SubscriptionService.featureIcon('grocery_browser'),
            'shopping_cart');
        expect(SubscriptionService.featureIcon('export'), 'download');
        expect(SubscriptionService.featureIcon('tax_simulator'), 'calculate');
      });

      test('returns star as fallback for unknown feature', () {
        expect(SubscriptionService.featureIcon('unknown_feature'), 'star');
      });
    });

    group('upgradeTo() edge cases', () {
      test('upgrading to free tier still marks trialUsed', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        final updated =
            await service.upgradeTo(state, SubscriptionTier.free);

        expect(updated.tier, SubscriptionTier.free);
        expect(updated.trialUsed, true);
        expect(updated.isTrialActive, false);
      });

      test('upgrade from premium to family', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );

        final updated =
            await service.upgradeTo(state, SubscriptionTier.family);

        expect(updated.tier, SubscriptionTier.family);
        expect(updated.hasFamilyAccess, true);
      });

      test('upgrade from family to premium (downgrade tier but still via upgradeTo)', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.family,
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );

        final updated =
            await service.upgradeTo(state, SubscriptionTier.premium);

        expect(updated.tier, SubscriptionTier.premium);
        expect(updated.hasPremiumAccess, true);
        expect(updated.hasFamilyAccess, false);
      });
    });

    group('markFeatureExplored() accumulation', () {
      test('multiple calls accumulate explored features', () async {
        SharedPreferences.setMockInitialValues({});
        var state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        state = await service.markFeatureExplored(state, 'dashboard');
        state = await service.markFeatureExplored(state, 'ai_coach');
        state = await service.markFeatureExplored(state, 'export');

        expect(state.featuresExplored, {'dashboard', 'ai_coach', 'export'});
        expect(state.featuresExploredCount, 3);
      });

      test('accumulated state persists correctly', () async {
        SharedPreferences.setMockInitialValues({});
        var state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        state = await service.markFeatureExplored(state, 'dashboard');
        state = await service.markFeatureExplored(state, 'meal_planner');

        final prefs = await SharedPreferences.getInstance();
        final restored = SubscriptionState.fromJsonString(
          prefs.getString('subscription_state')!,
        );
        expect(restored.featuresExplored, {'dashboard', 'meal_planner'});
      });
    });

    group('downgrade() edge cases', () {
      test('downgrade from family tier', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.family,
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );

        final updated = await service.downgrade(state);

        expect(updated.tier, SubscriptionTier.free);
        expect(updated.hasFamilyAccess, false);
        expect(updated.hasPremiumAccess, false);
      });

      test('downgrade from free tier (no-op on tier but still marks trialUsed)', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now(),
        );

        final updated = await service.downgrade(state);

        expect(updated.tier, SubscriptionTier.free);
        expect(updated.trialUsed, true);
        expect(updated.isTrialActive, false);
      });
    });

    group('syncFromRemoteTier()', () {
      test('updates tier when remote differs', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );

        final updated = await service.syncFromRemoteTier(
            state, SubscriptionTier.premium);

        expect(updated.tier, SubscriptionTier.premium);
        expect(updated.trialUsed, true);
      });

      test('returns same state when tiers match', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );

        final updated = await service.syncFromRemoteTier(
            state, SubscriptionTier.premium);

        expect(identical(updated, state), true);
      });

      test('preserves trialUsed when remote is free', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );

        final updated = await service.syncFromRemoteTier(
            state, SubscriptionTier.free);

        expect(updated.tier, SubscriptionTier.free);
        expect(updated.trialUsed, true);
      });

      test('sets trialUsed when remote is paid tier', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now(),
          trialUsed: false,
        );

        final updated = await service.syncFromRemoteTier(
            state, SubscriptionTier.family);

        expect(updated.tier, SubscriptionTier.family);
        expect(updated.trialUsed, true);
      });

      test('persists synced state', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now(),
        );

        await service.syncFromRemoteTier(state, SubscriptionTier.premium);

        final prefs = await SharedPreferences.getInstance();
        final restored = SubscriptionState.fromJsonString(
          prefs.getString('subscription_state')!,
        );
        expect(restored.tier, SubscriptionTier.premium);
      });
    });

    group('extendTrial()', () {
      test('sets trialExtensionUsed and clears trialUsed', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 22)),
        );

        final updated = await service.extendTrial(state);

        expect(updated.trialExtensionUsed, true);
        expect(updated.trialUsed, false);
        expect(updated.isTrialActive, true);
      });

      test('returns same state if extension already used', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 29)),
          trialExtensionUsed: true,
        );

        final updated = await service.extendTrial(state);

        expect(identical(updated, state), true);
      });

      test('persists extended state', () async {
        SharedPreferences.setMockInitialValues({});
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 22)),
        );

        await service.extendTrial(state);

        final prefs = await SharedPreferences.getInstance();
        final restored = SubscriptionState.fromJsonString(
          prefs.getString('subscription_state')!,
        );
        expect(restored.trialExtensionUsed, true);
      });

      test('extended trial gives 7 more days of access', () async {
        SharedPreferences.setMockInitialValues({});
        // Trial expired 1 day ago (day 22 of 21-day trial)
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 22)),
        );
        expect(state.isTrialActive, false);

        final updated = await service.extendTrial(state);
        // Now effective trial is 28 days, day 22 < 28 so active
        expect(updated.isTrialActive, true);
        expect(updated.trialDaysRemaining, 6);
      });
    });

    group('full lifecycle', () {
      test('load → explore → upgrade → downgrade', () async {
        SharedPreferences.setMockInitialValues({});

        // First launch: trial active
        var state = await service.load();
        expect(state.isTrialActive, true);
        expect(state.tier, SubscriptionTier.free);

        // Explore a feature
        state = await service.markFeatureExplored(state, 'dashboard');
        expect(state.featuresExplored, {'dashboard'});

        // Upgrade to premium
        state = await service.upgradeTo(state, SubscriptionTier.premium);
        expect(state.tier, SubscriptionTier.premium);
        expect(state.trialUsed, true);
        expect(state.isTrialActive, false);

        // Reload from storage — should match
        final reloaded = await service.load();
        expect(reloaded.tier, SubscriptionTier.premium);
        expect(reloaded.trialUsed, true);
        expect(reloaded.featuresExplored, {'dashboard'});

        // Downgrade
        state = await service.downgrade(reloaded);
        expect(state.tier, SubscriptionTier.free);
        expect(state.trialUsed, true);
        expect(state.hasPremiumAccess, false);
      });
    });
  });
}
