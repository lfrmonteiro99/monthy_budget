# Meal Planner Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a monthly dinner planner tab that generates a cost-minimised 30-day dinner plan within the food budget defined in settings.

**Architecture:** Hybrid — local greedy algorithm with ingredient clustering controls all numeric decisions (budget, cost, selection); OpenAI enriches recipe steps asynchronously post-generation. Static JSON catalogs bundled as assets. Integrates with existing ShoppingListService, AppSettings, and AiCoachService API key.

**Tech Stack:** Flutter/Dart, SharedPreferences, http (existing), flutter_test (existing).

---

## Task 1: Static asset catalogs + pubspec

**Files:**
- Create: `assets/meal_planner/ingredients.json`
- Create: `assets/meal_planner/recipes.json`
- Modify: `pubspec.yaml`

**Step 1: Create ingredients catalog**

```json
[
  {"id":"frango","name":"Frango","category":"proteina","unit":"kg","avgPricePerUnit":3.50,"minPurchaseQty":1.0},
  {"id":"carne_picada","name":"Carne Picada","category":"proteina","unit":"kg","avgPricePerUnit":5.50,"minPurchaseQty":0.5},
  {"id":"ovo","name":"Ovos","category":"proteina","unit":"unidade","avgPricePerUnit":0.22,"minPurchaseQty":6.0},
  {"id":"feijao","name":"Feijão","category":"proteina","unit":"kg","avgPricePerUnit":1.50,"minPurchaseQty":0.5},
  {"id":"grao","name":"Grão de Bico","category":"proteina","unit":"kg","avgPricePerUnit":1.80,"minPurchaseQty":0.5},
  {"id":"lentilhas","name":"Lentilhas","category":"proteina","unit":"kg","avgPricePerUnit":1.60,"minPurchaseQty":0.5},
  {"id":"pescada","name":"Pescada","category":"proteina","unit":"kg","avgPricePerUnit":5.50,"minPurchaseQty":0.5},
  {"id":"bacalhau","name":"Bacalhau","category":"proteina","unit":"kg","avgPricePerUnit":9.00,"minPurchaseQty":0.4},
  {"id":"chourico","name":"Chouriço","category":"proteina","unit":"kg","avgPricePerUnit":6.00,"minPurchaseQty":0.2},
  {"id":"cenoura","name":"Cenoura","category":"vegetal","unit":"kg","avgPricePerUnit":0.90,"minPurchaseQty":1.0},
  {"id":"cebola","name":"Cebola","category":"vegetal","unit":"kg","avgPricePerUnit":0.80,"minPurchaseQty":1.0},
  {"id":"batata","name":"Batata","category":"vegetal","unit":"kg","avgPricePerUnit":0.60,"minPurchaseQty":1.5},
  {"id":"tomate","name":"Tomate","category":"vegetal","unit":"kg","avgPricePerUnit":2.00,"minPurchaseQty":0.5},
  {"id":"courgette","name":"Courgette","category":"vegetal","unit":"kg","avgPricePerUnit":1.20,"minPurchaseQty":0.5},
  {"id":"espinafres","name":"Espinafres","category":"vegetal","unit":"kg","avgPricePerUnit":1.50,"minPurchaseQty":0.3},
  {"id":"broculos","name":"Brócolos","category":"vegetal","unit":"kg","avgPricePerUnit":1.80,"minPurchaseQty":0.5},
  {"id":"pimento","name":"Pimento","category":"vegetal","unit":"kg","avgPricePerUnit":1.50,"minPurchaseQty":0.3},
  {"id":"feijao_verde","name":"Feijão Verde","category":"vegetal","unit":"kg","avgPricePerUnit":1.80,"minPurchaseQty":0.5},
  {"id":"alho","name":"Alho","category":"condimento","unit":"kg","avgPricePerUnit":5.00,"minPurchaseQty":0.1},
  {"id":"tomate_pelado","name":"Tomate Pelado (lata)","category":"condimento","unit":"unidade","avgPricePerUnit":0.80,"minPurchaseQty":1.0},
  {"id":"azeite","name":"Azeite","category":"gordura","unit":"litro","avgPricePerUnit":8.00,"minPurchaseQty":0.5},
  {"id":"arroz","name":"Arroz","category":"carbo","unit":"kg","avgPricePerUnit":1.20,"minPurchaseQty":1.0},
  {"id":"massa","name":"Massa","category":"carbo","unit":"kg","avgPricePerUnit":1.00,"minPurchaseQty":0.5},
  {"id":"massa_lasanha","name":"Lasanha (folhas)","category":"carbo","unit":"kg","avgPricePerUnit":1.50,"minPurchaseQty":0.25},
  {"id":"pao","name":"Pão","category":"carbo","unit":"unidade","avgPricePerUnit":1.20,"minPurchaseQty":1.0}
]
```

