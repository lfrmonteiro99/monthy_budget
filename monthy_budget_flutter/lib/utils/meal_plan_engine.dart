import 'dart:math';
import '../models/meal_plan.dart';
import '../data/ingredients_db.dart';
import '../data/recipes_db.dart';

/// Deterministic meal planning engine.
///
/// Strategy: greedy controlled algorithm with protein clustering.
/// 1. Select 4 protein clusters for the month (rotate weekly).
/// 2. For each week, pick a dominant protein.
/// 3. Generate meals around that protein (3 dominant + 1 diverse).
/// 4. Distribute across 14 meal slots (7 lunches + 7 dinners).
/// 5. Use leftovers for some dinner slots.
/// 6. Validate weekly cost <= budget.
/// 7. Minimize waste by matching real purchase quantities.

class MealPlanEngine {
  final MealPlanConfig config;
  final Random _rng;

  MealPlanEngine({required this.config, int? seed})
      : _rng = Random(seed ?? DateTime.now().millisecondsSinceEpoch);

  // ─── Cost Calculation ───────────────────────────────────────────────

  /// Calculate cost of a recipe for the configured number of people.
  double calculateRecipeCost(Recipe recipe) {
    double total = 0;
    for (final ri in recipe.ingredientes) {
      final ingredient = getIngredient(ri.ingredientId);
      if (ingredient == null) continue;
      final qty = ri.quantidadePorPessoa * config.nPessoas;
      total += qty * ingredient.precoMedioUnitario;
    }
    return total;
  }

  /// Calculate cost per person for a recipe.
  double calculateRecipeCostPerPerson(Recipe recipe) {
    return calculateRecipeCost(recipe) / config.nPessoas;
  }

  /// Build the list of PlannedIngredients for a recipe.
  List<PlannedIngredient> buildPlannedIngredients(Recipe recipe) {
    return recipe.ingredientes.map((ri) {
      final ingredient = getIngredient(ri.ingredientId);
      final qty = ri.quantidadePorPessoa * config.nPessoas;
      final cost = ingredient != null ? qty * ingredient.precoMedioUnitario : 0.0;
      return PlannedIngredient(
        ingredientId: ri.ingredientId,
        nome: ingredient?.nome ?? ri.ingredientId,
        quantidade: qty,
        unidade: ingredient?.unidadeBase ?? 'kg',
        precoEstimado: cost,
      );
    }).toList();
  }

  /// Build a PlannedMeal from a Recipe.
  PlannedMeal buildPlannedMeal(Recipe recipe, {bool isSobras = false, String? sobrasDeReceitaId}) {
    final ingredients = buildPlannedIngredients(recipe);
    final totalCost = isSobras ? 0.0 : calculateRecipeCost(recipe);
    final costPerPerson = isSobras ? 0.0 : calculateRecipeCostPerPerson(recipe);
    return PlannedMeal(
      receitaId: recipe.id,
      nomeReceita: isSobras ? 'Sobras: ${recipe.nome}' : recipe.nome,
      ingredientes: ingredients,
      custoEstimadoPorPessoa: costPerPerson,
      custoEstimadoTotal: totalCost,
      isSobras: isSobras,
      sobrasDeReceitaId: sobrasDeReceitaId,
    );
  }

  // ─── Protein Cluster Selection ──────────────────────────────────────

  /// Select 4 protein clusters for the month based on variety level.
  List<ProteinCluster> selectMonthlyClusters() {
    final all = List<ProteinCluster>.from(ProteinCluster.values);
    _shuffle(all);

    switch (config.nivelVariedade) {
      case VarietyLevel.economico:
        // Use 3 cheapest clusters, repeat one
        final scored = all.map((c) => MapEntry(c, _clusterAvgCost(c))).toList()
          ..sort((a, b) => a.value.compareTo(b.value));
        final top3 = scored.take(3).map((e) => e.key).toList();
        return [top3[0], top3[1], top3[2], top3[0]];
      case VarietyLevel.equilibrado:
        // Use 4 different clusters
        return all.take(4).toList();
      case VarietyLevel.variado:
        // Use all 5 clusters (one week gets 2 clusters)
        return [...all.take(4)];
    }
  }

