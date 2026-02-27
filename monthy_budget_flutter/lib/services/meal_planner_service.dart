import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meal_planner.dart';
import '../models/app_settings.dart';
import '../models/meal_settings.dart';

class MealPlannerService {

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
    if (settings.mealSettings.householdSize != null) {
      return settings.mealSettings.householdSize!;
    }
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

  MealPlan generate(AppSettings settings, DateTime forMonth, {List<String> favorites = const []}) {
    assert(_catalogLoaded, 'Call loadCatalog() first');
    final ms = settings.mealSettings;
    final np = nPessoas(settings);
    final totalBudget = monthlyFoodBudget(settings);
    final iMap = ingredientMap;
    final daysInMonth = DateTime(forMonth.year, forMonth.month + 1, 0).day;

    final rng = Random();

    // Base filtered pool (eliminatory)
    List<Recipe> basePool(MealType mealType) {
      var pool = _recipes.where((r) {
        if (!r.suitableMealTypes.contains(mealType.name)) return false;
        if (ms.glutenFree && !r.glutenFree) return false;
        if (ms.lactoseFree && !r.lactoseFree) return false;
        if (ms.nutFree && !r.nutFree) return false;
        if (ms.shellfishFree && !r.shellfishFree) return false;
        if (r.complexity > ms.maxComplexity) return false;
        if (r.prepMinutes > ms.maxPrepMinutes) return false;
        if (ms.excludedProteins.contains(r.proteinId)) return false;
        // Equipment check
        for (final eq in r.requiresEquipment) {
          final mapped = KitchenEquipment.values.firstWhere(
            (k) => k.name == eq, orElse: () => KitchenEquipment.oven);
          if (!ms.availableEquipment.contains(mapped)) return false;
        }
        // Disliked ingredients
        for (final ri in r.ingredients) {
          final ing = iMap[ri.ingredientId];
          if (ing == null) continue;
          if (ms.dislikedIngredients.any((d) =>
              d.toLowerCase() == ing.name.toLowerCase())) {
            return false;
          }
        }
        return true;
      }).toList();

      // Objective filter
      switch (ms.objective) {
        case MealObjective.highProtein:
          final hp = pool.where((r) => r.isHighProtein).toList();
          if (hp.isNotEmpty) pool = hp;
          break;
        case MealObjective.lowCarb:
          final lc = pool.where((r) => r.isLowCarb).toList();
          if (lc.isNotEmpty) pool = lc;
          break;
        case MealObjective.vegetarian:
          final veg = pool.where((r) => r.isVegetarian).toList();
          if (veg.isNotEmpty) pool = veg;
          break;
        default:
          break;
      }

      if (pool.isEmpty) {
        // Fallback: keep allergy/dietary hard filters, drop soft filters
        pool = _recipes.where((r) {
          if (!r.suitableMealTypes.contains(mealType.name)) return false;
          if (ms.glutenFree && !r.glutenFree) return false;
          if (ms.lactoseFree && !r.lactoseFree) return false;
          if (ms.nutFree && !r.nutFree) return false;
          if (ms.shellfishFree && !r.shellfishFree) return false;
          if (ms.excludedProteins.contains(r.proteinId)) return false;
          for (final ri in r.ingredients) {
            final ing = iMap[ri.ingredientId];
            if (ing == null) continue;
            if (ms.dislikedIngredients.any((d) =>
                d.toLowerCase() == ing.name.toLowerCase())) {
              return false;
            }
          }
          return true;
        }).toList();
      }
      // Ultimate fallback: if still empty after allergy filters, use full list
      if (pool.isEmpty) pool = _recipes.toList();
      return pool;
    }

    // Determine veggie day indices (distributed evenly across month)
    final Set<int> veggieDays = {};
    if (ms.veggieDaysPerWeek > 0 && ms.objective != MealObjective.vegetarian) {
      final totalVegDays = (ms.veggieDaysPerWeek * daysInMonth / 7).round();
      final step = daysInMonth / (totalVegDays + 1);
      for (int i = 1; i <= totalVegDays; i++) {
        veggieDays.add((step * i).round().clamp(1, daysInMonth));
      }
    }

    final days = <MealDay>[];

    // Per-meal-type tracking for waste minimization
    final usedIngredientsThisWeek = <MealType, Set<String>>{
      for (final m in ms.enabledMeals) m: {}
    };
    final newIngredientCountThisWeek = <MealType, int>{
      for (final m in ms.enabledMeals) m: 0
    };

    // Batch cooking tracking: {mealType: {recipeId, daysRemaining}}
    final batchState = <MealType, ({String recipeId, int daysLeft})>{};
    final usedRecipesPerDay = <int, Set<String>>{};

    for (int day = 1; day <= daysInMonth; day++) {
      usedRecipesPerDay[day] = {};
      // Reset weekly tracking on Mondays (weekday 1)
      final weekday = DateTime(forMonth.year, forMonth.month, day).weekday;
      if (weekday == 1) {
        for (final m in ms.enabledMeals) {
          usedIngredientsThisWeek[m] = {};
          newIngredientCountThisWeek[m] = 0;
        }
      }

      final isVeggieDay = veggieDays.contains(day);

      for (final mealType in ms.enabledMeals) {
        // --- Batch cooking ---
        if (ms.batchCookingEnabled && batchState.containsKey(mealType)) {
          final state = batchState[mealType]!;
          if (state.daysLeft > 0) {
            final recipe = recipeMap[state.recipeId]!;
            final cost = recipeCost(recipe, np, iMap);
            days.add(MealDay(
              dayIndex: day,
              recipeId: state.recipeId,
              costEstimate: cost,
              mealType: mealType,
            ));
            batchState[mealType] = (
              recipeId: state.recipeId,
              daysLeft: state.daysLeft - 1,
            );
            continue;
          } else {
            batchState.remove(mealType);
          }
        }

        // --- Leftovers (lunch reuses previous dinner) ---
        if (ms.reuseLeftovers && mealType == MealType.lunch && day > 1) {
          final prevDinner = days.lastWhere(
            (d) => d.dayIndex == day - 1 && d.mealType == MealType.dinner,
            orElse: () => MealDay(dayIndex: 0, recipeId: '', costEstimate: 0),
          );
          if (prevDinner.recipeId.isNotEmpty) {
            days.add(MealDay(
              dayIndex: day,
              recipeId: prevDinner.recipeId,
              isLeftover: true,
              costEstimate: 0,
              mealType: MealType.lunch,
            ));
            continue;
          }
        }

        var pool = basePool(mealType);

        // Force veggie on designated days
        if (isVeggieDay) {
          final veg = pool.where((r) => r.isVegetarian).toList();
          if (veg.isNotEmpty) pool = veg;
        }

        // Sort by objective
        if (ms.objective == MealObjective.minimizeCost || ms.prioritizeLowCost) {
          pool.sort((a, b) => recipeCost(a, np, iMap).compareTo(recipeCost(b, np, iMap)));
        }

        // Waste minimization: prefer recipes with known ingredients
        if (ms.minimizeWaste) {
          final used = usedIngredientsThisWeek[mealType]!;
          final reuseFirst = pool.where((r) =>
              r.ingredients.every((ri) => used.contains(ri.ingredientId))).toList();
          if (reuseFirst.isNotEmpty) pool = reuseFirst;
        }

        // Max new ingredients cap
        if (ms.maxNewIngredientsPerWeek < 10) {
          final used = usedIngredientsThisWeek[mealType]!;
          final remaining = ms.maxNewIngredientsPerWeek - (newIngredientCountThisWeek[mealType] ?? 0);
          if (remaining <= 0) {
            final noNew = pool.where((r) =>
                r.ingredients.every((ri) => used.contains(ri.ingredientId))).toList();
            if (noNew.isNotEmpty) pool = noNew;
          }
        }

        // Favorites boost
        if (favorites.isNotEmpty) {
          final boosted = pool.where((r) {
            final ing = iMap[r.proteinId];
            if (ing == null) return false;
            return favorites.any((fav) =>
                fav.toLowerCase().contains(ing.name.toLowerCase()) ||
                ing.name.toLowerCase().contains(fav.toLowerCase().split(' ').first));
          }).toList();
          if (boosted.isNotEmpty) pool = boosted;
        }

        // Pick recipe: shuffle + avoid same-day duplicates
        final usedToday = usedRecipesPerDay[day]!;
        var available = pool.where((r) => !usedToday.contains(r.id)).toList();
        if (available.isEmpty) available = pool.toList();
        if (available.isEmpty) available = _recipes.toList();
        available.shuffle(rng);
        final recipe = available.first;
        usedToday.add(recipe.id);

        final cost = recipeCost(recipe, np, iMap);

        days.add(MealDay(
          dayIndex: day,
          recipeId: recipe.id,
          costEstimate: cost,
          mealType: mealType,
        ));

        // Update ingredient tracking
        final used = usedIngredientsThisWeek[mealType]!;
        int newCount = newIngredientCountThisWeek[mealType] ?? 0;
        for (final ri in recipe.ingredients) {
          if (!used.contains(ri.ingredientId)) {
            used.add(ri.ingredientId);
            newCount++;
          }
        }
        newIngredientCountThisWeek[mealType] = newCount;

        // Start batch cooking block if applicable and on preferred day
        if (ms.batchCookingEnabled && recipe.batchCookable && ms.maxBatchDays > 1) {
          final isPreferredDay = ms.preferredCookingWeekday == null ||
              weekday - 1 == ms.preferredCookingWeekday;
          if (isPreferredDay && !batchState.containsKey(mealType)) {
            batchState[mealType] = (
              recipeId: recipe.id,
              daysLeft: recipe.maxBatchDays.clamp(1, ms.maxBatchDays) - 1,
            );
          }
        }
      }
    }

    var plan = MealPlan(
      month: forMonth.month,
      year: forMonth.year,
      nPessoas: np,
      monthlyBudget: totalBudget,
      days: days,
      totalEstimatedCost: days.fold(0.0, (d, e) => d + e.costEstimate),
      generatedAt: DateTime.now(),
    );

    plan = _enforceBudget(plan, np, iMap, ms);
    return plan;
  }

