// Derived view model for meal plan budget insights.

enum MealBudgetStatus { safe, watch, over }

class MealCostEntry {
  final String recipeId;
  final String recipeName;
  final double cost;
  final int dayIndex;
  final String mealType;

  const MealCostEntry({
    required this.recipeId,
    required this.recipeName,
    required this.cost,
    required this.dayIndex,
    required this.mealType,
  });
}

class MealCostSwap {
  final MealCostEntry original;
  final String alternativeRecipeId;
  final String alternativeRecipeName;
  final double alternativeCost;

  const MealCostSwap({
    required this.original,
    required this.alternativeRecipeId,
    required this.alternativeRecipeName,
    required this.alternativeCost,
  });

  double get savings => original.cost - alternativeCost;
}

class ShoppingImpactSummary {
  final int uniqueIngredients;
  final double estimatedShoppingCost;
  final int ingredientsSavedByPantry;
  final double pantrySavings;

  const ShoppingImpactSummary({
    required this.uniqueIngredients,
    required this.estimatedShoppingCost,
    this.ingredientsSavedByPantry = 0,
    this.pantrySavings = 0.0,
  });
}

class DayCostBreakdown {
  final int dayIndex;
  final Map<String, double> mealCosts; // mealType -> cost

  const DayCostBreakdown({
    required this.dayIndex,
    required this.mealCosts,
  });

  double get totalCost => mealCosts.values.fold(0.0, (s, c) => s + c);
}

class MealPlanBudgetInsight {
  final double weeklyEstimatedCost;
  final double projectedMonthlySpend;
  final double monthlyBudget;
  final double remainingBudget;
  final MealBudgetStatus status;
  final List<MealCostEntry> topExpensiveMeals;
  final List<MealCostSwap> suggestedSwaps;
  final ShoppingImpactSummary shoppingImpact;
  final List<DayCostBreakdown> dailyBreakdown;

  const MealPlanBudgetInsight({
    required this.weeklyEstimatedCost,
    required this.projectedMonthlySpend,
    required this.monthlyBudget,
    required this.remainingBudget,
    required this.status,
    required this.topExpensiveMeals,
    required this.suggestedSwaps,
    required this.shoppingImpact,
    this.dailyBreakdown = const [],
  });

  double get budgetUsagePercent =>
      monthlyBudget > 0 ? projectedMonthlySpend / monthlyBudget : 0.0;
}