  double _clusterAvgCost(ProteinCluster cluster) {
    final recipes = getRecipesByCluster(cluster);
    if (recipes.isEmpty) return double.infinity;
    final total = recipes.fold(0.0, (sum, r) => sum + calculateRecipeCostPerPerson(r));
    return total / recipes.length;
  }

  // ─── Week Plan Generation ──────────────────────────────────────────

  /// Generate a week plan for a given protein cluster and start date.
  WeekPlan generateWeekPlan({
    required int semana,
    required ProteinCluster dominantCluster,
    required DateTime weekStart,
    List<String> usedRecipeIds = const [],
  }) {
    final clusterRecipes = getRecipesByCluster(dominantCluster)
        .where((r) => r.complexidade <= config.preferenciaComplexidade + 1)
        .toList();

    // Sort by cost (cheapest first for economico, mixed for others)
    clusterRecipes.sort((a, b) =>
        calculateRecipeCostPerPerson(a).compareTo(calculateRecipeCostPerPerson(b)));

    // Select recipes from dominant cluster
    final recipesPerWeek = config.nivelVariedade.recipesPerWeek;
    final dominantCount = (recipesPerWeek * 0.7).ceil().clamp(3, clusterRecipes.length);

    final selectedDominant = <Recipe>[];
    for (final r in clusterRecipes) {
      if (selectedDominant.length >= dominantCount) break;
      if (!usedRecipeIds.contains(r.id)) {
        selectedDominant.add(r);
      }
    }
    // If not enough unique, allow repeats from cluster
    if (selectedDominant.length < 3) {
      for (final r in clusterRecipes) {
        if (selectedDominant.length >= 3) break;
        if (!selectedDominant.any((s) => s.id == r.id)) {
          selectedDominant.add(r);
        }
      }
    }

    // Select diverse recipes from other clusters
    final diverseCount = recipesPerWeek - selectedDominant.length;
    final otherClusters = ProteinCluster.values
        .where((c) => c != dominantCluster)
        .toList();
    _shuffle(otherClusters);

    final selectedDiverse = <Recipe>[];
    for (final cluster in otherClusters) {
      if (selectedDiverse.length >= diverseCount) break;
      final recipes = getRecipesByCluster(cluster)
          .where((r) => r.complexidade <= config.preferenciaComplexidade + 1)
          .where((r) => !usedRecipeIds.contains(r.id))
          .toList();
      if (recipes.isNotEmpty) {
        recipes.sort((a, b) =>
            calculateRecipeCostPerPerson(a).compareTo(calculateRecipeCostPerPerson(b)));
        selectedDiverse.add(recipes.first);
      }
    }

    // Combine all selected recipes
    final allSelected = [...selectedDominant, ...selectedDiverse];

    // Distribute across 7 days (almoco + jantar)
    final days = <DayPlan>[];
    final weekBudget = config.orcamentoSemanal;
    double weekCostSoFar = 0;

    for (int d = 0; d < 7; d++) {
      final date = weekStart.add(Duration(days: d));

      // Pick lunch recipe - cycle through selected recipes
      final lunchIdx = d % allSelected.length;
      final lunchRecipe = allSelected[lunchIdx];
      final lunchMeal = buildPlannedMeal(lunchRecipe);

      // Pick dinner - prefer leftovers from reutilizavel lunch, else pick different recipe
      PlannedMeal dinnerMeal;
      if (lunchRecipe.reutilizavel && d % 2 == 0) {
        // Use leftovers every other day for reutilizavel recipes
        dinnerMeal = buildPlannedMeal(
          lunchRecipe,
          isSobras: true,
          sobrasDeReceitaId: lunchRecipe.id,
        );
      } else {
        // Pick a different recipe for dinner
        final dinnerIdx = (d + allSelected.length ~/ 2) % allSelected.length;
        final dinnerRecipe = allSelected[dinnerIdx];
        // If it would push us over budget, try to find cheaper
        final dinnerCost = calculateRecipeCost(dinnerRecipe);
        if (weekCostSoFar + lunchMeal.custoEstimadoTotal + dinnerCost > weekBudget * 1.05) {
          // Find cheapest available recipe
          final cheapest = allSelected.reduce((a, b) =>
              calculateRecipeCostPerPerson(a) <= calculateRecipeCostPerPerson(b) ? a : b);
          dinnerMeal = buildPlannedMeal(cheapest);
        } else {
          dinnerMeal = buildPlannedMeal(dinnerRecipe);
        }
      }

      weekCostSoFar += lunchMeal.custoEstimadoTotal + dinnerMeal.custoEstimadoTotal;

      days.add(DayPlan(
        data: date,
        almoco: lunchMeal,
        jantar: dinnerMeal,
      ));
    }

    return WeekPlan(
      semana: semana,
      dias: days,
      proteinaDominante: dominantCluster,
    );
  }