**Step 2: Create recipes catalog**

```json
[
  {
    "id":"frango_assado","name":"Frango Assado com Batata","proteinId":"frango",
    "type":"carne","complexity":1,"prepMinutes":15,"servings":4,
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
    "ingredients":[
      {"ingredientId":"frango","quantity":0.5},
      {"ingredientId":"azeite","quantity":0.03}
    ]
  },
  {
    "id":"frango_broculos","name":"Frango com Brócolos","proteinId":"frango",
    "type":"carne","complexity":2,"prepMinutes":25,"servings":4,
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
    "ingredients":[
      {"ingredientId":"bacalhau","quantity":0.3},
      {"ingredientId":"grao","quantity":0.2},
      {"ingredientId":"alho","quantity":0.03},
      {"ingredientId":"azeite","quantity":0.05}
    ]
  }
]
```

**Step 3: Register assets in pubspec.yaml**

In `pubspec.yaml`, under `flutter.assets`, add:
```yaml
    - assets/meal_planner/ingredients.json
    - assets/meal_planner/recipes.json
```

**Step 4: Verify**
```
flutter pub get
```

---

## Task 2: Data models

**Files:**
- Create: `lib/models/meal_planner.dart`

**Step 1: Write the file**

```dart
import 'dart:convert';

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

  const Recipe({
    required this.id,
    required this.name,
    required this.proteinId,
    required this.type,
    required this.complexity,
    required this.prepMinutes,
    required this.servings,
    required this.ingredients,
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
      };
}

class MealDay {
  final int dayIndex;
  final String recipeId;
  final bool isLeftover;
  final double costEstimate;

  const MealDay({
    required this.dayIndex,
    required this.recipeId,
    this.isLeftover = false,
    required this.costEstimate,
  });

  MealDay copyWith({String? recipeId, double? costEstimate}) => MealDay(
        dayIndex: dayIndex,
        recipeId: recipeId ?? this.recipeId,
        isLeftover: isLeftover,
        costEstimate: costEstimate ?? this.costEstimate,
      );

  factory MealDay.fromJson(Map<String, dynamic> json) => MealDay(
        dayIndex: json['dayIndex'] as int,
        recipeId: json['recipeId'] as String,
        isLeftover: json['isLeftover'] as bool? ?? false,
        costEstimate: (json['costEstimate'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'dayIndex': dayIndex,
        'recipeId': recipeId,
        'isLeftover': isLeftover,
        'costEstimate': costEstimate,
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

  const MealPlan({
    required this.month,
    required this.year,
    required this.nPessoas,
    required this.monthlyBudget,
    required this.days,
    required this.totalEstimatedCost,
    required this.generatedAt,
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
```

---

## Task 3: MealPlannerService

**Files:**
- Create: `lib/services/meal_planner_service.dart`

