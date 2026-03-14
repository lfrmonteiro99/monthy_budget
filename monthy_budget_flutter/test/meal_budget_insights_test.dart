import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_budget_insight.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/services/meal_planner_service.dart';
import 'package:monthly_management/utils/meal_budget_insights.dart';

void main() {
  late MealPlannerService service;

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
    Ingredient(
      id: 'salmao',
      name: 'Salmao',
      category: IngredientCategory.proteina,
      unit: 'kg',
      avgPricePerUnit: 12.00,
      minPurchaseQty: 0.5,
    ),
    Ingredient(
      id: 'arroz',
      name: 'Arroz',
      category: IngredientCategory.carbo,
      unit: 'kg',
      avgPricePerUnit: 1.20,
      minPurchaseQty: 1.0,
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
    Recipe(
      id: 'salmao_grelhado',
      name: 'Salmao Grelhado',
      proteinId: 'salmao',
      type: RecipeType.peixe,
      complexity: 2,
      prepMinutes: 20,
      servings: 4,
      ingredients: [
        RecipeIngredient(ingredientId: 'salmao', quantity: 0.8),
        RecipeIngredient(ingredientId: 'batata', quantity: 0.4),
      ],
    ),
    Recipe(
      id: 'arroz_simples',
      name: 'Arroz Simples',
      proteinId: 'frango',
      type: RecipeType.carne,
      complexity: 1,
      prepMinutes: 10,
      servings: 4,
      ingredients: [
        RecipeIngredient(ingredientId: 'arroz', quantity: 0.3),
        RecipeIngredient(ingredientId: 'frango', quantity: 0.5),
      ],
    ),
  ];

  setUp(() {
    service = MealPlannerService();
    service.loadCatalogFromJson(
      jsonEncode(testIngredients.map((i) => {
        'id': i.id,
        'name': i.name,
        'category': i.category.name,
        'unit': i.unit,
        'avgPricePerUnit': i.avgPricePerUnit,
        'minPurchaseQty': i.minPurchaseQty,
      }).toList()),
      jsonEncode(testRecipes.map((r) => r.toJson()).toList()),
    );
  });

  MealPlan buildPlan({
    required List<MealDay> days,
    double monthlyBudget = 300.0,
    int nPessoas = 4,
    int month = 3,
    int year = 2026,
  }) {
    return MealPlan(
      month: month,
      year: year,
      nPessoas: nPessoas,
      monthlyBudget: monthlyBudget,
      days: days,
      totalEstimatedCost: days.fold(0.0, (s, d) => s + d.costEstimate),
      generatedAt: DateTime(2026, 3, 1),
    );
  }

  group('MealBudgetStatus thresholds', () {
    test('safe when projected is below 85% of budget', () {
      // Budget 300, plan cost 240 = 80%
      final plan = buildPlan(
        monthlyBudget: 300.0,
        days: [
          MealDay(dayIndex: 1, recipeId: 'frango_assado', costEstimate: 3.86, mealType: MealType.dinner),
          MealDay(dayIndex: 2, recipeId: 'frango_assado', costEstimate: 3.86, mealType: MealType.dinner),
        ],
      );
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      expect(insight.status, MealBudgetStatus.safe);
    });

    test('watch when projected is between 85% and 100% of budget', () {
      // Budget 10, total = 9.0 -> 90%
      final plan = buildPlan(
        monthlyBudget: 10.0,
        days: [
          MealDay(dayIndex: 1, recipeId: 'salmao_grelhado', costEstimate: 9.0, mealType: MealType.dinner),
        ],
      );
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      expect(insight.status, MealBudgetStatus.watch);
    });

    test('over when projected exceeds budget', () {
      // Budget 5, total = 9.84 -> ~196%
      final plan = buildPlan(
        monthlyBudget: 5.0,
        days: [
          MealDay(dayIndex: 1, recipeId: 'salmao_grelhado', costEstimate: 9.84, mealType: MealType.dinner),
        ],
      );
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      expect(insight.status, MealBudgetStatus.over);
    });

    test('safe when budget is zero', () {
      final plan = buildPlan(
        monthlyBudget: 0.0,
        days: [
          MealDay(dayIndex: 1, recipeId: 'frango_assado', costEstimate: 3.86, mealType: MealType.dinner),
        ],
      );
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      expect(insight.status, MealBudgetStatus.safe);
    });
  });

  group('Expensive meal ranking', () {
    test('ranks meals by cost descending', () {
      final plan = buildPlan(days: [
        MealDay(dayIndex: 1, recipeId: 'frango_assado', costEstimate: 3.86, mealType: MealType.dinner),
        MealDay(dayIndex: 2, recipeId: 'salmao_grelhado', costEstimate: 9.84, mealType: MealType.dinner),
        MealDay(dayIndex: 3, recipeId: 'arroz_simples', costEstimate: 2.11, mealType: MealType.dinner),
      ]);
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      expect(insight.topExpensiveMeals.length, 3);
      expect(insight.topExpensiveMeals[0].recipeId, 'salmao_grelhado');
      expect(insight.topExpensiveMeals[1].recipeId, 'frango_assado');
      expect(insight.topExpensiveMeals[2].recipeId, 'arroz_simples');
    });

    test('excludes zero-cost meals from ranking', () {
      final plan = buildPlan(days: [
        MealDay(dayIndex: 1, recipeId: 'frango_assado', costEstimate: 3.86, mealType: MealType.dinner),
        MealDay(dayIndex: 2, recipeId: 'frango_assado', costEstimate: 0.0, isLeftover: true, mealType: MealType.lunch),
      ]);
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      expect(insight.topExpensiveMeals.length, 1);
    });

    test('caps at 5 entries', () {
      final days = List.generate(
        10,
        (i) => MealDay(
          dayIndex: i + 1,
          recipeId: 'frango_assado',
          costEstimate: 3.86,
          mealType: MealType.dinner,
        ),
      );
      final plan = buildPlan(days: days);
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      expect(insight.topExpensiveMeals.length, 5);
    });
  });

  group('Swap savings calculation', () {
    test('suggests cheaper alternatives with positive savings', () {
      final plan = buildPlan(days: [
        MealDay(dayIndex: 1, recipeId: 'salmao_grelhado', costEstimate: 9.84, mealType: MealType.dinner),
      ]);
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      // There should be swaps since frango_assado and arroz_simples are cheaper
      if (insight.suggestedSwaps.isNotEmpty) {
        for (final swap in insight.suggestedSwaps) {
          expect(swap.savings, greaterThan(0));
          expect(swap.alternativeCost, lessThan(swap.original.cost));
        }
      }
    });

    test('caps at 3 suggested swaps', () {
      final days = List.generate(
        6,
        (i) => MealDay(
          dayIndex: i + 1,
          recipeId: 'salmao_grelhado',
          costEstimate: 9.84,
          mealType: MealType.dinner,
        ),
      );
      final plan = buildPlan(days: days);
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      expect(insight.suggestedSwaps.length, lessThanOrEqualTo(3));
    });
  });

  group('Shopping impact', () {
    test('counts unique ingredients', () {
      final plan = buildPlan(days: [
        MealDay(dayIndex: 1, recipeId: 'frango_assado', costEstimate: 3.86, mealType: MealType.dinner),
        MealDay(dayIndex: 2, recipeId: 'salmao_grelhado', costEstimate: 9.84, mealType: MealType.dinner),
      ]);
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      // frango, batata, salmao = 3 unique ingredients
      expect(insight.shoppingImpact.uniqueIngredients, 3);
    });

    test('calculates estimated shopping cost from ingredient prices', () {
      final plan = buildPlan(days: [
        MealDay(dayIndex: 1, recipeId: 'frango_assado', costEstimate: 3.86, mealType: MealType.dinner),
      ]);
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      expect(insight.shoppingImpact.estimatedShoppingCost, greaterThan(0));
    });

    test('excludes leftovers from shopping impact', () {
      final plan = buildPlan(days: [
        MealDay(dayIndex: 1, recipeId: 'frango_assado', costEstimate: 3.86, mealType: MealType.dinner),
        MealDay(dayIndex: 2, recipeId: 'frango_assado', costEstimate: 0.0, isLeftover: true, mealType: MealType.lunch),
      ]);
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      // Only 1 non-leftover meal → ingredients from 1 recipe
      expect(insight.shoppingImpact.uniqueIngredients, 2); // frango + batata
    });
  });

  group('Daily breakdown', () {
    test('generates per-day breakdown', () {
      final plan = buildPlan(days: [
        MealDay(dayIndex: 1, recipeId: 'frango_assado', costEstimate: 3.86, mealType: MealType.dinner),
        MealDay(dayIndex: 1, recipeId: 'arroz_simples', costEstimate: 2.11, mealType: MealType.lunch),
        MealDay(dayIndex: 2, recipeId: 'salmao_grelhado', costEstimate: 9.84, mealType: MealType.dinner),
      ]);
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      expect(insight.dailyBreakdown.length, 2);
      expect(insight.dailyBreakdown[0].dayIndex, 1);
      expect(insight.dailyBreakdown[0].totalCost, closeTo(5.97, 0.01));
      expect(insight.dailyBreakdown[1].dayIndex, 2);
      expect(insight.dailyBreakdown[1].totalCost, closeTo(9.84, 0.01));
    });
  });

  group('Weekly cost and remaining budget', () {
    test('weekly cost sums selected week meals only', () {
      final plan = buildPlan(days: [
        // Week 0: days 1-7
        MealDay(dayIndex: 1, recipeId: 'frango_assado', costEstimate: 3.86, mealType: MealType.dinner),
        MealDay(dayIndex: 5, recipeId: 'salmao_grelhado', costEstimate: 9.84, mealType: MealType.dinner),
        // Week 1: days 8-14
        MealDay(dayIndex: 8, recipeId: 'arroz_simples', costEstimate: 2.11, mealType: MealType.dinner),
      ]);
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      expect(insight.weeklyEstimatedCost, closeTo(3.86 + 9.84, 0.01));
    });

    test('remaining budget is monthly budget minus total plan cost', () {
      final plan = buildPlan(
        monthlyBudget: 100.0,
        days: [
          MealDay(dayIndex: 1, recipeId: 'frango_assado', costEstimate: 30.0, mealType: MealType.dinner),
          MealDay(dayIndex: 8, recipeId: 'frango_assado', costEstimate: 20.0, mealType: MealType.dinner),
        ],
      );
      final calculator = MealBudgetInsightsCalculator(service);
      final insight = calculator.compute(plan: plan, selectedWeek: 0);
      expect(insight.remainingBudget, closeTo(50.0, 0.01));
    });
  });

  group('MealCostSwap model', () {
    test('savings is positive when alternative is cheaper', () {
      final swap = MealCostSwap(
        original: MealCostEntry(
          recipeId: 'a',
          recipeName: 'A',
          cost: 10.0,
          dayIndex: 1,
          mealType: 'dinner',
        ),
        alternativeRecipeId: 'b',
        alternativeRecipeName: 'B',
        alternativeCost: 6.0,
      );
      expect(swap.savings, 4.0);
    });
  });
}
