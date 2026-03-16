import '../models/meal_planner.dart';

class WasteItem {
  final String ingredientId;
  final double excessQty;
  final String unit;
  final double estimatedWasteCost;

  const WasteItem({
    required this.ingredientId,
    required this.excessQty,
    required this.unit,
    required this.estimatedWasteCost,
  });
}

class WasteCalculator {
  /// Returns waste risk for a recipe (0.0 = no waste, 1.0 = high waste).
  /// Based on ratio of ingredients with excess vs total ingredients.
  static double wasteRisk(
    Recipe recipe,
    int nPessoas,
    Map<String, Ingredient> ingredientMap,
  ) {
    if (recipe.ingredients.isEmpty) return 0;

    final scale = nPessoas / recipe.servings;
    int countWithExcess = 0;

    for (final ri in recipe.ingredients) {
      final ingredient = ingredientMap[ri.ingredientId];
      if (ingredient == null) continue;

      final needed = ri.quantity * scale;
      final minPurchase = ingredient.minPurchaseQty;
      if (minPurchase <= 0) continue;

      final purchases = (needed / minPurchase).ceil();
      final bought = purchases * minPurchase;
      final excess = bought - needed;

      if (excess > 0.01) {
        countWithExcess++;
      }
    }

    return (countWithExcess / recipe.ingredients.length).clamp(0.0, 1.0);
  }

  /// Returns list of ingredients with excess quantities after plan.
  /// Compares minPurchaseQty multiples vs actual needed quantity.
  static List<WasteItem> excessIngredients(
    Map<String, double> consolidatedTotals,
    Map<String, Ingredient> ingredientMap,
  ) {
    final items = <WasteItem>[];

    for (final entry in consolidatedTotals.entries) {
      final ingredient = ingredientMap[entry.key];
      if (ingredient == null) continue;

      final needed = entry.value;
      final minPurchase = ingredient.minPurchaseQty;
      if (minPurchase <= 0) continue;

      final purchases = (needed / minPurchase).ceil();
      final bought = purchases * minPurchase;
      final excess = bought - needed;

      if (excess > 0.01) {
        items.add(WasteItem(
          ingredientId: entry.key,
          excessQty: excess,
          unit: ingredient.unit,
          estimatedWasteCost: excess * ingredient.avgPricePerUnit,
        ));
      }
    }

    items.sort((a, b) => b.estimatedWasteCost.compareTo(a.estimatedWasteCost));
    return items;
  }

  /// Total estimated waste cost for a plan's consolidated ingredients.
  static double totalWasteCost(
    Map<String, double> consolidatedTotals,
    Map<String, Ingredient> ingredientMap,
  ) {
    return excessIngredients(consolidatedTotals, ingredientMap)
        .fold(0.0, (sum, item) => sum + item.estimatedWasteCost);
  }
}
