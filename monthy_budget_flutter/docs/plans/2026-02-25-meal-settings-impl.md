# Meal Planner Settings Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a full meal settings system with 5-step wizard, configurable meals/restrictions/strategy, and an updated generator that respects all rules.

**Architecture:** `MealSettings` embedded in `AppSettings` (no schema changes), `MealWizardScreen` shown on first use, new "Refeições" section in `SettingsScreen`, updated `MealPlannerService.generate()` pipeline. `MealDay` gains a `mealType` field; day cards group all meals for a day.

**Tech Stack:** Flutter/Dart, Supabase settings_json (existing), local JSON assets

---

## Context: Key Files

- `lib/models/app_settings.dart` — `AppSettings`, `DashboardConfig` pattern to follow
- `lib/models/meal_planner.dart` — `Recipe`, `MealDay`, `MealPlan`
- `lib/services/meal_planner_service.dart` — `generate()`, `_enforceBudget()`
- `lib/screens/meal_planner_screen.dart` — `MealPlannerScreen`, `_DayCard`
- `lib/screens/settings_screen.dart` — collapsible `_SectionHeader` pattern
- `lib/main.dart` — passes `settings` to `MealPlannerScreen`
- `assets/meal_planner/recipes.json` — 25 recipes, no dietary attributes yet

---

## Task 1: Create `lib/models/meal_settings.dart`

**Files:**
- Create: `lib/models/meal_settings.dart`

**Step 1: Create the file with full model, enums, toJson/fromJson/copyWith**

```dart
// lib/models/meal_settings.dart

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

  /// Budget weight (sums to 1.0 across all 4 types)
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
  final bool advancedMode;
  final bool wizardCompleted;

  const MealSettings({
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

  MealSettings copyWith({
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

  static const Object _sentinel = Object();

  Map<String, dynamic> toJson() => {
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
```

**Step 2: Verify file compiles**

```bash
cd monthy_budget_flutter && flutter analyze lib/models/meal_settings.dart
```
Expected: no errors

---

## Task 2: Update `lib/models/meal_planner.dart`

**Files:**
- Modify: `lib/models/meal_planner.dart`

**Step 1: Add new fields to `Recipe` class**

After `final List<RecipeIngredient> ingredients;` add:

```dart
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
```

Update constructor, `fromJson` (with safe defaults), `toJson`.

Full updated `Recipe` class:

```dart
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
      };
}
```

**Step 2: Add `mealType` to `MealDay`**

Add field after `isLeftover`:
```dart
  final MealType mealType;
```

Import at top of file:
```dart
import 'meal_settings.dart';
```

Update constructor (default `MealType.dinner` for backwards compat), `copyWith`, `fromJson`, `toJson`:

```dart
class MealDay {
  final int dayIndex;
  final String recipeId;
  final bool isLeftover;
  final double costEstimate;
  final MealType mealType;

  const MealDay({
    required this.dayIndex,
    required this.recipeId,
    this.isLeftover = false,
    required this.costEstimate,
    this.mealType = MealType.dinner,
  });

  MealDay copyWith({String? recipeId, double? costEstimate, MealType? mealType}) => MealDay(
        dayIndex: dayIndex,
        recipeId: recipeId ?? this.recipeId,
        isLeftover: isLeftover,
        costEstimate: costEstimate ?? this.costEstimate,
        mealType: mealType ?? this.mealType,
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
      );

  Map<String, dynamic> toJson() => {
        'dayIndex': dayIndex,
        'recipeId': recipeId,
        'isLeftover': isLeftover,
        'costEstimate': costEstimate,
        'mealType': mealType.name,
      };
}
```

**Step 3: Verify**

```bash
flutter analyze lib/models/meal_planner.dart
```
Expected: no errors

---

## Task 3: Update `lib/models/app_settings.dart`

**Files:**
- Modify: `lib/models/app_settings.dart`

**Step 1: Add import at top**

```dart
import 'meal_settings.dart';
```

**Step 2: Add `mealSettings` field to `AppSettings`**

Add to class fields:
```dart
  final MealSettings mealSettings;
```

Add to default constructor:
```dart
    this.mealSettings = const MealSettings(),
```

**Step 3: Update `copyWith`**

Add parameter and propagation:
```dart
  AppSettings copyWith({
    PersonalInfo? personalInfo,
    List<SalaryInfo>? salaries,
    List<ExpenseItem>? expenses,
    DashboardConfig? dashboardConfig,
    MealSettings? mealSettings,
  }) {
    return AppSettings(
      personalInfo: personalInfo ?? this.personalInfo,
      salaries: salaries ?? this.salaries,
      expenses: expenses ?? this.expenses,
      dashboardConfig: dashboardConfig ?? this.dashboardConfig,
      mealSettings: mealSettings ?? this.mealSettings,
    );
  }
```

**Step 4: Update `toJsonString` and `fromJsonString`**

In `toJsonString`, add:
```dart
      'mealSettings': mealSettings.toJson(),
```

In `fromJsonString`, add:
```dart
      mealSettings: MealSettings.fromJson(
        (map['mealSettings'] as Map<String, dynamic>?) ?? {},
      ),
```

**Step 5: Verify**

```bash
flutter analyze lib/models/app_settings.dart
```
Expected: no errors

---

## Task 4: Annotate `assets/meal_planner/recipes.json`

**Files:**
- Modify: `assets/meal_planner/recipes.json`

Replace entire file with annotated version. New fields per recipe (equipment values: `"oven"`, `"airFryer"`, `"foodProcessor"`, `"pressureCooker"`, `"microwave"`):

