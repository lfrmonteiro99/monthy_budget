import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/services/meal_planner_ai_service.dart';

void main() {
  group('MealPlannerAiService.buildLocalPrepSteps', () {
    const recipe = Recipe(
      id: 'bacalhau_bras',
      name: 'Bacalhau à Brás',
      proteinId: 'bacalhau',
      type: RecipeType.peixe,
      complexity: 2,
      prepMinutes: 35,
      servings: 4,
      batchCookable: false,
      ingredients: [
        RecipeIngredient(ingredientId: 'bacalhau', quantity: 0.4),
        RecipeIngredient(ingredientId: 'batata', quantity: 0.3),
        RecipeIngredient(ingredientId: 'cebola', quantity: 0.15),
        RecipeIngredient(ingredientId: 'ovo', quantity: 0.2),
      ],
    );

    const ovenRecipe = Recipe(
      id: 'frango_forno',
      name: 'Frango no Forno',
      proteinId: 'frango',
      type: RecipeType.carne,
      complexity: 1,
      prepMinutes: 50,
      servings: 4,
      batchCookable: true,
      requiresEquipment: ['oven'],
      ingredients: [
        RecipeIngredient(ingredientId: 'frango', quantity: 1),
      ],
    );

    test('returns non-empty steps for a recipe without prepSteps', () {
      final steps = MealPlannerAiService.buildLocalPrepSteps(
        recipe: recipe,
        nPessoas: 4,
        locale: 'en',
      );
      expect(steps, isNotEmpty);
      expect(steps.length, greaterThanOrEqualTo(3));
    });

    test('includes recipe name in step text', () {
      final steps = MealPlannerAiService.buildLocalPrepSteps(
        recipe: recipe,
        nPessoas: 4,
        locale: 'en',
      );
      expect(steps.any((s) => s.contains('Bacalhau à Brás')), isTrue);
    });

    test('mentions oven preheat when recipe requires oven', () {
      final steps = MealPlannerAiService.buildLocalPrepSteps(
        recipe: ovenRecipe,
        nPessoas: 4,
        locale: 'en',
      );
      expect(
        steps.any((s) => s.toLowerCase().contains('oven')),
        isTrue,
      );
    });

    test('produces portuguese fallback steps when locale is pt', () {
      final steps = MealPlannerAiService.buildLocalPrepSteps(
        recipe: recipe,
        nPessoas: 4,
        locale: 'pt',
      );
      expect(steps, isNotEmpty);
      // Should contain portuguese text
      expect(
        steps.any((s) => s.contains('Bacalhau à Brás')),
        isTrue,
      );
    });

    test('scales ingredient step for nPessoas', () {
      final steps = MealPlannerAiService.buildLocalPrepSteps(
        recipe: recipe,
        nPessoas: 2,
        locale: 'en',
      );
      // Should mention serving count
      expect(steps.any((s) => s.contains('2')), isTrue);
    });
  });

  group('generateBatchPlan always returns a usable plan', () {
    test('buildLocalBatchPlan never returns empty prepOrder for non-empty recipes', () {
      const recipe = Recipe(
        id: 'test_batch',
        name: 'Test Batch Recipe',
        proteinId: 'frango',
        type: RecipeType.carne,
        complexity: 1,
        prepMinutes: 30,
        servings: 4,
        batchCookable: true,
        ingredients: [
          RecipeIngredient(ingredientId: 'frango', quantity: 1),
        ],
      );

      final plan = MealPlannerAiService.buildLocalBatchPlan(
        batchRecipes: const [recipe],
        nPessoas: 4,
        locale: 'en',
      );

      expect(plan.prepOrder, isNotEmpty);
      expect(plan.totalTimeEstimate, isNotEmpty);
    });
  });
}
