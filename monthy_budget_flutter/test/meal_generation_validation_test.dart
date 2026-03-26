import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/models/shopping_item.dart';
import 'package:monthly_management/services/meal_planner_service.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

AppSettings _makeSettings({MealSettings? ms, double budget = 500}) {
  return AppSettings(
    salaries: const [SalaryInfo(label: 'S1', enabled: true, titulares: 2)],
    personalInfo: const PersonalInfo(dependentes: 2),
    expenses: [
      ExpenseItem(id: 'food', label: 'Alimentacao', amount: budget, category: 'alimentacao'),
    ],
    mealSettings: ms ?? const MealSettings(),
  );
}

/// Build a simple shopping list from a plan (mirrors _addWeekToShoppingList logic).
Map<String, double> _buildShoppingTotals(
  MealPlannerService svc,
  MealPlan plan,
  List<MealDay> days,
) {
  final totals = <String, double>{};
  for (final day in days) {
    if (day.isLeftover || day.isFreeform) continue;
    final recipe = svc.recipeMap[day.recipeId];
    if (recipe == null) continue;
    final guests = plan.extraGuests[day.dayIndex] ?? 0;
    final scale = (plan.nPessoas + guests) / recipe.servings;
    for (final ri in recipe.ingredients) {
      // Apply substitutions — this is the critical bug fix we're testing
      final effectiveId = day.substitutions[ri.ingredientId] ?? ri.ingredientId;
      totals.update(effectiveId, (v) => v + ri.quantity * scale, ifAbsent: () => ri.quantity * scale);
    }
  }
  return totals;
}

void _analyzeAndPrint(String label, MealPlan plan, MealPlannerService svc) {
  final recipeMap = svc.recipeMap;
  final mains = plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover);
  final soups = plan.days.where((d) => d.courseType == CourseType.soupOrStarter);
  final desserts = plan.days.where((d) => d.courseType == CourseType.dessert);

  final mainCounts = <String, int>{};
  for (final d in mains) mainCounts[d.recipeId] = (mainCounts[d.recipeId] ?? 0) + 1;

  print('--- $label ---');
  print('Total entries: ${plan.days.length} | Mains: ${mains.length} (${mainCounts.length} unique)');
  if (soups.isNotEmpty) print('Soups: ${soups.length} (${soups.map((d) => d.recipeId).toSet().length} unique)');
  if (desserts.isNotEmpty) print('Desserts: ${desserts.length} (${desserts.map((d) => d.recipeId).toSet().length} unique)');

  final sorted = mainCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  print('Top 3: ${sorted.take(3).map((e) => '${recipeMap[e.key]?.name ?? e.key}:${e.value}x').join(', ')}');
  print('Cost: ${plan.totalEstimatedCost.toStringAsFixed(2)} EUR\n');
}

// ── Shared validation ────────────────────────────────────────────────────────

