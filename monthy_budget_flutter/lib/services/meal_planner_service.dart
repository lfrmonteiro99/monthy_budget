import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_planner.dart';
import '../models/app_settings.dart';
import '../models/meal_settings.dart';
import '../models/pantry_item.dart';
import '../repositories/meal_repository.dart';
import 'log_service.dart';
import '../utils/taste_profile.dart';
import '../utils/unit_converter.dart';

class MealPlannerService {

  static const _recipeCacheKey = 'cached_recipes_json';
  static const _ingredientCacheKey = 'cached_ingredients_json';

  List<Ingredient> _ingredients = [];
  List<Recipe> _recipes = [];
  bool _catalogLoaded = false;
  Map<String, Ingredient>? _ingredientMapCache;
  Map<String, Recipe>? _recipeMapCache;
  MealPlanRepository? _repository;

  MealPlannerService({MealPlanRepository? repository})
    : _repository = repository;

  MealPlanRepository get _mealPlanRepository =>
      _repository ??= SupabaseMealPlanRepository();

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
      final recipesData = await _mealPlanRepository.loadRecipeRows();

      if (recipesData.isEmpty) return false;

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
          isCompleteMeal: r['is_complete_meal'] as bool? ?? true,
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
          courseType: CourseType.values.firstWhere(
            (e) => e.name == (r['course_type'] ?? 'mainCourse'),
            orElse: () => CourseType.mainCourse,
          ),
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
      LogService.warning(
        'Supabase recipe load failed, falling back to cache/assets',
        error: e,
        category: 'service.meal_planner',
      );
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

  /// Check if an ingredient is seasonally cheap (current price < 80% of its
  /// average price from the meal planner catalog).
  @visibleForTesting
  static bool isSeasonallyCheap(
    String ingredientName,
    Map<String, double> currentPrices,
    Map<String, double> avgPrices,
  ) {
    final key = ingredientName.toLowerCase();
    final current = currentPrices[key];
    final avg = avgPrices[key];
    if (current == null || avg == null || avg == 0) return false;
    return current < avg * 0.8;
  }

  /// Builds a map of ingredient name (lowercase) -> avgPricePerUnit from the
  /// loaded ingredient catalog. Used as the baseline for seasonal price
  /// comparison.
  Map<String, double> _buildAvgPriceMap() {
    final map = <String, double>{};
    for (final ing in _ingredients) {
      if (ing.avgPricePerUnit > 0) {
        map[ing.name.toLowerCase()] = ing.avgPricePerUnit;
      }
    }
    return map;
  }

