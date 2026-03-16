import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meal_planner.dart';
import '../models/app_settings.dart';
import '../models/meal_settings.dart';
import '../utils/taste_profile.dart';

class MealPlannerService {

  static const _recipeCacheKey = 'cached_recipes_json';
  static const _ingredientCacheKey = 'cached_ingredients_json';

  List<Ingredient> _ingredients = [];
  List<Recipe> _recipes = [];
  bool _catalogLoaded = false;
  Map<String, Ingredient>? _ingredientMapCache;
  Map<String, Recipe>? _recipeMapCache;

  /// Loads the recipe catalog using a three-tier strategy:
  /// 1. Supabase (remote, authoritative)
  /// 2. SharedPreferences cache (offline fallback)
  /// 3. Local bundled asset JSON (final fallback)
  Future<void> loadCatalog() async {
    if (_catalogLoaded) return;

    final loaded = await _tryLoadFromSupabase();
    if (!loaded) {
      final cachedLoaded = await _tryLoadFromCache();
      if (!cachedLoaded) {
        await _loadFromAssets();
      }
    }
  }

  Future<bool> _tryLoadFromSupabase() async {
    try {
      final client = Supabase.instance.client;
      final recipesData = await client
          .from('recipes')
          .select('*, recipe_ingredients(*)')
          .order('name');

      if ((recipesData as List).isEmpty) return false;

      _recipes = recipesData.map<Recipe>((r) {
        final ingredients =
            (r['recipe_ingredients'] as List? ?? []).map<RecipeIngredient>((ri) =>
              RecipeIngredient(
                ingredientId: ri['ingredient_id'] as String,
                quantity: (ri['quantity'] as num).toDouble(),
              ),
            ).toList();

        return Recipe(
          id: r['id'] as String,
          name: r['name'] as String,
          proteinId: r['protein_id'] as String? ?? '',
          type: RecipeType.values.firstWhere(
            (t) => t.name == r['type'],
            orElse: () => RecipeType.carne,
          ),
          complexity: r['complexity'] as int? ?? 3,
          prepMinutes: r['prep_minutes'] as int? ?? 30,
          servings: r['servings'] as int? ?? 4,
          ingredients: ingredients,
          isVegetarian: r['is_vegetarian'] as bool? ?? false,
          isHighProtein: r['is_high_protein'] as bool? ?? false,
          isLowCarb: r['is_low_carb'] as bool? ?? false,
          glutenFree: r['gluten_free'] as bool? ?? false,
          lactoseFree: r['lactose_free'] as bool? ?? false,
          nutFree: r['nut_free'] as bool? ?? true,
          shellfishFree: r['shellfish_free'] as bool? ?? true,
          batchCookable: r['batch_cookable'] as bool? ?? false,
          maxBatchDays: r['max_batch_days'] as int? ?? 2,
          isPortable: r['is_portable'] as bool? ?? false,
          suitableMealTypes:
              (r['suitable_meal_types'] as List?)?.cast<String>() ??
                  ['lunch', 'dinner'],
          seasons: (r['seasons'] as List?)?.cast<String>() ?? [],
          requiresEquipment:
              (r['requires_equipment'] as List?)?.cast<String>() ?? [],
          nutrition: r['nutrition'] != null
              ? NutritionInfo.fromJson(
                  r['nutrition'] is String
                      ? jsonDecode(r['nutrition'] as String)
                          as Map<String, dynamic>
                      : r['nutrition'] as Map<String, dynamic>,
                )
              : null,
          prepSteps: (r['prep_steps'] as List?)?.cast<String>() ?? [],
        );
      }).toList();

      // Ingredients are simpler and change rarely -- load from assets
      final ingJson =
          await rootBundle.loadString('assets/meal_planner/ingredients.json');
      _ingredients = (jsonDecode(ingJson) as List<dynamic>)
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList();

      _catalogLoaded = true;
      _ingredientMapCache = null;
      _recipeMapCache = null;

      // Cache for offline use (fire-and-forget)
      _cacheCurrentCatalog();

      return true;
    } catch (e) {
      debugPrint('Supabase recipe load failed: $e');
      return false;
    }
  }

