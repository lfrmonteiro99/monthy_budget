enum MealType {
  breakfast,
  lunch,
  snack,
  dinner;

  String get label {
    switch (this) {
      case MealType.breakfast: return 'Pequeno-almo\u00E7o';
      case MealType.lunch:     return 'Almo\u00E7o';
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
  vegetarian;

  String get label {
    switch (this) {
      case MealObjective.minimizeCost:   return 'Minimizar custo';
      case MealObjective.balancedHealth: return 'Equil\u00EDbrio custo/sa\u00FAde';
      case MealObjective.highProtein:    return 'Alta prote\u00EDna';
      case MealObjective.lowCarb:        return 'Baixo carboidrato';
      case MealObjective.vegetarian:     return 'Vegetariano';
    }
  }
}

enum KitchenEquipment {
  oven,
  airFryer,
  foodProcessor,
  pressureCooker,
  microwave,
  bimby;

  String get label {
    switch (this) {
      case KitchenEquipment.oven:           return 'Forno';
      case KitchenEquipment.airFryer:       return 'Air Fryer';
      case KitchenEquipment.foodProcessor:  return 'Robot de cozinha';
      case KitchenEquipment.pressureCooker: return 'Panela de press\u00E3o';
      case KitchenEquipment.microwave:      return 'Micro-ondas';
      case KitchenEquipment.bimby:          return 'Bimby / Thermomix';
    }
  }

  String get jsonValue => name;
}

enum SodiumPreference {
  noRestriction,
  reducedSodium,
  lowSodium;

  String get label {
    switch (this) {
      case SodiumPreference.noRestriction: return 'Sem restri\u00E7\u00E3o';
      case SodiumPreference.reducedSodium: return 'S\u00F3dio reduzido';
      case SodiumPreference.lowSodium:     return 'Baixo s\u00F3dio';
    }
  }
}

enum AgeGroup {
  child0to3,
  child4to10,
  teen,
  adult,
  senior;

  String get label {
    switch (this) {
      case AgeGroup.child0to3:  return '0\u20133 anos';
      case AgeGroup.child4to10: return '4\u201310 anos';
      case AgeGroup.teen:       return 'Adolescente';
      case AgeGroup.adult:      return 'Adulto';
      case AgeGroup.senior:     return 'S\u00E9nior (65+)';
    }
  }

  double get portionFactor {
    switch (this) {
      case AgeGroup.child0to3:  return 0.4;
      case AgeGroup.child4to10: return 0.65;
      case AgeGroup.teen:       return 1.0;
      case AgeGroup.adult:      return 1.0;
      case AgeGroup.senior:     return 0.8;
    }
  }
}

enum ActivityLevel {
  sedentary,
  moderate,
  active,
  veryActive;

  String get label {
    switch (this) {
      case ActivityLevel.sedentary:  return 'Sedent\u00E1rio';
      case ActivityLevel.moderate:   return 'Moderado';
      case ActivityLevel.active:     return 'Ativo';
      case ActivityLevel.veryActive: return 'Muito ativo';
    }
  }

  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:  return 1.0;
      case ActivityLevel.moderate:   return 1.1;
      case ActivityLevel.active:     return 1.25;
      case ActivityLevel.veryActive: return 1.4;
    }
  }
}

enum MedicalCondition {
  diabetes,
  hypertension,
  highCholesterol,
  gout,
  ibs;

  String get label {
    switch (this) {
      case MedicalCondition.diabetes:        return 'Diabetes';
      case MedicalCondition.hypertension:    return 'Hipertensão';
      case MedicalCondition.highCholesterol: return 'Colesterol alto';
      case MedicalCondition.gout:            return 'Gota';
      case MedicalCondition.ibs:             return 'Síndrome do intestino irritável';
    }
  }
}

class HouseholdMember {
  final String name;
  final AgeGroup ageGroup;
  final ActivityLevel activityLevel;

  const HouseholdMember({
    required this.name,
    this.ageGroup = AgeGroup.adult,
    this.activityLevel = ActivityLevel.moderate,
  });

  double get portionEquivalent => ageGroup.portionFactor * activityLevel.multiplier;

