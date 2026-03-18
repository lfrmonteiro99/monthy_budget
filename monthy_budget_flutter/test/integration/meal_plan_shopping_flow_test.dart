import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/services/planning_interchange_service.dart';

import 'helpers/meal_plan_flow_helpers.dart';

void main() {
  group('meal plan to shopping flow', () {
    test('generated plan becomes an exportable shopping list', () {
      final mealPlanner = loadMealPlannerServiceFromAssets();
      final settings = makeMealPlannerSettings();

      final generated = mealPlanner.generate(settings, DateTime(2026, 3));
      final plan = generated.copyWith(
        days: [
          ...generated.days,
          const MealDay(
            dayIndex: 31,
            mealKind: MealKind.freeform,
            costEstimate: 1.8,
            freeformTitle: 'Market stop',
            freeformShoppingItems: [
              FreeformMealItem(
                name: 'Banana',
                quantity: 6,
                unit: 'un',
                estimatedPrice: 1.8,
              ),
            ],
          ),
        ],
        totalEstimatedCost: generated.totalEstimatedCost + 1.8,
      );

      final shoppingItems = buildShoppingItemsFromPlan(mealPlanner, plan);
      expect(shoppingItems, isNotEmpty);
      expect(
        shoppingItems.any((item) => item.sourceMealLabels.isNotEmpty),
        isTrue,
      );

      final interchange = PlanningInterchangeService();
      final exported = interchange.exportShoppingListJson(shoppingItems);
      final restored = interchange.importShoppingListJson(exported);

      final banana = restored.firstWhere(
        (item) => item.productName == 'Banana',
      );
      expect(banana.quantity, 6);
      expect(banana.price, 1.8);
      expect(restored.length, shoppingItems.length);
    });
  });
}
