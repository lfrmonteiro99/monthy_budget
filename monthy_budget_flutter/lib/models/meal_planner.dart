import 'dart:convert';
import 'meal_settings.dart';

enum MealFeedback { none, liked, disliked, skipped }
enum MealKind { recipe, freeform }

enum IngredientCategory { proteina, carbo, vegetal, gordura, condimento }
enum RecipeType { carne, peixe, vegetariano, ovos, leguminosas }

class FreeformMealItem {
  final String name;
  final double? quantity;
  final String? unit;
  final double? estimatedPrice;
  final String? store;

  const FreeformMealItem({
    required this.name,
    this.quantity,
    this.unit,
    this.estimatedPrice,
    this.store,
  });

  factory FreeformMealItem.fromJson(Map<String, dynamic> json) =>
      FreeformMealItem(
        name: json['name'] as String,
        quantity: (json['quantity'] as num?)?.toDouble(),
        unit: json['unit'] as String?,
        estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
        store: json['store'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit,
        if (estimatedPrice != null) 'estimatedPrice': estimatedPrice,
        if (store != null) 'store': store,
      };
}

class Ingredient {
  final String id;
  final String name;
  final IngredientCategory category;
  final String unit;
  final double avgPricePerUnit;
  final double minPurchaseQty;

  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.avgPricePerUnit,
    required this.minPurchaseQty,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        id: json['id'] as String,
        name: json['name'] as String,
        category: IngredientCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => IngredientCategory.condimento,
        ),
        unit: json['unit'] as String,
        avgPricePerUnit: (json['avgPricePerUnit'] as num).toDouble(),
        minPurchaseQty: (json['minPurchaseQty'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'unit': unit,
        'avgPricePerUnit': avgPricePerUnit,
        'minPurchaseQty': minPurchaseQty,
      };
}

class RecipeIngredient {
  final String ingredientId;
  final double quantity;