```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_planner.dart';
import '../models/app_settings.dart';

class MealPlannerService {
  static const _planKey = 'meal_plan';

  // Protein clusters: dominant protein ids per week (index 0-3)
  static const _weekClusters = [
    ['frango'],
    ['carne_picada'],
    ['feijao', 'grao', 'lentilhas'],
    ['pescada', 'bacalhau'],
  ];
  static const _weekVariety = [
    ['feijao', 'grao', 'lentilhas'],
    ['ovo'],
    ['frango'],
    ['carne_picada'],
  ];

  List<Ingredient> _ingredients = [];
  List<Recipe> _recipes = [];
  bool _catalogLoaded = false;

  Future<void> loadCatalog() async {
    if (_catalogLoaded) return;
    final ingJson = await rootBundle.loadString('assets/meal_planner/ingredients.json');
    final recJson = await rootBundle.loadString('assets/meal_planner/recipes.json');
    _ingredients = (jsonDecode(ingJson) as List<dynamic>)
        .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
        .toList();
    _recipes = (jsonDecode(recJson) as List<dynamic>)
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
        .toList();
    _catalogLoaded = true;
  }

  List<Ingredient> get ingredients => _ingredients;
  List<Recipe> get recipes => _recipes;

  Map<String, Ingredient> get ingredientMap =>
      {for (final i in _ingredients) i.id: i};

  Map<String, Recipe> get recipeMap =>
      {for (final r in _recipes) r.id: r};

  // --- Settings helpers ---

  int nPessoas(AppSettings settings) {
    final titulares = settings.salaries
        .where((s) => s.enabled)
        .fold(0, (sum, s) => sum + s.titulares);
    return titulares + settings.personalInfo.dependentes;
  }

  double monthlyFoodBudget(AppSettings settings) {
    return settings.expenses
        .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // --- Cost calculation ---

  double recipeCost(Recipe recipe, int nPessoas, Map<String, Ingredient> iMap) {
    final scale = nPessoas / recipe.servings;
    return recipe.ingredients.fold(0.0, (sum, ri) {
      final ing = iMap[ri.ingredientId];
      if (ing == null) return sum;
      return sum + ri.quantity * scale * ing.avgPricePerUnit;
    });
  }

  // --- Plan generation ---

  MealPlan generate(AppSettings settings, DateTime forMonth) {
    assert(_catalogLoaded, 'Call loadCatalog() first');
    final np = nPessoas(settings);
    final budget = monthlyFoodBudget(settings);
    final iMap = ingredientMap;
    final now = forMonth;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final days = <MealDay>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final weekIndex = ((day - 1) ~/ 7).clamp(0, 3);
      final isVarietyDay = (day % 7 == 0); // last day of each 7-day block = variety

      final clusterIds = isVarietyDay
          ? _weekVariety[weekIndex]
          : _weekClusters[weekIndex];

      final candidates = _recipes
          .where((r) => clusterIds.contains(r.proteinId))
          .toList()
        ..sort((a, b) =>
            recipeCost(a, np, iMap).compareTo(recipeCost(b, np, iMap)));

      // Rotate within cluster to avoid repeating same recipe
      final slotInWeek = (day - 1) % 7;
      final recipe = candidates[slotInWeek % candidates.length];
      final cost = recipeCost(recipe, np, iMap);

      days.add(MealDay(dayIndex: day, recipeId: recipe.id, costEstimate: cost));
    }

    var plan = MealPlan(
      month: now.month,
      year: now.year,
      nPessoas: np,
      monthlyBudget: budget,
      days: days,
      totalEstimatedCost: days.fold(0.0, (s, d) => s + d.costEstimate),
      generatedAt: DateTime.now(),
    );

    // Budget validation: greedy descent
    plan = _enforcebudget(plan, np, iMap);

    return plan;
  }

  MealPlan _enforcebudget(MealPlan plan, int np, Map<String, Ingredient> iMap) {
    var days = List<MealDay>.from(plan.days);
    var total = days.fold(0.0, (s, d) => s + d.costEstimate);

    int iterations = 0;
    while (total > plan.monthlyBudget && iterations < 100) {
      iterations++;
      // Find most expensive day
      days.sort((a, b) => b.costEstimate.compareTo(a.costEstimate));
      final expensive = days.first;
      final currentRecipe = recipeMap[expensive.recipeId]!;

      // Find cheaper alternative in same cluster
      final cheaper = _recipes
          .where((r) =>
              r.proteinId == currentRecipe.proteinId &&
              r.id != currentRecipe.id)
          .map((r) => (recipe: r, cost: recipeCost(r, np, iMap)))
          .where((e) => e.cost < expensive.costEstimate)
          .toList()
        ..sort((a, b) => a.cost.compareTo(b.cost));

      if (cheaper.isEmpty) break;

      final replacement = cheaper.first;
      final idx = days.indexWhere((d) => d.dayIndex == expensive.dayIndex);
      days[idx] = expensive.copyWith(
        recipeId: replacement.recipe.id,
        costEstimate: replacement.cost,
      );
      total = days.fold(0.0, (s, d) => s + d.costEstimate);
    }

    days.sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    return plan.copyWithDays(days);
  }

  // --- Swap ---

  List<Recipe> alternativesFor(String recipeId, int np) {
    final current = recipeMap[recipeId];
    if (current == null) return [];
    final iMap = ingredientMap;
    return _recipes
        .where((r) => r.proteinId == current.proteinId && r.id != recipeId)
        .toList()
      ..sort((a, b) =>
          recipeCost(a, np, iMap).compareTo(recipeCost(b, np, iMap)));
  }

  MealPlan swapDay(MealPlan plan, int dayIndex, String newRecipeId) {
    final iMap = ingredientMap;
    final newRecipe = recipeMap[newRecipeId]!;
    final newCost = recipeCost(newRecipe, plan.nPessoas, iMap);
    final updatedDays = plan.days.map((d) {
      if (d.dayIndex == dayIndex) return d.copyWith(recipeId: newRecipeId, costEstimate: newCost);
      return d;
    }).toList();
    return plan.copyWithDays(updatedDays);
  }

  // --- Consolidated ingredient list ---

  Map<String, double> consolidatedIngredients(MealPlan plan) {
    final iMap = ingredientMap;
    final totals = <String, double>{};
    for (final day in plan.days) {
      final recipe = recipeMap[day.recipeId];
      if (recipe == null) continue;
      final scale = plan.nPessoas / recipe.servings;
      for (final ri in recipe.ingredients) {
        totals.update(
          ri.ingredientId,
          (v) => v + ri.quantity * scale,
          ifAbsent: () => ri.quantity * scale,
        );
      }
    }
    return totals;
  }

  // --- Persistence ---

  Future<MealPlan?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_planKey);
    if (raw == null) return null;
    try {
      return MealPlan.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(MealPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_planKey, plan.toJsonString());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_planKey);
  }
}
```

