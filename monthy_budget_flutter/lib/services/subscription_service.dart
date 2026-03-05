import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_state.dart';

/// Manages subscription state, trial tracking, and feature discovery.
class SubscriptionService {
  static const _key = 'subscription_state';

  Future<SubscriptionState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) {
      // First launch: start trial now
      final initial = SubscriptionState(trialStartDate: DateTime.now());
      await save(initial);
      return initial;
    }
    return SubscriptionState.fromJsonString(json);
  }

  Future<void> save(SubscriptionState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, state.toJsonString());
  }

  /// Record that the user explored a feature (for discovery tracking).
  Future<SubscriptionState> markFeatureExplored(
      SubscriptionState current, String featureKey) async {
    if (current.featuresExplored.contains(featureKey)) return current;
    final updated = current.copyWith(
      featuresExplored: {...current.featuresExplored, featureKey},
    );
    await save(updated);
    return updated;
  }

  /// Upgrade to a paid tier (called after successful payment).
  Future<SubscriptionState> upgradeTo(
      SubscriptionState current, SubscriptionTier tier) async {
    final updated = current.copyWith(tier: tier, trialUsed: true);
    await save(updated);
    return updated;
  }

  /// Sync local state with a remote tier from RevenueCat.
  ///
  /// If tiers match, returns [current] unchanged.
  /// If different, updates the tier (and marks trial as used for paid tiers).
  Future<SubscriptionState> syncFromRemoteTier(
      SubscriptionState current, SubscriptionTier remoteTier) async {
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

  /// Downgrade to free tier (e.g., subscription cancelled).
  Future<SubscriptionState> downgrade(SubscriptionState current) async {
    final updated =
        current.copyWith(tier: SubscriptionTier.free, trialUsed: true);
    await save(updated);
    return updated;
  }

  Future<SubscriptionState> setPreferredCoachMode(
      SubscriptionState current, CoachMode mode) async {
    final updated = current.copyWith(preferredCoachMode: mode);
    await save(updated);
    return updated;
  }

  Future<SubscriptionState> addAiCredits(
      SubscriptionState current, int amount) async {
    if (amount <= 0) return current;
    final updated = current.copyWith(aiCredits: current.aiCredits + amount);
    await save(updated);
    return updated;
  }

  Future<SubscriptionState> consumeAiCredits(
      SubscriptionState current, int amount) async {
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
    final resolution = current.resolveCoachMode(requestedMode: requestedMode);
    if (resolution.estimatedCreditCost <= 0) {
      return (state: current, resolution: resolution);
    }

    final updated = await consumeAiCredits(current, resolution.estimatedCreditCost);
    return (state: updated, resolution: resolution);
  }

  /// Returns a human-readable label for a feature key.
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

  /// Returns the icon for a feature key.
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