```json
[
  {
    "id":"frango_assado","name":"Frango Assado com Batata","proteinId":"frango",
    "type":"carne","complexity":1,"prepMinutes":15,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":["oven"],"batchCookable":true,"maxBatchDays":3,
    "ingredients":[
      {"ingredientId":"frango","quantity":1.0},
      {"ingredientId":"batata","quantity":0.6},
      {"ingredientId":"alho","quantity":0.02},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"frango_arroz","name":"Frango com Arroz","proteinId":"frango",
    "type":"carne","complexity":2,"prepMinutes":30,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":[],"batchCookable":true,"maxBatchDays":2,
    "ingredients":[
      {"ingredientId":"frango","quantity":0.5},
      {"ingredientId":"arroz","quantity":0.25},
      {"ingredientId":"cenoura","quantity":0.2},
      {"ingredientId":"cebola","quantity":0.15},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"frango_estufado","name":"Frango Estufado com Legumes","proteinId":"frango",
    "type":"carne","complexity":2,"prepMinutes":30,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":true,
    "requiresEquipment":[],"batchCookable":true,"maxBatchDays":3,
    "ingredients":[
      {"ingredientId":"frango","quantity":0.6},
      {"ingredientId":"cenoura","quantity":0.3},
      {"ingredientId":"cebola","quantity":0.2},
      {"ingredientId":"tomate_pelado","quantity":1.0},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"frango_grelhado","name":"Peito de Frango Grelhado","proteinId":"frango",
    "type":"carne","complexity":1,"prepMinutes":20,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":true,
    "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
    "ingredients":[
      {"ingredientId":"frango","quantity":0.5},
      {"ingredientId":"azeite","quantity":0.03}
    ]
  },
  {
    "id":"frango_broculos","name":"Frango com Brócolos","proteinId":"frango",
    "type":"carne","complexity":2,"prepMinutes":25,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":true,
    "requiresEquipment":[],"batchCookable":true,"maxBatchDays":2,
    "ingredients":[
      {"ingredientId":"frango","quantity":0.5},
      {"ingredientId":"broculos","quantity":0.5},
      {"ingredientId":"alho","quantity":0.02},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"esparguete_bolonhesa","name":"Esparguete à Bolonhesa","proteinId":"carne_picada",
    "type":"carne","complexity":2,"prepMinutes":30,"servings":4,
    "glutenFree":false,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":[],"batchCookable":true,"maxBatchDays":2,
    "ingredients":[
      {"ingredientId":"carne_picada","quantity":0.4},
      {"ingredientId":"massa","quantity":0.3},
      {"ingredientId":"tomate_pelado","quantity":1.0},
      {"ingredientId":"cebola","quantity":0.15},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"almondegas","name":"Almôndegas em Molho de Tomate","proteinId":"carne_picada",
    "type":"carne","complexity":3,"prepMinutes":40,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":true,
    "requiresEquipment":[],"batchCookable":true,"maxBatchDays":3,
    "ingredients":[
      {"ingredientId":"carne_picada","quantity":0.5},
      {"ingredientId":"tomate_pelado","quantity":2.0},
      {"ingredientId":"cebola","quantity":0.15},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"empadao","name":"Empadão de Carne","proteinId":"carne_picada",
    "type":"carne","complexity":3,"prepMinutes":60,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":["oven"],"batchCookable":true,"maxBatchDays":3,
    "ingredients":[
      {"ingredientId":"carne_picada","quantity":0.4},
      {"ingredientId":"batata","quantity":0.8},
      {"ingredientId":"cebola","quantity":0.15},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"hamburguer","name":"Hambúrguer Caseiro","proteinId":"carne_picada",
    "type":"carne","complexity":2,"prepMinutes":20,"servings":4,
    "glutenFree":false,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
    "ingredients":[
      {"ingredientId":"carne_picada","quantity":0.5},
      {"ingredientId":"pao","quantity":4.0},
      {"ingredientId":"cebola","quantity":0.1},
      {"ingredientId":"tomate","quantity":0.2}
    ]
  },
  {
    "id":"lasanha","name":"Lasanha Simples","proteinId":"carne_picada",
    "type":"carne","complexity":4,"prepMinutes":75,"servings":4,
    "glutenFree":false,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":["oven"],"batchCookable":true,"maxBatchDays":3,
    "ingredients":[
      {"ingredientId":"carne_picada","quantity":0.4},
      {"ingredientId":"massa_lasanha","quantity":0.25},
      {"ingredientId":"tomate_pelado","quantity":2.0},
      {"ingredientId":"cebola","quantity":0.15}
    ]
  },
  {
    "id":"feijoada_simples","name":"Feijoada Simples","proteinId":"feijao",
    "type":"leguminosas","complexity":2,"prepMinutes":30,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":[],"batchCookable":true,"maxBatchDays":3,
    "ingredients":[
      {"ingredientId":"feijao","quantity":0.3},
      {"ingredientId":"chourico","quantity":0.1},
      {"ingredientId":"cenoura","quantity":0.2},
      {"ingredientId":"cebola","quantity":0.15},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"grao_espinafres","name":"Grão com Espinafres","proteinId":"grao",
    "type":"leguminosas","complexity":1,"prepMinutes":15,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":true,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":[],"batchCookable":true,"maxBatchDays":3,
    "ingredients":[
      {"ingredientId":"grao","quantity":0.3},
      {"ingredientId":"espinafres","quantity":0.3},
      {"ingredientId":"alho","quantity":0.02},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"lentilhas_estufadas","name":"Lentilhas Estufadas","proteinId":"lentilhas",
    "type":"leguminosas","complexity":2,"prepMinutes":30,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":true,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":[],"batchCookable":true,"maxBatchDays":4,
    "ingredients":[
      {"ingredientId":"lentilhas","quantity":0.3},
      {"ingredientId":"cenoura","quantity":0.2},
      {"ingredientId":"cebola","quantity":0.15},
      {"ingredientId":"tomate_pelado","quantity":1.0},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"feijao_verde_batata","name":"Feijão Verde com Batata","proteinId":"feijao",
    "type":"leguminosas","complexity":1,"prepMinutes":20,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":true,"isHighProtein":false,"isLowCarb":false,
    "requiresEquipment":[],"batchCookable":true,"maxBatchDays":2,
    "ingredients":[
      {"ingredientId":"feijao_verde","quantity":0.4},
      {"ingredientId":"batata","quantity":0.4},
      {"ingredientId":"alho","quantity":0.02},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"sopa_feijao","name":"Sopa de Feijão Rica","proteinId":"feijao",
    "type":"leguminosas","complexity":1,"prepMinutes":30,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":true,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":[],"batchCookable":true,"maxBatchDays":3,
    "ingredients":[
      {"ingredientId":"feijao","quantity":0.2},
      {"ingredientId":"batata","quantity":0.3},
      {"ingredientId":"cenoura","quantity":0.2},
      {"ingredientId":"cebola","quantity":0.1},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"omelete_legumes","name":"Omelete de Legumes","proteinId":"ovo",
    "type":"ovos","complexity":1,"prepMinutes":15,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":true,"isHighProtein":true,"isLowCarb":true,
    "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
    "ingredients":[
      {"ingredientId":"ovo","quantity":6.0},
      {"ingredientId":"pimento","quantity":0.2},
      {"ingredientId":"cebola","quantity":0.1},
      {"ingredientId":"azeite","quantity":0.03}
    ]
  },
  {
    "id":"tortilha","name":"Tortilha Espanhola","proteinId":"ovo",
    "type":"ovos","complexity":2,"prepMinutes":30,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":true,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":[],"batchCookable":true,"maxBatchDays":2,
    "ingredients":[
      {"ingredientId":"ovo","quantity":6.0},
      {"ingredientId":"batata","quantity":0.5},
      {"ingredientId":"cebola","quantity":0.15},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"frittata_espinafres","name":"Frittata de Espinafres","proteinId":"ovo",
    "type":"ovos","complexity":2,"prepMinutes":20,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":true,"isHighProtein":true,"isLowCarb":true,
    "requiresEquipment":["oven"],"batchCookable":false,"maxBatchDays":1,
    "ingredients":[
      {"ingredientId":"ovo","quantity":6.0},
      {"ingredientId":"espinafres","quantity":0.3},
      {"ingredientId":"alho","quantity":0.02},
      {"ingredientId":"azeite","quantity":0.03}
    ]
  },
  {
    "id":"ovos_mexidos_tomate","name":"Ovos Mexidos com Tomate","proteinId":"ovo",
    "type":"ovos","complexity":1,"prepMinutes":15,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":true,"isHighProtein":true,"isLowCarb":true,
    "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
    "ingredients":[
      {"ingredientId":"ovo","quantity":8.0},
      {"ingredientId":"tomate","quantity":0.3},
      {"ingredientId":"cebola","quantity":0.1},
      {"ingredientId":"azeite","quantity":0.03}
    ]
  },
  {
    "id":"ovo_arroz","name":"Ovos com Arroz e Legumes","proteinId":"ovo",
    "type":"ovos","complexity":1,"prepMinutes":25,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":true,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":[],"batchCookable":true,"maxBatchDays":2,
    "ingredients":[
      {"ingredientId":"ovo","quantity":4.0},
      {"ingredientId":"arroz","quantity":0.3},
      {"ingredientId":"cenoura","quantity":0.2},
      {"ingredientId":"azeite","quantity":0.03}
    ]
  },
  {
    "id":"pescada_forno","name":"Pescada no Forno com Batata","proteinId":"pescada",
    "type":"peixe","complexity":2,"prepMinutes":50,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":["oven"],"batchCookable":false,"maxBatchDays":1,
    "ingredients":[
      {"ingredientId":"pescada","quantity":0.6},
      {"ingredientId":"batata","quantity":0.5},
      {"ingredientId":"cebola","quantity":0.2},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"peixe_grelhado","name":"Peixe Grelhado com Legumes","proteinId":"pescada",
    "type":"peixe","complexity":1,"prepMinutes":25,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":true,
    "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
    "ingredients":[
      {"ingredientId":"pescada","quantity":0.5},
      {"ingredientId":"courgette","quantity":0.3},
      {"ingredientId":"cenoura","quantity":0.2},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"arroz_peixe","name":"Arroz de Peixe","proteinId":"pescada",
    "type":"peixe","complexity":3,"prepMinutes":40,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
    "ingredients":[
      {"ingredientId":"pescada","quantity":0.4},
      {"ingredientId":"arroz","quantity":0.3},
      {"ingredientId":"tomate_pelado","quantity":1.0},
      {"ingredientId":"cebola","quantity":0.15},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"bacalhau_cozido","name":"Bacalhau Cozido","proteinId":"bacalhau",
    "type":"peixe","complexity":2,"prepMinutes":40,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
    "ingredients":[
      {"ingredientId":"bacalhau","quantity":0.4},
      {"ingredientId":"batata","quantity":0.5},
      {"ingredientId":"ovo","quantity":4.0},
      {"ingredientId":"cebola","quantity":0.2},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  },
  {
    "id":"bacalhau_grao","name":"Bacalhau com Grão","proteinId":"bacalhau",
    "type":"peixe","complexity":2,"prepMinutes":30,"servings":4,
    "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
    "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
    "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
    "ingredients":[
      {"ingredientId":"bacalhau","quantity":0.3},
      {"ingredientId":"grao","quantity":0.2},
      {"ingredientId":"alho","quantity":0.03},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  }
]
```

