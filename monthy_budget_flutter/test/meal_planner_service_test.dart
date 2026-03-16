import 'dart:convert';
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
}
