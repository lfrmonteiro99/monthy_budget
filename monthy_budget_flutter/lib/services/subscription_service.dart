import 'package:shared_preferences/shared_preferences.dart';

import '../exceptions/app_exceptions.dart';
import '../models/subscription_state.dart';
import '../repositories/auth_repository.dart';

/// Manages subscription state, trial tracking, and feature discovery.
class SubscriptionService {
  static const _key = 'subscription_state';
  static const _trialEndNoticeKey = 'trial_end_notice_seen';
  static const _downgradeAppliedKey = 'downgrade_applied';

  final AuthRepository _authRepository;

  SubscriptionService({AuthRepository? authRepository})
    : _authRepository = authRepository ?? SupabaseAuthRepository();

  /// Returns the account creation date from Supabase auth.
  /// Falls back to [DateTime.now()] if unavailable (e.g. in tests).
  DateTime _accountCreatedAt() {
    try {
      final user = _authRepository.currentUser;
      if (user != null && user.createdAt.isNotEmpty) {
        return DateTime.parse(user.createdAt);
      }
    } catch (_) {
      // Supabase not initialized (unit tests) - fall through to default.
    }
    return DateTime.now();
  }

  Future<SubscriptionState> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);
      final accountDate = _accountCreatedAt();
      if (json == null) {
        final initial = SubscriptionState(
          trialStartDate: accountDate,
          aiCredits: SubscriptionState.trialStarterCredits,
          trialStarterCreditsGranted: true,
        );
        await save(initial);
        return initial;
      }
      var loaded = SubscriptionState.fromJsonString(json);
      if (loaded.trialStartDate.isAfter(accountDate)) {
        loaded = loaded.copyWith(trialStartDate: accountDate);
        await save(loaded);
      }
      if (!loaded.trialStarterCreditsGranted && loaded.isTrialActive) {
        final upgraded = loaded.copyWith(
          aiCredits: loaded.aiCredits + SubscriptionState.trialStarterCredits,
          trialStarterCreditsGranted: true,
        );
        await save(upgraded);
        return upgraded;
      }
      return loaded;
    } catch (e, stack) {
      throw SubscriptionException(
        'Failed to load subscription state',
        e,
        stack,
      );
    }
  }

  Future<void> save(SubscriptionState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, state.toJsonString());
    } catch (e, stack) {
      throw SubscriptionException(
        'Failed to save subscription state',
        e,
        stack,
      );
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e, stack) {
      throw SubscriptionException(
        'Failed to clear subscription state',
        e,
        stack,
      );
    }
  }

  Future<SubscriptionState> markFeatureExplored(
    SubscriptionState current,
    String featureKey,
  ) async {
    if (current.featuresExplored.contains(featureKey)) return current;
    final updated = current.copyWith(
      featuresExplored: {...current.featuresExplored, featureKey},
    );
    await save(updated);
    return updated;
  }

  Future<SubscriptionState> upgradeTo(
    SubscriptionState current,
    SubscriptionTier tier,
  ) async {
    final updated = current.copyWith(tier: tier, trialUsed: true);
    await save(updated);
    return updated;
  }

  Future<SubscriptionState> syncFromRemoteTier(
    SubscriptionState current,
    SubscriptionTier remoteTier,
  ) async {
    if (current.tier == remoteTier) return current;
    final updated = current.copyWith(
      tier: remoteTier,
      trialUsed: remoteTier != SubscriptionTier.free
          ? true
          : current.trialUsed,
    );
    await save(updated);
    return updated;
  }

  Future<SubscriptionState> downgrade(SubscriptionState current) async {
    final updated = current.copyWith(
      tier: SubscriptionTier.free,
      trialUsed: true,
    );
    await save(updated);
    return updated;
  }

  Future<bool> isTrialEndNoticeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trialEndNoticeKey) ?? false;
  }

  Future<void> markTrialEndNoticeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trialEndNoticeKey, true);
  }

  Future<bool> isDowngradeApplied() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_downgradeAppliedKey) ?? false;
  }

  Future<void> markDowngradeApplied() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_downgradeAppliedKey, true);
  }

  Future<SubscriptionState> extendTrial(SubscriptionState current) async {
    if (current.trialExtensionUsed) return current;
    final updated = current.copyWith(
      trialExtensionUsed: true,
      trialUsed: false,
    );
    await save(updated);
    return updated;
  }

  Future<void> resetDowngradeTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_downgradeAppliedKey, false);
    await prefs.setBool(_trialEndNoticeKey, false);
  }

  Future<SubscriptionState> setPreferredCoachMode(
    SubscriptionState current,
    CoachMode mode,
  ) async {
    final updated = current.copyWith(preferredCoachMode: mode);
    await save(updated);
    return updated;
  }

  Future<SubscriptionState> addAiCredits(
    SubscriptionState current,
    int amount,
  ) async {
    if (amount <= 0) return current;
    final capped = (current.aiCredits + amount).clamp(
      0,
      SubscriptionState.maxCreditCap,
    );
    final updated = current.copyWith(
      aiCredits: capped,
      downgradeCardShown: false,
    );
    await save(updated);
    return updated;
  }

  Future<SubscriptionState> consumeAiCredits(
    SubscriptionState current,
    int amount,
  ) async {
    if (amount <= 0) return current;
    final next = current.aiCredits - amount;
    final updated = current.copyWith(aiCredits: next < 0 ? 0 : next);
    await save(updated);
    return updated;
  }

  Future<({SubscriptionState state, CoachModeResolution resolution})>
  resolveAndConsumeCoachMode(
    SubscriptionState current, {
    CoachMode? requestedMode,
  }) async {
    final requested = requestedMode ?? current.preferredCoachMode;
    if (current.isInEndowmentPeriod && requested == CoachMode.plus) {
      final resolution = CoachModeResolution(
        requestedMode: requested,
        effectiveMode: CoachMode.plus,
        estimatedCreditCost: 0,
        usedFallback: false,
      );
      return (state: current, resolution: resolution);
    }

    final resolution = current.resolveCoachMode(requestedMode: requestedMode);
    if (resolution.estimatedCreditCost <= 0) {
      return (state: current, resolution: resolution);
    }

    final updated = await consumeAiCredits(
      current,
      resolution.estimatedCreditCost,
    );
    return (state: updated, resolution: resolution);
  }

  Future<SubscriptionState> markDowngradeCardShown(
    SubscriptionState current,
  ) async {
    final updated = current.copyWith(downgradeCardShown: true);
    await save(updated);
    return updated;
  }

  Future<SubscriptionState> incrementConversationCount(
    SubscriptionState current,
  ) async {
    final newCount = current.coachConversationCount + 1;
    final completed = newCount >= SubscriptionState.endowmentConversations;
    final updated = current.copyWith(
      coachConversationCount: newCount,
      endowmentPlusCompleted: completed || current.endowmentPlusCompleted,
    );
    await save(updated);
    return updated;
  }

  Future<SubscriptionState> trackRecommendation(
    SubscriptionState current, {
    required bool accepted,
  }) async {
    final updated = current.copyWith(
      recommendationsShown: current.recommendationsShown + 1,
      recommendationsAccepted: accepted
          ? current.recommendationsAccepted + 1
          : current.recommendationsAccepted,
    );
    await save(updated);
    return updated;
  }

  Future<SubscriptionState> setSessionInsight(
    SubscriptionState current,
    String insight,
    String? value,
  ) async {
    final updated = current.copyWith(
      lastSessionInsight: insight,
      lastSessionInsightValue: value,
    );
    await save(updated);
    return updated;
  }

  Future<SubscriptionState> trackSessionCompleted(
    SubscriptionState current,
    CoachMode mode,
  ) async {
    final updated = current.copyWith(
      totalProSessions: mode == CoachMode.pro
          ? current.totalProSessions + 1
          : current.totalProSessions,
      totalPlusSessions: mode == CoachMode.plus
          ? current.totalPlusSessions + 1
          : current.totalPlusSessions,
    );
    await save(updated);
    return updated;
  }

  Future<SubscriptionState> setLastMicroAction(
    SubscriptionState current,
    String action,
  ) async {
    final updated = current.copyWith(
      lastMicroAction: action,
      lastMicroActionDate: DateTime.now(),
    );
    await save(updated);
    return updated;
  }

  Future<SubscriptionState> clearLastMicroAction(
    SubscriptionState current,
  ) async {
    final updated = SubscriptionState(
      tier: current.tier,
      trialStartDate: current.trialStartDate,
      trialUsed: current.trialUsed,
      featuresExplored: current.featuresExplored,
      aiCredits: current.aiCredits,
      preferredCoachMode: current.preferredCoachMode,
      trialStarterCreditsGranted: current.trialStarterCreditsGranted,
      trialExtensionUsed: current.trialExtensionUsed,
      downgradeCardShown: current.downgradeCardShown,
      coachConversationCount: current.coachConversationCount,
      endowmentPlusCompleted: current.endowmentPlusCompleted,
      recommendationsAccepted: current.recommendationsAccepted,
      recommendationsShown: current.recommendationsShown,
      lastSessionInsight: current.lastSessionInsight,
      lastSessionInsightValue: current.lastSessionInsightValue,
      totalProSessions: current.totalProSessions,
      totalPlusSessions: current.totalPlusSessions,
    );
    await save(updated);
    return updated;
  }

  static String featureLabel(String featureKey) {
    switch (featureKey) {
      case 'dashboard':
        return 'Budget Dashboard';
      case 'ai_coach':
        return 'AI Financial Coach';
      case 'meal_planner':
        return 'Meal Planner';
      case 'expense_tracker':
        return 'Expense Tracker';
      case 'savings_goals':
        return 'Savings Goals';
      case 'shopping_list':
        return 'Shopping List';
      case 'grocery_browser':
        return 'Grocery Browser';
      case 'export':
        return 'Export Reports';
      case 'tax_simulator':
        return 'Tax Simulator';
      default:
        return featureKey;
    }
  }

  static String featureIcon(String featureKey) {
    switch (featureKey) {
      case 'dashboard':
        return 'dashboard';
      case 'ai_coach':
        return 'psychology';
      case 'meal_planner':
        return 'restaurant';
      case 'expense_tracker':
        return 'receipt_long';
      case 'savings_goals':
        return 'savings';
      case 'shopping_list':
        return 'shopping_basket';
      case 'grocery_browser':
        return 'shopping_cart';
      case 'export':
        return 'download';
      case 'tax_simulator':
        return 'calculate';
      default:
        return 'star';
    }
  }
}