void _runCoreValidation(
  MealPlan plan,
  MealPlannerService service, {
  bool expectSoups = false,
  bool expectDesserts = false,
}) {
  final recipeMap = service.recipeMap;

  // 1. Course type integrity
  for (final d in plan.days.where((d) => !d.isLeftover && !d.isFreeform)) {
    final recipe = recipeMap[d.recipeId];
    if (recipe == null) continue;

    if (d.courseType == CourseType.soupOrStarter) {
      expect(recipe.courseType, CourseType.soupOrStarter,
          reason: 'Day ${d.dayIndex} ${d.mealType.name}: soup slot has ${recipe.name} (courseType=${recipe.courseType.name})');
    } else if (d.courseType == CourseType.mainCourse) {
      expect(recipe.courseType, CourseType.mainCourse,
          reason: 'Day ${d.dayIndex} ${d.mealType.name}: main slot has ${recipe.name} (courseType=${recipe.courseType.name})');
    } else if (d.courseType == CourseType.dessert) {
      expect(recipe.courseType, CourseType.dessert,
          reason: 'Day ${d.dayIndex} ${d.mealType.name}: dessert slot has ${recipe.name} (courseType=${recipe.courseType.name})');
    }
  }

  // 2. No duplicate recipes within same day + meal type
  final dayMealGroups = <String, List<String>>{};
  for (final d in plan.days.where((d) => !d.isLeftover)) {
    final key = '${d.dayIndex}_${d.mealType.name}';
    (dayMealGroups[key] ??= []).add(d.recipeId);
  }
  for (final entry in dayMealGroups.entries) {
    final ids = entry.value;
    expect(ids.length, ids.toSet().length,
        reason: '${entry.key}: duplicate recipes $ids');
  }

  // 3. Multi-course completeness
  if (expectSoups) {
    for (final d in plan.days.where((d) =>
        d.courseType == CourseType.mainCourse &&
        !d.isLeftover &&
        (d.mealType == MealType.lunch || d.mealType == MealType.dinner))) {
      final key = '${d.dayIndex}_${d.mealType.name}';
      final group = dayMealGroups[key] ?? [];
      final hasSoup = plan.days.any((s) =>
          s.dayIndex == d.dayIndex &&
          s.mealType == d.mealType &&
          s.courseType == CourseType.soupOrStarter);
      expect(hasSoup, isTrue,
          reason: 'Day ${d.dayIndex} ${d.mealType.name}: missing soup');
    }
  }

  if (expectDesserts) {
    for (final d in plan.days.where((d) =>
        d.courseType == CourseType.mainCourse &&
        !d.isLeftover &&
        (d.mealType == MealType.lunch || d.mealType == MealType.dinner))) {
      final hasDessert = plan.days.any((s) =>
          s.dayIndex == d.dayIndex &&
          s.mealType == d.mealType &&
          s.courseType == CourseType.dessert);
      expect(hasDessert, isTrue,
          reason: 'Day ${d.dayIndex} ${d.mealType.name}: missing dessert');
    }
  }

  // 4. Weekly variety (relaxed: at least 3 unique for full weeks, 2 for partial)
  final weeklyMains = <int, Set<String>>{};
  for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover)) {
    final week = ((d.dayIndex - 1) / 7).floor();
    weeklyMains.putIfAbsent(week, () => {}).add(d.recipeId);
  }
  for (final entry in weeklyMains.entries) {
    final meals = entry.value.length;
    final minUnique = meals >= 10 ? 4 : (meals >= 6 ? 3 : 2);
    expect(entry.value.length, greaterThanOrEqualTo(minUnique),
        reason: 'Week ${entry.key}: only ${entry.value.length} unique mains out of $meals meals (need $minUnique)');
  }

  // 5. Max repetitions per week (allow up to 4 for constrained pools like vegetarian)
  final weeklyRecipeCounts = <int, Map<String, int>>{};
  for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover)) {
    final week = ((d.dayIndex - 1) / 7).floor();
    final counts = weeklyRecipeCounts.putIfAbsent(week, () => {});
    counts[d.recipeId] = (counts[d.recipeId] ?? 0) + 1;
  }
  for (final weekEntry in weeklyRecipeCounts.entries) {
    for (final recipeEntry in weekEntry.value.entries) {
      expect(recipeEntry.value, lessThanOrEqualTo(4),
          reason: '${recipeMap[recipeEntry.key]?.name ?? recipeEntry.key} x${recipeEntry.value} in week ${weekEntry.key}');
    }
  }

  // 6. No consecutive-day repeats for main courses
  final prevMain = <String, (int, String)>{};
  for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse).toList()
    ..sort((a, b) => a.dayIndex.compareTo(b.dayIndex))) {
    final mt = d.mealType.name;
    if (prevMain.containsKey(mt) && prevMain[mt]!.$1 == d.dayIndex - 1) {
      expect(prevMain[mt]!.$2, isNot(d.recipeId),
          reason: 'Day ${d.dayIndex} $mt: same main ${recipeMap[d.recipeId]?.name} as yesterday');
    }
    prevMain[mt] = (d.dayIndex, d.recipeId);
  }

  // 7. Cost sanity
  for (final d in plan.days.where((d) => !d.isLeftover)) {
    expect(d.costEstimate, greaterThanOrEqualTo(0));
    expect(d.costEstimate, lessThan(100),
        reason: 'Day ${d.dayIndex}: cost ${d.costEstimate}');
  }

  // 8. Complete meals for lunch/dinner
  for (final d in plan.days.where((d) =>
      d.courseType == CourseType.mainCourse &&
      !d.isLeftover &&
      (d.mealType == MealType.lunch || d.mealType == MealType.dinner))) {
    final recipe = recipeMap[d.recipeId];
    if (recipe != null) {
      expect(recipe.isCompleteMeal, isTrue,
          reason: 'Day ${d.dayIndex} ${d.mealType.name}: incomplete meal ${recipe.name}');
    }
  }
}

