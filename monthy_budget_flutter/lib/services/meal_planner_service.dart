import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_planner.dart';
import '../models/app_settings.dart';

class MealPlannerService {
  static const _planKey = 'meal_plan';

  // Protein clusters: dominant protein ids per week (index 0-3)
  static const _weekClusters = [
    ['frango'],
    ['carne_picada'],
    ['feijao', 'grao', 'lentilhas'],
    ['pescada', 'bacalhau'],
  ];
  static const _weekVariety = [
    ['feijao', 'grao', 'lentilhas'],
    ['ovo'],
    ['frango'],
    ['carne_picada'],
  ];

  List<Ingredient> _ingredients = [];
  List<Recipe> _recipes = [];
  bool _catalogLoaded = false;

  Future<void> loadCatalog() async {
    if (_catalogLoaded) return;
    final ingJson = await rootBundle.loadString('assets/meal_planner/ingredients.json');
    final recJson = await rootBundle.loadString('assets/meal_planner/recipes.json');
    _ingredients = (jsonDecode(ingJson) as List<dynamic>)
        .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
        .toList();
    _recipes = (jsonDecode(recJson) as List<dynamic>)
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
        .toList();
    _catalogLoaded = true;
  }

  List<Ingredient> get ingredients => _ingredients;
  List<Recipe> get recipes => _recipes;

  Map<String, Ingredient> get ingredientMap =>
      {for (final i in _ingredients) i.id: i};

  Map<String, Recipe> get recipeMap =>
      {for (final r in _recipes) r.id: r};

  // --- Settings helpers ---

  int nPessoas(AppSettings settings) {
    final titulares = settings.salaries
        .where((s) => s.enabled)
        .fold(0, (sum, s) => sum + s.titulares);
    return titulares + settings.personalInfo.dependentes;
  }

  double monthlyFoodBudget(AppSettings settings) {
    return settings.expenses
        .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // --- Cost calculation ---

  double recipeCost(Recipe recipe, int nPessoas, Map<String, Ingredient> iMap) {
    final scale = nPessoas / recipe.servings;
    return recipe.ingredients.fold(0.0, (sum, ri) {
      final ing = iMap[ri.ingredientId];
      if (ing == null) return sum;
      return sum + ri.quantity * scale * ing.avgPricePerUnit;
    });
  }

  // --- Plan generation ---

  MealPlan generate(AppSettings settings, DateTime forMonth) {
    assert(_catalogLoaded, 'Call loadCatalog() first');
    final np = nPessoas(settings);
    final budget = monthlyFoodBudget(settings);
    final iMap = ingredientMap;
    final daysInMonth = DateTime(forMonth.year, forMonth.month + 1, 0).day;

    final days = <MealDay>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final weekIndex = ((day - 1) ~/ 7).clamp(0, 3);
      final isVarietyDay = (day % 7 == 0);

      final clusterIds = isVarietyDay
          ? _weekVariety[weekIndex]
          : _weekClusters[weekIndex];

      final candidates = _recipes
          .where((r) => clusterIds.contains(r.proteinId))
          .toList()
        ..sort((a, b) =>
            recipeCost(a, np, iMap).compareTo(recipeCost(b, np, iMap)));

      if (candidates.isEmpty) continue;

      final slotInWeek = (day - 1) % 7;
      final recipe = candidates[slotInWeek % candidates.length];
      final cost = recipeCost(recipe, np, iMap);

      days.add(MealDay(dayIndex: day, recipeId: recipe.id, costEstimate: cost));
    }

    var plan = MealPlan(
      month: forMonth.month,
      year: forMonth.year,
      nPessoas: np,
      monthlyBudget: budget,
      days: days,
      totalEstimatedCost: days.fold(0.0, (s, d) => s + d.costEstimate),
      generatedAt: DateTime.now(),
    );

    plan = _enforceBudget(plan, np, iMap);

    return plan;
  }

  MealPlan _enforceBudget(MealPlan plan, int np, Map<String, Ingredient> iMap) {
    var days = List<MealDay>.from(plan.days);
    var total = days.fold(0.0, (s, d) => s + d.costEstimate);

    int iterations = 0;
    while (total > plan.monthlyBudget && iterations < 100) {
      iterations++;
      days.sort((a, b) => b.costEstimate.compareTo(a.costEstimate));
      final expensive = days.first;
      final currentRecipe = recipeMap[expensive.recipeId]!;

      final cheaper = _recipes
          .where((r) =>
              r.proteinId == currentRecipe.proteinId &&
              r.id != currentRecipe.id)
          .map((r) => (recipe: r, cost: recipeCost(r, np, iMap)))
          .where((e) => e.cost < expensive.costEstimate)
          .toList()
        ..sort((a, b) => a.cost.compareTo(b.cost));

      if (cheaper.isEmpty) break;

      final replacement = cheaper.first;
      final idx = days.indexWhere((d) => d.dayIndex == expensive.dayIndex);
      days[idx] = expensive.copyWith(
        recipeId: replacement.recipe.id,
        costEstimate: replacement.cost,
      );
      total = days.fold(0.0, (s, d) => s + d.costEstimate);
    }

    days.sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    return plan.copyWithDays(days);
  }

  // --- Swap ---

  List<Recipe> alternativesFor(String recipeId, int np) {
    final current = recipeMap[recipeId];
    if (current == null) return [];
    final iMap = ingredientMap;
    return _recipes
        .where((r) => r.proteinId == current.proteinId && r.id != recipeId)
        .toList()
      ..sort((a, b) =>
          recipeCost(a, np, iMap).compareTo(recipeCost(b, np, iMap)));
  }

  MealPlan swapDay(MealPlan plan, int dayIndex, String newRecipeId) {
    final iMap = ingredientMap;
    final newRecipe = recipeMap[newRecipeId]!;
    final newCost = recipeCost(newRecipe, plan.nPessoas, iMap);
    final updatedDays = plan.days.map((d) {
      if (d.dayIndex == dayIndex) {
        return d.copyWith(recipeId: newRecipeId, costEstimate: newCost);
      }
      return d;
    }).toList();
    return plan.copyWithDays(updatedDays);
  }

  // --- Consolidated ingredient list ---

  Map<String, double> consolidatedIngredients(MealPlan plan) {
    final iMap = ingredientMap;
    final totals = <String, double>{};
    for (final day in plan.days) {
      final recipe = recipeMap[day.recipeId];
      if (recipe == null) continue;
      final scale = plan.nPessoas / recipe.servings;
      for (final ri in recipe.ingredients) {
        totals.update(
          ri.ingredientId,
          (v) => v + ri.quantity * scale,
          ifAbsent: () => ri.quantity * scale,
        );
      }
    }
    return totals;
  }

  // --- Persistence ---

  Future<MealPlan?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_planKey);
    if (raw == null) return null;
    try {
      return MealPlan.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(MealPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_planKey, plan.toJsonString());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_planKey);
  }
}
