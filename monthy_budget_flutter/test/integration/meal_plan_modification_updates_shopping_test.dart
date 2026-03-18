import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/services/planning_interchange_service.dart';

import 'helpers/meal_plan_flow_helpers.dart';

void main() {
  group('meal plan modification flow', () {
    test('swapping a meal updates the derived shopping list', () {
      final mealPlanner = loadMealPlannerServiceFromAssets();
      final settings = makeMealPlannerSettings(
        enabledMeals: const {MealType.dinner},
      );
      final originalPlan = mealPlanner.generate(settings, DateTime(2026, 3));
      final firstDinner = originalPlan.days.first;
      final replacement = mealPlanner
          .alternativesFor(firstDinner.recipeId, originalPlan.nPessoas)
          .firstWhere((recipe) => recipe.id != firstDinner.recipeId);

      final originalItems = buildShoppingItemsFromPlan(
        mealPlanner,
        originalPlan,
      );
      final updatedPlan = mealPlanner.swapDay(
        originalPlan,
        firstDinner.dayIndex,
        firstDinner.mealType,
        replacement.id,
      );
      final updatedItems = buildShoppingItemsFromPlan(mealPlanner, updatedPlan);

      final originalByName = {
        for (final item in originalItems)
          if (item.quantity != null) item.productName: item.quantity!,
      };
      final updatedByName = {
        for (final item in updatedItems)
          if (item.quantity != null) item.productName: item.quantity!,
      };

      final changedProducts = {
        ...originalByName.keys,
        ...updatedByName.keys,
      }.where((name) => originalByName[name] != updatedByName[name]).toList();

      expect(changedProducts, isNotEmpty);
      expect(updatedPlan.days.first.recipeId, replacement.id);

      final interchange = PlanningInterchangeService();
      final restored = interchange.importShoppingListJson(
        interchange.exportShoppingListJson(updatedItems),
      );
      expect(restored.length, updatedItems.length);
    });
  });
}