**Step 2: Verify JSON is valid**

```bash
node -e "JSON.parse(require('fs').readFileSync('assets/meal_planner/recipes.json','utf8')); console.log('valid')"
```
Expected: `valid`

---

## Task 5: Update `lib/services/meal_planner_service.dart`

**Files:**
- Modify: `lib/services/meal_planner_service.dart`

**Step 1: Add import**

```dart
import '../models/meal_settings.dart';
```

**Step 2: Replace the `generate()` method entirely**

```dart
MealPlan generate(AppSettings settings, DateTime forMonth, {List<String> favorites = const []}) {
  assert(_catalogLoaded, 'Call loadCatalog() first');
  final ms = settings.mealSettings;
  final np = nPessoas(settings);
  final totalBudget = monthlyFoodBudget(settings);
  final iMap = ingredientMap;
  final daysInMonth = DateTime(forMonth.year, forMonth.month + 1, 0).day;

  // Compute per-meal budgets based on enabled meals
  final enabledWeights = {
    for (final m in ms.enabledMeals) m: m.budgetWeight
  };
  final totalWeight = enabledWeights.values.fold(0.0, (s, v) => s + v);
  final mealBudgets = {
    for (final e in enabledWeights.entries)
      e.key: totalWeight > 0 ? (e.value / totalWeight) * totalBudget : 0.0
  };

  // Base filtered pool (eliminatory)
  List<Recipe> _basePool(MealType mealType) {
    var pool = _recipes.where((r) {
      if (ms.glutenFree && !r.glutenFree) return false;
      if (ms.lactoseFree && !r.lactoseFree) return false;
      if (ms.nutFree && !r.nutFree) return false;
      if (ms.shellfishFree && !r.shellfishFree) return false;
      if (r.complexity > ms.maxComplexity) return false;
      if (r.prepMinutes > ms.maxPrepMinutes) return false;
      if (ms.excludedProteins.contains(r.proteinId)) return false;
      // Equipment check
      for (final eq in r.requiresEquipment) {
        final mapped = KitchenEquipment.values.firstWhere(
          (k) => k.name == eq, orElse: () => KitchenEquipment.oven);
        if (!ms.availableEquipment.contains(mapped)) return false;
      }
      // Disliked ingredients
      for (final ri in r.ingredients) {
        final ing = iMap[ri.ingredientId];
        if (ing == null) continue;
        if (ms.dislikedIngredients.any((d) =>
            d.toLowerCase() == ing.name.toLowerCase())) return false;
      }
      return true;
    }).toList();

    // Objective filter
    switch (ms.objective) {
      case MealObjective.highProtein:
        final hp = pool.where((r) => r.isHighProtein).toList();
        if (hp.isNotEmpty) pool = hp;
        break;
      case MealObjective.lowCarb:
        final lc = pool.where((r) => r.isLowCarb).toList();
        if (lc.isNotEmpty) pool = lc;
        break;
      case MealObjective.vegetarian:
        final veg = pool.where((r) => r.isVegetarian).toList();
        if (veg.isNotEmpty) pool = veg;
        break;
      default:
        break;
    }

    if (pool.isEmpty) pool = _recipes.toList(); // fallback: no filters
    return pool;
  }

  // Determine veggie day indices (distributed evenly across month)
  final Set<int> veggieDays = {};
  if (ms.veggieDaysPerWeek > 0 && ms.objective != MealObjective.vegetarian) {
    final totalVegDays = (ms.veggieDaysPerWeek * daysInMonth / 7).round();
    final step = daysInMonth / (totalVegDays + 1);
    for (int i = 1; i <= totalVegDays; i++) {
      veggieDays.add((step * i).round().clamp(1, daysInMonth));
    }
  }

  final days = <MealDay>[];

  // Per-meal-type tracking for waste minimization
  final usedIngredientsThisWeek = <MealType, Set<String>>{
    for (final m in ms.enabledMeals) m: {}
  };
  final newIngredientCountThisWeek = <MealType, int>{
    for (final m in ms.enabledMeals) m: 0
  };

  // Batch cooking tracking: {mealType: {recipeId, daysRemaining}}
  final batchState = <MealType, ({String recipeId, int daysLeft})>{};

  for (int day = 1; day <= daysInMonth; day++) {
    // Reset weekly tracking on Mondays (weekday 1)
    final weekday = DateTime(forMonth.year, forMonth.month, day).weekday;
    if (weekday == 1) {
      for (final m in ms.enabledMeals) {
        usedIngredientsThisWeek[m] = {};
        newIngredientCountThisWeek[m] = 0;
      }
    }

    final isVeggieDay = veggieDays.contains(day);

    for (final mealType in ms.enabledMeals) {
      // --- Batch cooking ---
      if (ms.batchCookingEnabled && batchState.containsKey(mealType)) {
        final state = batchState[mealType]!;
        if (state.daysLeft > 0) {
          final recipe = recipeMap[state.recipeId]!;
          final cost = recipeCost(recipe, np, iMap) *
              (mealBudgets[mealType]! / totalBudget);
          days.add(MealDay(
            dayIndex: day,
            recipeId: state.recipeId,
            costEstimate: cost,
            mealType: mealType,
          ));
          batchState[mealType] = (
            recipeId: state.recipeId,
            daysLeft: state.daysLeft - 1,
          );
          continue;
        } else {
          batchState.remove(mealType);
        }
      }

      // --- Leftovers (lunch reuses previous dinner) ---
      if (ms.reuseLeftovers && mealType == MealType.lunch && day > 1) {
        final prevDinner = days.lastWhere(
          (d) => d.dayIndex == day - 1 && d.mealType == MealType.dinner,
          orElse: () => MealDay(dayIndex: 0, recipeId: '', costEstimate: 0),
        );
        if (prevDinner.recipeId.isNotEmpty) {
          days.add(MealDay(
            dayIndex: day,
            recipeId: prevDinner.recipeId,
            isLeftover: true,
            costEstimate: 0,
            mealType: MealType.lunch,
          ));
          continue;
        }
      }

      var pool = _basePool(mealType);

      // Force veggie on designated days
      if (isVeggieDay) {
        final veg = pool.where((r) => r.isVegetarian).toList();
        if (veg.isNotEmpty) pool = veg;
      }

      // Sort by objective
      if (ms.objective == MealObjective.minimizeCost || ms.prioritizeLowCost) {
        pool.sort((a, b) => recipeCost(a, np, iMap).compareTo(recipeCost(b, np, iMap)));
      }

      // Waste minimization: prefer recipes with known ingredients
      if (ms.minimizeWaste) {
        final used = usedIngredientsThisWeek[mealType]!;
        final reuseFirst = pool.where((r) =>
            r.ingredients.every((ri) => used.contains(ri.ingredientId))).toList();
        if (reuseFirst.isNotEmpty) pool = reuseFirst;
      }

      // Max new ingredients cap
      if (ms.maxNewIngredientsPerWeek < 10) {
        final used = usedIngredientsThisWeek[mealType]!;
        final remaining = ms.maxNewIngredientsPerWeek - (newIngredientCountThisWeek[mealType] ?? 0);
        if (remaining <= 0) {
          final noNew = pool.where((r) =>
              r.ingredients.every((ri) => used.contains(ri.ingredientId))).toList();
          if (noNew.isNotEmpty) pool = noNew;
        }
      }

      // Favorites boost
      if (favorites.isNotEmpty) {
        final boosted = pool.where((r) {
          final ing = iMap[r.proteinId];
          if (ing == null) return false;
          return favorites.any((fav) =>
              fav.toLowerCase().contains(ing.name.toLowerCase()) ||
              ing.name.toLowerCase().contains(fav.toLowerCase().split(' ').first));
        }).toList();
        if (boosted.isNotEmpty) pool = boosted;
      }

      // Pick recipe (rotate by day slot)
      final weekIndex = ((day - 1) ~/ 7).clamp(0, 3);
      final slotInWeek = (day - 1) % 7;
      final fallbackPool = pool.isNotEmpty ? pool : _recipes;
      final recipe = fallbackPool[
          (weekIndex * 7 + slotInWeek) % fallbackPool.length];

      final mealBudgetRatio = totalBudget > 0
          ? (mealBudgets[mealType] ?? 0) / totalBudget
          : 1.0;
      final cost = recipeCost(recipe, np, iMap) * mealBudgetRatio;

      days.add(MealDay(
        dayIndex: day,
        recipeId: recipe.id,
        costEstimate: cost,
        mealType: mealType,
      ));

      // Update ingredient tracking
      final used = usedIngredientsThisWeek[mealType]!;
      int newCount = newIngredientCountThisWeek[mealType] ?? 0;
      for (final ri in recipe.ingredients) {
        if (!used.contains(ri.ingredientId)) {
          used.add(ri.ingredientId);
          newCount++;
        }
      }
      newIngredientCountThisWeek[mealType] = newCount;

      // Start batch cooking block if applicable and on preferred day
      if (ms.batchCookingEnabled && recipe.batchCookable && ms.maxBatchDays > 1) {
        final isPreferredDay = ms.preferredCookingWeekday == null ||
            weekday - 1 == ms.preferredCookingWeekday;
        if (isPreferredDay && !batchState.containsKey(mealType)) {
          batchState[mealType] = (
            recipeId: recipe.id,
            daysLeft: recipe.maxBatchDays.clamp(1, ms.maxBatchDays) - 1,
          );
        }
      }
    }
  }

  var plan = MealPlan(
    month: forMonth.month,
    year: forMonth.year,
    nPessoas: np,
    monthlyBudget: totalBudget,
    days: days,
    totalEstimatedCost: days.fold(0.0, (s, d) => s + d.costEstimate),
    generatedAt: DateTime.now(),
  );

  plan = _enforceBudget(plan, np, iMap);
  return plan;
}
```

