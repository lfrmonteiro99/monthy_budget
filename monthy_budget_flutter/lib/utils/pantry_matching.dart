import '../models/meal_planner.dart';
import '../models/meal_settings.dart';

/// Result of computing how well a recipe's ingredients are covered by the
/// user's pantry (staples + weekly).
class PantryCoverage {
  final List<String> matchedIngredients;
  final List<String> missingIngredients;
  final double coverageRatio;

  const PantryCoverage({
    required this.matchedIngredients,
    required this.missingIngredients,
    required this.coverageRatio,
  });
}

/// Resolve the full active pantry set by merging staple ingredients,
/// weekly pantry ingredients, quantity-aware pantry stock, and the legacy
/// [pantryIngredients] field.
Set<String> resolveActivePantry(MealSettings settings) {
  return {
    ...settings.stapleIngredients,
    ...settings.weeklyPantryIngredients,
    ...settings.pantryIngredients,
    for (final item in settings.pantryItems)
      if (item.quantity > 0) item.ingredientId,
  };
}

/// Compute how many of [recipe]'s ingredients are covered by [pantryIds].
PantryCoverage computePantryCoverage(Recipe recipe, Set<String> pantryIds) {
  final matched = <String>[];
  final missing = <String>[];

  for (final ri in recipe.ingredients) {
    if (pantryIds.contains(ri.ingredientId)) {
      matched.add(ri.ingredientId);
    } else {
      missing.add(ri.ingredientId);
    }
  }

  final total = recipe.ingredients.length;
  final ratio = total > 0 ? matched.length / total : 0.0;

  return PantryCoverage(
    matchedIngredients: matched,
    missingIngredients: missing,
    coverageRatio: ratio,
  );
}

/// Exclude pantry items from a consolidated ingredient map.
/// Returns a new map with pantry ingredient IDs removed.
Map<String, double> excludePantryFromConsolidated(
  Map<String, double> consolidated,
  Set<String> pantryIds,
) {
  final result = Map<String, double>.from(consolidated);
  for (final id in pantryIds) {
    result.remove(id);
  }
  return result;
}

/// Generate planner hints based on pantry coverage across recipes.
/// Returns a list of human-readable hint strings.
List<String> generatePantryHints({
  required List<Recipe> recipes,
  required Set<String> pantryIds,
  required Map<String, Ingredient> ingredientMap,
}) {
  if (pantryIds.isEmpty) return [];

  final hints = <String>[];
  final coverages = <String, PantryCoverage>{};

  for (final recipe in recipes) {
    coverages[recipe.id] = computePantryCoverage(recipe, pantryIds);
  }

  // Find fully covered recipes
  final fullyCovered = coverages.entries
      .where((e) => e.value.coverageRatio == 1.0)
      .toList();
  if (fullyCovered.isNotEmpty) {
    final count = fullyCovered.length;
    hints.add('$count recipe${count == 1 ? '' : 's'} fully covered by pantry');
  }

  // Find recipes with high coverage (>= 75%)
  final highCoverage = coverages.entries
      .where(
        (e) => e.value.coverageRatio >= 0.75 && e.value.coverageRatio < 1.0,
      )
      .toList();
  if (highCoverage.isNotEmpty) {
    hints.add(
      '${highCoverage.length} recipe${highCoverage.length == 1 ? '' : 's'} need only 1-2 extra ingredients',
    );
  }

  // Compute overall average coverage
  if (coverages.isNotEmpty) {
    final avg =
        coverages.values.map((c) => c.coverageRatio).reduce((a, b) => a + b) /
        coverages.length;
    final pct = (avg * 100).round();
    hints.add('Average pantry coverage: $pct%');
  }

  return hints;
}
