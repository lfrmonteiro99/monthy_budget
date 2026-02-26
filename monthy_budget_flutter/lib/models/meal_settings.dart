enum MealType {
  breakfast,
  lunch,
  snack,
  dinner;

  String get label {
    switch (this) {
      case MealType.breakfast: return 'Pequeno-almoço';
      case MealType.lunch:     return 'Almoço';
      case MealType.snack:     return 'Lanche';
      case MealType.dinner:    return 'Jantar';
    }
  }

  double get budgetWeight {
    switch (this) {
      case MealType.breakfast: return 0.10;
      case MealType.lunch:     return 0.35;
      case MealType.snack:     return 0.15;
      case MealType.dinner:    return 0.40;
    }
  }
}

enum MealObjective {
  minimizeCost,
  balancedHealth,
  highProtein,
  lowCarb,
  vegetarian,
  custom;

  String get label {
    switch (this) {
      case MealObjective.minimizeCost:   return 'Minimizar custo';
      case MealObjective.balancedHealth: return 'Equilíbrio custo/saúde';
      case MealObjective.highProtein:    return 'Alta proteína';
      case MealObjective.lowCarb:        return 'Baixo carboidrato';
      case MealObjective.vegetarian:     return 'Vegetariano';
      case MealObjective.custom:         return 'Personalizado';
    }
  }
}

enum KitchenEquipment {
  oven,
  airFryer,
  foodProcessor,
  pressureCooker,
  microwave;

  String get label {
    switch (this) {
      case KitchenEquipment.oven:           return 'Forno';
      case KitchenEquipment.airFryer:       return 'Air Fryer';
      case KitchenEquipment.foodProcessor:  return 'Robot de cozinha';
      case KitchenEquipment.pressureCooker: return 'Panela de pressão';
      case KitchenEquipment.microwave:      return 'Micro-ondas';
    }
  }

  String get jsonValue => name;
}

class MealSettings {
  final Set<MealType> enabledMeals;
  final MealObjective objective;
  final bool glutenFree;
  final bool lactoseFree;
  final bool nutFree;
  final bool shellfishFree;
  final List<String> otherRestrictions;
  final List<String> dislikedIngredients;
  final List<String> excludedProteins;
  final int veggieDaysPerWeek;
  final bool prioritizeLowCost;
  final bool minimizeWaste;
  final int maxNewIngredientsPerWeek;
  final int maxPrepMinutes;
  final int maxComplexity;
  final Set<KitchenEquipment> availableEquipment;
  final bool batchCookingEnabled;
  final int maxBatchDays;
  final int? preferredCookingWeekday;
  final bool reuseLeftovers;
  final int? householdSize;
  final bool advancedMode;
  final bool wizardCompleted;

  const MealSettings({
    this.householdSize,
    this.enabledMeals = const {MealType.lunch, MealType.dinner},
    this.objective = MealObjective.balancedHealth,
    this.glutenFree = false,
    this.lactoseFree = false,
    this.nutFree = false,
    this.shellfishFree = false,
    this.otherRestrictions = const [],
    this.dislikedIngredients = const [],
    this.excludedProteins = const [],
    this.veggieDaysPerWeek = 0,
    this.prioritizeLowCost = false,
    this.minimizeWaste = false,
    this.maxNewIngredientsPerWeek = 10,
    this.maxPrepMinutes = 60,
    this.maxComplexity = 5,
    this.availableEquipment = const {
      KitchenEquipment.oven,
      KitchenEquipment.microwave,
    },
    this.batchCookingEnabled = false,
    this.maxBatchDays = 2,
    this.preferredCookingWeekday,
    this.reuseLeftovers = false,
    this.advancedMode = false,
    this.wizardCompleted = false,
  });

  static const Object _sentinel = Object();