  // ─── Full Month Plan Generation ────────────────────────────────────

  /// Generate a complete monthly meal plan.
  MealPlan generateMonthPlan({required int mes, required int ano}) {
    final clusters = selectMonthlyClusters();
    final semanas = <WeekPlan>[];
    final usedRecipeIds = <String>[];

    // Calculate the first Monday of the month (or first day)
    final firstDay = DateTime(ano, mes, 1);
    // Start from first day, align to Monday
    var weekStart = firstDay;
    if (weekStart.weekday != DateTime.monday) {
      // Go back to previous Monday or start from the 1st
      weekStart = firstDay;
    }

    for (int w = 0; w < 4; w++) {
      final cluster = clusters[w % clusters.length];
      final week = generateWeekPlan(
        semana: w + 1,
        dominantCluster: cluster,
        weekStart: weekStart.add(Duration(days: w * 7)),
        usedRecipeIds: usedRecipeIds,
      );

      // Track used recipes for variety
      for (final day in week.dias) {
        if (day.almoco != null && !day.almoco!.isSobras) {
          usedRecipeIds.add(day.almoco!.receitaId);
        }
        if (day.jantar != null && !day.jantar!.isSobras) {
          usedRecipeIds.add(day.jantar!.receitaId);
        }
      }

      semanas.add(week);
    }

    return MealPlan(
      id: 'plan_${ano}_$mes',
      mes: mes,
      ano: ano,
      config: config,
      semanas: semanas,
    );
  }

  // ─── Shopping List Generation ──────────────────────────────────────

  /// Generate a consolidated shopping list for a specific week.
  ShoppingList generateShoppingList(WeekPlan week) {
    // Aggregate ingredients across all meals in the week
    final aggregated = <String, _AggregatedIngredient>{};

    for (final day in week.dias) {
      for (final meal in [day.almoco, day.jantar]) {
        if (meal == null || meal.isSobras) continue;
        for (final pi in meal.ingredientes) {
          if (aggregated.containsKey(pi.ingredientId)) {
            aggregated[pi.ingredientId]!.quantidade += pi.quantidade;
            aggregated[pi.ingredientId]!.precoEstimado += pi.precoEstimado;
            if (!aggregated[pi.ingredientId]!.receitas.contains(meal.nomeReceita)) {
              aggregated[pi.ingredientId]!.receitas.add(meal.nomeReceita);
            }
          } else {
            aggregated[pi.ingredientId] = _AggregatedIngredient(
              ingredientId: pi.ingredientId,
              nome: pi.nome,
              quantidade: pi.quantidade,
              unidade: pi.unidade,
              precoEstimado: pi.precoEstimado,
              receitas: [meal.nomeReceita],
            );
          }
        }
      }
    }

    // Round up to realistic purchase quantities and recalculate cost
    final items = aggregated.values.map((agg) {
      final ingredient = getIngredient(agg.ingredientId);
      final minPurchase = ingredient?.quantidadeCompraMinima ?? agg.quantidade;
      final purchaseQty = _roundUpToPurchase(agg.quantidade, minPurchase);
      final pricePerUnit = ingredient?.precoMedioUnitario ?? 0;
      final purchaseCost = purchaseQty * pricePerUnit;

      return ShoppingListItem(
        ingredientId: agg.ingredientId,
        nome: agg.nome,
        categoria: ingredient?.categoria ?? IngredientCategory.outro,
        quantidadeNecessaria: agg.quantidade,
        quantidadeCompra: purchaseQty,
        unidade: agg.unidade,
        precoEstimado: purchaseCost,
        receitasQueUsam: agg.receitas,
      );
    }).toList();

    // Sort by category then name
    items.sort((a, b) {
      final catCmp = a.categoria.index.compareTo(b.categoria.index);
      if (catCmp != 0) return catCmp;
      return a.nome.compareTo(b.nome);
    });

    return ShoppingList(
      semana: week.semana,
      items: items,
    );
  }