**Step 3: Update `_enforceBudget` to filter by same mealType**

In `_enforceBudget`, when looking for cheaper alternatives, also match on `mealType` awareness (the budget enforcement only cares about cost, no change needed to the method — it operates on `MealDay.costEstimate` directly and swaps same-protein recipes). No change needed.

**Step 4: Verify**

```bash
flutter analyze lib/services/meal_planner_service.dart
```
Expected: no errors

---

## Task 6: Create `lib/screens/meal_wizard_screen.dart`

**Files:**
- Create: `lib/screens/meal_wizard_screen.dart`

**Step 1: Create the 5-step wizard**

```dart
import 'package:flutter/material.dart';
import '../models/meal_settings.dart';

class MealWizardScreen extends StatefulWidget {
  final MealSettings initial;
  final ValueChanged<MealSettings> onComplete;

  const MealWizardScreen({
    super.key,
    required this.initial,
    required this.onComplete,
  });

  @override
  State<MealWizardScreen> createState() => _MealWizardScreenState();
}

class _MealWizardScreenState extends State<MealWizardScreen> {
  late MealSettings _draft;
  int _step = 0;
  final _pageController = PageController();

  static const _totalSteps = 5;
  static const _stepTitles = [
    'Refeições',
    'Objetivo',
    'Restrições',
    'Cozinha',
    'Estratégia',
  ];

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finish() {
    final completed = _draft.copyWith(wizardCompleted: true);
    widget.onComplete(completed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _back,
              )
            : null,
        title: Text(
          _stepTitles[_step],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / _totalSteps,
            backgroundColor: const Color(0xFFE2E8F0),
            color: const Color(0xFF3B82F6),
            minHeight: 4,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step1Meals(
                  draft: _draft,
                  onChanged: (s) => setState(() => _draft = s),
                ),
                _Step2Objective(
                  draft: _draft,
                  onChanged: (s) => setState(() => _draft = s),
                ),
                _Step3Restrictions(
                  draft: _draft,
                  onChanged: (s) => setState(() => _draft = s),
                ),
                _Step4Kitchen(
                  draft: _draft,
                  onChanged: (s) => setState(() => _draft = s),
                ),
                _Step5Strategy(
                  draft: _draft,
                  onChanged: (s) => setState(() => _draft = s),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  if (_step == _totalSteps - 1)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 16, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Podes alterar as definições do planeador em qualquer altura em Definições → Refeições.',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF1E40AF)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _step == _totalSteps - 1 ? 'Gerar Plano' : 'Continuar',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Text(
                    'Passo ${_step + 1} de $_totalSteps',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Step 1: Refeições ---
class _Step1Meals extends StatelessWidget {
  final MealSettings draft;
  final ValueChanged<MealSettings> onChanged;
  const _Step1Meals({required this.draft, required this.onChanged});

  static const _weights = {
    MealType.breakfast: '10%',
    MealType.lunch: '35%',
    MealType.snack: '15%',
    MealType.dinner: '40%',
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Quais refeições queres incluir no plano diário?',
          style: TextStyle(fontSize: 15, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 20),
        ...MealType.values.map((mt) {
          final enabled = draft.enabledMeals.contains(mt);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFFE2E8F0),
                width: enabled ? 2 : 1,
              ),
            ),
            child: SwitchListTile(
              value: enabled,
              onChanged: (v) {
                final newSet = Set<MealType>.from(draft.enabledMeals);
                if (v) newSet.add(mt); else newSet.remove(mt);
                if (newSet.isEmpty) return; // must have at least 1
                onChanged(draft.copyWith(enabledMeals: newSet));
              },
              title: Text(mt.label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('${_weights[mt]} do orçamento',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF94A3B8))),
              activeTrackColor: const Color(0xFF3B82F6),
            ),
          );
        }),
      ],
    );
  }
}

// --- Step 2: Objetivo ---
class _Step2Objective extends StatelessWidget {
  final MealSettings draft;
  final ValueChanged<MealSettings> onChanged;
  const _Step2Objective({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Qual é o objetivo principal do teu plano alimentar?',
          style: TextStyle(fontSize: 15, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 20),
        ...MealObjective.values.map((obj) {
          final selected = draft.objective == obj;
          return GestureDetector(
            onTap: () {
              var updated = draft.copyWith(objective: obj);
              if (obj == MealObjective.vegetarian) {
                updated = updated.copyWith(veggieDaysPerWeek: 7);
              }
              onChanged(updated);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFEFF6FF) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFE2E8F0),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFCBD5E1),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(obj.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF475569),
                      )),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// --- Step 3: Restrições ---
class _Step3Restrictions extends StatefulWidget {
  final MealSettings draft;
  final ValueChanged<MealSettings> onChanged;
  const _Step3Restrictions({required this.draft, required this.onChanged});

  @override
  State<_Step3Restrictions> createState() => _Step3RestrictionsState();
}

class _Step3RestrictionsState extends State<_Step3Restrictions> {
  final _dislikedCtrl = TextEditingController();

  @override
  void dispose() {
    _dislikedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.draft;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _sectionLabel('RESTRIÇÕES DIETÉTICAS'),
        const SizedBox(height: 8),
        ...[
          ('Sem glúten', d.glutenFree,
              (v) => widget.onChanged(d.copyWith(glutenFree: v))),
          ('Sem lactose', d.lactoseFree,
              (v) => widget.onChanged(d.copyWith(lactoseFree: v))),
          ('Sem frutos secos', d.nutFree,
              (v) => widget.onChanged(d.copyWith(nutFree: v))),
          ('Sem marisco', d.shellfishFree,
              (v) => widget.onChanged(d.copyWith(shellfishFree: v))),
        ].map(
          (item) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.$1,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            value: item.$2,
            activeColor: const Color(0xFF3B82F6),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (v) => item.$3(v ?? false),
          ),
        ),
        const SizedBox(height: 20),
        _sectionLabel('INGREDIENTES QUE NÃO GOSTAS'),
        const SizedBox(height: 8),
        if (d.dislikedIngredients.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: d.dislikedIngredients
                .map((name) => Chip(
                      label: Text(name, style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        final updated = List<String>.from(d.dislikedIngredients)
                          ..remove(name);
                        widget.onChanged(d.copyWith(dislikedIngredients: updated));
                      },
                    ))
                .toList(),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _dislikedCtrl,
                decoration: InputDecoration(
                  hintText: 'ex: atum, brócolos',
                  hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF3B82F6), width: 2)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () {
                final text = _dislikedCtrl.text.trim();
                if (text.isEmpty) return;
                final updated = [...d.dislikedIngredients, text];
                widget.onChanged(d.copyWith(dislikedIngredients: updated));
                _dislikedCtrl.clear();
              },
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6)),
            ),
          ],
        ),
      ],
    );
  }
}

// --- Step 4: Cozinha ---
class _Step4Kitchen extends StatelessWidget {
  final MealSettings draft;
  final ValueChanged<MealSettings> onChanged;
  const _Step4Kitchen({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final prepOptions = [15, 30, 45, 60];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _sectionLabel('TEMPO MÁXIMO POR REFEIÇÃO'),
        const SizedBox(height: 12),
        Row(
          children: prepOptions.map((mins) {
            final selected = draft.maxPrepMinutes == mins;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: mins != prepOptions.last ? 8 : 0),
                child: GestureDetector(
                  onTap: () =>
                      onChanged(draft.copyWith(maxPrepMinutes: mins)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF3B82F6)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      mins == 60 ? '60+' : '${mins}min',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _sectionLabel('COMPLEXIDADE MÁXIMA'),
        const SizedBox(height: 12),
        Row(
          children: [
            ('Fácil', 2),
            ('Médio', 3),
            ('Avançado', 5),
          ].map(((String, int) item) {
            final selected = draft.maxComplexity == item.$2;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: item.$2 != 5 ? 8 : 0),
                child: GestureDetector(
                  onTap: () =>
                      onChanged(draft.copyWith(maxComplexity: item.$2)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF3B82F6)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.$1,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _sectionLabel('EQUIPAMENTO DISPONÍVEL'),
        const SizedBox(height: 8),
        ...KitchenEquipment.values.map((eq) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(eq.label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              value: draft.availableEquipment.contains(eq),
              activeColor: const Color(0xFF3B82F6),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (v) {
                final updated = Set<KitchenEquipment>.from(
                    draft.availableEquipment);
                if (v == true) updated.add(eq); else updated.remove(eq);
                onChanged(draft.copyWith(availableEquipment: updated));
              },
            )),
      ],
    );
  }
}

// --- Step 5: Estratégia ---
class _Step5Strategy extends StatelessWidget {
  final MealSettings draft;
  final ValueChanged<MealSettings> onChanged;
  const _Step5Strategy({required this.draft, required this.onChanged});

  static const _weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Batch cooking',
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: const Text('Cozinhar para vários dias de uma vez',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          value: draft.batchCookingEnabled,
          activeTrackColor: const Color(0xFF3B82F6),
          onChanged: (v) =>
              onChanged(draft.copyWith(batchCookingEnabled: v)),
        ),
        if (draft.batchCookingEnabled) ...[
          const SizedBox(height: 12),
          _sectionLabel('MÁXIMO DE DIAS POR RECEITA'),
          Slider(
            value: draft.maxBatchDays.toDouble(),
            min: 1,
            max: 4,
            divisions: 3,
            label: '${draft.maxBatchDays} dias',
            activeColor: const Color(0xFF3B82F6),
            onChanged: (v) =>
                onChanged(draft.copyWith(maxBatchDays: v.round())),
          ),
          _sectionLabel('DIA PREFERIDO PARA COZINHAR'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: List.generate(7, (i) {
              final selected = draft.preferredCookingWeekday == i;
              return ChoiceChip(
                label: Text(_weekdays[i]),
                selected: selected,
                selectedColor: const Color(0xFF3B82F6),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF475569),
                  fontSize: 12,
                ),
                onSelected: (v) => onChanged(
                  draft.copyWith(
                      preferredCookingWeekday: v ? i : null),
                ),
              );
            }),
          ),
        ],
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Reaproveitar sobras',
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: const Text('Jantar de ontem = almoço de hoje (custo 0)',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          value: draft.reuseLeftovers,
          activeTrackColor: const Color(0xFF3B82F6),
          onChanged: (v) => onChanged(draft.copyWith(reuseLeftovers: v)),
        ),
        const SizedBox(height: 16),
        _sectionLabel('MÁXIMO DE INGREDIENTES NOVOS POR SEMANA'),
        Slider(
          value: draft.maxNewIngredientsPerWeek.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: draft.maxNewIngredientsPerWeek == 10
              ? 'Sem limite'
              : '${draft.maxNewIngredientsPerWeek}',
          activeColor: const Color(0xFF3B82F6),
          onChanged: (v) => onChanged(
              draft.copyWith(maxNewIngredientsPerWeek: v.round())),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Minimizar desperdício',
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: const Text(
              'Prefere receitas que reutilizam ingredientes já usados',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          value: draft.minimizeWaste,
          activeTrackColor: const Color(0xFF3B82F6),
          onChanged: (v) => onChanged(draft.copyWith(minimizeWaste: v)),
        ),
      ],
    );
  }
}

Widget _sectionLabel(String text) => Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
        letterSpacing: 1.2,
      ),
    );
```