// ── Main test suite ──────────────────────────────────────────────────────────

void main() {
  late MealPlannerService service;

  setUpAll(() {
    service = MealPlannerService();
    final ingJson = File('assets/meal_planner/ingredients.json').readAsStringSync();
    final recJson = File('assets/meal_planner/recipes.json').readAsStringSync();
    service.loadCatalogFromJson(ingJson, recJson);
  });

  final forMonth = DateTime(2026, 4);

  // ═══════════════════════════════════════════════════════════════════════════
  // PART 1: Generation validation (7 configs)
  // ═══════════════════════════════════════════════════════════════════════════

  group('Generation: Config 1 - Default (lunch+dinner)', () {
    late MealPlan plan;
    setUpAll(() => plan = service.generate(_makeSettings(), forMonth));

    test('core validation passes', () => _runCoreValidation(plan, service));
    test('analysis', () => _analyzeAndPrint('Config 1: Default', plan, service));
  });

  group('Generation: Config 2 - Soup + Main', () {
    late MealPlan plan;
    setUpAll(() => plan = service.generate(
      _makeSettings(ms: const MealSettings(includeSoupOrStarter: true)), forMonth));

    test('core validation passes', () => _runCoreValidation(plan, service, expectSoups: true));
    test('analysis', () => _analyzeAndPrint('Config 2: Soup+Main', plan, service));
  });

  group('Generation: Config 3 - Full multi-course', () {
    late MealPlan plan;
    setUpAll(() => plan = service.generate(
      _makeSettings(ms: const MealSettings(includeSoupOrStarter: true, includeDessert: true)), forMonth));

    test('core validation passes', () =>
        _runCoreValidation(plan, service, expectSoups: true, expectDesserts: true));
    test('analysis', () => _analyzeAndPrint('Config 3: Full multi-course', plan, service));
  });

  group('Generation: Config 4 - Vegetarian', () {
    late MealPlan plan;
    setUpAll(() => plan = service.generate(
      _makeSettings(ms: const MealSettings(objective: MealObjective.vegetarian)), forMonth));

    test('core validation passes', () => _runCoreValidation(plan, service));
    test('analysis', () => _analyzeAndPrint('Config 4: Vegetarian', plan, service));
  });

  group('Generation: Config 5 - Minimize Cost', () {
    late MealPlan plan;
    setUpAll(() => plan = service.generate(
      _makeSettings(ms: const MealSettings(objective: MealObjective.minimizeCost)), forMonth));

    test('core validation passes', () => _runCoreValidation(plan, service));
    test('analysis', () => _analyzeAndPrint('Config 5: MinCost', plan, service));
  });

  group('Generation: Config 6 - High Protein + Multi-course', () {
    late MealPlan plan;
    setUpAll(() => plan = service.generate(
      _makeSettings(ms: const MealSettings(
        objective: MealObjective.highProtein, includeSoupOrStarter: true, includeDessert: true)), forMonth));

    test('core validation passes', () =>
        _runCoreValidation(plan, service, expectSoups: true, expectDesserts: true));
    test('analysis', () => _analyzeAndPrint('Config 6: HighProt+Multi', plan, service));
  });

  group('Generation: Config 7 - All meals', () {
    late MealPlan plan;
    setUpAll(() => plan = service.generate(
      _makeSettings(ms: const MealSettings(
        enabledMeals: {MealType.breakfast, MealType.lunch, MealType.dinner},
        includeSoupOrStarter: true, includeDessert: true)), forMonth));

    test('core validation passes', () =>
        _runCoreValidation(plan, service, expectSoups: true, expectDesserts: true));
    test('analysis', () => _analyzeAndPrint('Config 7: All meals', plan, service));
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // PART 2: Ingredient substitution tests
  // ═══════════════════════════════════════════════════════════════════════════

  group('Ingredient substitution', () {
    late MealPlan plan;

    setUpAll(() {
      plan = service.generate(
        _makeSettings(ms: const MealSettings(
          includeSoupOrStarter: true, includeDessert: true)),
        forMonth,
      );
    });

    test('can substitute any ingredient in a main course', () {
      // Pick the first main course that has ingredients
      final mainDay = plan.days.firstWhere(
        (d) => d.courseType == CourseType.mainCourse && !d.isLeftover && !d.isFreeform,
      );
      final recipe = service.recipeMap[mainDay.recipeId]!;
      expect(recipe.ingredients.isNotEmpty, isTrue);

      // Substitute the first ingredient with a different one
      final originalIngId = recipe.ingredients.first.ingredientId;
      // Find an alternative ingredient (different ID)
      final altIng = service.ingredients.firstWhere((i) => i.id != originalIngId);

      final newSubs = Map<String, String>.from(mainDay.substitutions);
      newSubs[originalIngId] = altIng.id;

      final updatedDays = plan.days.map((d) {
        if (d.dayIndex == mainDay.dayIndex &&
            d.mealType == mainDay.mealType &&
            d.courseType == mainDay.courseType) {
          return d.copyWith(substitutions: newSubs);
        }
        return d;
      }).toList();
      final updatedPlan = plan.copyWithDays(updatedDays);

      // Verify substitution is stored
      final updatedDay = updatedPlan.days.firstWhere((d) =>
          d.dayIndex == mainDay.dayIndex &&
          d.mealType == mainDay.mealType &&
          d.courseType == mainDay.courseType);
      expect(updatedDay.substitutions[originalIngId], altIng.id);
    });

    test('can substitute ingredient in soup course', () {
      final soupDay = plan.days.firstWhere(
        (d) => d.courseType == CourseType.soupOrStarter && !d.isLeftover,
      );
      final recipe = service.recipeMap[soupDay.recipeId]!;
      expect(recipe.ingredients.isNotEmpty, isTrue);

      final originalId = recipe.ingredients.first.ingredientId;
      final altIng = service.ingredients.firstWhere((i) => i.id != originalId);

      final updatedDays = plan.days.map((d) {
        if (d.dayIndex == soupDay.dayIndex &&
            d.mealType == soupDay.mealType &&
            d.courseType == soupDay.courseType) {
          return d.copyWith(substitutions: {originalId: altIng.id});
        }
        return d;
      }).toList();
      final updatedPlan = plan.copyWithDays(updatedDays);

      final updatedDay = updatedPlan.days.firstWhere((d) =>
          d.dayIndex == soupDay.dayIndex &&
          d.mealType == soupDay.mealType &&
          d.courseType == soupDay.courseType);
      expect(updatedDay.substitutions[originalId], altIng.id);
    });

    test('can substitute ingredient in dessert course', () {
      final dessertDay = plan.days.firstWhere(
        (d) => d.courseType == CourseType.dessert && !d.isLeftover,
      );
      final recipe = service.recipeMap[dessertDay.recipeId]!;
      expect(recipe.ingredients.isNotEmpty, isTrue);

      final originalId = recipe.ingredients.first.ingredientId;
      final altIng = service.ingredients.firstWhere((i) => i.id != originalId);

      final updatedDays = plan.days.map((d) {
        if (d.dayIndex == dessertDay.dayIndex &&
            d.mealType == dessertDay.mealType &&
            d.courseType == dessertDay.courseType) {
          return d.copyWith(substitutions: {originalId: altIng.id});
        }
        return d;
      }).toList();
      final updatedPlan = plan.copyWithDays(updatedDays);

      final updatedDay = updatedPlan.days.firstWhere((d) =>
          d.dayIndex == dessertDay.dayIndex &&
          d.mealType == dessertDay.mealType &&
          d.courseType == dessertDay.courseType);
      expect(updatedDay.substitutions[originalId], altIng.id);
    });

    test('multiple substitutions on same meal work independently', () {
      final mainDay = plan.days.firstWhere(
        (d) => d.courseType == CourseType.mainCourse &&
               !d.isLeftover &&
               service.recipeMap[d.recipeId]!.ingredients.length >= 2,
      );
      final recipe = service.recipeMap[mainDay.recipeId]!;
      final ing1 = recipe.ingredients[0].ingredientId;
      final ing2 = recipe.ingredients[1].ingredientId;

      final alt1 = service.ingredients.firstWhere((i) => i.id != ing1 && i.id != ing2);
      final alt2 = service.ingredients.firstWhere((i) => i.id != ing1 && i.id != ing2 && i.id != alt1.id);

      final updatedDays = plan.days.map((d) {
        if (d.dayIndex == mainDay.dayIndex &&
            d.mealType == mainDay.mealType &&
            d.courseType == mainDay.courseType) {
          return d.copyWith(substitutions: {ing1: alt1.id, ing2: alt2.id});
        }
        return d;
      }).toList();
      final updatedPlan = plan.copyWithDays(updatedDays);

      final updatedDay = updatedPlan.days.firstWhere((d) =>
          d.dayIndex == mainDay.dayIndex &&
          d.mealType == mainDay.mealType &&
          d.courseType == mainDay.courseType);
      expect(updatedDay.substitutions[ing1], alt1.id);
      expect(updatedDay.substitutions[ing2], alt2.id);
      expect(updatedDay.substitutions.length, 2);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // PART 3: Shopping list reflects substitutions
  // ═══════════════════════════════════════════════════════════════════════════

  group('Shopping list with substitutions', () {
    late MealPlan basePlan;

    setUpAll(() {
      basePlan = service.generate(
        _makeSettings(ms: const MealSettings(
          includeSoupOrStarter: true, includeDessert: true)),
        forMonth,
      );
    });

    test('shopping list uses original ingredients when no substitutions', () {
      final weekDays = basePlan.days.where((d) => d.dayIndex <= 7).toList();
      final totals = _buildShoppingTotals(service, basePlan, weekDays);

      expect(totals.isNotEmpty, isTrue);
      // All ingredient IDs should be in the ingredient map
      for (final id in totals.keys) {
        expect(service.ingredientMap.containsKey(id), isTrue,
            reason: 'Unknown ingredient $id in shopping list');
      }
    });

    test('substitution replaces old ingredient with new in shopping list', () {
      // Pick a day with a main course
      final targetDay = basePlan.days.firstWhere(
        (d) => d.dayIndex <= 7 && d.courseType == CourseType.mainCourse && !d.isLeftover,
      );
      final recipe = service.recipeMap[targetDay.recipeId]!;
      final originalIngId = recipe.ingredients.first.ingredientId;

      // Find a replacement that is NOT already in this recipe
      final replacementIng = service.ingredients.firstWhere(
        (i) => i.id != originalIngId && !recipe.ingredients.any((ri) => ri.ingredientId == i.id),
      );

      // Build shopping list WITHOUT substitution
      final weekDays = basePlan.days.where((d) => d.dayIndex <= 7).toList();
      final totalsBefore = _buildShoppingTotals(service, basePlan, weekDays);
      final origQtyBefore = totalsBefore[originalIngId] ?? 0;
      final replQtyBefore = totalsBefore[replacementIng.id] ?? 0;

      // Apply substitution
      final updatedDays = basePlan.days.map((d) {
        if (d.dayIndex == targetDay.dayIndex &&
            d.mealType == targetDay.mealType &&
            d.courseType == targetDay.courseType) {
          return d.copyWith(substitutions: {originalIngId: replacementIng.id});
        }
        return d;
      }).toList();
      final updatedPlan = basePlan.copyWithDays(updatedDays);

      // Build shopping list WITH substitution
      final updatedWeekDays = updatedPlan.days.where((d) => d.dayIndex <= 7).toList();
      final totalsAfter = _buildShoppingTotals(service, updatedPlan, updatedWeekDays);
      final origQtyAfter = totalsAfter[originalIngId] ?? 0;
      final replQtyAfter = totalsAfter[replacementIng.id] ?? 0;

      // Original ingredient quantity should decrease
      expect(origQtyAfter, lessThan(origQtyBefore),
          reason: 'Original ingredient ${service.ingredientMap[originalIngId]?.name} '
              'should decrease after substitution: $origQtyBefore -> $origQtyAfter');

      // Replacement ingredient quantity should increase
      expect(replQtyAfter, greaterThan(replQtyBefore),
          reason: 'Replacement ${replacementIng.name} should increase: $replQtyBefore -> $replQtyAfter');
    });

    test('consolidatedIngredients respects substitutions', () {
      // Use service.consolidatedIngredients directly
      final totalsOriginal = service.consolidatedIngredients(basePlan);

      // Apply substitution to day 1 main course
      final targetDay = basePlan.days.firstWhere(
        (d) => d.courseType == CourseType.mainCourse && !d.isLeftover,
      );
      final recipe = service.recipeMap[targetDay.recipeId]!;
      final originalIngId = recipe.ingredients.first.ingredientId;
      final replacement = service.ingredients.firstWhere(
        (i) => i.id != originalIngId && !recipe.ingredients.any((ri) => ri.ingredientId == i.id),
      );

      final updatedDays = basePlan.days.map((d) {
        if (d.dayIndex == targetDay.dayIndex &&
            d.mealType == targetDay.mealType &&
            d.courseType == targetDay.courseType) {
          return d.copyWith(substitutions: {originalIngId: replacement.id});
        }
        return d;
      }).toList();
      final updatedPlan = basePlan.copyWithDays(updatedDays);
      final totalsUpdated = service.consolidatedIngredients(updatedPlan);

      // Replacement ingredient should appear or increase
      final newQty = totalsUpdated[replacement.id] ?? 0;
      final oldQty = totalsOriginal[replacement.id] ?? 0;
      expect(newQty, greaterThan(oldQty),
          reason: 'consolidatedIngredients should include replacement ${replacement.name}');
    });

    test('substitution in soup course updates shopping list', () {
      final soupDay = basePlan.days.firstWhere(
        (d) => d.dayIndex <= 7 && d.courseType == CourseType.soupOrStarter,
      );
      final recipe = service.recipeMap[soupDay.recipeId]!;
      final originalIngId = recipe.ingredients.first.ingredientId;
      final replacement = service.ingredients.firstWhere(
        (i) => i.id != originalIngId && !recipe.ingredients.any((ri) => ri.ingredientId == i.id),
      );

      final weekDays = basePlan.days.where((d) => d.dayIndex <= 7).toList();
      final totalsBefore = _buildShoppingTotals(service, basePlan, weekDays);

      final updatedDays = basePlan.days.map((d) {
        if (d.dayIndex == soupDay.dayIndex &&
            d.mealType == soupDay.mealType &&
            d.courseType == soupDay.courseType) {
          return d.copyWith(substitutions: {originalIngId: replacement.id});
        }
        return d;
      }).toList();
      final updatedPlan = basePlan.copyWithDays(updatedDays);
      final updatedWeekDays = updatedPlan.days.where((d) => d.dayIndex <= 7).toList();
      final totalsAfter = _buildShoppingTotals(service, updatedPlan, updatedWeekDays);

      // Replacement should appear in shopping list
      expect(totalsAfter.containsKey(replacement.id), isTrue,
          reason: 'Soup substitution: ${replacement.name} missing from shopping list');
    });

    test('substitution in dessert course updates shopping list', () {
      final dessertDay = basePlan.days.firstWhere(
        (d) => d.dayIndex <= 7 && d.courseType == CourseType.dessert,
      );
      final recipe = service.recipeMap[dessertDay.recipeId]!;
      final originalIngId = recipe.ingredients.first.ingredientId;
      final replacement = service.ingredients.firstWhere(
        (i) => i.id != originalIngId && !recipe.ingredients.any((ri) => ri.ingredientId == i.id),
      );

      final updatedDays = basePlan.days.map((d) {
        if (d.dayIndex == dessertDay.dayIndex &&
            d.mealType == dessertDay.mealType &&
            d.courseType == dessertDay.courseType) {
          return d.copyWith(substitutions: {originalIngId: replacement.id});
        }
        return d;
      }).toList();
      final updatedPlan = basePlan.copyWithDays(updatedDays);
      final weekDays = updatedPlan.days.where((d) => d.dayIndex <= 7).toList();
      final totals = _buildShoppingTotals(service, updatedPlan, weekDays);

      expect(totals.containsKey(replacement.id), isTrue,
          reason: 'Dessert substitution: ${replacement.name} missing from shopping list');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // PART 4: Recipe swap tests
  // ═══════════════════════════════════════════════════════════════════════════

  group('Recipe swap', () {
    late MealPlan plan;

    setUpAll(() {
      plan = service.generate(
        _makeSettings(ms: const MealSettings(
          includeSoupOrStarter: true, includeDessert: true)),
        forMonth,
      );
    });

    test('swapDay replaces recipe and recalculates cost', () {
      final mainDay = plan.days.firstWhere(
        (d) => d.courseType == CourseType.mainCourse && !d.isLeftover,
      );
      final alternatives = service.alternativesFor(
        mainDay.recipeId, plan.nPessoas,
        ms: const MealSettings(),
        courseType: CourseType.mainCourse,
      );
      expect(alternatives, isNotEmpty);

      final newRecipeId = alternatives.first.id;
      final swapped = service.swapDay(
        plan, mainDay.dayIndex, mainDay.mealType, newRecipeId,
        courseType: CourseType.mainCourse,
      );

      final swappedDay = swapped.days.firstWhere((d) =>
          d.dayIndex == mainDay.dayIndex &&
          d.mealType == mainDay.mealType &&
          d.courseType == CourseType.mainCourse);
      expect(swappedDay.recipeId, newRecipeId);
      expect(swappedDay.costEstimate, greaterThan(0));
    });

    test('swapDay for soup only changes soup course', () {
      final soupDay = plan.days.firstWhere(
        (d) => d.courseType == CourseType.soupOrStarter,
      );
      final mainDay = plan.days.firstWhere(
        (d) => d.dayIndex == soupDay.dayIndex &&
               d.mealType == soupDay.mealType &&
               d.courseType == CourseType.mainCourse,
      );

      final soupAlternatives = service.alternativesFor(
        soupDay.recipeId, plan.nPessoas,
        courseType: CourseType.soupOrStarter,
      );
      expect(soupAlternatives, isNotEmpty);

      final swapped = service.swapDay(
        plan, soupDay.dayIndex, soupDay.mealType, soupAlternatives.first.id,
        courseType: CourseType.soupOrStarter,
      );

      // Soup changed
      final newSoup = swapped.days.firstWhere((d) =>
          d.dayIndex == soupDay.dayIndex &&
          d.mealType == soupDay.mealType &&
          d.courseType == CourseType.soupOrStarter);
      expect(newSoup.recipeId, soupAlternatives.first.id);

      // Main course UNCHANGED
      final unchangedMain = swapped.days.firstWhere((d) =>
          d.dayIndex == mainDay.dayIndex &&
          d.mealType == mainDay.mealType &&
          d.courseType == CourseType.mainCourse);
      expect(unchangedMain.recipeId, mainDay.recipeId);
    });

    test('alternativesFor with courseType only returns matching type', () {
      final soupAlts = service.alternativesFor('sopa_legumes', plan.nPessoas,
          courseType: CourseType.soupOrStarter);
      for (final r in soupAlts) {
        expect(r.courseType, CourseType.soupOrStarter,
            reason: '${r.name} is not a soup but was returned as soup alternative');
      }

      final dessertAlts = service.alternativesFor('sobremesa_fruta_epoca', plan.nPessoas,
          courseType: CourseType.dessert);
      for (final r in dessertAlts) {
        expect(r.courseType, CourseType.dessert,
            reason: '${r.name} is not a dessert but was returned as dessert alternative');
      }

      final mainAlts = service.alternativesFor('frango_assado', plan.nPessoas,
          courseType: CourseType.mainCourse);
      for (final r in mainAlts) {
        expect(r.courseType, CourseType.mainCourse,
            reason: '${r.name} is not a main but was returned as main alternative');
      }
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // PART 5: Edge cases & serialization
  // ═══════════════════════════════════════════════════════════════════════════

  group('Edge cases', () {
    test('MealDay serialization preserves courseType and substitutions', () {
      final day = MealDay(
        dayIndex: 5,
        recipeId: 'frango_assado',
        costEstimate: 3.50,
        mealType: MealType.dinner,
        courseType: CourseType.mainCourse,
        substitutions: const {'arroz': 'massa', 'frango': 'peru'},
      );

      final json = day.toJson();
      final restored = MealDay.fromJson(json);

      expect(restored.courseType, CourseType.mainCourse);
      expect(restored.substitutions['arroz'], 'massa');
      expect(restored.substitutions['frango'], 'peru');
      expect(restored.substitutions.length, 2);
    });

    test('MealDay fromJson defaults courseType to mainCourse for legacy data', () {
      final legacyJson = {
        'dayIndex': 1,
        'recipeId': 'frango_arroz',
        'costEstimate': 2.0,
        'mealType': 'dinner',
        'feedback': 'none',
        // No courseType field — legacy plan
      };
      final day = MealDay.fromJson(legacyJson);
      expect(day.courseType, CourseType.mainCourse);
    });

    test('MealSettings serialization preserves includeSoupOrStarter and includeDessert', () {
      const ms = MealSettings(includeSoupOrStarter: true, includeDessert: true);
      final json = ms.toJson();
      final restored = MealSettings.fromJson(json);
      expect(restored.includeSoupOrStarter, isTrue);
      expect(restored.includeDessert, isTrue);
    });

    test('MealSettings fromJson defaults multi-course to false for legacy data', () {
      final legacyJson = <String, dynamic>{
        'objective': 'balancedHealth',
        // No includeSoupOrStarter or includeDessert
      };
      final ms = MealSettings.fromJson(legacyJson);
      expect(ms.includeSoupOrStarter, isFalse);
      expect(ms.includeDessert, isFalse);
    });

    test('Recipe courseType field persists through JSON roundtrip', () {
      final soupRecipe = service.recipes.firstWhere((r) => r.courseType == CourseType.soupOrStarter);
      final json = soupRecipe.toJson();
      final restored = Recipe.fromJson(json);
      expect(restored.courseType, CourseType.soupOrStarter);
      expect(restored.isSoupOrStarter, isTrue);
      expect(restored.isDessert, isFalse);

      final dessertRecipe = service.recipes.firstWhere((r) => r.courseType == CourseType.dessert);
      final djson = dessertRecipe.toJson();
      final drestored = Recipe.fromJson(djson);
      expect(drestored.courseType, CourseType.dessert);
      expect(drestored.isDessert, isTrue);
      expect(drestored.isSoupOrStarter, isFalse);
    });

    test('catalog has correct courseType distribution', () {
      final soups = service.recipes.where((r) => r.courseType == CourseType.soupOrStarter).length;
      final mains = service.recipes.where((r) => r.courseType == CourseType.mainCourse).length;
      final desserts = service.recipes.where((r) => r.courseType == CourseType.dessert).length;

      expect(soups, greaterThanOrEqualTo(10), reason: 'Need enough soups for variety');
      expect(mains, greaterThanOrEqualTo(50), reason: 'Need enough mains for a month');
      expect(desserts, greaterThanOrEqualTo(5), reason: 'Need enough desserts for variety');
      expect(soups + mains + desserts, service.recipes.length);
      print('Catalog: $soups soups, $mains mains, $desserts desserts (${service.recipes.length} total)');
    });
  });
}