  MealPlan _enforceBudget(MealPlan plan, int np, Map<String, Ingredient> iMap, MealSettings ms) {
    var days = List<MealDay>.from(plan.days);
    var total = days.fold(0.0, (s, d) => s + d.costEstimate);

    int iterations = 0;
    while (total > plan.monthlyBudget && iterations < 100) {
      iterations++;
      days.sort((a, b) => b.costEstimate.compareTo(a.costEstimate));
      final expensive = days.first;
      final currentRecipe = recipeMap[expensive.recipeId]!;

      final cheaper = _recipes.where((r) {
        if (r.id == currentRecipe.id) return false;
        if (ms.glutenFree && !r.glutenFree) return false;
        if (ms.lactoseFree && !r.lactoseFree) return false;
        if (ms.nutFree && !r.nutFree) return false;
        if (ms.shellfishFree && !r.shellfishFree) return false;
        if (ms.excludedProteins.contains(r.proteinId)) return false;
        if (!r.suitableMealTypes.contains(expensive.mealType.name)) return false;
        return true;
      })
          .map((r) => (recipe: r, cost: recipeCost(r, np, iMap)))
          .where((e) => e.cost < expensive.costEstimate)
          .toList()
        ..sort((a, b) => a.cost.compareTo(b.cost));

      if (cheaper.isEmpty) break;

      final replacement = cheaper.first;
      final idx = days.indexWhere((d) => d.dayIndex == expensive.dayIndex && d.mealType == expensive.mealType);
      days[idx] = expensive.copyWith(
        recipeId: replacement.recipe.id,
        costEstimate: replacement.cost,
      );
      total = days.fold(0.0, (s, d) => s + d.costEstimate);
    }

    days.sort((a, b) => a.dayIndex.compareTo(b.dayIndex));

    // Fix stale leftover references
    for (int i = 0; i < days.length; i++) {
      if (!days[i].isLeftover) continue;
      final dinnerDay = days[i].dayIndex - 1;
      final dinner = days.where(
        (d) => d.dayIndex == dinnerDay && d.mealType == MealType.dinner,
      ).firstOrNull;
      if (dinner != null && dinner.recipeId != days[i].recipeId) {
        days[i] = days[i].copyWith(recipeId: dinner.recipeId, costEstimate: 0);
      }
    }

    return plan.copyWithDays(days);
  }