**Step 2: Verify**

```bash
flutter analyze lib/screens/meal_wizard_screen.dart
```
Expected: no errors

---

## Task 7: Update `lib/screens/settings_screen.dart`

**Files:**
- Modify: `lib/screens/settings_screen.dart`

**Step 1: Add import**

At top of file, after existing imports:
```dart
import '../models/meal_settings.dart';
```

**Step 2: Add `initialSection` parameter to `SettingsScreen`**

In `SettingsScreen` widget, add optional param:
```dart
  final String? initialSection;
```

In `const SettingsScreen({...})` constructor:
```dart
    this.initialSection,
```

**Step 3: Use `initialSection` in `initState`**

In `_SettingsScreenState.initState()`, after `_draft = widget.settings;` add:
```dart
    if (widget.initialSection != null) {
      _openSection = widget.initialSection;
    }
```

**Step 4: Add "Refeições" section header and body after "Produtos Favoritos" section**

In `build()`, after `if (_openSection == 'favorites') _buildFavoritesSection(),` add:

```dart
                    _SectionHeader(
                      icon: Icons.restaurant,
                      title: 'Refeições',
                      isOpen: _openSection == 'meals',
                      onTap: () => _toggleSection('meals'),
                    ),
                    if (_openSection == 'meals') _buildMealsSection(),
```