  const RecipeIngredient({required this.ingredientId, required this.quantity});

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) => RecipeIngredient(
        ingredientId: json['ingredientId'] as String,
        quantity: (json['quantity'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'ingredientId': ingredientId,
        'quantity': quantity,
      };
}

class NutritionInfo {
  final int kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sodiumMg;

  const NutritionInfo({
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.sodiumMg,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) => NutritionInfo(
    kcal: json['kcal'] as int,
    proteinG: (json['proteinG'] as num).toDouble(),
    carbsG: (json['carbsG'] as num).toDouble(),
    fatG: (json['fatG'] as num).toDouble(),
    fiberG: (json['fiberG'] as num).toDouble(),
    sodiumMg: (json['sodiumMg'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'kcal': kcal,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
    'fiberG': fiberG,
    'sodiumMg': sodiumMg,
  };
}

class Recipe {
  final String id;
  final String name;
  final String proteinId;
  final RecipeType type;
  final int complexity;
  final int prepMinutes;
  final int servings;
  final List<RecipeIngredient> ingredients;
  final bool glutenFree;
  final bool lactoseFree;
  final bool nutFree;
  final bool shellfishFree;
  final bool isVegetarian;
  final bool isHighProtein;
  final bool isLowCarb;
  final List<String> requiresEquipment;
  final bool batchCookable;
  final int maxBatchDays;
  final List<String> suitableMealTypes;
  final bool isPortable;
  final List<String> seasons; // empty = all seasons
  final NutritionInfo? nutrition;
  final List<String> prepSteps;

  const Recipe({
    required this.id,
    required this.name,
    required this.proteinId,
    required this.type,
    required this.complexity,
    required this.prepMinutes,
    required this.servings,
    required this.ingredients,
    this.glutenFree = false,
    this.lactoseFree = true,
    this.nutFree = true,
    this.shellfishFree = true,
    this.isVegetarian = false,
    this.isHighProtein = false,
    this.isLowCarb = false,
    this.requiresEquipment = const [],
    this.batchCookable = false,
    this.maxBatchDays = 1,
    this.suitableMealTypes = const ['lunch', 'dinner'],
    this.isPortable = true,
    this.seasons = const [],
    this.nutrition,
    this.prepSteps = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        name: json['name'] as String,
        proteinId: json['proteinId'] as String,
        type: RecipeType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => RecipeType.carne,
        ),
        complexity: json['complexity'] as int,
        prepMinutes: json['prepMinutes'] as int,
        servings: json['servings'] as int,
        ingredients: (json['ingredients'] as List<dynamic>)
            .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
            .toList(),
        glutenFree: json['glutenFree'] ?? false,
        lactoseFree: json['lactoseFree'] ?? true,
        nutFree: json['nutFree'] ?? true,
        shellfishFree: json['shellfishFree'] ?? true,
        isVegetarian: json['isVegetarian'] ?? false,
        isHighProtein: json['isHighProtein'] ?? false,
        isLowCarb: json['isLowCarb'] ?? false,
        requiresEquipment: List<String>.from(json['requiresEquipment'] ?? []),
        batchCookable: json['batchCookable'] ?? false,
        maxBatchDays: json['maxBatchDays'] ?? 1,
        suitableMealTypes: List<String>.from(json['suitableMealTypes'] ?? ['lunch', 'dinner']),
        isPortable: json['isPortable'] ?? true,
        seasons: List<String>.from(json['seasons'] ?? []),
        nutrition: json['nutrition'] != null
            ? NutritionInfo.fromJson(json['nutrition'] as Map<String, dynamic>)
            : null,
        prepSteps: List<String>.from(json['prepSteps'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'proteinId': proteinId,
        'type': type.name,
        'complexity': complexity,
        'prepMinutes': prepMinutes,
        'servings': servings,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
        'glutenFree': glutenFree,
        'lactoseFree': lactoseFree,
        'nutFree': nutFree,
        'shellfishFree': shellfishFree,
        'isVegetarian': isVegetarian,
        'isHighProtein': isHighProtein,
        'isLowCarb': isLowCarb,
        'requiresEquipment': requiresEquipment,
        'batchCookable': batchCookable,
        'maxBatchDays': maxBatchDays,
        'suitableMealTypes': suitableMealTypes,
        'isPortable': isPortable,
        'seasons': seasons,
        if (nutrition != null) 'nutrition': nutrition!.toJson(),
        if (prepSteps.isNotEmpty) 'prepSteps': prepSteps,
      };
}

class MealDay {
  final int dayIndex;
  final MealKind mealKind;
  final String recipeId;
  final bool isLeftover;
  final double costEstimate;
  final MealType mealType;
  final MealFeedback feedback;
  final String? freeformTitle;
  final String? freeformNote;
  final double? freeformEstimatedCost;
  final List<String> freeformTags;
  final List<FreeformMealItem> freeformShoppingItems;
  /// Ingredient substitutions: key = original ingredientId, value = replacement ingredientId
  final Map<String, String> substitutions;

  const MealDay({
    required this.dayIndex,
    this.mealKind = MealKind.recipe,
    this.recipeId = '',
    this.isLeftover = false,
    required this.costEstimate,
    this.mealType = MealType.dinner,
    this.feedback = MealFeedback.none,
    this.freeformTitle,
    this.freeformNote,
    this.freeformEstimatedCost,
    this.freeformTags = const [],
    this.freeformShoppingItems = const [],
    this.substitutions = const {},
  });

  bool get isFreeform => mealKind == MealKind.freeform;

  /// Display name: recipe name must be resolved externally; freeform uses title.
  String get displayTitle => isFreeform ? (freeformTitle ?? '') : '';

  MealDay copyWith({
    MealKind? mealKind,
    String? recipeId,
    double? costEstimate,
    MealType? mealType,
    MealFeedback? feedback,
    String? freeformTitle,
    String? freeformNote,
    double? freeformEstimatedCost,
    List<String>? freeformTags,
    List<FreeformMealItem>? freeformShoppingItems,
    Map<String, String>? substitutions,
  }) =>
      MealDay(
        dayIndex: dayIndex,
        mealKind: mealKind ?? this.mealKind,
        recipeId: recipeId ?? this.recipeId,
        isLeftover: isLeftover,
        costEstimate: costEstimate ?? this.costEstimate,
        mealType: mealType ?? this.mealType,
        feedback: feedback ?? this.feedback,
        freeformTitle: freeformTitle ?? this.freeformTitle,
        freeformNote: freeformNote ?? this.freeformNote,
        freeformEstimatedCost: freeformEstimatedCost ?? this.freeformEstimatedCost,
        freeformTags: freeformTags ?? this.freeformTags,
        freeformShoppingItems: freeformShoppingItems ?? this.freeformShoppingItems,
        substitutions: substitutions ?? this.substitutions,
      );

  /// Backward-compatible: old plans without mealKind default to recipe when
  /// recipeId is present. Plans without recipeId and without mealKind are
  /// treated as recipe with empty id (harmless -- card will skip rendering).
  factory MealDay.fromJson(Map<String, dynamic> json) {
    final hasKind = json.containsKey('mealKind');
    final MealKind kind;
    if (hasKind) {
      kind = MealKind.values.firstWhere(
        (e) => e.name == json['mealKind'],
        orElse: () => MealKind.recipe,
      );
    } else {
      // Legacy data: infer kind
      kind = MealKind.recipe;
    }

    return MealDay(
      dayIndex: json['dayIndex'] as int,
      mealKind: kind,
      recipeId: json['recipeId'] as String? ?? '',
      isLeftover: json['isLeftover'] as bool? ?? false,
      costEstimate: (json['costEstimate'] as num).toDouble(),
      mealType: MealType.values.firstWhere(
        (e) => e.name == (json['mealType'] ?? 'dinner'),
        orElse: () => MealType.dinner,
      ),
      feedback: MealFeedback.values.firstWhere(
        (e) => e.name == (json['feedback'] ?? 'none'),
        orElse: () => MealFeedback.none,
      ),
      freeformTitle: json['freeformTitle'] as String?,
      freeformNote: json['freeformNote'] as String?,
      freeformEstimatedCost: (json['freeformEstimatedCost'] as num?)?.toDouble(),
      freeformTags: List<String>.from(json['freeformTags'] ?? []),
      freeformShoppingItems: (json['freeformShoppingItems'] as List<dynamic>?)
              ?.map((e) => FreeformMealItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      substitutions: json['substitutions'] != null
          ? Map<String, String>.from(json['substitutions'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'dayIndex': dayIndex,
        'mealKind': mealKind.name,
        'recipeId': recipeId,
        'isLeftover': isLeftover,
        'costEstimate': costEstimate,
        'mealType': mealType.name,
        'feedback': feedback.name,
        if (freeformTitle != null) 'freeformTitle': freeformTitle,
        if (freeformNote != null) 'freeformNote': freeformNote,
        if (freeformEstimatedCost != null) 'freeformEstimatedCost': freeformEstimatedCost,
        if (freeformTags.isNotEmpty) 'freeformTags': freeformTags,
        if (freeformShoppingItems.isNotEmpty)
          'freeformShoppingItems': freeformShoppingItems.map((e) => e.toJson()).toList(),
        if (substitutions.isNotEmpty) 'substitutions': substitutions,
      };
}

class RecipeAiContent {
  final List<String> steps;
  final String tip;
  final String variation;
  final String leftoverIdea;
  final String pairingSuggestion;
  final String storageInfo;

  const RecipeAiContent({
    required this.steps,
    required this.tip,
    required this.variation,
    this.leftoverIdea = '',
    this.pairingSuggestion = '',
    this.storageInfo = '',
  });

  factory RecipeAiContent.fromJson(Map<String, dynamic> json) => RecipeAiContent(
        steps: (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        tip: json['tip'] as String? ?? '',
        variation: json['variation'] as String? ?? '',
        leftoverIdea: json['leftoverIdea'] as String? ?? '',
        pairingSuggestion: json['pairingSuggestion'] as String? ?? '',
        storageInfo: json['storageInfo'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'steps': steps,
        'tip': tip,
        'variation': variation,
        'leftoverIdea': leftoverIdea,
        'pairingSuggestion': pairingSuggestion,
        'storageInfo': storageInfo,
      };
}

class WeeklyNutritionSummary {
  final List<String> highlights;
  final List<String> concerns;
  final int overallScore;

  const WeeklyNutritionSummary({
    required this.highlights,
    required this.concerns,
    required this.overallScore,
  });

  factory WeeklyNutritionSummary.fromJson(Map<String, dynamic> json) =>
      WeeklyNutritionSummary(
        highlights: (json['highlights'] as List<dynamic>?)?.cast<String>() ?? [],
        concerns: (json['concerns'] as List<dynamic>?)?.cast<String>() ?? [],
        overallScore: (json['overallScore'] as int?) ?? 5,
      );
}

class BatchCookingPlan {
  final List<String> prepOrder;
  final String totalTimeEstimate;
  final List<String> parallelTips;

  const BatchCookingPlan({
    required this.prepOrder,
    required this.totalTimeEstimate,
    required this.parallelTips,
  });

  factory BatchCookingPlan.fromJson(Map<String, dynamic> json) => BatchCookingPlan(
        prepOrder: (json['prepOrder'] as List<dynamic>?)?.cast<String>() ?? [],
        totalTimeEstimate: json['totalTimeEstimate'] as String? ?? '',
        parallelTips: (json['parallelTips'] as List<dynamic>?)?.cast<String>() ?? [],
      );
}

class MealPlan {
  final int month;
  final int year;
  final int nPessoas;
  final double monthlyBudget;
  final List<MealDay> days;
  final double totalEstimatedCost;
  final DateTime generatedAt;
  final Map<int, int> extraGuests; // dayIndex -> extra people

  const MealPlan({
    required this.month,
    required this.year,
    required this.nPessoas,
    required this.monthlyBudget,
    required this.days,
    required this.totalEstimatedCost,
    required this.generatedAt,
    this.extraGuests = const {},
  });

  MealPlan copyWith({
    List<MealDay>? days,
    Map<int, int>? extraGuests,
    double? totalEstimatedCost,
  }) {
    final effectiveDays = days ?? this.days;
    return MealPlan(
      month: month,
      year: year,
      nPessoas: nPessoas,
      monthlyBudget: monthlyBudget,
      days: effectiveDays,
      totalEstimatedCost: totalEstimatedCost ??
          (days != null
              ? days.fold(0.0, (s, d) => s + d.costEstimate)
              : this.totalEstimatedCost),
      generatedAt: generatedAt,
      extraGuests: extraGuests ?? this.extraGuests,
    );
  }

  MealPlan copyWithDays(List<MealDay> days) => copyWith(days: days);

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
        month: json['month'] as int,
        year: json['year'] as int,
        nPessoas: json['nPessoas'] as int,
        monthlyBudget: (json['monthlyBudget'] as num).toDouble(),
        days: (json['days'] as List<dynamic>)
            .map((e) => MealDay.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalEstimatedCost: (json['totalEstimatedCost'] as num).toDouble(),
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        extraGuests: (json['extraGuests'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(int.parse(k), v as int)) ??
            const {},
      );

  Map<String, dynamic> toJson() => {
        'month': month,
        'year': year,
        'nPessoas': nPessoas,
        'monthlyBudget': monthlyBudget,
        'days': days.map((d) => d.toJson()).toList(),
        'totalEstimatedCost': totalEstimatedCost,
        'generatedAt': generatedAt.toIso8601String(),
        if (extraGuests.isNotEmpty)
          'extraGuests': extraGuests.map((k, v) => MapEntry(k.toString(), v)),
      };

  String toJsonString() => jsonEncode(toJson());

  factory MealPlan.fromJsonString(String s) =>
      MealPlan.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
