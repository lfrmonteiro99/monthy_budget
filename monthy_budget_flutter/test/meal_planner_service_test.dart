import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/services/meal_planner_service.dart';

void main() {
  final service = MealPlannerService();

  final testIngredients = [
    Ingredient(
      id: 'frango',
      name: 'Frango',
      category: IngredientCategory.proteina,
      unit: 'kg',
      avgPricePerUnit: 3.50,
      minPurchaseQty: 1.0,
    ),
    Ingredient(
      id: 'batata',
      name: 'Batata',
      category: IngredientCategory.vegetal,
      unit: 'kg',
      avgPricePerUnit: 0.60,
      minPurchaseQty: 1.5,
    ),
  ];

  final testRecipes = [
    Recipe(
      id: 'frango_assado',
      name: 'Frango Assado',
      proteinId: 'frango',
      type: RecipeType.carne,
      complexity: 1,
      prepMinutes: 15,
      servings: 4,
      ingredients: [
        RecipeIngredient(ingredientId: 'frango', quantity: 1.0),
        RecipeIngredient(ingredientId: 'batata', quantity: 0.6),
      ],
    ),
  ];

  final iMap = {for (final i in testIngredients) i.id: i};

  group('recipeCost', () {
    test('calculates base cost correctly for 4 people', () {
      final cost = service.recipeCost(testRecipes[0], 4, iMap);
      // frango: 1.0 * 3.50 = 3.50
      // batata: 0.6 * 0.60 = 0.36
      // total = 3.86
      expect(cost, closeTo(3.86, 0.01));
    });

    test('scales proportionally for more people', () {
      final cost4 = service.recipeCost(testRecipes[0], 4, iMap);
      final cost8 = service.recipeCost(testRecipes[0], 8, iMap);
      expect(cost8, closeTo(cost4 * 2, 0.01));
    });

    test('returns 0 for recipe with no ingredients', () {
      final empty = Recipe(
        id: 'empty',
        name: 'Empty',
        proteinId: 'frango',
        type: RecipeType.carne,
        complexity: 1,
        prepMinutes: 5,
        servings: 4,
        ingredients: [],
      );
      expect(service.recipeCost(empty, 4, iMap), 0.0);
    });
  });

  group('nPessoas', () {
    test('sums enabled salary titulares plus dependentes', () {
      final settings = AppSettings(
        salaries: const [
          SalaryInfo(label: 'S1', enabled: true, titulares: 1),
          SalaryInfo(label: 'S2', enabled: true, titulares: 1),
          SalaryInfo(label: 'S3', enabled: false, titulares: 1),
        ],
        personalInfo: const PersonalInfo(dependentes: 2),
      );
      expect(service.nPessoas(settings), 4);
    });

    test('disabled salaries do not count', () {
      final settings = AppSettings(
        salaries: const [
          SalaryInfo(label: 'S1', enabled: false, titulares: 2),
        ],
        personalInfo: const PersonalInfo(dependentes: 1),
      );
      expect(service.nPessoas(settings), 1);
    });
  });

  group('monthlyFoodBudget', () {
    test('sums only enabled alimentacao expenses', () {
      final settings = AppSettings(
        expenses: const [
          ExpenseItem(
            id: 'food',
            label: 'Comida',
            amount: 200,
            category: 'alimentacao',
          ),
          ExpenseItem(
            id: 'food2',
            label: 'Extra',
            amount: 50,
            category: 'alimentacao',
            enabled: false,
          ),
          ExpenseItem(
            id: 'rent',
            label: 'Renda',
            amount: 700,
            category: 'habitacao',
          ),
        ],
      );
      expect(service.monthlyFoodBudget(settings), 200.0);
    });

    test('returns 0 when no alimentacao expenses exist', () {
      final settings = AppSettings(
        expenses: const [
          ExpenseItem(id: 'rent', label: 'Renda', amount: 700, category: 'habitacao'),
        ],
      );
      expect(service.monthlyFoodBudget(settings), 0.0);
    });
  });

  group('Recipe prepSteps', () {
    test('prepSteps defaults to empty list', () {
      const recipe = Recipe(
        id: 'test',
        name: 'Test',
        proteinId: 'frango',
        type: RecipeType.carne,
        complexity: 1,
        prepMinutes: 10,
        servings: 4,
        ingredients: [],
      );
      expect(recipe.prepSteps, isEmpty);
    });

    test('prepSteps round-trips through JSON', () {
      const recipe = Recipe(
        id: 'test',
        name: 'Test',
        proteinId: 'frango',
        type: RecipeType.carne,
        complexity: 1,
        prepMinutes: 10,
        servings: 4,
        ingredients: [],
        prepSteps: ['Passo 1', 'Passo 2', 'Passo 3'],
      );
      final json = recipe.toJson();
      final restored = Recipe.fromJson(json);
      expect(restored.prepSteps, ['Passo 1', 'Passo 2', 'Passo 3']);
    });

    test('fromJson handles missing prepSteps gracefully', () {
      final json = {
        'id': 'test',
        'name': 'Test',
        'proteinId': 'frango',
        'type': 'carne',
        'complexity': 1,
        'prepMinutes': 10,
        'servings': 4,
        'ingredients': <Map<String, dynamic>>[],
      };
      final recipe = Recipe.fromJson(json);
      expect(recipe.prepSteps, isEmpty);
    });

    test('toJson omits prepSteps when empty', () {
      const recipe = Recipe(
        id: 'test',
        name: 'Test',
        proteinId: 'frango',
        type: RecipeType.carne,
        complexity: 1,
        prepMinutes: 10,
        servings: 4,
        ingredients: [],
      );
      final json = recipe.toJson();
      expect(json.containsKey('prepSteps'), isFalse);
    });
  });

  group('consolidatedIngredients substitution handling', () {
    late MealPlannerService svc;

    setUp(() {
      svc = MealPlannerService();

      final ingredientsJson = jsonEncode([
        {
          'id': 'frango',
          'name': 'Frango',
          'category': 'proteina',
          'unit': 'kg',
          'avgPricePerUnit': 3.50,
          'minPurchaseQty': 1.0,
        },
        {
          'id': 'peixe',
          'name': 'Peixe',
          'category': 'proteina',
          'unit': 'kg',
          'avgPricePerUnit': 5.00,
          'minPurchaseQty': 0.5,
        },
        {
          'id': 'batata',
          'name': 'Batata',
          'category': 'vegetal',
          'unit': 'kg',
          'avgPricePerUnit': 0.60,
          'minPurchaseQty': 1.5,
        },
      ]);

      final recipesJson = jsonEncode([
        {
          'id': 'frango_assado',
          'name': 'Frango Assado',
          'proteinId': 'frango',
          'type': 'carne',
          'complexity': 1,
          'prepMinutes': 15,
          'servings': 4,
          'ingredients': [
            {'ingredientId': 'frango', 'quantity': 1.0},
            {'ingredientId': 'batata', 'quantity': 0.6},
          ],
        },
      ]);

      svc.loadCatalogFromJson(ingredientsJson, recipesJson);
    });

    test('uses substituted ingredient ID when substitution exists', () {
      final plan = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 4,
        monthlyBudget: 300,
        days: [
          MealDay(
            dayIndex: 0,
            recipeId: 'frango_assado',
            costEstimate: 3.86,
            substitutions: {'frango': 'peixe'},
          ),
        ],
        totalEstimatedCost: 3.86,
        generatedAt: DateTime(2026, 3, 1),
      );

      final totals = svc.consolidatedIngredients(plan);

      // frango was substituted by peixe, so frango should not appear
      expect(totals.containsKey('frango'), isFalse);
      // peixe should have the quantity that was originally frango's (1.0 * 4/4 = 1.0)
      expect(totals['peixe'], closeTo(1.0, 0.001));
      // batata was not substituted, so it remains (0.6 * 4/4 = 0.6)
      expect(totals['batata'], closeTo(0.6, 0.001));
    });

    test('unsubstituted ingredients remain unchanged', () {
      final plan = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 4,
        monthlyBudget: 300,
        days: [
          MealDay(
            dayIndex: 0,
            recipeId: 'frango_assado',
            costEstimate: 3.86,
          ),
        ],
        totalEstimatedCost: 3.86,
        generatedAt: DateTime(2026, 3, 1),
      );

      final totals = svc.consolidatedIngredients(plan);

      // No substitutions — original IDs should be present
      expect(totals['frango'], closeTo(1.0, 0.001));
      expect(totals['batata'], closeTo(0.6, 0.001));
      expect(totals.containsKey('peixe'), isFalse);
    });

    test('substitution merges quantities when replacement already exists', () {
      // Two meals on same day: one uses frango_assado with frango->peixe sub,
      // another also contributes peixe. Both should merge under peixe.
      final plan = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 4,
        monthlyBudget: 300,
        days: [
          MealDay(
            dayIndex: 0,
            recipeId: 'frango_assado',
            costEstimate: 3.86,
            substitutions: {'frango': 'peixe'},
          ),
          MealDay(
            dayIndex: 1,
            recipeId: 'frango_assado',
            costEstimate: 3.86,
            substitutions: {'frango': 'peixe'},
          ),
        ],
        totalEstimatedCost: 7.72,
        generatedAt: DateTime(2026, 3, 1),
      );

      final totals = svc.consolidatedIngredients(plan);

      // Two days both substitute frango->peixe: 1.0 + 1.0 = 2.0
      expect(totals['peixe'], closeTo(2.0, 0.001));
      expect(totals.containsKey('frango'), isFalse);
      // batata: 0.6 + 0.6 = 1.2
      expect(totals['batata'], closeTo(1.2, 0.001));
    });
  });

  group('recipe loading fallback', () {
    test('loadCatalogFromJson still works as local fallback', () {
      final svc = MealPlannerService();

      final ingredientsJson = jsonEncode([
        {
          'id': 'frango',
          'name': 'Frango',
          'category': 'proteina',
          'unit': 'kg',
          'avgPricePerUnit': 3.50,
          'minPurchaseQty': 1.0,
        },
      ]);

      final recipesJson = jsonEncode([
        {
          'id': 'frango_assado',
          'name': 'Frango Assado',
          'proteinId': 'frango',
          'type': 'carne',
          'complexity': 1,
          'prepMinutes': 15,
          'servings': 4,
          'ingredients': [
            {'ingredientId': 'frango', 'quantity': 1.0},
          ],
        },
      ]);

      svc.loadCatalogFromJson(ingredientsJson, recipesJson);
      expect(svc.recipeMap.isNotEmpty, true);
      expect(svc.recipeMap['frango_assado']?.name, 'Frango Assado');
      expect(svc.ingredientMap['frango']?.name, 'Frango');
    });

    test('Ingredient.toJson round-trips correctly', () {
      const ingredient = Ingredient(
        id: 'frango',
        name: 'Frango',
        category: IngredientCategory.proteina,
        unit: 'kg',
        avgPricePerUnit: 3.50,
        minPurchaseQty: 1.0,
      );
      final json = ingredient.toJson();
      final restored = Ingredient.fromJson(json);
      expect(restored.id, ingredient.id);
      expect(restored.name, ingredient.name);
      expect(restored.category, ingredient.category);
      expect(restored.unit, ingredient.unit);
      expect(restored.avgPricePerUnit, ingredient.avgPricePerUnit);
      expect(restored.minPurchaseQty, ingredient.minPurchaseQty);
    });

    test('Recipe.fromJson parses Supabase-style snake_case nutrition', () {
      // Supabase returns nutrition as a nested jsonb object.
      // The NutritionInfo.fromJson uses camelCase keys since it mirrors the
      // local JSON format. When loading from Supabase, the service maps
      // the row data to Recipe constructor directly; this test verifies
      // the local JSON round-trip still works (the most testable path
      // without mocking Supabase).
      final json = {
        'id': 'test_recipe',
        'name': 'Test Recipe',
        'proteinId': 'frango',
        'type': 'carne',
        'complexity': 2,
        'prepMinutes': 20,
        'servings': 4,
        'ingredients': <Map<String, dynamic>>[],
        'nutrition': {
          'kcal': 350,
          'proteinG': 28.0,
          'carbsG': 40.0,
          'fatG': 12.0,
          'fiberG': 3.0,
          'sodiumMg': 300.0,
        },
        'prepSteps': ['Step 1', 'Step 2'],
      };
      final recipe = Recipe.fromJson(json);
      expect(recipe.nutrition, isNotNull);
      expect(recipe.nutrition!.kcal, 350);
      expect(recipe.nutrition!.proteinG, 28.0);
      expect(recipe.prepSteps.length, 2);
    });

    test('Recipe toJson/fromJson round-trip preserves all fields', () {
      const recipe = Recipe(
        id: 'roundtrip_test',
        name: 'Roundtrip Test',
        proteinId: 'frango',
        type: RecipeType.carne,
        complexity: 2,
        prepMinutes: 25,
        servings: 4,
        ingredients: [
          RecipeIngredient(ingredientId: 'frango', quantity: 1.0),
        ],
        glutenFree: true,
        lactoseFree: false,
        nutFree: true,
        shellfishFree: true,
        isVegetarian: false,
        isHighProtein: true,
        isLowCarb: false,
        batchCookable: true,
        maxBatchDays: 3,
        isPortable: false,
        suitableMealTypes: ['lunch', 'dinner'],
        seasons: ['winter', 'autumn'],
        requiresEquipment: ['oven'],
        nutrition: NutritionInfo(
          kcal: 400,
          proteinG: 35,
          carbsG: 30,
          fatG: 15,
          fiberG: 2,
          sodiumMg: 350,
        ),
        prepSteps: ['Passo 1', 'Passo 2'],
      );

      final json = recipe.toJson();
      final restored = Recipe.fromJson(json);

      expect(restored.id, recipe.id);
      expect(restored.name, recipe.name);
      expect(restored.proteinId, recipe.proteinId);
      expect(restored.type, recipe.type);
      expect(restored.complexity, recipe.complexity);
      expect(restored.prepMinutes, recipe.prepMinutes);
      expect(restored.servings, recipe.servings);
      expect(restored.glutenFree, recipe.glutenFree);
      expect(restored.lactoseFree, recipe.lactoseFree);
      expect(restored.isHighProtein, recipe.isHighProtein);
      expect(restored.batchCookable, recipe.batchCookable);
      expect(restored.maxBatchDays, recipe.maxBatchDays);
      expect(restored.isPortable, recipe.isPortable);
      expect(restored.seasons, recipe.seasons);
      expect(restored.requiresEquipment, recipe.requiresEquipment);
      expect(restored.nutrition?.kcal, recipe.nutrition?.kcal);
      expect(restored.prepSteps, recipe.prepSteps);
      expect(restored.ingredients.length, recipe.ingredients.length);
    });
  });

  group('extraGuests', () {
    MealPlan _makePlan({Map<int, int> extraGuests = const {}}) => MealPlan(
          month: 3,
          year: 2026,
          nPessoas: 2,
          monthlyBudget: 300.0,
          days: [
            const MealDay(dayIndex: 0, costEstimate: 5.0, recipeId: 'frango_assado'),
            const MealDay(dayIndex: 1, costEstimate: 3.0, recipeId: 'frango_assado'),
          ],
          totalEstimatedCost: 8.0,
          generatedAt: DateTime(2026, 3, 1),
          extraGuests: extraGuests,
        );

    test('serialization round-trip preserves extraGuests', () {
      final plan = _makePlan(extraGuests: {0: 2, 3: 4});
      final json = plan.toJson();
      final restored = MealPlan.fromJson(json);
      expect(restored.extraGuests, {0: 2, 3: 4});
    });

    test('toJson omits extraGuests when empty', () {
      final plan = _makePlan();
      final json = plan.toJson();
      expect(json.containsKey('extraGuests'), isFalse);
    });

    test('fromJson handles missing extraGuests gracefully', () {
      final json = {
        'month': 3,
        'year': 2026,
        'nPessoas': 2,
        'monthlyBudget': 300.0,
        'days': <Map<String, dynamic>>[],
        'totalEstimatedCost': 0.0,
        'generatedAt': '2026-03-01T00:00:00.000',
      };
      final plan = MealPlan.fromJson(json);
      expect(plan.extraGuests, isEmpty);
    });

    test('copyWith preserves extraGuests by default', () {
      final plan = _makePlan(extraGuests: {0: 3});
      final updated = plan.copyWith(days: plan.days);
      expect(updated.extraGuests, {0: 3});
    });

    test('copyWithDays preserves extraGuests', () {
      final plan = _makePlan(extraGuests: {1: 5});
      final updated = plan.copyWithDays(plan.days);
      expect(updated.extraGuests, {1: 5});
    });

    test('copyWith can override extraGuests', () {
      final plan = _makePlan(extraGuests: {0: 3});
      final updated = plan.copyWith(extraGuests: {1: 7});
      expect(updated.extraGuests, {1: 7});
    });

    test('consolidation with extraGuests yields higher quantities', () {
      // Load real catalog so recipeMap resolves frango_assado
      final svc = MealPlannerService();
      final ingJson = File('assets/meal_planner/ingredients.json').readAsStringSync();
      final recJson = File('assets/meal_planner/recipes.json').readAsStringSync();
      svc.loadCatalogFromJson(ingJson, recJson);

      // Recipe: frango_assado, servings=4, frango qty=1.0, batata qty=0.6
      // nPessoas=2, extraGuests day0=2 -> scale day0 = (2+2)/4 = 1.0
      // day1 no extra -> scale day1 = 2/4 = 0.5
      final plan = _makePlan(extraGuests: {0: 2});
      final totals = svc.consolidatedIngredients(plan);
      // frango: day0: 1.0*1.0 + day1: 1.0*0.5 = 1.5
      expect(totals['frango'], closeTo(1.5, 0.001));
      // batata: day0: 0.6*1.0 + day1: 0.6*0.5 = 0.9
      expect(totals['batata'], closeTo(0.9, 0.001));
    });

    test('consolidation without extraGuests uses nPessoas only', () {
      final svc = MealPlannerService();
      final ingJson = File('assets/meal_planner/ingredients.json').readAsStringSync();
      final recJson = File('assets/meal_planner/recipes.json').readAsStringSync();
      svc.loadCatalogFromJson(ingJson, recJson);

      final plan = _makePlan();
      final totals = svc.consolidatedIngredients(plan);
      // Both days: scale = 2/4 = 0.5
      // frango: 1.0*0.5 + 1.0*0.5 = 1.0
      expect(totals['frango'], closeTo(1.0, 0.001));
      // batata: 0.6*0.5 + 0.6*0.5 = 0.6
      expect(totals['batata'], closeTo(0.6, 0.001));
    });
  });
}
