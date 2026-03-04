import 'dart:convert';

/// Available subscription tiers.
enum SubscriptionTier { free, premium, family }

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
  final SubscriptionTier tier;
  final DateTime trialStartDate;
  final bool trialUsed;
  final Set<String> featuresExplored;

  static const trialDays = 14;

  const SubscriptionState({
    this.tier = SubscriptionTier.free,
    required this.trialStartDate,
    this.trialUsed = false,
    this.featuresExplored = const {},
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
  }) {
    return SubscriptionState(
      tier: tier ?? this.tier,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialUsed: trialUsed ?? this.trialUsed,
      featuresExplored: featuresExplored ?? this.featuresExplored,
    );
  }

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'trialStartDate': trialStartDate.toIso8601String(),
        'trialUsed': trialUsed,
        'featuresExplored': featuresExplored.toList(),
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
    );
  }

  factory SubscriptionState.fromJsonString(String s) =>
      SubscriptionState.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());
}