  // --- Swap ---

  List<Recipe> alternativesFor(String recipeId, int np, {MealSettings? ms}) {
    final current = recipeMap[recipeId];
    if (current == null) return [];
    final iMap = ingredientMap;
    var pool = _recipes.where((r) => r.id != recipeId).toList();
    if (ms != null) {
      pool = pool.where((r) {
        if (ms.glutenFree && !r.glutenFree) return false;
        if (ms.lactoseFree && !r.lactoseFree) return false;
        if (ms.nutFree && !r.nutFree) return false;
        if (ms.shellfishFree && !r.shellfishFree) return false;
        if (ms.excludedProteins.contains(r.proteinId)) return false;
        return true;
      }).toList();
    }
    pool.sort((a, b) {
      final aMatch = a.proteinId == current.proteinId ? 0 : 1;
      final bMatch = b.proteinId == current.proteinId ? 0 : 1;
      if (aMatch != bMatch) return aMatch.compareTo(bMatch);
      return recipeCost(a, np, iMap).compareTo(recipeCost(b, np, iMap));
    });
    return pool;
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

  Future<MealPlan?> load(String householdId, int month, int year) async {
    final client = Supabase.instance.client;
    final row = await client
        .from('meal_plans')
        .select('plan_json')
        .eq('household_id', householdId)
        .eq('month', month)
        .eq('year', year)
        .maybeSingle();

    if (row == null) return null;
    try {
      return MealPlan.fromJsonString(row['plan_json'] as String);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(MealPlan plan, String householdId) async {
    final client = Supabase.instance.client;
    await client.from('meal_plans').upsert({
      'household_id': householdId,
      'month': plan.month,
      'year': plan.year,
      'plan_json': plan.toJsonString(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> clear(String householdId, int month, int year) async {
    final client = Supabase.instance.client;
    await client
        .from('meal_plans')
        .delete()
        .eq('household_id', householdId)
        .eq('month', month)
        .eq('year', year);
  }
}