  MealSettings copyWith({
    Object? householdSize = _sentinel,
    Set<MealType>? enabledMeals,
    MealObjective? objective,
    bool? glutenFree,
    bool? lactoseFree,
    bool? nutFree,
    bool? shellfishFree,
    List<String>? otherRestrictions,
    List<String>? dislikedIngredients,
    List<String>? excludedProteins,
    int? veggieDaysPerWeek,
    bool? prioritizeLowCost,
    bool? minimizeWaste,
    int? maxNewIngredientsPerWeek,
    int? maxPrepMinutes,
    int? maxComplexity,
    Set<KitchenEquipment>? availableEquipment,
    bool? batchCookingEnabled,
    int? maxBatchDays,
    Object? preferredCookingWeekday = _sentinel,
    bool? reuseLeftovers,
    bool? advancedMode,
    bool? wizardCompleted,
  }) {
    return MealSettings(
      householdSize: householdSize == _sentinel
          ? this.householdSize
          : householdSize as int?,
      enabledMeals: enabledMeals ?? this.enabledMeals,
      objective: objective ?? this.objective,
      glutenFree: glutenFree ?? this.glutenFree,
      lactoseFree: lactoseFree ?? this.lactoseFree,
      nutFree: nutFree ?? this.nutFree,
      shellfishFree: shellfishFree ?? this.shellfishFree,
      otherRestrictions: otherRestrictions ?? this.otherRestrictions,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
      excludedProteins: excludedProteins ?? this.excludedProteins,
      veggieDaysPerWeek: veggieDaysPerWeek ?? this.veggieDaysPerWeek,
      prioritizeLowCost: prioritizeLowCost ?? this.prioritizeLowCost,
      minimizeWaste: minimizeWaste ?? this.minimizeWaste,
      maxNewIngredientsPerWeek: maxNewIngredientsPerWeek ?? this.maxNewIngredientsPerWeek,
      maxPrepMinutes: maxPrepMinutes ?? this.maxPrepMinutes,
      maxComplexity: maxComplexity ?? this.maxComplexity,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      batchCookingEnabled: batchCookingEnabled ?? this.batchCookingEnabled,
      maxBatchDays: maxBatchDays ?? this.maxBatchDays,
      preferredCookingWeekday: preferredCookingWeekday == _sentinel
          ? this.preferredCookingWeekday
          : preferredCookingWeekday as int?,
      reuseLeftovers: reuseLeftovers ?? this.reuseLeftovers,
      advancedMode: advancedMode ?? this.advancedMode,
      wizardCompleted: wizardCompleted ?? this.wizardCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'householdSize': householdSize,
    'enabledMeals': enabledMeals.map((e) => e.name).toList(),
    'objective': objective.name,
    'glutenFree': glutenFree,
    'lactoseFree': lactoseFree,
    'nutFree': nutFree,
    'shellfishFree': shellfishFree,
    'otherRestrictions': otherRestrictions,
    'dislikedIngredients': dislikedIngredients,
    'excludedProteins': excludedProteins,
    'veggieDaysPerWeek': veggieDaysPerWeek,
    'prioritizeLowCost': prioritizeLowCost,
    'minimizeWaste': minimizeWaste,
    'maxNewIngredientsPerWeek': maxNewIngredientsPerWeek,
    'maxPrepMinutes': maxPrepMinutes,
    'maxComplexity': maxComplexity,
    'availableEquipment': availableEquipment.map((e) => e.jsonValue).toList(),
    'batchCookingEnabled': batchCookingEnabled,
    'maxBatchDays': maxBatchDays,
    'preferredCookingWeekday': preferredCookingWeekday,
    'reuseLeftovers': reuseLeftovers,
    'advancedMode': advancedMode,
    'wizardCompleted': wizardCompleted,
  };

  factory MealSettings.fromJson(Map<String, dynamic> json) {
    Set<MealType> parseMealTypes(dynamic raw) {
      if (raw == null) return const {MealType.lunch, MealType.dinner};
      return (raw as List<dynamic>)
          .map((e) => MealType.values.firstWhere(
                (m) => m.name == e,
                orElse: () => MealType.dinner,
              ))
          .toSet();
    }

    Set<KitchenEquipment> parseEquipment(dynamic raw) {
      if (raw == null) return const {KitchenEquipment.oven, KitchenEquipment.microwave};
      return (raw as List<dynamic>)
          .map((e) => KitchenEquipment.values.firstWhere(
                (k) => k.name == e,
                orElse: () => KitchenEquipment.oven,
              ))
          .toSet();
    }

    return MealSettings(
      householdSize: json['householdSize'] as int?,
      enabledMeals: parseMealTypes(json['enabledMeals']),
      objective: MealObjective.values.firstWhere(
        (e) => e.name == json['objective'],
        orElse: () => MealObjective.balancedHealth,
      ),
      glutenFree: json['glutenFree'] ?? false,
      lactoseFree: json['lactoseFree'] ?? false,
      nutFree: json['nutFree'] ?? false,
      shellfishFree: json['shellfishFree'] ?? false,
      otherRestrictions: List<String>.from(json['otherRestrictions'] ?? []),
      dislikedIngredients: List<String>.from(json['dislikedIngredients'] ?? []),
      excludedProteins: List<String>.from(json['excludedProteins'] ?? []),
      veggieDaysPerWeek: json['veggieDaysPerWeek'] ?? 0,
      prioritizeLowCost: json['prioritizeLowCost'] ?? false,
      minimizeWaste: json['minimizeWaste'] ?? false,
      maxNewIngredientsPerWeek: json['maxNewIngredientsPerWeek'] ?? 10,
      maxPrepMinutes: json['maxPrepMinutes'] ?? 60,
      maxComplexity: json['maxComplexity'] ?? 5,
      availableEquipment: parseEquipment(json['availableEquipment']),
      batchCookingEnabled: json['batchCookingEnabled'] ?? false,
      maxBatchDays: json['maxBatchDays'] ?? 2,
      preferredCookingWeekday: json['preferredCookingWeekday'] as int?,
      reuseLeftovers: json['reuseLeftovers'] ?? false,
      advancedMode: json['advancedMode'] ?? false,
      wizardCompleted: json['wizardCompleted'] ?? false,
    );
  }
}