**Step 5: Add `_buildMealsSection()` method** (add before `_buildCoachSection()`):

```dart
  Widget _buildMealsSection() {
    final ms = _draft.mealSettings;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Refeições ativas
          _label('REFEIÇÕES ATIVAS'),
          const SizedBox(height: 8),
          ...MealType.values.map((mt) => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(mt.label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                value: ms.enabledMeals.contains(mt),
                activeTrackColor: const Color(0xFF3B82F6),
                onChanged: (v) {
                  final newSet = Set<MealType>.from(ms.enabledMeals);
                  if (v) newSet.add(mt); else newSet.remove(mt);
                  if (newSet.isEmpty) return;
                  setState(() => _draft = _draft.copyWith(
                      mealSettings: ms.copyWith(enabledMeals: newSet)));
                },
              )),
          const SizedBox(height: 16),
          // Objetivo
          _label('OBJETIVO'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MealObjective>(
                value: ms.objective,
                isExpanded: true,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569)),
                items: MealObjective.values
                    .map((o) =>
                        DropdownMenuItem(value: o, child: Text(o.label)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  var updated = ms.copyWith(objective: v);
                  if (v == MealObjective.vegetarian) {
                    updated = updated.copyWith(veggieDaysPerWeek: 7);
                  }
                  setState(() => _draft = _draft.copyWith(mealSettings: updated));
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Dias vegetarianos
          _label('DIAS VEGETARIANOS POR SEMANA'),
          Slider(
            value: ms.veggieDaysPerWeek.toDouble(),
            min: 0,
            max: 7,
            divisions: 7,
            label: '${ms.veggieDaysPerWeek}',
            activeColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(veggieDaysPerWeek: v.round()))),
          ),
          const SizedBox(height: 8),
          // Restrições
          _label('RESTRIÇÕES DIETÉTICAS'),
          ...[
            ('Sem glúten', ms.glutenFree,
                (bool v) => setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(glutenFree: v)))),
            ('Sem lactose', ms.lactoseFree,
                (bool v) => setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(lactoseFree: v)))),
            ('Sem frutos secos', ms.nutFree,
                (bool v) => setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(nutFree: v)))),
            ('Sem marisco', ms.shellfishFree,
                (bool v) => setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(shellfishFree: v)))),
          ].map((item) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.$1,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                value: item.$2,
                activeColor: const Color(0xFF3B82F6),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) => item.$3(v ?? false),
              )),
          const SizedBox(height: 16),
          // Tempo e complexidade
          _label('TEMPO MÁXIMO (MINUTOS)'),
          Slider(
            value: ms.maxPrepMinutes.toDouble(),
            min: 15,
            max: 60,
            divisions: 3,
            label: ms.maxPrepMinutes == 60 ? '60+' : '${ms.maxPrepMinutes}',
            activeColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(maxPrepMinutes: v.round()))),
          ),
          _label('COMPLEXIDADE MÁXIMA (${ms.maxComplexity}/5)'),
          Slider(
            value: ms.maxComplexity.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '${ms.maxComplexity}',
            activeColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(maxComplexity: v.round()))),
          ),
          const SizedBox(height: 8),
          // Equipamento
          _label('EQUIPAMENTO DISPONÍVEL'),
          ...KitchenEquipment.values.map((eq) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(eq.label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                value: ms.availableEquipment.contains(eq),
                activeColor: const Color(0xFF3B82F6),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) {
                  final updated = Set<KitchenEquipment>.from(ms.availableEquipment);
                  if (v == true) updated.add(eq); else updated.remove(eq);
                  setState(() => _draft = _draft.copyWith(
                      mealSettings: ms.copyWith(availableEquipment: updated)));
                },
              )),
          const SizedBox(height: 16),
          // Batch cooking
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Batch cooking',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            value: ms.batchCookingEnabled,
            activeTrackColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(batchCookingEnabled: v))),
          ),
          if (ms.batchCookingEnabled) ...[
            _label('MÁXIMO DE DIAS POR RECEITA'),
            Slider(
              value: ms.maxBatchDays.toDouble(),
              min: 1,
              max: 4,
              divisions: 3,
              label: '${ms.maxBatchDays}',
              activeColor: const Color(0xFF3B82F6),
              onChanged: (v) => setState(() => _draft = _draft.copyWith(
                  mealSettings: ms.copyWith(maxBatchDays: v.round()))),
            ),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reaproveitar sobras',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            value: ms.reuseLeftovers,
            activeTrackColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(reuseLeftovers: v))),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Minimizar desperdício',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            value: ms.minimizeWaste,
            activeTrackColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(minimizeWaste: v))),
          ),
          const SizedBox(height: 16),
          // Repor Wizard
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _draft = _draft.copyWith(
                  mealSettings: ms.copyWith(wizardCompleted: false))),
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Repor Wizard'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
```

