import 'dart:convert';

/// Available subscription tiers.
enum SubscriptionTier { free, premium, family }

/// Coach response mode and memory depth.
enum CoachMode { eco, plus, pro }

const coachModeCreditCost = <CoachMode, int>{
  CoachMode.eco: 0,
  CoachMode.plus: 2,
  CoachMode.pro: 5,
};

const coachModeMessageWindow = <CoachMode, int>{
  CoachMode.eco: 6,
  CoachMode.plus: 20,
  CoachMode.pro: 40,
};

class CoachModeResolution {
  final CoachMode requestedMode;
  final CoachMode effectiveMode;
  final int estimatedCreditCost;
  final bool usedFallback;
  final String? reason;

  const CoachModeResolution({
    required this.requestedMode,
    required this.effectiveMode,
    required this.estimatedCreditCost,
    required this.usedFallback,
    this.reason,
  });
}

/// Features that can be gated behind a subscription tier.
enum PremiumFeature {
  aiCoach,
  mealPlanner,
  exportData,
  unlimitedCategories,
  billReminders,
  shoppingListSync,
  noAds,
  householdSharing,
  taxSimulator,
  stressIndex,
  monthReview,
  dashboardCustomization,
  allThemes,
  expenseTrends,
  unlimitedSavingsGoals,
}

/// Maps each premium feature to the minimum tier required.
const featureTierRequirements = <PremiumFeature, SubscriptionTier>{
  // Premium features (€3.99/mo)
  PremiumFeature.aiCoach: SubscriptionTier.premium,
  PremiumFeature.mealPlanner: SubscriptionTier.premium,
  PremiumFeature.exportData: SubscriptionTier.premium,
  PremiumFeature.unlimitedCategories: SubscriptionTier.premium,
  PremiumFeature.billReminders: SubscriptionTier.premium,
  PremiumFeature.shoppingListSync: SubscriptionTier.premium,
  PremiumFeature.noAds: SubscriptionTier.premium,
  PremiumFeature.expenseTrends: SubscriptionTier.premium,
  PremiumFeature.unlimitedSavingsGoals: SubscriptionTier.premium,
  // Family features (€6.99/mo)
  PremiumFeature.householdSharing: SubscriptionTier.family,
  PremiumFeature.taxSimulator: SubscriptionTier.family,
  PremiumFeature.stressIndex: SubscriptionTier.family,
  PremiumFeature.monthReview: SubscriptionTier.family,
  PremiumFeature.dashboardCustomization: SubscriptionTier.family,
  PremiumFeature.allThemes: SubscriptionTier.family,
};

/// Persistent state for the user's subscription.
class SubscriptionState {
  static const trialStarterCredits = 20;
  final SubscriptionTier tier;
  final DateTime trialStartDate;
  final bool trialUsed;
  final Set<String> featuresExplored;
  final int aiCredits;
  final CoachMode preferredCoachMode;
  final bool trialStarterCreditsGranted;

  static const trialDays = 14;

  const SubscriptionState({
    this.tier = SubscriptionTier.free,
    required this.trialStartDate,
    this.trialUsed = false,
    this.featuresExplored = const {},
    this.aiCredits = 0,
    this.preferredCoachMode = CoachMode.plus,
    this.trialStarterCreditsGranted = false,
  });

  /// Whether the trial is currently active.
  bool get isTrialActive {
    if (trialUsed) return false;
    return DateTime.now().difference(trialStartDate).inDays < trialDays;
  }

  /// Days remaining in trial. 0 if expired.
  int get trialDaysRemaining {
    if (trialUsed) return 0;
    final remaining =
        trialDays - DateTime.now().difference(trialStartDate).inDays;
    return remaining.clamp(0, trialDays);
  }

  /// Whether the user currently has premium-level access (paid or trial).
  bool get hasPremiumAccess =>
      tier == SubscriptionTier.premium ||
      tier == SubscriptionTier.family ||
      isTrialActive;

  /// Whether the user currently has family-level access (paid or trial).
  bool get hasFamilyAccess =>
      tier == SubscriptionTier.family || isTrialActive;

  bool get hasAiCredits => aiCredits > 0;