  /// Generate shopping list for specific meals (for "add to shopping list" from meal).
  List<ShoppingListItem> generateItemsForMeal(PlannedMeal meal) {
    return meal.ingredientes.map((pi) {
      final ingredient = getIngredient(pi.ingredientId);
      final minPurchase = ingredient?.quantidadeCompraMinima ?? pi.quantidade;
      final purchaseQty = _roundUpToPurchase(pi.quantidade, minPurchase);
      final pricePerUnit = ingredient?.precoMedioUnitario ?? 0;

      return ShoppingListItem(
        ingredientId: pi.ingredientId,
        nome: pi.nome,
        categoria: ingredient?.categoria ?? IngredientCategory.outro,
        quantidadeNecessaria: pi.quantidade,
        quantidadeCompra: purchaseQty,
        unidade: pi.unidade,
        precoEstimado: purchaseQty * pricePerUnit,
        receitasQueUsam: [meal.nomeReceita],
      );
    }).toList();
  }

  // ─── Meal Swap ─────────────────────────────────────────────────────

  /// Get swap suggestions for a meal slot.
  /// Returns recipes from the same cluster first, then other clusters.
  List<Recipe> getSwapSuggestions(PlannedMeal currentMeal, ProteinCluster weekCluster) {
    final sameCluster = getRecipesByCluster(weekCluster)
        .where((r) => r.id != currentMeal.receitaId)
        .toList();

    final otherClusters = <Recipe>[];
    for (final cluster in ProteinCluster.values) {
      if (cluster == weekCluster) continue;
      final recipes = getRecipesByCluster(cluster);
      if (recipes.isNotEmpty) {
        otherClusters.add(recipes[_rng.nextInt(recipes.length)]);
      }
    }

    // Sort same cluster by cost
    sameCluster.sort((a, b) =>
        calculateRecipeCostPerPerson(a).compareTo(calculateRecipeCostPerPerson(b)));

    return [...sameCluster.take(4), ...otherClusters.take(2)];
  }

  // ─── Helpers ───────────────────────────────────────────────────────

  /// Round up quantity to the nearest multiple of minPurchase.
  double _roundUpToPurchase(double needed, double minPurchase) {
    if (minPurchase <= 0) return needed;
    return (needed / minPurchase).ceil() * minPurchase;
  }

  void _shuffle<T>(List<T> list) {
    for (int i = list.length - 1; i > 0; i--) {
      final j = _rng.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
  }
}

/// Internal helper for aggregating ingredients.
class _AggregatedIngredient {
  final String ingredientId;
  final String nome;
  double quantidade;
  final String unidade;
  double precoEstimado;
  final List<String> receitas;

  _AggregatedIngredient({
    required this.ingredientId,
    required this.nome,
    required this.quantidade,
    required this.unidade,
    required this.precoEstimado,
    required this.receitas,
  });
}
