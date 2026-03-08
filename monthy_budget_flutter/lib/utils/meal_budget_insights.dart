import '../models/meal_budget_insight.dart';
import '../models/meal_planner.dart';
import '../models/purchase_record.dart';
import '../services/meal_planner_service.dart';

/// Computes budget insights from a [MealPlan] and related context.
class MealBudgetInsightsCalculator {
  final MealPlannerService service;

  const MealBudgetInsightsCalculator(this.service);

  /// Main computation entry point.
  MealPlanBudgetInsight compute({
    required MealPlan plan,
    required int selectedWeek,
    PurchaseHistory? purchaseHistory,
  }) {
    final weekDays = _getWeekDays(plan, selectedWeek);
    final weeklyEstimatedCost =
        weekDays.fold(0.0, (sum, d) => sum + d.costEstimate);

    final daysInMonth = DateTime(plan.year, plan.month + 1, 0).day;
    final weekCount = (daysInMonth / 7).ceil();
    final projectedMonthlySpend = weekCount > 0
        ? _computeProjectedMonthlySpend(plan, weeklyEstimatedCost, weekCount)
        : weeklyEstimatedCost;

    final monthlyBudget = plan.monthlyBudget;
    final remainingBudget = monthlyBudget - plan.totalEstimatedCost;

    final status = _computeStatus(
      projected: projectedMonthlySpend,
      budget: monthlyBudget,
    );

    final topExpensiveMeals = _rankExpensiveMeals(weekDays, plan);
    final suggestedSwaps =
        _computeSwaps(topExpensiveMeals, plan);
    final shoppingImpact =
        _computeShoppingImpact(weekDays, plan);
    final dailyBreakdown = _computeDailyBreakdown(weekDays);

    return MealPlanBudgetInsight(
      weeklyEstimatedCost: weeklyEstimatedCost,
      projectedMonthlySpend: projectedMonthlySpend,
      monthlyBudget: monthlyBudget,
      remainingBudget: remainingBudget,
      status: status,
      topExpensiveMeals: topExpensiveMeals,
      suggestedSwaps: suggestedSwaps,
      shoppingImpact: shoppingImpact,
      dailyBreakdown: dailyBreakdown,
    );
  }

  double _computeProjectedMonthlySpend(
    MealPlan plan,
    double weeklyEstimatedCost,
    int weekCount,
  ) {
    // Use the whole plan cost for accuracy when available;
    // fallback to weekly average * weeks when plan is partial.
    if (plan.totalEstimatedCost > 0) {
      return plan.totalEstimatedCost;
    }
    return weeklyEstimatedCost * weekCount;
  }

  MealBudgetStatus _computeStatus({
    required double projected,
    required double budget,
  }) {
    if (budget <= 0) return MealBudgetStatus.safe;
    final ratio = projected / budget;
    if (ratio <= 0.85) return MealBudgetStatus.safe;
    if (ratio <= 1.0) return MealBudgetStatus.watch;
    return MealBudgetStatus.over;
  }

  List<MealCostEntry> _rankExpensiveMeals(
    List<MealDay> weekDays,
    MealPlan plan,
  ) {
    final rMap = service.recipeMap;
    final entries = <MealCostEntry>[];
    for (final day in weekDays) {
      if (day.costEstimate <= 0) continue;
      final recipe = rMap[day.recipeId];
      if (recipe == null) continue;
      entries.add(MealCostEntry(
        recipeId: day.recipeId,
        recipeName: recipe.name,
        cost: day.costEstimate,
        dayIndex: day.dayIndex,
        mealType: day.mealType.name,
      ));
    }
    entries.sort((a, b) => b.cost.compareTo(a.cost));
    return entries.take(5).toList();
  }

  List<MealCostSwap> _computeSwaps(
    List<MealCostEntry> expensiveMeals,
    MealPlan plan,
  ) {
    final swaps = <MealCostSwap>[];
    final iMap = service.ingredientMap;

    for (final entry in expensiveMeals) {
      final alternatives =
          service.alternativesFor(entry.recipeId, plan.nPessoas);
      if (alternatives.isEmpty) continue;

      // Find the cheapest alternative that costs less
      Recipe? cheapest;
      double cheapestCost = entry.cost;
      for (final alt in alternatives) {
        final altCost = service.recipeCost(alt, plan.nPessoas, iMap);
        if (altCost < cheapestCost) {
          cheapestCost = altCost;
          cheapest = alt;
        }
      }

      if (cheapest != null) {
        swaps.add(MealCostSwap(
          original: entry,
          alternativeRecipeId: cheapest.id,
          alternativeRecipeName: cheapest.name,
          alternativeCost: cheapestCost,
        ));
      }
    }
    swaps.sort((a, b) => b.savings.compareTo(a.savings));
    return swaps.take(3).toList();
  }

  ShoppingImpactSummary _computeShoppingImpact(
    List<MealDay> weekDays,
    MealPlan plan,
  ) {
    final rMap = service.recipeMap;
    final iMap = service.ingredientMap;
    final ingredientTotals = <String, double>{};

    for (final day in weekDays) {
      if (day.isLeftover) continue;
      final recipe = rMap[day.recipeId];
      if (recipe == null) continue;
      final scale = plan.nPessoas / recipe.servings;
      for (final ri in recipe.ingredients) {
        ingredientTotals.update(
          ri.ingredientId,
          (v) => v + ri.quantity * scale,
          ifAbsent: () => ri.quantity * scale,
        );
      }
    }

    double totalShoppingCost = 0.0;
    for (final entry in ingredientTotals.entries) {
      final ing = iMap[entry.key];
      if (ing == null) continue;
      totalShoppingCost += entry.value * ing.avgPricePerUnit;
    }

    return ShoppingImpactSummary(
      uniqueIngredients: ingredientTotals.length,
      estimatedShoppingCost: totalShoppingCost,
    );
  }

  List<DayCostBreakdown> _computeDailyBreakdown(List<MealDay> weekDays) {
    final dayMap = <int, Map<String, double>>{};
    for (final day in weekDays) {
      dayMap
          .putIfAbsent(day.dayIndex, () => {})
          .update(day.mealType.name, (v) => v + day.costEstimate,
              ifAbsent: () => day.costEstimate);
    }
    final result = dayMap.entries
        .map((e) => DayCostBreakdown(dayIndex: e.key, mealCosts: e.value))
        .toList();
    result.sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    return result;
  }

  List<MealDay> _getWeekDays(MealPlan plan, int weekIndex) {
    final start = weekIndex * 7 + 1;
    final daysInMonth = DateTime(plan.year, plan.month + 1, 0).day;
    final end =
        (weekIndex + 1) * 7 < daysInMonth ? start + 6 : daysInMonth;
    return plan.days
        .where((d) => d.dayIndex >= start && d.dayIndex <= end)
        .toList();
  }
}