  MealPlan generate(AppSettings settings, DateTime forMonth, {List<String> favorites = const [], Map<String, MealFeedback> previousFeedback = const {}, Map<String, int> previousRatings = const {}, Map<String, double>? groceryPrices}) {
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

    // Build taste profile from previous feedback and ratings
    final tasteProfile = (previousFeedback.isNotEmpty || previousRatings.isNotEmpty)
        ? TasteProfile.fromFeedback(feedback: previousFeedback, recipeMap: recipeMap, ratings: previousRatings)
        : const TasteProfile();

    // Pre-compute average price map for price-based seasonal boost
    final avgPriceMap = groceryPrices != null ? _buildAvgPriceMap() : <String, double>{};

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

    // Core eliminatory filter (day-independent parts).
    // Split into two layers:
    //   - passesDietarySafety: allergens, medical, sodium, disliked, excluded
    //     proteins. These are safety invariants — never relax.
    //   - hasRequiredEquipment: convenience constraint for mains only.
    // Soups/desserts apply only the safety layer so an optional starter or
    // dessert does not disappear just because its recipe needs a blender.
    bool passesDietarySafety(Recipe r) {
      if (ms.glutenFree && !r.glutenFree) return false;
      if (ms.lactoseFree && !r.lactoseFree) return false;
      if (ms.nutFree && !r.nutFree) return false;
      if (ms.shellfishFree && !r.shellfishFree) return false;
      if (ms.eggFree && r.ingredients.any((ri) => ri.ingredientId == 'ovo')) return false;
      if (excludedProteinsSet.contains(r.proteinId)) return false;
      if (hasDislikedIngredient(r)) return false;
      if (isLowSodium && r.ingredients.any((ri) => highSodiumIds.contains(ri.ingredientId))) return false;
      if (hasDiabetes && r.nutrition != null && r.nutrition!.carbsG > 55) return false;
      if (hasHypertension && r.nutrition != null && r.nutrition!.sodiumMg > 500) return false;
      if (hasCholesterol && r.nutrition != null && r.nutrition!.fatG > 25) return false;
      if (hasGout && highPurineProteins.contains(r.proteinId)) return false;
      return true;
    }

    bool passesHardFilters(Recipe r) {
      if (!passesDietarySafety(r)) return false;
      if (!hasRequiredEquipment(r)) return false;
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
    final weeklySoupCount = <int, int>{}; // weekNumber -> count
    const maxSoupsPerWeek = 2;

    // Track recent soup/dessert recipes for multi-day dedup
    final recentSoupRecipes = <String>[]; // last N soup recipe IDs (across days)
    final recentDessertRecipes = <String>[]; // last N dessert recipe IDs (across days)
    // Track the recipe used 2 days ago per meal type for extended main course dedup
    final prevPrevRecipePerMealType = <MealType, String>{};

    for (int day = 1; day <= daysInMonth; day++) {
      usedRecipesPerDay[day] = {};
      // Reset weekly tracking on Mondays (weekday 1).
      // IMPORTANT: reset BEFORE the eating-out skip, otherwise trackers
      // never reset when Monday is an eating-out day.
      final weekday = DateTime(forMonth.year, forMonth.month, day).weekday;
      final isWeekend = weekday == 6 || weekday == 7;
      if (weekday == 1) {
        globalUsedIngredientsThisWeek = {};
        for (final m in ms.enabledMeals) {
          newIngredientCountThisWeek[m] = 0;
        }
      }
      // Skip eating-out days
      if (ms.eatingOutWeekdays.contains(weekday)) continue;

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

        // --- Leftovers (lunch reuses previous dinner's MAIN course) ---
        // With multi-course dinners, yesterday has up to 3 MealDay entries for
        // dinner (soup, main, dessert). We must explicitly pick the mainCourse
        // so leftovers don't inherit a dessert or soup recipe.
        if (ms.reuseLeftovers && mealType == MealType.lunch && day > 1 && ms.enabledMeals.contains(MealType.dinner)) {
          final prevDinner = days.lastWhere(
            (d) =>
                d.dayIndex == day - 1 &&
                d.mealType == MealType.dinner &&
                d.courseType == CourseType.mainCourse,
            orElse: () => MealDay(dayIndex: 0, recipeId: '', costEstimate: 0),
          );
          if (prevDinner.recipeId.isNotEmpty) {
            days.add(MealDay(
              dayIndex: day,
              recipeId: prevDinner.recipeId,
              isLeftover: true,
              costEstimate: 0,
              mealType: MealType.lunch,
              courseType: CourseType.mainCourse,
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

        // Soup limit: max 2 soups per week
        final soupsSoFar = weeklySoupCount[weekNum] ?? 0;
        if (soupsSoFar >= maxSoupsPerWeek) {
          final noSoup = pool.where((r) => r.courseType != CourseType.soupOrStarter).toList();
          if (noSoup.isNotEmpty) pool = noSoup;
        }

        // Always exclude soups/desserts from the main course pool —
        // they should never be picked as standalone main courses.
        {
          final mainOnly = pool.where((r) =>
            r.courseType != CourseType.soupOrStarter && r.courseType != CourseType.dessert).toList();
          if (mainOnly.isNotEmpty) pool = mainOnly;
        }

        // Minimum protein: exclude low-protein soups/sides from main meals
        final highProtein = pool.where((r) =>
          r.nutrition == null ||
          r.nutrition!.proteinG >= Recipe.mainMealMinProteinG).toList();
        if (highProtein.length >= 3) pool = highProtein;

        // Complete meal filter: for lunch/dinner, REQUIRE recipes with a real
        // protein source (meat, fish, eggs, tofu). This is a HARD filter —
        // no fallback to incomplete meals. Every lunch/dinner main course
        // must have strong protein.
        if (mealType == MealType.lunch || mealType == MealType.dinner) {
          final complete = pool.where((r) => r.isCompleteMeal).toList();
          if (complete.isNotEmpty) pool = complete;
        }

        // Pick recipe: dedup + protein diversity + favorites boost
        final usedToday = usedRecipesPerDay[day]!;
        var available = pool.where((r) => !usedToday.contains(r.id)).toList();
        if (available.isEmpty) available = pool.toList();
        if (available.isEmpty) available = _recipes.toList();

        // Consecutive-day dedup: avoid same recipe as yesterday AND 2 days ago for this mealType
        final prevRecipe = recentRecipePerMealType[mealType];
        final prevPrevRecipe = prevPrevRecipePerMealType[mealType];
        final recentMainRecipes = <String>{
          if (prevRecipe != null) prevRecipe,
          if (prevPrevRecipe != null) prevPrevRecipe,
        };
        if (recentMainRecipes.isNotEmpty) {
          final deduped = available.where((r) => !recentMainRecipes.contains(r.id)).toList();
          if (deduped.isNotEmpty) {
            available = deduped;
          } else {
            // Pool collapsed to repeated recipes — widen to base pool
            final fallback = basePool(mealType, isWeekend)
                .where((r) => !recentMainRecipes.contains(r.id) && !usedToday.contains(r.id))
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

        // Price-based seasonal boost: prefer recipes with cheap ingredients
        if (groceryPrices != null && groceryPrices.isNotEmpty && available.length > 1) {
          int cheapCount(Recipe r) {
            int count = 0;
            for (final ri in r.ingredients) {
              final name = ingredientNameLower[ri.ingredientId];
              if (name != null && isSeasonallyCheap(name, groceryPrices, avgPriceMap)) {
                count++;
              }
            }
            return count;
          }
          final boosted = <Recipe>[];
          final rest = <Recipe>[];
          for (final r in available) {
            if (cheapCount(r) > 0) {
              boosted.add(r);
            } else {
              rest.add(r);
            }
          }
          if (boosted.isNotEmpty && boosted.length < available.length) {
            // Sort boosted recipes by number of cheap ingredients (desc)
            boosted.sort((a, b) => cheapCount(b).compareTo(cheapCount(a)));
            available = [...boosted, ...rest];
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
        // Track prev-prev before overwriting prev for extended 2-day dedup
        final oldPrev = recentRecipePerMealType[mealType];
        if (oldPrev != null) {
          prevPrevRecipePerMealType[mealType] = oldPrev;
        }
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
        if (recipe.courseType == CourseType.soupOrStarter) {
          weeklySoupCount[weekNum] = (weeklySoupCount[weekNum] ?? 0) + 1;
        }

        // --- Multi-course meal generation ---
        // If soup/starter is enabled and this is a main meal (lunch/dinner),
        // pick a soup/starter BEFORE the main course. The maxSoupsPerWeek cap
        // applies to soup MAIN COURSES only (soups picked as the main dish);
        // starter soups reflect an explicit user opt-in and are not capped.
        if (ms.includeSoupOrStarter &&
            (mealType == MealType.lunch || mealType == MealType.dinner)) {
          final soupPool = _recipes.where((r) {
            if (r.courseType != CourseType.soupOrStarter) return false;
            if (!r.suitableMealTypes.contains(mealType.name)) return false;
            // Safety layer only: allergens, medical, disliked, sodium,
            // excluded proteins. Equipment is intentionally omitted so an
            // optional starter isn't silently dropped when only mains need
            // it.
            if (!passesDietarySafety(r)) return false;
            return true;
          }).toList();
          if (soupPool.isNotEmpty) {
            // Filter out recipes already used today (cross-course dedup)
            var filteredSoups = soupPool.where((r) => !usedToday.contains(r.id)).toList();
            if (filteredSoups.isEmpty) filteredSoups = soupPool;
            // Filter out soups used in the previous 3 days
            if (recentSoupRecipes.isNotEmpty) {
              final recentSoupSet = recentSoupRecipes.toSet();
              final dedupedSoups = filteredSoups.where((r) => !recentSoupSet.contains(r.id)).toList();
              if (dedupedSoups.isNotEmpty) filteredSoups = dedupedSoups;
            }
            filteredSoups.shuffle(rng);
            final soupRecipe = filteredSoups.first;
            usedToday.add(soupRecipe.id);
            // Track recent soups (keep last 3 for 3-day dedup window)
            recentSoupRecipes.add(soupRecipe.id);
            if (recentSoupRecipes.length > 3) recentSoupRecipes.removeAt(0);
            days.add(MealDay(
              dayIndex: day,
              recipeId: soupRecipe.id,
              costEstimate: cachedCost(soupRecipe),
              mealType: mealType,
              courseType: CourseType.soupOrStarter,
            ));
          }
        }

        // Main course
        days.add(MealDay(
          dayIndex: day,
          recipeId: recipe.id,
          costEstimate: cachedCost(recipe),
          mealType: mealType,
          courseType: CourseType.mainCourse,
        ));

        // If dessert is enabled, pick a dessert AFTER the main course.
        // Safety layer only (allergens, medical, disliked, excluded proteins,
        // sodium); equipment is intentionally omitted since an optional
        // dessert shouldn't disappear when it requires a blender the user
        // doesn't have.
        if (ms.includeDessert &&
            (mealType == MealType.lunch || mealType == MealType.dinner)) {
          final dessertPool = _recipes.where((r) {
            if (r.courseType != CourseType.dessert) return false;
            if (!r.suitableMealTypes.contains(mealType.name)) return false;
            if (!passesDietarySafety(r)) return false;
            return true;
          }).toList();
          if (dessertPool.isNotEmpty) {
            // Filter out recipes already used today (cross-course dedup)
            var filteredDesserts = dessertPool.where((r) => !usedToday.contains(r.id)).toList();
            if (filteredDesserts.isEmpty) filteredDesserts = dessertPool;
            // Filter out desserts used in the previous 2 days
            if (recentDessertRecipes.isNotEmpty) {
              final recentDessertSet = recentDessertRecipes.toSet();
              final dedupedDesserts = filteredDesserts.where((r) => !recentDessertSet.contains(r.id)).toList();
              if (dedupedDesserts.isNotEmpty) filteredDesserts = dedupedDesserts;
            }
            filteredDesserts.shuffle(rng);
            final dessertRecipe = filteredDesserts.first;
            usedToday.add(dessertRecipe.id);
            // Track recent desserts (keep last 2 for 2-day dedup window)
            recentDessertRecipes.add(dessertRecipe.id);
            if (recentDessertRecipes.length > 2) recentDessertRecipes.removeAt(0);
            days.add(MealDay(
              dayIndex: day,
              recipeId: dessertRecipe.id,
              costEstimate: cachedCost(dessertRecipe),
              mealType: mealType,
              courseType: CourseType.dessert,
            ));
          }
        }

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

      // Find cheapest eligible replacement from pre-sorted list.
      // Must match the same courseType to preserve multi-course integrity.
      // For lunch/dinner main courses, the replacement must also be a
      // complete meal so we don't swap a hearty main for a cheap side dish.
      final expensiveRecipe = recipeMap[expensive.recipeId];
      final expensiveCourseType = expensiveRecipe?.courseType ?? expensive.courseType;
      final requireCompleteMeal =
          expensiveCourseType == CourseType.mainCourse &&
              (expensive.mealType == MealType.lunch ||
                  expensive.mealType == MealType.dinner);
      final eligible = eligibleByMealType[expensive.mealType] ?? [];
      (Recipe, double)? replacement;
      for (final entry in eligible) {
        if (entry.$1.id != expensive.recipeId &&
            entry.$2 < expensive.costEstimate &&
            entry.$1.courseType == expensiveCourseType &&
            (!requireCompleteMeal || entry.$1.isCompleteMeal)) {
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
      // Multi-course dinners may have soup/main/dessert entries; lock to the
      // main course so leftovers never point at a soup or dessert recipe.
      final dinner = days.where(
        (d) =>
            d.dayIndex == dinnerDay &&
            d.mealType == MealType.dinner &&
            d.courseType == CourseType.mainCourse,
      ).firstOrNull;
      if (dinner != null && dinner.recipeId != days[i].recipeId) {
        days[i] = days[i].copyWith(recipeId: dinner.recipeId, costEstimate: 0);
      }
    }
    return plan.copyWithDays(days);
  }

  // --- Swap ---

  List<Recipe> alternativesFor(String recipeId, int np, {MealSettings? ms, bool crossType = false, CourseType? courseType}) {
    final current = recipeMap[recipeId];
    if (current == null) return [];
    final iMap = ingredientMap;
    final excludedSet = ms?.excludedProteins.toSet();
    var pool = _recipes.where((r) => r.id != recipeId).toList();

    // Filter by course type: soups swap with soups, desserts with desserts, etc.
    if (courseType != null) {
      switch (courseType) {
        case CourseType.soupOrStarter:
          pool = pool.where((r) => r.courseType == CourseType.soupOrStarter).toList();
        case CourseType.dessert:
          pool = pool.where((r) => r.courseType == CourseType.dessert).toList();
        case CourseType.mainCourse:
          pool = pool.where((r) => r.courseType != CourseType.soupOrStarter && r.courseType != CourseType.dessert).toList();
      }
    }

    // When crossType is false, restrict to recipes sharing at least one
    // suitableMealType with the current recipe (same-type swap).
    if (!crossType && current.suitableMealTypes.isNotEmpty) {
      final types = current.suitableMealTypes.toSet();
      pool = pool.where((r) => r.suitableMealTypes.any(types.contains)).toList();
    }

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

  MealPlan swapDay(MealPlan plan, int dayIndex, MealType mealType, String newRecipeId, {MealType? newMealType, CourseType? courseType}) {
    final iMap = ingredientMap;
    final newRecipe = recipeMap[newRecipeId]!;
    final newCost = recipeCost(newRecipe, plan.nPessoas, iMap);
    final updatedDays = plan.days.map((d) {
      if (d.dayIndex == dayIndex && d.mealType == mealType &&
          (courseType == null || d.courseType == courseType)) {
        return d.copyWith(
          recipeId: newRecipeId,
          costEstimate: newCost,
          mealType: newMealType,
        );
      }
      return d;
    }).toList();
    return plan.copyWithDays(updatedDays);
  }

  // --- Consolidated ingredient list ---

  Map<String, double> consolidatedIngredients(
    MealPlan plan, {
    List<String> pantryIngredients = const [],
    List<PantryItem> pantryItems = const [],
  }) {
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
    // Legacy: remove pantry ingredient IDs entirely (no quantity awareness)
    for (final id in pantryIngredients) {
      totals.remove(id);
    }
    // Quantity-aware pantry subtraction
    final iMap = ingredientMap;
    for (final item in pantryItems) {
      if (!totals.containsKey(item.ingredientId)) continue;
      final needed = totals[item.ingredientId]!;
      final ingredient = iMap[item.ingredientId];
      double available = item.quantity;
      // Convert pantry unit to recipe unit if compatible
      if (ingredient != null && item.unit != ingredient.unit) {
        final converted =
            UnitConverter.convert(item.quantity, item.unit, ingredient.unit);
        if (converted != null) available = converted;
      }
      final remaining = needed - available;
      if (remaining <= 0) {
        totals.remove(item.ingredientId);
      } else {
        totals[item.ingredientId] = remaining;
      }
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
    return _mealPlanRepository.loadPlan(householdId, month, year);
  }

  Future<void> save(MealPlan plan, String householdId) async {
    await _mealPlanRepository.savePlan(plan, householdId);
  }

  Future<void> clear(String householdId, int month, int year) async {
    await _mealPlanRepository.clearPlan(householdId, month, year);
  }

  // --- Undo support ---

  /// Save a plan as the "previous" plan for undo capability.
  /// Only keeps one previous plan per month/year.
  Future<void> savePreviousPlan(MealPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'meal_plan_previous_${plan.month}_${plan.year}';
    await prefs.setString(key, plan.toJsonString());
  }

  /// Load the previous plan for a given month/year, if any.
  Future<MealPlan?> loadPreviousPlan(int month, int year) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'meal_plan_previous_${month}_$year';
    final json = prefs.getString(key);
    if (json == null) return null;
    try {
      return MealPlan.fromJsonString(json);
    } catch (_) {
      return null;
    }
  }

  /// Clear the previous plan backup.
  Future<void> clearPreviousPlan(int month, int year) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'meal_plan_previous_${month}_$year';
    await prefs.remove(key);
  }
}
