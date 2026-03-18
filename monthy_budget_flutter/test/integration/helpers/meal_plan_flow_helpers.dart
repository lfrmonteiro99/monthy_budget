import 'dart:io';

import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/models/shopping_item.dart';
import 'package:monthly_management/services/meal_planner_service.dart';
import 'package:monthly_management/utils/shopping_grouping.dart';

MealPlannerService loadMealPlannerServiceFromAssets() {
  final service = MealPlannerService();
  final ingredientsJson = File(
    'assets/meal_planner/ingredients.json',
  ).readAsStringSync();
  final recipesJson = File(
    'assets/meal_planner/recipes.json',
  ).readAsStringSync();
  service.loadCatalogFromJson(ingredientsJson, recipesJson);
  return service;
}

AppSettings makeMealPlannerSettings({
  int householdSize = 2,
  double foodBudget = 450,
  Set<MealType> enabledMeals = const {MealType.lunch, MealType.dinner},
}) {
  return AppSettings(
    salaries: const [SalaryInfo(label: 'Primary', enabled: true, titulares: 1)],
    personalInfo: const PersonalInfo(dependentes: 0),
    expenses: [
      ExpenseItem(
        id: 'food',
        label: 'Food',
        amount: foodBudget,
        category: 'alimentacao',
      ),
    ],
    mealSettings: MealSettings(
      householdSize: householdSize,
      enabledMeals: enabledMeals,
    ),
  );
}

List<ShoppingItem> buildShoppingItemsFromPlan(
  MealPlannerService service,
  MealPlan plan,
) {
  final totals = service.consolidatedIngredients(plan);
  final ingredientLabels = <String, Set<String>>{};

  for (final day in plan.days) {
    if (day.isLeftover || day.isFreeform) continue;
    final recipe = service.recipeMap[day.recipeId];
    if (recipe == null) continue;
    for (final ingredient in recipe.ingredients) {
      final effectiveId =
          day.substitutions[ingredient.ingredientId] ?? ingredient.ingredientId;
      (ingredientLabels[effectiveId] ??= <String>{}).add(recipe.name);
    }
  }

  final items = totals.entries
      .map((entry) {
        final ingredient = service.ingredientMap[entry.key]!;
        return ShoppingItem(
          productName: ingredient.name,
          store: '',
          price: entry.value * ingredient.avgPricePerUnit,
          quantity: entry.value,
          unit: ingredient.unit,
          sourceMealLabels: ingredientLabels[entry.key]?.toList() ?? const [],
        );
      })
      .toList(growable: true);

  for (final day in plan.days.where((day) => day.isFreeform)) {
    for (final freeformItem in day.freeformShoppingItems) {
      _mergeShoppingItem(
        items,
        ShoppingItem(
          productName: freeformItem.name,
          store: freeformItem.store ?? '',
          price: freeformItem.estimatedPrice ?? 0,
          quantity: freeformItem.quantity,
          unit: freeformItem.unit,
          sourceMealLabels: [
            if ((day.freeformTitle ?? '').isNotEmpty) day.freeformTitle!,
          ],
        ),
      );
    }
  }

  return items;
}

void _mergeShoppingItem(List<ShoppingItem> items, ShoppingItem item) {
  final result = mergeIntoList(items, item);
  if (result.isNew) {
    items.add(item);
    return;
  }

  final index = items.indexWhere(
    (existing) =>
        existing.productName.toLowerCase() == item.productName.toLowerCase(),
  );
  if (index != -1) {
    items[index] = result.merged!;
  }
}