---

## Task 4: MealPlannerAiService

**Files:**
- Create: `lib/services/meal_planner_ai_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_planner.dart';

class MealPlannerAiService {
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  // In-memory cache: recipeId → content
  final Map<String, RecipeAiContent> _cache = {};

  Future<RecipeAiContent?> enrichRecipe({
    required String apiKey,
    required Recipe recipe,
    required Map<String, Ingredient> ingredientMap,
    required int nPessoas,
  }) async {
    if (apiKey.isEmpty) return null;
    if (_cache.containsKey(recipe.id)) return _cache[recipe.id];

    final ingList = recipe.ingredients.map((ri) {
      final ing = ingredientMap[ri.ingredientId];
      if (ing == null) return '';
      final scaled = ri.quantity * nPessoas / recipe.servings;
      return '${ing.name} ${scaled.toStringAsFixed(0)} ${ing.unit}';
    }).where((s) => s.isNotEmpty).join(', ');

    final prompt = '''
Receita: ${recipe.name}
Para $nPessoas pessoas.
Ingredientes: $ingList

Responde APENAS em JSON válido com esta estrutura:
{
  "steps": ["passo 1", "passo 2", "passo 3"],
  "tip": "uma dica curta",
  "variation": "uma variação possível"
}
''';

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content': 'És um chef português. Responde sempre em português europeu. '
                      'Responde APENAS com JSON válido, sem texto extra.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'max_tokens': 400,
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final content = (data['choices'] as List).first['message']['content'] as String;
        // Strip markdown code fences if present
        final clean = content.replaceAll(RegExp(r'```json|```'), '').trim();
        final parsed = jsonDecode(clean) as Map<String, dynamic>;
        final result = RecipeAiContent.fromJson(parsed);
        _cache[recipe.id] = result;
        return result;
      }
    } catch (_) {
      // Enrichment is best-effort; fail silently
    }
    return null;
  }
}
```

---

## Task 5: MealPlannerScreen

