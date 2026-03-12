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

class CreditPack {
  final String id;
  final int credits;
  final String fallbackPrice;

  const CreditPack({
    required this.id,
    required this.credits,
    required this.fallbackPrice,
  });
}

const creditPacks = <CreditPack>[
  CreditPack(id: 'credits_50', credits: 50, fallbackPrice: '€0.99'),
  CreditPack(id: 'credits_150', credits: 150, fallbackPrice: '€1.99'),
  CreditPack(id: 'credits_500', credits: 500, fallbackPrice: '€4.99'),
];

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
  static const maxCreditCap = 150;
  static const endowmentConversations = 3;

  final SubscriptionTier tier;
  final DateTime trialStartDate;
  final bool trialUsed;
  final Set<String> featuresExplored;
  final int aiCredits;
  final CoachMode preferredCoachMode;
  final bool trialStarterCreditsGranted;
  final bool trialExtensionUsed;

  // Feature #1: Downgrade Transition Card
  final bool downgradeCardShown;

  // Feature #2: Endowment Plus
  final int coachConversationCount;
  final bool endowmentPlusCompleted;

  // Feature #3: Smart Mode Recommendation
  final int recommendationsAccepted;
  final int recommendationsShown;

  // Feature #4: ROI Framing
  final String? lastSessionInsight;
  final String? lastSessionInsightValue;
  final int totalProSessions;
  final int totalPlusSessions;

  // Feature #5: Micro-Action Follow-up
  final String? lastMicroAction;
  final DateTime? lastMicroActionDate;

  static const trialDays = 21;
  static const trialExtensionDays = 7;

  const SubscriptionState({
    this.tier = SubscriptionTier.free,
    required this.trialStartDate,
    this.trialUsed = false,
    this.featuresExplored = const {},
    this.aiCredits = 0,
    this.preferredCoachMode = CoachMode.plus,
    this.trialStarterCreditsGranted = false,
    this.trialExtensionUsed = false,
    this.downgradeCardShown = false,
    this.coachConversationCount = 0,
    this.endowmentPlusCompleted = false,
    this.recommendationsAccepted = 0,
    this.recommendationsShown = 0,
    this.lastSessionInsight,
    this.lastSessionInsightValue,
    this.totalProSessions = 0,
    this.totalPlusSessions = 0,
    this.lastMicroAction,
    this.lastMicroActionDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionState &&
          tier == other.tier &&
          trialStartDate == other.trialStartDate &&
          trialUsed == other.trialUsed &&
          aiCredits == other.aiCredits &&
          preferredCoachMode == other.preferredCoachMode &&
          trialStarterCreditsGranted == other.trialStarterCreditsGranted &&
          trialExtensionUsed == other.trialExtensionUsed &&
          downgradeCardShown == other.downgradeCardShown &&
          coachConversationCount == other.coachConversationCount &&
          endowmentPlusCompleted == other.endowmentPlusCompleted &&
          recommendationsAccepted == other.recommendationsAccepted &&
          recommendationsShown == other.recommendationsShown &&
          lastSessionInsight == other.lastSessionInsight &&
          lastSessionInsightValue == other.lastSessionInsightValue &&
          totalProSessions == other.totalProSessions &&
          totalPlusSessions == other.totalPlusSessions &&
          lastMicroAction == other.lastMicroAction &&
          lastMicroActionDate == other.lastMicroActionDate;

  @override
  int get hashCode => Object.hash(
        tier, trialStartDate, trialUsed, aiCredits,
        preferredCoachMode, trialStarterCreditsGranted, trialExtensionUsed,
        downgradeCardShown, coachConversationCount, endowmentPlusCompleted,
        recommendationsAccepted, recommendationsShown,
        lastSessionInsight, lastSessionInsightValue,
        totalProSessions, totalPlusSessions,
        lastMicroAction, lastMicroActionDate,
      );

  /// Total trial days including any extension.
  int get effectiveTrialDays =>
      trialDays + (trialExtensionUsed ? trialExtensionDays : 0);

  /// Whether the trial is currently active.
  bool get isTrialActive {
    if (trialUsed) return false;
    return DateTime.now().difference(trialStartDate).inDays < effectiveTrialDays;
  }

  /// Days remaining in trial. 0 if expired.
  int get trialDaysRemaining {
    if (trialUsed) return 0;
    final remaining =
        effectiveTrialDays - DateTime.now().difference(trialStartDate).inDays;
    return remaining.clamp(0, effectiveTrialDays);
  }

  /// Whether a trial extension can be offered (trial expired, extension not yet used).
  bool get canExtendTrial =>
      !trialExtensionUsed && !isTrialActive && !trialUsed;

  /// Whether the user just transitioned from trial to free (needs downgrade handling).
  bool get justDowngraded => trialUsed && tier == SubscriptionTier.free;

  /// Whether the user currently has premium-level access (paid or trial).
  bool get hasPremiumAccess =>
      tier == SubscriptionTier.premium ||
      tier == SubscriptionTier.family ||
      isTrialActive;

  /// Whether the user currently has family-level access (paid or trial).
  bool get hasFamilyAccess =>
      tier == SubscriptionTier.family || isTrialActive;

  // Feature #6: Credit cap getters
  bool get isAtCreditCap => aiCredits >= maxCreditCap;
  int creditsAfterPurchase(int packCredits) =>
      (aiCredits + packCredits).clamp(0, maxCreditCap);
  int creditsWasted(int packCredits) {
    final excess = (aiCredits + packCredits) - maxCreditCap;
    return excess > 0 ? excess : 0;
  }

  // Feature #2: Endowment Plus getter
  bool get isInEndowmentPeriod =>
      !endowmentPlusCompleted &&
      coachConversationCount < endowmentConversations &&
      (tier == SubscriptionTier.premium || tier == SubscriptionTier.family);

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
    bool? trialExtensionUsed,
    bool? downgradeCardShown,
    int? coachConversationCount,
    bool? endowmentPlusCompleted,
    int? recommendationsAccepted,
    int? recommendationsShown,
    String? lastSessionInsight,
    String? lastSessionInsightValue,
    int? totalProSessions,
    int? totalPlusSessions,
    String? lastMicroAction,
    DateTime? lastMicroActionDate,
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
      trialExtensionUsed: trialExtensionUsed ?? this.trialExtensionUsed,
      downgradeCardShown: downgradeCardShown ?? this.downgradeCardShown,
      coachConversationCount:
          coachConversationCount ?? this.coachConversationCount,
      endowmentPlusCompleted:
          endowmentPlusCompleted ?? this.endowmentPlusCompleted,
      recommendationsAccepted:
          recommendationsAccepted ?? this.recommendationsAccepted,
      recommendationsShown: recommendationsShown ?? this.recommendationsShown,
      lastSessionInsight: lastSessionInsight ?? this.lastSessionInsight,
      lastSessionInsightValue:
          lastSessionInsightValue ?? this.lastSessionInsightValue,
      totalProSessions: totalProSessions ?? this.totalProSessions,
      totalPlusSessions: totalPlusSessions ?? this.totalPlusSessions,
      lastMicroAction: lastMicroAction ?? this.lastMicroAction,
      lastMicroActionDate: lastMicroActionDate ?? this.lastMicroActionDate,
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
        'trialExtensionUsed': trialExtensionUsed,
        'downgradeCardShown': downgradeCardShown,
        'coachConversationCount': coachConversationCount,
        'endowmentPlusCompleted': endowmentPlusCompleted,
        'recommendationsAccepted': recommendationsAccepted,
        'recommendationsShown': recommendationsShown,
        if (lastSessionInsight != null) 'lastSessionInsight': lastSessionInsight,
        if (lastSessionInsightValue != null)
          'lastSessionInsightValue': lastSessionInsightValue,
        'totalProSessions': totalProSessions,
        'totalPlusSessions': totalPlusSessions,
        if (lastMicroAction != null) 'lastMicroAction': lastMicroAction,
        if (lastMicroActionDate != null)
          'lastMicroActionDate': lastMicroActionDate!.toIso8601String(),
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
      trialExtensionUsed:
          json['trialExtensionUsed'] as bool? ?? false,
      downgradeCardShown:
          json['downgradeCardShown'] as bool? ?? false,
      coachConversationCount:
          (json['coachConversationCount'] as num?)?.toInt() ?? 0,
      endowmentPlusCompleted:
          json['endowmentPlusCompleted'] as bool? ?? false,
      recommendationsAccepted:
          (json['recommendationsAccepted'] as num?)?.toInt() ?? 0,
      recommendationsShown:
          (json['recommendationsShown'] as num?)?.toInt() ?? 0,
      lastSessionInsight: json['lastSessionInsight'] as String?,
      lastSessionInsightValue: json['lastSessionInsightValue'] as String?,
      totalProSessions:
          (json['totalProSessions'] as num?)?.toInt() ?? 0,
      totalPlusSessions:
          (json['totalPlusSessions'] as num?)?.toInt() ?? 0,
      lastMicroAction: json['lastMicroAction'] as String?,
      lastMicroActionDate: json['lastMicroActionDate'] != null
          ? DateTime.parse(json['lastMicroActionDate'] as String)
          : null,
    );
  }

  factory SubscriptionState.fromJsonString(String s) =>
      SubscriptionState.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());
}