**Step 6: Update `_handleSave` to also save `mealSettings`**

`_handleSave` calls `widget.onSave(_draft)` — `_draft` already includes `mealSettings` since it's part of `AppSettings`. No extra change needed.

**Step 7: Verify**

```bash
flutter analyze lib/screens/settings_screen.dart
```
Expected: no errors

---

## Task 8: Update `lib/screens/meal_planner_screen.dart`

**Files:**
- Modify: `lib/screens/meal_planner_screen.dart`

**Step 1: Add imports**

```dart
import '../models/meal_settings.dart';
import 'settings_screen.dart';
import 'meal_wizard_screen.dart';
```

**Step 2: Add wizard gate to `build()`**

In `build()`, before the `return Scaffold(...)`, add wizard gate:

```dart
  @override
  Widget build(BuildContext context) {
    // Show wizard if not completed
    if (!widget.settings.mealSettings.wizardCompleted) {
      return MealWizardScreen(
        initial: widget.settings.mealSettings,
        onComplete: (ms) {
          // Save settings then generate plan
          final updated = widget.settings.copyWith(mealSettings: ms);
          // We need to propagate via onSave — use a callback
          // For now, trigger via navigation pop and settings save
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MealPlannerScreen(
                settings: updated,
                apiKey: widget.apiKey,
                favorites: widget.favorites,
                onAddToShoppingList: widget.onAddToShoppingList,
                householdId: widget.householdId,
                onSaveSettings: widget.onSaveSettings,
              ),
            ),
          );
          widget.onSaveSettings(updated);
          // Generate plan with new settings
        },
      );
    }
    // ... rest of build
```