**Files:**
- Create: `lib/screens/meal_planner_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_settings.dart';
import '../models/meal_planner.dart';
import '../models/shopping_item.dart';
import '../services/meal_planner_service.dart';
import '../services/meal_planner_ai_service.dart';

class MealPlannerScreen extends StatefulWidget {
  final AppSettings settings;
  final String apiKey;
  final void Function(ShoppingItem) onAddToShoppingList;

  const MealPlannerScreen({
    super.key,
    required this.settings,
    required this.apiKey,
    required this.onAddToShoppingList,
  });

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final _service = MealPlannerService();
  final _aiService = MealPlannerAiService();

  MealPlan? _plan;
  bool _loading = false;
  bool _catalogReady = false;
  int _selectedWeek = 0;

  // recipeId → AI content
  final Map<String, RecipeAiContent> _aiContent = {};
  final Set<String> _aiPending = {};

  // expanded state per dayIndex
  final Set<int> _expanded = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _service.loadCatalog();
    final saved = await _service.load();
    setState(() {
      _plan = saved;
      _catalogReady = true;
    });
    if (saved != null) _enrichPlan(saved);
  }

  Future<void> _generatePlan() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final plan = _service.generate(widget.settings, now);
    await _service.save(plan);
    setState(() {
      _plan = plan;
      _loading = false;
      _selectedWeek = 0;
      _expanded.clear();
    });
    _enrichPlan(plan);
  }

  void _enrichPlan(MealPlan plan) {
    if (widget.apiKey.isEmpty) return;
    final iMap = _service.ingredientMap;
    final uniqueRecipeIds = plan.days.map((d) => d.recipeId).toSet();
    for (final recipeId in uniqueRecipeIds) {
      if (_aiContent.containsKey(recipeId) || _aiPending.contains(recipeId)) continue;
      _aiPending.add(recipeId);
      final recipe = _service.recipeMap[recipeId];
      if (recipe == null) continue;
      _aiService.enrichRecipe(
        apiKey: widget.apiKey,
        recipe: recipe,
        ingredientMap: iMap,
        nPessoas: plan.nPessoas,
      ).then((content) {
        if (content != null && mounted) {
          setState(() => _aiContent[recipeId] = content);
        }
        _aiPending.remove(recipeId);
      });
    }
  }

  void _swapRecipe(int dayIndex, String currentRecipeId) {
    final plan = _plan!;
    final alternatives = _service.alternativesFor(currentRecipeId, plan.nPessoas);
    final iMap = _service.ingredientMap;

    showModalBottomSheet(
      context: context,
      builder: (_) => _SwapSheet(
        alternatives: alternatives,
        currentRecipeId: currentRecipeId,
        nPessoas: plan.nPessoas,
        ingredientMap: iMap,
        service: _service,
        onSelect: (newRecipeId) {
          final updated = _service.swapDay(plan, dayIndex, newRecipeId);
          _service.save(updated);
          setState(() => _plan = updated);
          _enrichPlan(updated);
        },
      ),
    );
  }

  void _showConsolidatedList() {
    final plan = _plan!;
    final totals = _service.consolidatedIngredients(plan);
    final iMap = _service.ingredientMap;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ConsolidatedSheet(
        totals: totals,
        ingredientMap: iMap,
        nPessoas: plan.nPessoas,
        onAddToShoppingList: widget.onAddToShoppingList,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Planeador de Refeições',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: !_catalogReady
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : _plan == null
              ? _buildEmptyState()
              : _buildPlanView(),
    );
  }

  Widget _buildEmptyState() {
    if (!_catalogReady) return const SizedBox();
    final budget = _service.monthlyFoodBudget(widget.settings);
    final np = _service.nPessoas(widget.settings);
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy', 'pt_PT').format(now);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant_outlined, size: 64, color: Color(0xFF94A3B8)),
            const SizedBox(height: 24),
            Text(
              monthName[0].toUpperCase() + monthName.substring(1),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            _InfoRow(label: 'Orçamento alimentação', value: '${budget.toStringAsFixed(2)}€'),
            const SizedBox(height: 8),
            _InfoRow(label: 'Pessoas no agregado', value: '$np'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _generatePlan,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_loading ? 'A gerar...' : 'Gerar Plano Mensal'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanView() {
    final plan = _plan!;
    final budgetUsed = plan.totalEstimatedCost / plan.monthlyBudget;
    final weekDays = _getWeekDays(plan, _selectedWeek);

    return Column(
      children: [
        // Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${plan.totalEstimatedCost.toStringAsFixed(2)}€ / ${plan.monthlyBudget.toStringAsFixed(2)}€',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _plan = null);
                      _service.clear();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Regenerar'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: budgetUsed.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFFE2E8F0),
                color: budgetUsed > 1 ? Colors.red : const Color(0xFF3B82F6),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 12),
              // Week tabs
              Row(
                children: List.generate(4, (i) {
                  final selected = _selectedWeek == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedWeek = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Sem.${i + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        // Day cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: weekDays.length,
            itemBuilder: (_, i) => _DayCard(
              mealDay: weekDays[i],
              plan: plan,
              service: _service,
              aiContent: _aiContent[weekDays[i].recipeId],
              isExpanded: _expanded.contains(weekDays[i].dayIndex),
              onToggleExpand: () => setState(() {
                if (_expanded.contains(weekDays[i].dayIndex)) {
                  _expanded.remove(weekDays[i].dayIndex);
                } else {
                  _expanded.add(weekDays[i].dayIndex);
                }
              }),
              onSwap: () => _swapRecipe(weekDays[i].dayIndex, weekDays[i].recipeId),
              onAddIngredientToList: widget.onAddToShoppingList,
            ),
          ),
        ),
      ],
    );
  }

  List<MealDay> _getWeekDays(MealPlan plan, int weekIndex) {
    final start = weekIndex * 7 + 1;
    final end = (start + 6).clamp(1, plan.days.length);
    return plan.days.where((d) => d.dayIndex >= start && d.dayIndex <= end).toList();
  }
}

// ── Day Card ────────────────────────────────────────────────────────────────

class _DayCard extends StatelessWidget {
  final MealDay mealDay;
  final MealPlan plan;
  final MealPlannerService service;
  final RecipeAiContent? aiContent;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onSwap;
  final void Function(ShoppingItem) onAddIngredientToList;

  const _DayCard({
    required this.mealDay,
    required this.plan,
    required this.service,
    required this.aiContent,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onSwap,
    required this.onAddIngredientToList,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = service.recipeMap[mealDay.recipeId];
    if (recipe == null) return const SizedBox();
    final iMap = service.ingredientMap;
    final dayName = _dayName(mealDay.dayIndex);
    final costPerPerson = mealDay.costEstimate / plan.nPessoas;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dayName,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6)),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${mealDay.costEstimate.toStringAsFixed(2)}€',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Stars(recipe.complexity),
                    const SizedBox(width: 10),
                    const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 3),
                    Text('${recipe.prepMinutes}min',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    const SizedBox(width: 10),
                    const Icon(Icons.person_outline, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 3),
                    Text('${costPerPerson.toStringAsFixed(2)}€/pess',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onToggleExpand,
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 16,
                        ),
                        label: Text(isExpanded ? 'Fechar' : 'Ingredientes',
                            style: const TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSwap,
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: const Text('Trocar', style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Expanded ingredients
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ingredientes',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  ...recipe.ingredients.map((ri) {
                    final ing = iMap[ri.ingredientId];
                    if (ing == null) return const SizedBox();
                    final scale = plan.nPessoas / recipe.servings;
                    final qty = ri.quantity * scale;
                    final cost = qty * ing.avgPricePerUnit;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              ing.name,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            '${_formatQty(qty)} ${ing.unit}',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => onAddIngredientToList(ShoppingItem(
                              productName: ing.name,
                              store: '',
                              price: cost,
                              unitPrice: '${ing.avgPricePerUnit.toStringAsFixed(2)}€/${ing.unit}',
                            )),
                            child: const Icon(Icons.add_shopping_cart,
                                size: 18, color: Color(0xFF3B82F6)),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (aiContent != null) ...[
                    const SizedBox(height: 12),
                    const Text('Preparação',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    ...aiContent!.steps.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${e.key + 1}. ${e.value}',
                              style: const TextStyle(fontSize: 13)),
                        )),
                    if (aiContent!.tip.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(aiContent!.tip,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF92400E))),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _dayName(int dayIndex) {
    // Day of week based on dayIndex within the month
    // We need the actual date to get the weekday name
    return 'Dia $dayIndex';
  }

  String _formatQty(double qty) {
    if (qty == qty.roundToDouble()) return qty.round().toString();
    return qty.toStringAsFixed(1);
  }
}

// ── Swap Bottom Sheet ───────────────────────────────────────────────────────

class _SwapSheet extends StatelessWidget {
  final List<Recipe> alternatives;
  final String currentRecipeId;
  final int nPessoas;
  final Map<String, Ingredient> ingredientMap;
  final MealPlannerService service;
  final void Function(String) onSelect;

  const _SwapSheet({
    required this.alternatives,
    required this.currentRecipeId,
    required this.nPessoas,
    required this.ingredientMap,
    required this.service,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final currentCost = service.recipeCost(
        service.recipeMap[currentRecipeId]!, nPessoas, ingredientMap);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alternativas',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...alternatives.take(3).map((r) {
              final cost = service.recipeCost(r, nPessoas, ingredientMap);
              final delta = cost - currentCost;
              final deltaStr = delta >= 0 ? '+${delta.toStringAsFixed(2)}€' : '${delta.toStringAsFixed(2)}€';
              final deltaColor = delta > 0 ? Colors.red : const Color(0xFF16A34A);
              return ListTile(
                title: Text(r.name, style: const TextStyle(fontSize: 14)),
                subtitle: Text('${cost.toStringAsFixed(2)}€ total',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                trailing: Text(deltaStr, style: TextStyle(fontSize: 13, color: deltaColor, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  onSelect(r.id);
                },
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Consolidated List Sheet ─────────────────────────────────────────────────

class _ConsolidatedSheet extends StatelessWidget {
  final Map<String, double> totals;
  final Map<String, Ingredient> ingredientMap;
  final int nPessoas;
  final void Function(ShoppingItem) onAddToShoppingList;

  const _ConsolidatedSheet({
    required this.totals,
    required this.ingredientMap,
    required this.nPessoas,
    required this.onAddToShoppingList,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = <IngredientCategory, List<MapEntry<String, double>>>{};
    for (final entry in totals.entries) {
      final ing = ingredientMap[entry.key];
      if (ing == null) continue;
      grouped.putIfAbsent(ing.category, () => []).add(entry);
    }

    final categories = [
      IngredientCategory.proteina,
      IngredientCategory.vegetal,
      IngredientCategory.carbo,
      IngredientCategory.gordura,
      IngredientCategory.condimento,
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Lista Consolidada',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: categories.map((cat) {
                final items = grouped[cat];
                if (items == null || items.isEmpty) return const SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      _categoryLabel(cat).toUpperCase(),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 8),
                    ...items.map((entry) {
                      final ing = ingredientMap[entry.key]!;
                      final cost = entry.value * ing.avgPricePerUnit;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text(ing.name, style: const TextStyle(fontSize: 14))),
                            Text(
                              '${_fmt(entry.value)} ${ing.unit}',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(width: 8),
                            Text('${cost.toStringAsFixed(2)}€',
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => onAddToShoppingList(ShoppingItem(
                                productName: ing.name,
                                store: '',
                                price: cost,
                                unitPrice:
                                    '${ing.avgPricePerUnit.toStringAsFixed(2)}€/${ing.unit}',
                              )),
                              child: const Icon(Icons.add_shopping_cart,
                                  size: 18, color: Color(0xFF3B82F6)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(IngredientCategory cat) {
    switch (cat) {
      case IngredientCategory.proteina:
        return 'Proteínas';
      case IngredientCategory.vegetal:
        return 'Vegetais';
      case IngredientCategory.carbo:
        return 'Hidratos';
      case IngredientCategory.gordura:
        return 'Gorduras';
      case IngredientCategory.condimento:
        return 'Condimentos';
    }
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(1);
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  final int complexity;
  const _Stars(this.complexity);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
          5,
          (i) => Icon(
                i < complexity ? Icons.star : Icons.star_border,
                size: 13,
                color: const Color(0xFFF59E0B),
              )),
    );
  }
}
```