  int creditCostForMode(CoachMode mode) => coachModeCreditCost[mode] ?? 0;

  int contextWindowForMode(CoachMode mode) => coachModeMessageWindow[mode] ?? 6;

  CoachModeResolution resolveCoachMode({CoachMode? requestedMode}) {
    final requested = requestedMode ?? preferredCoachMode;
    final requestedCost = creditCostForMode(requested);
    if (requested == CoachMode.eco || requestedCost == 0) {
      return CoachModeResolution(
        requestedMode: requested,
        effectiveMode: CoachMode.eco,
        estimatedCreditCost: 0,
        usedFallback: false,
      );
    }

    if (aiCredits >= requestedCost) {
      return CoachModeResolution(
        requestedMode: requested,
        effectiveMode: requested,
        estimatedCreditCost: requestedCost,
        usedFallback: false,
      );
    }

    return CoachModeResolution(
      requestedMode: requested,
      effectiveMode: CoachMode.eco,
      estimatedCreditCost: 0,
      usedFallback: true,
      reason: 'insufficient_credits',
    );
  }

  /// Check if a specific feature is accessible.
  bool canAccess(PremiumFeature feature) {
    if (isTrialActive) return true;
    final required = featureTierRequirements[feature];
    if (required == null) return true;
    switch (required) {
      case SubscriptionTier.free:
        return true;
      case SubscriptionTier.premium:
        return tier == SubscriptionTier.premium ||
            tier == SubscriptionTier.family;
      case SubscriptionTier.family:
        return tier == SubscriptionTier.family;
    }
  }

  /// How many features the user has explored during the trial.
  int get featuresExploredCount => featuresExplored.length;

  /// Total trackable features for discovery.
  static const discoverableFeatures = [
    'dashboard',
    'ai_coach',
    'meal_planner',
    'expense_tracker',
    'savings_goals',
    'shopping_list',
    'grocery_browser',
    'export',
    'tax_simulator',
  ];

  /// Fraction of features explored (0.0 to 1.0).
  double get explorationProgress =>
      featuresExploredCount / discoverableFeatures.length;

  /// Next feature the user hasn't tried yet.
  String? get nextFeatureToDiscover {
    for (final f in discoverableFeatures) {
      if (!featuresExplored.contains(f)) return f;
    }
    return null;
  }

  SubscriptionState copyWith({
    SubscriptionTier? tier,
    DateTime? trialStartDate,
    bool? trialUsed,
    Set<String>? featuresExplored,
    int? aiCredits,
    CoachMode? preferredCoachMode,
    bool? trialStarterCreditsGranted,
  }) {
    return SubscriptionState(
      tier: tier ?? this.tier,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialUsed: trialUsed ?? this.trialUsed,
      featuresExplored: featuresExplored ?? this.featuresExplored,
      aiCredits: aiCredits ?? this.aiCredits,
      preferredCoachMode: preferredCoachMode ?? this.preferredCoachMode,
      trialStarterCreditsGranted:
          trialStarterCreditsGranted ?? this.trialStarterCreditsGranted,
    );
  }

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'trialStartDate': trialStartDate.toIso8601String(),
        'trialUsed': trialUsed,
        'featuresExplored': featuresExplored.toList(),
        'aiCredits': aiCredits,
        'preferredCoachMode': preferredCoachMode.name,
        'trialStarterCreditsGranted': trialStarterCreditsGranted,
      };

  factory SubscriptionState.fromJson(Map<String, dynamic> json) {
    return SubscriptionState(
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      trialStartDate: json['trialStartDate'] != null
          ? DateTime.parse(json['trialStartDate'] as String)
          : DateTime.now(),
      trialUsed: json['trialUsed'] as bool? ?? false,
      featuresExplored: (json['featuresExplored'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
      aiCredits: (json['aiCredits'] as num?)?.toInt() ?? 0,
      preferredCoachMode: CoachMode.values.firstWhere(
        (m) => m.name == json['preferredCoachMode'],
        orElse: () => CoachMode.plus,
      ),
      trialStarterCreditsGranted:
          json['trialStarterCreditsGranted'] as bool? ?? false,
    );
  }

  factory SubscriptionState.fromJsonString(String s) =>
      SubscriptionState.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());
}