  Map<String, dynamic> toJson() => {
    'name': name,
    'ageGroup': ageGroup.name,
    'activityLevel': activityLevel.name,
  };

  factory HouseholdMember.fromJson(Map<String, dynamic> json) => HouseholdMember(
    name: json['name'] as String? ?? '',
    ageGroup: AgeGroup.values.firstWhere(
      (e) => e.name == json['ageGroup'],
      orElse: () => AgeGroup.adult,
    ),
    activityLevel: ActivityLevel.values.firstWhere(
      (e) => e.name == json['activityLevel'],
      orElse: () => ActivityLevel.moderate,
    ),
  );
}

class MealSettings {
  final Set<MealType> enabledMeals;
  final MealObjective objective;
  final bool glutenFree;
  final bool lactoseFree;
  final bool nutFree;
  final bool shellfishFree;
  final bool eggFree;
  final SodiumPreference sodiumPreference;
  final List<String> dislikedIngredients;
  final List<String> excludedProteins;
  final int veggieDaysPerWeek;
  final bool prioritizeLowCost;
  final bool minimizeWaste;
  final int maxNewIngredientsPerWeek;
  final int maxPrepMinutes;
  final int maxComplexity;
  final int maxPrepMinutesWeekend;
  final int maxComplexityWeekend;
  final Set<KitchenEquipment> availableEquipment;
  final bool batchCookingEnabled;
  final int maxBatchDays;
  final int? preferredCookingWeekday;
  final bool reuseLeftovers;
  final int? householdSize;
  final bool wizardCompleted;
  final Set<int> eatingOutWeekdays;
  final Map<String, String> pinnedMeals;
  final List<String> pantryIngredients;
  final bool lunchboxLunches;
  final int fishDaysPerWeek;
  final int legumeDaysPerWeek;
  final int redMeatMaxPerWeek;
  final List<HouseholdMember> householdMembers;
  final bool preferSeasonal;
  final int? dailyCalorieTarget;
  final int? dailyProteinTargetG;
  final int? dailyFiberTargetG;
  final Set<MedicalCondition> medicalConditions;