---

## Task 6: Wire into main.dart

**Files:**
- Modify: `lib/main.dart`

**Step 1: Add import**

At the top of `main.dart`, add:
```dart
import 'services/meal_planner_service.dart';
import 'screens/meal_planner_screen.dart';
```

**Step 2: Add MealPlannerService field in `_AppHomeState`**

After line `final _aiCoachService = AiCoachService();`, add:
```dart
final _mealPlannerService = MealPlannerService();
```

**Step 3: Add MealPlannerScreen to screens list**

In the `screens` list (after CoachScreen), add:
```dart
MealPlannerScreen(
  settings: _settings,
  apiKey: _openAiApiKey,
  onAddToShoppingList: _addToShoppingList,
),
```

**Step 4: Add NavigationDestination**

After the Coach destination in `NavigationBar.destinations`, add:
```dart
const NavigationDestination(
  icon: Icon(Icons.restaurant_outlined),
  selectedIcon: Icon(Icons.restaurant, color: Color(0xFF3B82F6)),
  label: 'Refeições',
),
```

---

## Task 7: Unit tests for MealPlannerService

**Files:**
- Create: `test/meal_planner_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/meal_planner.dart';
import 'package:orcamento_mensal/models/app_settings.dart';
import 'package:orcamento_mensal/services/meal_planner_service.dart';

void main() {
  final service = MealPlannerService();

  final testIngredients = [
    Ingredient(
      id: 'frango', name: 'Frango', category: IngredientCategory.proteina,
      unit: 'kg', avgPricePerUnit: 3.50, minPurchaseQty: 1.0,
    ),
    Ingredient(
      id: 'batata', name: 'Batata', category: IngredientCategory.vegetal,
      unit: 'kg', avgPricePerUnit: 0.60, minPurchaseQty: 1.5,
    ),
  ];

  final testRecipes = [
    Recipe(
      id: 'frango_assado', name: 'Frango Assado', proteinId: 'frango',
      type: RecipeType.carne, complexity: 1, prepMinutes: 15, servings: 4,
      ingredients: [
        RecipeIngredient(ingredientId: 'frango', quantity: 1.0),
        RecipeIngredient(ingredientId: 'batata', quantity: 0.6),
      ],
    ),
  ];

  final iMap = {for (final i in testIngredients) i.id: i};

  group('recipeCost', () {
    test('scales cost to nPessoas correctly', () {
      final cost = service.recipeCost(testRecipes[0], 4, iMap);
      // frango: 1.0 * 3.50 + batata: 0.6 * 0.60 = 3.50 + 0.36 = 3.86
      expect(cost, closeTo(3.86, 0.01));
    });

    test('scales up for more people', () {
      final cost4 = service.recipeCost(testRecipes[0], 4, iMap);
      final cost8 = service.recipeCost(testRecipes[0], 8, iMap);
      expect(cost8, closeTo(cost4 * 2, 0.01));
    });
  });

  group('nPessoas', () {
    test('sums enabled salary titulares + dependentes', () {
      final settings = AppSettings(
        salaries: const [
          SalaryInfo(label: 'S1', enabled: true, titulares: 1),
          SalaryInfo(label: 'S2', enabled: true, titulares: 1),
          SalaryInfo(label: 'S3', enabled: false, titulares: 1),
        ],
        personalInfo: const PersonalInfo(dependentes: 2),
      );
      expect(service.nPessoas(settings), 4); // 1+1 enabled + 2 dependentes
    });
  });

  group('monthlyFoodBudget', () {
    test('sums only enabled alimentacao expenses', () {
      final settings = AppSettings(
        expenses: const [
          ExpenseItem(id: 'food', label: 'Comida', amount: 200, category: ExpenseCategory.alimentacao),
          ExpenseItem(id: 'food2', label: 'Extra', amount: 50, category: ExpenseCategory.alimentacao, enabled: false),
          ExpenseItem(id: 'rent', label: 'Renda', amount: 700, category: ExpenseCategory.habitacao),
        ],
      );
      expect(service.monthlyFoodBudget(settings), 200.0);
    });
  });
}
```

**Step 5: Run tests**
```
flutter test test/meal_planner_service_test.dart
```
Expected: all pass.
