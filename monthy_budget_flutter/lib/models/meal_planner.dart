import 'dart:convert';
import 'meal_settings.dart';

enum MealFeedback { none, liked, disliked, skipped }

enum IngredientCategory { proteina, carbo, vegetal, gordura, condimento }
enum RecipeType { carne, peixe, vegetariano, ovos, leguminosas }

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
      };
}

class MealDay {
  final int dayIndex;
  final String recipeId;
  final bool isLeftover;
  final double costEstimate;
  final MealType mealType;
  final MealFeedback feedback;

  const MealDay({
    required this.dayIndex,
    required this.recipeId,
    this.isLeftover = false,
    required this.costEstimate,
    this.mealType = MealType.dinner,
    this.feedback = MealFeedback.none,
  });

  MealDay copyWith({String? recipeId, double? costEstimate, MealType? mealType, MealFeedback? feedback}) => MealDay(
        dayIndex: dayIndex,
        recipeId: recipeId ?? this.recipeId,
        isLeftover: isLeftover,
        costEstimate: costEstimate ?? this.costEstimate,
        mealType: mealType ?? this.mealType,
        feedback: feedback ?? this.feedback,
      );

  factory MealDay.fromJson(Map<String, dynamic> json) => MealDay(
        dayIndex: json['dayIndex'] as int,
        recipeId: json['recipeId'] as String,
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
      );

  Map<String, dynamic> toJson() => {
        'dayIndex': dayIndex,
        'recipeId': recipeId,
        'isLeftover': isLeftover,
        'costEstimate': costEstimate,
        'mealType': mealType.name,
        'feedback': feedback.name,
      };
}

class RecipeAiContent {
  final List<String> steps;
  final String tip;
  final String variation;

  const RecipeAiContent({
    required this.steps,
    required this.tip,
    required this.variation,
  });

  factory RecipeAiContent.fromJson(Map<String, dynamic> json) => RecipeAiContent(
        steps: (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
        tip: json['tip'] as String? ?? '',
        variation: json['variation'] as String? ?? '',
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

  MealPlan copyWithDays(List<MealDay> days) => MealPlan(
        month: month,
        year: year,
        nPessoas: nPessoas,
        monthlyBudget: monthlyBudget,
        days: days,
        totalEstimatedCost: days.fold(0.0, (s, d) => s + d.costEstimate),
        generatedAt: generatedAt,
      );

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
      );

  Map<String, dynamic> toJson() => {
        'month': month,
        'year': year,
        'nPessoas': nPessoas,
        'monthlyBudget': monthlyBudget,
        'days': days.map((d) => d.toJson()).toList(),
        'totalEstimatedCost': totalEstimatedCost,
        'generatedAt': generatedAt.toIso8601String(),
      };

  String toJsonString() => jsonEncode(toJson());

  factory MealPlan.fromJsonString(String s) =>
      MealPlan.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