  const MealSettings({
    this.householdSize,
    this.enabledMeals = const {MealType.lunch, MealType.dinner},
    this.objective = MealObjective.balancedHealth,
    this.glutenFree = false,
    this.lactoseFree = false,
    this.nutFree = false,
    this.shellfishFree = false,
    this.eggFree = false,
    this.sodiumPreference = SodiumPreference.noRestriction,
    this.dislikedIngredients = const [],
    this.excludedProteins = const [],
    this.veggieDaysPerWeek = 0,
    this.prioritizeLowCost = false,
    this.minimizeWaste = false,
    this.maxNewIngredientsPerWeek = 10,
    this.maxPrepMinutes = 60,
    this.maxComplexity = 5,
    this.maxPrepMinutesWeekend = 90,
    this.maxComplexityWeekend = 5,
    this.availableEquipment = const {
      KitchenEquipment.oven,
      KitchenEquipment.microwave,
    },
    this.batchCookingEnabled = false,
    this.maxBatchDays = 2,
    this.preferredCookingWeekday,
    this.reuseLeftovers = false,
    this.wizardCompleted = false,
    this.eatingOutWeekdays = const {},
    this.pinnedMeals = const {},
    this.pantryIngredients = const [],
    this.lunchboxLunches = false,
    this.fishDaysPerWeek = 0,
    this.legumeDaysPerWeek = 0,
    this.redMeatMaxPerWeek = 7,
    this.householdMembers = const [],
    this.preferSeasonal = false,
    this.dailyCalorieTarget,
    this.dailyProteinTargetG,
    this.dailyFiberTargetG,
    this.medicalConditions = const {},
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
    bool? eggFree,
    SodiumPreference? sodiumPreference,
    List<String>? dislikedIngredients,
    List<String>? excludedProteins,
    int? veggieDaysPerWeek,
    bool? prioritizeLowCost,
    bool? minimizeWaste,
    int? maxNewIngredientsPerWeek,
    int? maxPrepMinutes,
    int? maxComplexity,
    int? maxPrepMinutesWeekend,
    int? maxComplexityWeekend,
    Set<KitchenEquipment>? availableEquipment,
    bool? batchCookingEnabled,
    int? maxBatchDays,
    Object? preferredCookingWeekday = _sentinel,
    bool? reuseLeftovers,
    bool? wizardCompleted,
    Set<int>? eatingOutWeekdays,
    Map<String, String>? pinnedMeals,
    List<String>? pantryIngredients,
    bool? lunchboxLunches,
    int? fishDaysPerWeek,
    int? legumeDaysPerWeek,
    int? redMeatMaxPerWeek,
    List<HouseholdMember>? householdMembers,
    bool? preferSeasonal,
    Object? dailyCalorieTarget = _sentinel,
    Object? dailyProteinTargetG = _sentinel,
    Object? dailyFiberTargetG = _sentinel,
    Set<MedicalCondition>? medicalConditions,
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
      eggFree: eggFree ?? this.eggFree,
      sodiumPreference: sodiumPreference ?? this.sodiumPreference,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
      excludedProteins: excludedProteins ?? this.excludedProteins,
      veggieDaysPerWeek: veggieDaysPerWeek ?? this.veggieDaysPerWeek,
      prioritizeLowCost: prioritizeLowCost ?? this.prioritizeLowCost,
      minimizeWaste: minimizeWaste ?? this.minimizeWaste,
      maxNewIngredientsPerWeek: maxNewIngredientsPerWeek ?? this.maxNewIngredientsPerWeek,
      maxPrepMinutes: maxPrepMinutes ?? this.maxPrepMinutes,
      maxComplexity: maxComplexity ?? this.maxComplexity,
      maxPrepMinutesWeekend: maxPrepMinutesWeekend ?? this.maxPrepMinutesWeekend,
      maxComplexityWeekend: maxComplexityWeekend ?? this.maxComplexityWeekend,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      batchCookingEnabled: batchCookingEnabled ?? this.batchCookingEnabled,
      maxBatchDays: maxBatchDays ?? this.maxBatchDays,
      preferredCookingWeekday: preferredCookingWeekday == _sentinel
          ? this.preferredCookingWeekday
          : preferredCookingWeekday as int?,
      reuseLeftovers: reuseLeftovers ?? this.reuseLeftovers,
      wizardCompleted: wizardCompleted ?? this.wizardCompleted,
      eatingOutWeekdays: eatingOutWeekdays ?? this.eatingOutWeekdays,
      pinnedMeals: pinnedMeals ?? this.pinnedMeals,
      pantryIngredients: pantryIngredients ?? this.pantryIngredients,
      lunchboxLunches: lunchboxLunches ?? this.lunchboxLunches,
      fishDaysPerWeek: fishDaysPerWeek ?? this.fishDaysPerWeek,
      legumeDaysPerWeek: legumeDaysPerWeek ?? this.legumeDaysPerWeek,
      redMeatMaxPerWeek: redMeatMaxPerWeek ?? this.redMeatMaxPerWeek,
      householdMembers: householdMembers ?? this.householdMembers,
      preferSeasonal: preferSeasonal ?? this.preferSeasonal,
      dailyCalorieTarget: dailyCalorieTarget == _sentinel ? this.dailyCalorieTarget : dailyCalorieTarget as int?,
      dailyProteinTargetG: dailyProteinTargetG == _sentinel ? this.dailyProteinTargetG : dailyProteinTargetG as int?,
      dailyFiberTargetG: dailyFiberTargetG == _sentinel ? this.dailyFiberTargetG : dailyFiberTargetG as int?,
      medicalConditions: medicalConditions ?? this.medicalConditions,
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
    'eggFree': eggFree,
    'sodiumPreference': sodiumPreference.name,
    'dislikedIngredients': dislikedIngredients,
    'excludedProteins': excludedProteins,
    'veggieDaysPerWeek': veggieDaysPerWeek,
    'prioritizeLowCost': prioritizeLowCost,
    'minimizeWaste': minimizeWaste,
    'maxNewIngredientsPerWeek': maxNewIngredientsPerWeek,
    'maxPrepMinutes': maxPrepMinutes,
    'maxComplexity': maxComplexity,
    'maxPrepMinutesWeekend': maxPrepMinutesWeekend,
    'maxComplexityWeekend': maxComplexityWeekend,
    'availableEquipment': availableEquipment.map((e) => e.jsonValue).toList(),
    'batchCookingEnabled': batchCookingEnabled,
    'maxBatchDays': maxBatchDays,
    'preferredCookingWeekday': preferredCookingWeekday,
    'reuseLeftovers': reuseLeftovers,
    'wizardCompleted': wizardCompleted,
    'eatingOutWeekdays': eatingOutWeekdays.toList(),
    'pinnedMeals': pinnedMeals,
    'pantryIngredients': pantryIngredients,
    'lunchboxLunches': lunchboxLunches,
    'fishDaysPerWeek': fishDaysPerWeek,
    'legumeDaysPerWeek': legumeDaysPerWeek,
    'redMeatMaxPerWeek': redMeatMaxPerWeek,
    'householdMembers': householdMembers.map((m) => m.toJson()).toList(),
    'preferSeasonal': preferSeasonal,
    'dailyCalorieTarget': dailyCalorieTarget,
    'dailyProteinTargetG': dailyProteinTargetG,
    'dailyFiberTargetG': dailyFiberTargetG,
    'medicalConditions': medicalConditions.map((c) => c.name).toList(),
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
      eggFree: json['eggFree'] ?? false,
      sodiumPreference: SodiumPreference.values.firstWhere(
        (e) => e.name == (json['sodiumPreference'] ?? 'noRestriction'),
        orElse: () => SodiumPreference.noRestriction,
      ),
      dislikedIngredients: List<String>.from(json['dislikedIngredients'] ?? []),
      excludedProteins: List<String>.from(json['excludedProteins'] ?? []),
      veggieDaysPerWeek: json['veggieDaysPerWeek'] ?? 0,
      prioritizeLowCost: json['prioritizeLowCost'] ?? false,
      minimizeWaste: json['minimizeWaste'] ?? false,
      maxNewIngredientsPerWeek: json['maxNewIngredientsPerWeek'] ?? 10,
      maxPrepMinutes: json['maxPrepMinutes'] ?? 60,
      maxComplexity: json['maxComplexity'] ?? 5,
      maxPrepMinutesWeekend: json['maxPrepMinutesWeekend'] ?? 90,
      maxComplexityWeekend: json['maxComplexityWeekend'] ?? 5,
      availableEquipment: parseEquipment(json['availableEquipment']),
      batchCookingEnabled: json['batchCookingEnabled'] ?? false,
      maxBatchDays: json['maxBatchDays'] ?? 2,
      preferredCookingWeekday: json['preferredCookingWeekday'] as int?,
      reuseLeftovers: json['reuseLeftovers'] ?? false,
      wizardCompleted: json['wizardCompleted'] ?? false,
      eatingOutWeekdays: json['eatingOutWeekdays'] != null
          ? Set<int>.from((json['eatingOutWeekdays'] as List<dynamic>).map((e) => e as int))
          : const {},
      pinnedMeals: json['pinnedMeals'] != null
          ? Map<String, String>.from(json['pinnedMeals'] as Map)
          : const {},
      pantryIngredients: List<String>.from(json['pantryIngredients'] ?? []),
      lunchboxLunches: json['lunchboxLunches'] ?? false,
      fishDaysPerWeek: json['fishDaysPerWeek'] ?? 0,
      legumeDaysPerWeek: json['legumeDaysPerWeek'] ?? 0,
      redMeatMaxPerWeek: json['redMeatMaxPerWeek'] ?? 7,
      householdMembers: json['householdMembers'] != null
          ? (json['householdMembers'] as List<dynamic>)
              .map((e) => HouseholdMember.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      preferSeasonal: json['preferSeasonal'] ?? false,
      dailyCalorieTarget: json['dailyCalorieTarget'] as int?,
      dailyProteinTargetG: json['dailyProteinTargetG'] as int?,
      dailyFiberTargetG: json['dailyFiberTargetG'] as int?,
      medicalConditions: json['medicalConditions'] != null
          ? (json['medicalConditions'] as List<dynamic>)
              .map((e) => MedicalCondition.values.firstWhere(
                    (c) => c.name == e,
                    orElse: () => MedicalCondition.diabetes,
                  ))
              .toSet()
          : const {},
    );
  }
}
