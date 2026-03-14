import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/services/meal_planner_ai_service.dart';

void main() {
  group('MealPlannerAiService local batch prep fallback', () {
    const ovenRecipe = Recipe(
      id: 'frango_assado',
      name: 'Frango Assado',
      proteinId: 'frango',
      type: RecipeType.carne,
      complexity: 1,
      prepMinutes: 45,
      servings: 4,
      batchCookable: true,
      requiresEquipment: ['oven'],
      ingredients: [
        RecipeIngredient(ingredientId: 'frango', quantity: 1),
        RecipeIngredient(ingredientId: 'cebola', quantity: 0.2),
      ],
    );

    const stoveRecipe = Recipe(
      id: 'arroz_frango',
      name: 'Arroz de Frango',
      proteinId: 'frango',
      type: RecipeType.carne,
      complexity: 2,
      prepMinutes: 30,
      servings: 4,
      batchCookable: true,
      ingredients: [
        RecipeIngredient(ingredientId: 'frango', quantity: 0.5),
        RecipeIngredient(ingredientId: 'cebola', quantity: 0.1),
        RecipeIngredient(ingredientId: 'arroz', quantity: 0.3),
      ],
    );

    test('builds a deterministic fallback plan with concrete steps', () {
      final plan = MealPlannerAiService.buildLocalBatchPlan(
        batchRecipes: const [ovenRecipe, stoveRecipe],
        nPessoas: 4,
        locale: 'en',
      );

      expect(plan.prepOrder, isNotEmpty);
      expect(plan.prepOrder.first, contains('Preheat the oven'));
      expect(plan.prepOrder.join(' '), contains('Frango Assado'));
      expect(plan.prepOrder.join(' '), contains('Arroz de Frango'));
      expect(plan.totalTimeEstimate, isNotEmpty);
      expect(plan.parallelTips, isNotEmpty);
    });

    test('mentions shared ingredients in portuguese fallback when they repeat', () {
      final plan = MealPlannerAiService.buildLocalBatchPlan(
        batchRecipes: const [ovenRecipe, stoveRecipe],
        nPessoas: 4,
        locale: 'pt',
      );

      expect(
        plan.prepOrder.any(
          (step) => step.contains('frango') || step.contains('cebola'),
        ),
        isTrue,
      );
      expect(plan.parallelTips.join(' '), contains('semana'));
    });
  });
}