Wait — `MealPlannerScreen` needs an `onSaveSettings` callback to propagate `MealSettings` changes up to `AppHome`. Add this parameter:

```dart
class MealPlannerScreen extends StatefulWidget {
  final AppSettings settings;
  final String apiKey;
  final List<String> favorites;
  final void Function(ShoppingItem) onAddToShoppingList;
  final String householdId;
  final ValueChanged<AppSettings> onSaveSettings; // NEW

  const MealPlannerScreen({
    super.key,
    required this.settings,
    required this.apiKey,
    required this.favorites,
    required this.onAddToShoppingList,
    required this.householdId,
    required this.onSaveSettings, // NEW
  });
```

**Step 3: Update wizard completion handler** (simplified — no pushReplacement needed, just save and generate):

```dart
    if (!widget.settings.mealSettings.wizardCompleted) {
      return MealWizardScreen(
        initial: widget.settings.mealSettings,
        onComplete: (ms) {
          final updated = widget.settings.copyWith(mealSettings: ms);
          widget.onSaveSettings(updated);
          _generatePlan();
        },
      );
    }
```

Since `widget.settings` is passed from parent, after `onSaveSettings` the parent rebuilds with updated settings and the wizard gate passes. Then call `_generatePlan()`.

**Step 4: Add ⚙️ button to AppBar**

In `_buildAppBar()` (or in the AppBar in `build()`), add actions:

```dart
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Planeador de Refeições',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Definições',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  settings: widget.settings,
                  onSave: (s) => widget.onSaveSettings(s),
                  favorites: widget.favorites,
                  onSaveFavorites: (_) {},
                  apiKey: widget.apiKey,
                  onSaveApiKey: (_) {},
                  isAdmin: true,
                  householdId: widget.householdId,
                  initialSection: 'meals',
                ),
              ),
            ),
          ),
        ],
      ),
```

**Step 5: Add confirmation dialog to "Regenerar" button**

Replace the existing `TextButton.icon` "Regenerar":
```dart
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Regenerar plano?'),
                          content: const Text(
                              'O plano atual será substituído. Continuar?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                final plan = _plan!;
                                setState(() => _plan = null);
                                _service.clear(
                                    widget.householdId, plan.month, plan.year);
                              },
                              style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6)),
                              child: const Text('Regenerar'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Regenerar'),
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B)),
                  ),
```

**Step 6: Update `_DayCard` to show `mealType` label**

In `_DayCard.build()`, after the `'Dia ${mealDay.dayIndex}'` chip, add meal type label:

```dart
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            mealDay.mealType.label,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B)),
                          ),
                        ),
```

**Step 7: Update `_getWeekDays` — no change needed** (returns all MealDay objects for the week; with multiple per day, the list is longer but still correct)

**Step 8: Verify**

```bash
flutter analyze lib/screens/meal_planner_screen.dart
```
Expected: no errors

---

## Task 9: Update `lib/main.dart`

**Files:**
- Modify: `lib/main.dart`

**Step 1: Add `onSaveSettings` to `MealPlannerScreen` construction**

In `_AppHomeState.build()`, find `MealPlannerScreen(...)` and add:

```dart
      MealPlannerScreen(
        settings: _settings,
        apiKey: _openAiApiKey,
        favorites: _favorites,
        onAddToShoppingList: _addToShoppingList,
        householdId: widget.householdId,
        onSaveSettings: _saveSettings,  // NEW
      ),
```

**Step 2: Verify**

```bash
flutter analyze lib/main.dart
```
Expected: no errors

---

## Task 10: Build and commit

**Step 1: Full build**

```bash
cd monthy_budget_flutter && flutter build apk --release --no-tree-shake-icons
```
Expected: `✓ Built build/app/outputs/flutter-apk/app-release.apk`

**Step 2: Commit**

```bash
git add lib/models/meal_settings.dart \
        lib/models/meal_planner.dart \
        lib/models/app_settings.dart \
        assets/meal_planner/recipes.json \
        lib/services/meal_planner_service.dart \
        lib/screens/meal_wizard_screen.dart \
        lib/screens/settings_screen.dart \
        lib/screens/meal_planner_screen.dart \
        lib/main.dart

git commit -m "claude/budget-calculator-app-TFWgZ: add meal settings wizard and configurable meal generator"
```