  Future<bool> _tryLoadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedRecipes = prefs.getString(_recipeCacheKey);
      final cachedIngredients = prefs.getString(_ingredientCacheKey);
      if (cachedRecipes != null && cachedIngredients != null) {
        loadCatalogFromJson(cachedIngredients, cachedRecipes);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadFromAssets() async {
    final ingJson =
        await rootBundle.loadString('assets/meal_planner/ingredients.json');
    final recJson =
        await rootBundle.loadString('assets/meal_planner/recipes.json');
    loadCatalogFromJson(ingJson, recJson);
  }

  Future<void> _cacheCurrentCatalog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recJson = jsonEncode(_recipes.map((r) => r.toJson()).toList());
      final ingJson =
          jsonEncode(_ingredients.map((i) => i.toJson()).toList());
      await prefs.setString(_recipeCacheKey, recJson);
      await prefs.setString(_ingredientCacheKey, ingJson);
    } catch (_) {
      // Cache failure is non-critical
    }
  }

  @visibleForTesting
  void loadCatalogFromJson(String ingredientsJson, String recipesJson) {
    _ingredients = (jsonDecode(ingredientsJson) as List<dynamic>)
        .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
        .toList();
    _recipes = (jsonDecode(recipesJson) as List<dynamic>)
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
        .toList();
    _ingredientMapCache = null;
    _recipeMapCache = null;
    _catalogLoaded = true;
  }

  List<Ingredient> get ingredients => _ingredients;
  List<Recipe> get recipes => _recipes;

  Map<String, Ingredient> get ingredientMap =>
      _ingredientMapCache ??= {for (final i in _ingredients) i.id: i};

  Map<String, Recipe> get recipeMap =>
      _recipeMapCache ??= {for (final r in _recipes) r.id: r};

  // --- Settings helpers ---

  int nPessoas(AppSettings settings) {
    final members = settings.mealSettings.householdMembers;
    if (members.isNotEmpty) {
      return members.fold(0.0, (sum, m) => sum + m.portionEquivalent).round().clamp(1, 99);
    }
    if (settings.mealSettings.householdSize != null) {
      return settings.mealSettings.householdSize!.clamp(1, 99);
    }
    final titulares = settings.salaries
        .where((s) => s.enabled)
        .fold(0, (sum, s) => sum + s.titulares);
    final total = titulares + settings.personalInfo.dependentes;
    return total.clamp(1, 99);
  }

  double monthlyFoodBudget(AppSettings settings) {
    return settings.expenses
        .where((e) => e.category == 'alimentacao' && e.enabled)
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

  MealPlan generate(AppSettings settings, DateTime forMonth, {List<String> favorites = const [], Map<String, MealFeedback> previousFeedback = const {}}) {
    assert(_catalogLoaded, 'Call loadCatalog() first');
    final ms = settings.mealSettings;
    final np = nPessoas(settings);
    final totalBudget = monthlyFoodBudget(settings);
    final iMap = ingredientMap;
    final rMap = recipeMap;
    final daysInMonth = DateTime(forMonth.year, forMonth.month + 1, 0).day;

    final rng = Random();

    // Resolve active pantry IDs for pantry-first boost
    final pantryIds = <String>{
      ...ms.pantryIngredients,
      ...ms.stapleIngredients,
      ...ms.weeklyPantryIngredients,
    };

    // Build taste profile from previous feedback
    final tasteProfile = previousFeedback.isNotEmpty
        ? TasteProfile.fromFeedback(feedback: previousFeedback, recipeMap: recipeMap)
        : const TasteProfile();

    // Pre-compute cost cache: recipeId -> cost for this np
    final costCache = <String, double>{};
    double cachedCost(Recipe recipe) {
      return costCache.putIfAbsent(recipe.id, () => recipeCost(recipe, np, iMap));
    }

    // Pre-lowercase disliked ingredients for O(1) lookup
    final dislikedLower = ms.dislikedIngredients.map((d) => d.toLowerCase()).toSet();

    // Pre-build ingredient name lookup (lowercased)
    final ingredientNameLower = <String, String>{};
    for (final ing in _ingredients) {
      ingredientNameLower[ing.id] = ing.name.toLowerCase();
    }

    // Pre-build equipment name→enum map
    final equipmentByName = <String, KitchenEquipment>{
      for (final k in KitchenEquipment.values) k.name: k,
    };

    // Pre-compute excludedProteins as a Set for O(1) lookup
    final excludedProteinsSet = ms.excludedProteins.toSet();

    // Helper: check if recipe has disliked ingredients
    bool hasDislikedIngredient(Recipe r) {
      if (dislikedLower.isEmpty) return false;
      for (final ri in r.ingredients) {
        final name = ingredientNameLower[ri.ingredientId];
        if (name != null && dislikedLower.contains(name)) return true;
      }
      return false;
    }

    // Helper: check equipment requirements
    bool hasRequiredEquipment(Recipe r) {
      for (final eq in r.requiresEquipment) {
        final mapped = equipmentByName[eq] ?? KitchenEquipment.oven;
        if (!ms.availableEquipment.contains(mapped)) return false;
      }
      return true;
    }

    // Pre-compute hard-filter flags per recipe (settings-only, day-independent)
    final hasDiabetes = ms.medicalConditions.contains(MedicalCondition.diabetes);
    final hasHypertension = ms.medicalConditions.contains(MedicalCondition.hypertension);
    final hasCholesterol = ms.medicalConditions.contains(MedicalCondition.highCholesterol);
    final hasGout = ms.medicalConditions.contains(MedicalCondition.gout);
    final isLowSodium = ms.sodiumPreference == SodiumPreference.lowSodium;
    const highSodiumIds = {'bacalhau', 'chourico', 'fiambre', 'sardinha'};
    const highPurineProteins = {'sardinha', 'porco'};

    // Core eliminatory filter (day-independent parts)
    bool passesHardFilters(Recipe r) {
      if (ms.glutenFree && !r.glutenFree) return false;
      if (ms.lactoseFree && !r.lactoseFree) return false;
      if (ms.nutFree && !r.nutFree) return false;
      if (ms.shellfishFree && !r.shellfishFree) return false;
      if (ms.eggFree && r.ingredients.any((ri) => ri.ingredientId == 'ovo')) return false;
      if (excludedProteinsSet.contains(r.proteinId)) return false;
      if (hasDislikedIngredient(r)) return false;
      if (!hasRequiredEquipment(r)) return false;
      if (isLowSodium && r.ingredients.any((ri) => highSodiumIds.contains(ri.ingredientId))) return false;
      if (hasDiabetes && r.nutrition != null && r.nutrition!.carbsG > 55) return false;
      if (hasHypertension && r.nutrition != null && r.nutrition!.sodiumMg > 500) return false;
      if (hasCholesterol && r.nutrition != null && r.nutrition!.fatG > 25) return false;
      if (hasGout && highPurineProteins.contains(r.proteinId)) return false;
      return true;
    }

    // Cache base pools by (mealType, isWeekend) — only 2×N_mealTypes combos
    final poolCache = <(MealType, bool), List<Recipe>>{};

    List<Recipe> basePool(MealType mealType, bool isWeekend) {
      final key = (mealType, isWeekend);
      final cached = poolCache[key];
      if (cached != null) return List.of(cached);

      final effectiveMaxPrep = isWeekend ? ms.maxPrepMinutesWeekend : ms.maxPrepMinutes;
      final effectiveMaxComplexity = isWeekend ? ms.maxComplexityWeekend : ms.maxComplexity;
      final mealTypeName = mealType.name;

      var pool = _recipes.where((r) {
        if (!r.suitableMealTypes.contains(mealTypeName)) return false;
        if (!passesHardFilters(r)) return false;
        if (r.complexity > effectiveMaxComplexity) return false;
        if (r.prepMinutes > effectiveMaxPrep) return false;
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
        // Fallback: keep allergy/dietary hard filters, drop soft filters (complexity/prep)
        pool = _recipes.where((r) {
          if (!r.suitableMealTypes.contains(mealTypeName)) return false;
          if (ms.glutenFree && !r.glutenFree) return false;
          if (ms.lactoseFree && !r.lactoseFree) return false;
          if (ms.nutFree && !r.nutFree) return false;
          if (ms.shellfishFree && !r.shellfishFree) return false;
          if (ms.eggFree && r.ingredients.any((ri) => ri.ingredientId == 'ovo')) return false;
          if (excludedProteinsSet.contains(r.proteinId)) return false;
          if (hasDislikedIngredient(r)) return false;
          return true;
        }).toList();
      }
      if (pool.isEmpty) {
        pool = _recipes.where((r) => r.suitableMealTypes.contains(mealTypeName)).toList();
      }
      if (pool.isEmpty) pool = _recipes.toList();

      poolCache[key] = pool;
      return List.of(pool);
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

    // Global tracking for waste minimization (shared across meal types)
    var globalUsedIngredientsThisWeek = <String>{};
    final newIngredientCountThisWeek = <MealType, int>{
      for (final m in ms.enabledMeals) m: 0
    };

    // Batch cooking tracking: {mealType: {recipeId, daysRemaining}}
    final batchState = <MealType, ({String recipeId, int daysLeft})>{};
    final usedRecipesPerDay = <int, Set<String>>{};
    final recentRecipePerMealType = <MealType, String>{};
    final recentProteinPerMealType = <MealType, List<String>>{};

    final weeklyFishCount = <int, int>{}; // weekNumber -> count
    final weeklyLegumeCount = <int, int>{};
    final weeklyRedMeatCount = <int, int>{};

    for (int day = 1; day <= daysInMonth; day++) {
      usedRecipesPerDay[day] = {};
      // Reset weekly tracking on Mondays (weekday 1)
      final weekday = DateTime(forMonth.year, forMonth.month, day).weekday;
      final isWeekend = weekday == 6 || weekday == 7;
      // Skip eating-out days
      if (ms.eatingOutWeekdays.contains(weekday)) continue;
      if (weekday == 1) {
        globalUsedIngredientsThisWeek = {};
        for (final m in ms.enabledMeals) {
          newIngredientCountThisWeek[m] = 0;
        }
      }

      final isVeggieDay = veggieDays.contains(day);

      for (final mealType in ms.enabledMeals) {
        // --- Batch cooking ---
        if (ms.batchCookingEnabled && batchState.containsKey(mealType)) {
          final state = batchState[mealType]!;
          if (state.daysLeft > 0) {
            final recipe = rMap[state.recipeId]!;
            final cost = cachedCost(recipe);
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
        if (ms.reuseLeftovers && mealType == MealType.lunch && day > 1 && ms.enabledMeals.contains(MealType.dinner)) {
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

        // Pinned meals: check if this weekday/mealType is pinned
        final pinKey = '${weekday}_${mealType.name}';
        final pinnedRecipeId = ms.pinnedMeals[pinKey];
        if (pinnedRecipeId != null) {
          if (pinnedRecipeId == 'skip') continue;
          final pinnedRecipe = rMap[pinnedRecipeId];
          if (pinnedRecipe != null) {
            final cost = cachedCost(pinnedRecipe);
            days.add(MealDay(
              dayIndex: day,
              recipeId: pinnedRecipeId,
              costEstimate: cost,
              mealType: mealType,
            ));
            continue;
          }
        }

        var pool = basePool(mealType, isWeekend);

        // Lunchbox filter: only portable recipes for lunch
        if (ms.lunchboxLunches && mealType == MealType.lunch) {
          final portable = pool.where((r) => r.isPortable).toList();
          if (portable.isNotEmpty) pool = portable;
        }

        // Force veggie on designated days
        if (isVeggieDay) {
          final veg = pool.where((r) => r.isVegetarian).toList();
          if (veg.isNotEmpty) pool = veg;
        }

        // Pantry-first boost: soft-sort recipes by pantry ingredient count (desc)
        if (pantryIds.isNotEmpty) {
          pool.sort((a, b) {
            final aCount = a.ingredients.where((ri) => pantryIds.contains(ri.ingredientId)).length;
            final bCount = b.ingredients.where((ri) => pantryIds.contains(ri.ingredientId)).length;
            return bCount.compareTo(aCount); // more pantry matches first
          });
        }

        // Sort by objective
        if (ms.objective == MealObjective.minimizeCost || ms.prioritizeLowCost) {
          pool.sort((a, b) => cachedCost(a).compareTo(cachedCost(b)));
        }

        // Waste minimization: prefer recipes sharing ingredients (any, not all)
        if (ms.minimizeWaste && globalUsedIngredientsThisWeek.isNotEmpty) {
          final reuse = pool.where((r) =>
              r.ingredients.any((ri) => globalUsedIngredientsThisWeek.contains(ri.ingredientId))).toList();
          if (reuse.length >= 3) pool = reuse;
        }

        // Max new ingredients cap — soft: prefer fewer new ingredients, don't hard-block
        if (ms.maxNewIngredientsPerWeek < 10) {
          final remaining = ms.maxNewIngredientsPerWeek - (newIngredientCountThisWeek[mealType] ?? 0);
          if (remaining <= 0) {
            // Prefer recipes with zero new ingredients
            final noNew = pool.where((r) =>
                r.ingredients.every((ri) => globalUsedIngredientsThisWeek.contains(ri.ingredientId))).toList();
            if (noNew.length >= 2) {
              pool = noNew;
            } else {
              // Fallback: sort by fewest new ingredients instead of hard-blocking
              pool.sort((a, b) {
                final aNew = a.ingredients.where((ri) => !globalUsedIngredientsThisWeek.contains(ri.ingredientId)).length;
                final bNew = b.ingredients.where((ri) => !globalUsedIngredientsThisWeek.contains(ri.ingredientId)).length;
                return aNew.compareTo(bNew);
              });
            }
          }
        }

        // Food group distribution enforcement
        final weekNum = ((day - 1) / 7).floor();
        if (ms.fishDaysPerWeek > 0) {
          final fishSoFar = weeklyFishCount[weekNum] ?? 0;
          final daysLeftInWeek = 7 - ((day - 1) % 7);
          if (fishSoFar < ms.fishDaysPerWeek && daysLeftInWeek <= (ms.fishDaysPerWeek - fishSoFar)) {
            final fishPool = pool.where((r) => r.type == RecipeType.peixe).toList();
            if (fishPool.isNotEmpty) pool = fishPool;
          }
        }
        if (ms.legumeDaysPerWeek > 0) {
          final legSoFar = weeklyLegumeCount[weekNum] ?? 0;
          final daysLeftInWeek = 7 - ((day - 1) % 7);
          if (legSoFar < ms.legumeDaysPerWeek && daysLeftInWeek <= (ms.legumeDaysPerWeek - legSoFar)) {
            final legPool = pool.where((r) => r.type == RecipeType.leguminosas).toList();
            if (legPool.isNotEmpty) pool = legPool;
          }
        }
        if (ms.redMeatMaxPerWeek < 7) {
          final redSoFar = weeklyRedMeatCount[weekNum] ?? 0;
          if (redSoFar >= ms.redMeatMaxPerWeek) {
            final noRed = pool.where((r) => !(r.type == RecipeType.carne && const {'porco', 'carne_picada'}.contains(r.proteinId))).toList();
            if (noRed.isNotEmpty) pool = noRed;
          }
        }

        // Pick recipe: dedup + protein diversity + favorites boost
        final usedToday = usedRecipesPerDay[day]!;
        var available = pool.where((r) => !usedToday.contains(r.id)).toList();
        if (available.isEmpty) available = pool.toList();
        if (available.isEmpty) available = _recipes.toList();

        // Consecutive-day dedup: avoid same recipe as yesterday for this mealType
        final prevRecipe = recentRecipePerMealType[mealType];
        if (prevRecipe != null) {
          final deduped = available.where((r) => r.id != prevRecipe).toList();
          if (deduped.isNotEmpty) {
            available = deduped;
          } else {
            // Pool collapsed to a single repeated recipe — widen to base pool
            final fallback = basePool(mealType, isWeekend)
                .where((r) => r.id != prevRecipe && !usedToday.contains(r.id))
                .toList();
            if (fallback.isNotEmpty) available = fallback;
          }
        }

        // Protein diversity: avoid same protein as last 2 days for this mealType
        final recentProteins = recentProteinPerMealType[mealType] ?? [];
        if (recentProteins.isNotEmpty) {
          final diverse = available.where((r) => !recentProteins.contains(r.proteinId)).toList();
          if (diverse.isNotEmpty) available = diverse;
        }

        // Calorie target soft filter
        if (ms.dailyCalorieTarget != null) {
          final mealsPerDay = ms.enabledMeals.length;
          final targetPerMeal = ms.dailyCalorieTarget! / mealsPerDay;
          final maxKcal = (targetPerMeal * 1.3).round();
          final calFiltered = available.where((r) =>
            r.nutrition == null || r.nutrition!.kcal <= maxKcal).toList();
          if (calFiltered.length >= 3) available = calFiltered;
        }

        // Fiber boost
        if (ms.dailyFiberTargetG != null && ms.dailyFiberTargetG! > 0) {
          available.sort((a, b) {
            final aFiber = a.nutrition?.fiberG ?? 0;
            final bFiber = b.nutrition?.fiberG ?? 0;
            return bFiber.compareTo(aFiber);
          });
        }

        // Protein boost
        if (ms.dailyProteinTargetG != null) {
          final mealsPerDay = ms.enabledMeals.length;
          final targetPerMeal = ms.dailyProteinTargetG! / mealsPerDay;
          available.sort((a, b) {
            final aDiff = ((a.nutrition?.proteinG ?? 0) - targetPerMeal).abs();
            final bDiff = ((b.nutrition?.proteinG ?? 0) - targetPerMeal).abs();
            return aDiff.compareTo(bDiff);
          });
        }

        // Shuffle then partition: favorites first, rest after (boost, don't eliminate)
        // Skip shuffle when minimizing cost to preserve cost-sorted order
        if (ms.objective != MealObjective.minimizeCost) {
          available.shuffle(rng);
        }
        if (favorites.isNotEmpty) {
          final favs = <Recipe>[];
          final rest = <Recipe>[];
          for (final r in available) {
            final ing = iMap[r.proteinId];
            if (ing != null && favorites.any((fav) =>
                fav.toLowerCase().contains(ing.name.toLowerCase()) ||
                ing.name.toLowerCase().contains(fav.toLowerCase().split(' ').first))) {
              favs.add(r);
            } else {
              rest.add(r);
            }
          }
          available = [...favs, ...rest];
        }

        // Feedback integration
        if (previousFeedback.isNotEmpty) {
          // Remove disliked
          final noDisliked = available.where((r) =>
            previousFeedback[r.id] != MealFeedback.disliked).toList();
          if (noDisliked.length >= 3) available = noDisliked;

          // Boost liked
          final liked = <Recipe>[];
          final fbRest = <Recipe>[];
          for (final r in available) {
            if (previousFeedback[r.id] == MealFeedback.liked) {
              liked.add(r);
            } else {
              fbRest.add(r);
            }
          }
          available = [...liked, ...fbRest];
        }

        // Seasonal boost
        if (ms.preferSeasonal) {
          final month = forMonth.month;
          final season = month >= 3 && month <= 5 ? 'spring'
              : month >= 6 && month <= 8 ? 'summer'
              : month >= 9 && month <= 11 ? 'autumn'
              : 'winter';
          final seasonal = <Recipe>[];
          final nonSeasonal = <Recipe>[];
          for (final r in available) {
            if (r.seasons.isEmpty || r.seasons.contains(season)) {
              seasonal.add(r);
            } else {
              nonSeasonal.add(r);
            }
          }
          if (seasonal.isNotEmpty) {
            available = [...seasonal, ...nonSeasonal];
          }
        }

        // Taste profile boost: partition into profile-matching and rest
        if (!tasteProfile.isEmpty && available.length > 1) {
          final profiled = <Recipe>[];
          final profileRest = <Recipe>[];
          for (final r in available) {
            if (tasteProfile.scoreRecipe(r) >= 0.6) {
              profiled.add(r);
            } else {
              profileRest.add(r);
            }
          }
          if (profiled.isNotEmpty) {
            available = [...profiled, ...profileRest];
          }
        }

        final recipe = available.first;
        usedToday.add(recipe.id);
        recentRecipePerMealType[mealType] = recipe.id;
        final rpList = List<String>.from(recentProteinPerMealType[mealType] ?? []);
        rpList.add(recipe.proteinId);
        if (rpList.length > 2) rpList.removeAt(0);
        recentProteinPerMealType[mealType] = rpList;

        // Track food group distribution
        final rType = recipe.type;
        if (rType == RecipeType.peixe) {
          weeklyFishCount[weekNum] = (weeklyFishCount[weekNum] ?? 0) + 1;
        } else if (rType == RecipeType.leguminosas) {
          weeklyLegumeCount[weekNum] = (weeklyLegumeCount[weekNum] ?? 0) + 1;
        } else if (rType == RecipeType.carne && const {'porco', 'carne_picada'}.contains(recipe.proteinId)) {
          weeklyRedMeatCount[weekNum] = (weeklyRedMeatCount[weekNum] ?? 0) + 1;
        }

        days.add(MealDay(
          dayIndex: day,
          recipeId: recipe.id,
          costEstimate: cachedCost(recipe),
          mealType: mealType,
        ));

        // Update ingredient tracking
        int newCount = newIngredientCountThisWeek[mealType] ?? 0;
        for (final ri in recipe.ingredients) {
          if (!globalUsedIngredientsThisWeek.contains(ri.ingredientId)) {
            globalUsedIngredientsThisWeek.add(ri.ingredientId);
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

    if (total <= plan.monthlyBudget) {
      return _fixLeftoverRefs(plan, days);
    }

    // Pre-lowercase disliked ingredients once
    final dislikedLower = ms.dislikedIngredients.map((d) => d.toLowerCase()).toSet();
    final ingredientNameLower = <String, String>{};
    for (final ing in _ingredients) {
      ingredientNameLower[ing.id] = ing.name.toLowerCase();
    }
    final excludedSet = ms.excludedProteins.toSet();

    // Pre-compute eligible recipes per meal type (hard filters only, day-independent)
    final eligibleByMealType = <MealType, List<(Recipe, double)>>{};
    for (final mt in MealType.values) {
      final mtName = mt.name;
      final eligible = <(Recipe, double)>[];
      for (final r in _recipes) {
        if (!r.suitableMealTypes.contains(mtName)) continue;
        if (ms.glutenFree && !r.glutenFree) continue;
        if (ms.lactoseFree && !r.lactoseFree) continue;
        if (ms.nutFree && !r.nutFree) continue;
        if (ms.shellfishFree && !r.shellfishFree) continue;
        if (excludedSet.contains(r.proteinId)) continue;
        bool disliked = false;
        if (dislikedLower.isNotEmpty) {
          for (final ri in r.ingredients) {
            final name = ingredientNameLower[ri.ingredientId];
            if (name != null && dislikedLower.contains(name)) {
              disliked = true;
              break;
            }
          }
        }
        if (disliked) continue;
        eligible.add((r, recipeCost(r, np, iMap)));
      }
      // Pre-sort by cost ascending
      eligible.sort((a, b) => a.$2.compareTo(b.$2));
      eligibleByMealType[mt] = eligible;
    }

    int iterations = 0;
    while (total > plan.monthlyBudget && iterations < 100) {
      iterations++;

      // Find most expensive day in O(n) instead of sorting
      int expensiveIdx = 0;
      for (int i = 1; i < days.length; i++) {
        if (days[i].costEstimate > days[expensiveIdx].costEstimate) {
          expensiveIdx = i;
        }
      }
      final expensive = days[expensiveIdx];

      // Find cheapest eligible replacement from pre-sorted list
      final eligible = eligibleByMealType[expensive.mealType] ?? [];
      (Recipe, double)? replacement;
      for (final entry in eligible) {
        if (entry.$1.id != expensive.recipeId && entry.$2 < expensive.costEstimate) {
          replacement = entry;
          break; // already sorted by cost, first match is cheapest
        }
      }

      if (replacement == null) break;

      final oldCost = expensive.costEstimate;
      days[expensiveIdx] = expensive.copyWith(
        recipeId: replacement.$1.id,
        costEstimate: replacement.$2,
      );
      total += replacement.$2 - oldCost; // Incremental update
    }

    days.sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    return _fixLeftoverRefs(plan, days);
  }

  MealPlan _fixLeftoverRefs(MealPlan plan, List<MealDay> days) {
    days.sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
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
    final excludedSet = ms?.excludedProteins.toSet();
    var pool = _recipes.where((r) => r.id != recipeId).toList();
    if (ms != null) {
      pool = pool.where((r) {
        if (ms.glutenFree && !r.glutenFree) return false;
        if (ms.lactoseFree && !r.lactoseFree) return false;
        if (ms.nutFree && !r.nutFree) return false;
        if (ms.shellfishFree && !r.shellfishFree) return false;
        if (excludedSet != null && excludedSet.contains(r.proteinId)) return false;
        return true;
      }).toList();
    }
    // Pre-compute costs for sorting
    final costs = <String, double>{};
    for (final r in pool) {
      costs[r.id] = recipeCost(r, np, iMap);
    }
    final currentProtein = current.proteinId;
    pool.sort((a, b) {
      final aMatch = a.proteinId == currentProtein ? 0 : 1;
      final bMatch = b.proteinId == currentProtein ? 0 : 1;
      if (aMatch != bMatch) return aMatch.compareTo(bMatch);
      return costs[a.id]!.compareTo(costs[b.id]!);
    });
    return pool;
  }

  MealPlan swapDay(MealPlan plan, int dayIndex, MealType mealType, String newRecipeId) {
    final iMap = ingredientMap;
    final newRecipe = recipeMap[newRecipeId]!;
    final newCost = recipeCost(newRecipe, plan.nPessoas, iMap);
    final updatedDays = plan.days.map((d) {
      if (d.dayIndex == dayIndex && d.mealType == mealType) {
        return d.copyWith(recipeId: newRecipeId, costEstimate: newCost);
      }
      return d;
    }).toList();
    return plan.copyWithDays(updatedDays);
  }

  // --- Consolidated ingredient list ---

  Map<String, double> consolidatedIngredients(MealPlan plan, {List<String> pantryIngredients = const []}) {
    final totals = <String, double>{};
    for (final day in plan.days) {
      if (day.isLeftover) continue;
      if (day.isFreeform) continue; // freeform items handled separately
      final recipe = recipeMap[day.recipeId];
      if (recipe == null) continue;
      final dayGuests = plan.extraGuests[day.dayIndex] ?? 0;
      final scale = (plan.nPessoas + dayGuests) / recipe.servings;
      for (final ri in recipe.ingredients) {
        final effectiveId = day.substitutions[ri.ingredientId] ?? ri.ingredientId;
        totals.update(
          effectiveId,
          (v) => v + ri.quantity * scale,
          ifAbsent: () => ri.quantity * scale,
        );
      }
    }
    for (final id in pantryIngredients) {
      totals.remove(id);
    }
    return totals;
  }

  /// Returns freeform shopping items from all freeform meals in the plan.
  List<FreeformMealItem> freeformShoppingItems(MealPlan plan) {
    final items = <FreeformMealItem>[];
    for (final day in plan.days) {
      if (!day.isFreeform) continue;
      items.addAll(day.freeformShoppingItems);
    }
    return items;
  }

  /// Returns freeform shopping items from meals within the given week.
  List<FreeformMealItem> freeformShoppingItemsForWeek(MealPlan plan, List<MealDay> weekDays) {
    final items = <FreeformMealItem>[];
    for (final day in weekDays) {
      if (!day.isFreeform) continue;
      items.addAll(day.freeformShoppingItems);
    }
    return items;
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
