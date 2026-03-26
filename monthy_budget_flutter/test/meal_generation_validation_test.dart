import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/services/meal_planner_service.dart';

/// Helper to build AppSettings with specific MealSettings for testing.
AppSettings _makeSettings({MealSettings? ms}) {
  return AppSettings(
    salaries: const [
      SalaryInfo(label: 'S1', enabled: true, titulares: 2),
    ],
    personalInfo: const PersonalInfo(dependentes: 2),
    expenses: const [
      ExpenseItem(
        id: 'food',
        label: 'Alimentacao',
        amount: 500,
        category: 'alimentacao',
      ),
    ],
    mealSettings: ms ?? const MealSettings(),
  );
}

/// Prints analysis results for a generated meal plan.
void _analyzeAndPrint(String label, MealPlan plan, MealPlannerService svc) {
  final recipeMap = svc.recipeMap;
  final mainDays = plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover);
  final soupDays = plan.days.where((d) => d.courseType == CourseType.soupOrStarter);
  final dessertDays = plan.days.where((d) => d.courseType == CourseType.dessert);

  // Recipe distribution for main courses
  final mainCounts = <String, int>{};
  for (final d in mainDays) {
    mainCounts[d.recipeId] = (mainCounts[d.recipeId] ?? 0) + 1;
  }

  // Soup distribution
  final soupCounts = <String, int>{};
  for (final d in soupDays) {
    soupCounts[d.recipeId] = (soupCounts[d.recipeId] ?? 0) + 1;
  }

  // Dessert distribution
  final dessertCounts = <String, int>{};
  for (final d in dessertDays) {
    dessertCounts[d.recipeId] = (dessertCounts[d.recipeId] ?? 0) + 1;
  }

  print('--- $label ---');
  print('Total meal entries: ${plan.days.length}');
  print('Main courses: ${mainDays.length} (${mainCounts.length} unique)');
  if (soupDays.isNotEmpty) {
    print('Soups/starters: ${soupDays.length} (${soupCounts.length} unique)');
  }
  if (dessertDays.isNotEmpty) {
    print('Desserts: ${dessertDays.length} (${dessertCounts.length} unique)');
  }

  // Top 5 most used main recipes
  final sorted = mainCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  print('Top main recipes:');
  for (final e in sorted.take(5)) {
    final name = recipeMap[e.key]?.name ?? e.key;
    print('  $name: ${e.value}x');
  }

  // Weekly recipe repetition
  final weeklyRecipes = <int, Set<String>>{};
  for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover)) {
    final week = ((d.dayIndex - 1) / 7).floor();
    weeklyRecipes.putIfAbsent(week, () => {}).add(d.recipeId);
  }
  for (final entry in weeklyRecipes.entries) {
    print('Week ${entry.key}: ${entry.value.length} unique main recipes');
  }

  print('Total estimated cost: ${plan.totalEstimatedCost.toStringAsFixed(2)}');
  print('');
}

void main() {
  late MealPlannerService service;

  setUpAll(() {
    service = MealPlannerService();
    final ingJson = File('assets/meal_planner/ingredients.json').readAsStringSync();
    final recJson = File('assets/meal_planner/recipes.json').readAsStringSync();
    service.loadCatalogFromJson(ingJson, recJson);
  });

  final forMonth = DateTime(2026, 4);

  group('Config 1: Default settings (lunch + dinner, no soup/dessert)', () {
    late MealPlan plan;

    setUpAll(() {
      final settings = _makeSettings();
      plan = service.generate(settings, forMonth);
    });

    test('no recipe repeats on the same day for the same meal type (excluding leftovers)', () {
      final dayMealRecipes = <String, Set<String>>{};
      for (final d in plan.days.where((d) => !d.isLeftover)) {
        final key = '${d.dayIndex}_${d.mealType.name}_${d.courseType.name}';
        final set = dayMealRecipes.putIfAbsent(key, () => {});
        expect(set.contains(d.recipeId), isFalse,
            reason: 'Recipe ${d.recipeId} repeated for $key');
        set.add(d.recipeId);
      }
    });

    test('main courses are never soups or desserts', () {
      final recipeMap = service.recipeMap;
      for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover)) {
        final recipe = recipeMap[d.recipeId];
        if (recipe != null) {
          expect(recipe.isSoupOrStarter, isFalse,
              reason: 'Main course ${d.recipeId} is a soup/starter on day ${d.dayIndex}');
          expect(recipe.isDessert, isFalse,
              reason: 'Main course ${d.recipeId} is a dessert on day ${d.dayIndex}');
        }
      }
    });

    test('no recipe appears more than 3 times per week for main courses', () {
      final weeklyRecipeCounts = <int, Map<String, int>>{};
      for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover)) {
        final week = ((d.dayIndex - 1) / 7).floor();
        final counts = weeklyRecipeCounts.putIfAbsent(week, () => {});
        counts[d.recipeId] = (counts[d.recipeId] ?? 0) + 1;
      }
      for (final weekEntry in weeklyRecipeCounts.entries) {
        for (final recipeEntry in weekEntry.value.entries) {
          expect(recipeEntry.value, lessThanOrEqualTo(3),
              reason: 'Recipe ${recipeEntry.key} appears ${recipeEntry.value} times in week ${weekEntry.key}');
        }
      }
    });

    test('recipe variety: at least 5 unique recipes per week for main courses', () {
      final weeklyRecipes = <int, Set<String>>{};
      for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover)) {
        final week = ((d.dayIndex - 1) / 7).floor();
        weeklyRecipes.putIfAbsent(week, () => {}).add(d.recipeId);
      }
      for (final entry in weeklyRecipes.entries) {
        expect(entry.value.length, greaterThanOrEqualTo(5),
            reason: 'Week ${entry.key} has only ${entry.value.length} unique main recipes');
      }
    });

    test('cost estimates are positive and reasonable', () {
      for (final d in plan.days.where((d) => !d.isLeftover)) {
        expect(d.costEstimate, greaterThanOrEqualTo(0),
            reason: 'Negative cost on day ${d.dayIndex}');
        expect(d.costEstimate, lessThan(100),
            reason: 'Unreasonable cost ${d.costEstimate} on day ${d.dayIndex}');
      }
    });

    test('prints analysis', () {
      _analyzeAndPrint('Config 1: Default', plan, service);
    });
  });

  group('Config 2: Soup + main course enabled', () {
    late MealPlan plan;

    setUpAll(() {
      final settings = _makeSettings(
        ms: const MealSettings(includeSoupOrStarter: true),
      );
      plan = service.generate(settings, forMonth);
    });

    test('every lunch/dinner has a soupOrStarter course', () {
      final lunchDinnerDays = <int>{};
      for (final d in plan.days.where((d) =>
          (d.mealType == MealType.lunch || d.mealType == MealType.dinner) &&
          d.courseType == CourseType.mainCourse &&
          !d.isLeftover)) {
        lunchDinnerDays.add(d.dayIndex * 10 + d.mealType.index);
      }
      final soupDayMeals = <int>{};
      for (final d in plan.days.where((d) => d.courseType == CourseType.soupOrStarter)) {
        soupDayMeals.add(d.dayIndex * 10 + d.mealType.index);
      }
      for (final key in lunchDinnerDays) {
        expect(soupDayMeals.contains(key), isTrue,
            reason: 'Missing soup/starter for day/meal $key');
      }
    });

    test('soup courses are actually soup/starter recipes', () {
      final recipeMap = service.recipeMap;
      for (final d in plan.days.where((d) => d.courseType == CourseType.soupOrStarter)) {
        final recipe = recipeMap[d.recipeId];
        expect(recipe, isNotNull, reason: 'Unknown recipe ${d.recipeId}');
        expect(recipe!.courseType, CourseType.soupOrStarter,
            reason: 'Soup course ${d.recipeId} is not a soup/starter recipe');
      }
    });

    test('soups are never main courses or desserts', () {
      final recipeMap = service.recipeMap;
      for (final d in plan.days.where((d) => d.courseType == CourseType.soupOrStarter)) {
        final recipe = recipeMap[d.recipeId];
        if (recipe != null) {
          expect(recipe.isDessert, isFalse,
              reason: 'Soup ${d.recipeId} is a dessert');
        }
      }
    });

    test('no recipe repeats on the same day across course types', () {
      final dayRecipes = <int, Set<String>>{};
      for (final d in plan.days.where((d) => !d.isLeftover)) {
        final set = dayRecipes.putIfAbsent(d.dayIndex, () => {});
        // Same recipe can appear for different meal types (lunch vs dinner),
        // but not for different course types within the same meal type on same day
        final key = '${d.dayIndex}_${d.mealType.name}';
        // Actually, check within same day: no recipe should appear more than once per day
        // (soup, main, dessert should all be different recipes)
      }
      // Group by day
      for (int day = 1; day <= 30; day++) {
        final dayMeals = plan.days.where((d) => d.dayIndex == day && !d.isLeftover).toList();
        // Per meal type, all course entries should have distinct recipe IDs
        for (final mt in MealType.values) {
          final entries = dayMeals.where((d) => d.mealType == mt).toList();
          final ids = entries.map((d) => d.recipeId).toSet();
          expect(ids.length, entries.length,
              reason: 'Duplicate recipe on day $day for ${mt.name}: ${entries.map((d) => d.recipeId).toList()}');
        }
      }
    });

    test('no recipe appears more than 3 times per week', () {
      final weeklyRecipeCounts = <int, Map<String, int>>{};
      for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover)) {
        final week = ((d.dayIndex - 1) / 7).floor();
        final counts = weeklyRecipeCounts.putIfAbsent(week, () => {});
        counts[d.recipeId] = (counts[d.recipeId] ?? 0) + 1;
      }
      for (final weekEntry in weeklyRecipeCounts.entries) {
        for (final recipeEntry in weekEntry.value.entries) {
          expect(recipeEntry.value, lessThanOrEqualTo(3),
              reason: 'Recipe ${recipeEntry.key} appears ${recipeEntry.value} times in week ${weekEntry.key}');
        }
      }
    });

    test('prints analysis', () {
      _analyzeAndPrint('Config 2: Soup + Main', plan, service);
    });
  });

  group('Config 3: Soup + main + dessert', () {
    late MealPlan plan;

    setUpAll(() {
      final settings = _makeSettings(
        ms: const MealSettings(
          includeSoupOrStarter: true,
          includeDessert: true,
        ),
      );
      plan = service.generate(settings, forMonth);
    });

    test('every lunch/dinner has a dessert course', () {
      final lunchDinnerDays = <int>{};
      for (final d in plan.days.where((d) =>
          (d.mealType == MealType.lunch || d.mealType == MealType.dinner) &&
          d.courseType == CourseType.mainCourse &&
          !d.isLeftover)) {
        lunchDinnerDays.add(d.dayIndex * 10 + d.mealType.index);
      }
      final dessertDayMeals = <int>{};
      for (final d in plan.days.where((d) => d.courseType == CourseType.dessert)) {
        dessertDayMeals.add(d.dayIndex * 10 + d.mealType.index);
      }
      for (final key in lunchDinnerDays) {
        expect(dessertDayMeals.contains(key), isTrue,
            reason: 'Missing dessert for day/meal $key');
      }
    });

    test('dessert courses are actually dessert recipes', () {
      final recipeMap = service.recipeMap;
      for (final d in plan.days.where((d) => d.courseType == CourseType.dessert)) {
        final recipe = recipeMap[d.recipeId];
        expect(recipe, isNotNull, reason: 'Unknown recipe ${d.recipeId}');
        expect(recipe!.courseType, CourseType.dessert,
            reason: 'Dessert course ${d.recipeId} is not a dessert recipe');
      }
    });

    test('desserts are never main courses or soups', () {
      final recipeMap = service.recipeMap;
      for (final d in plan.days.where((d) => d.courseType == CourseType.dessert)) {
        final recipe = recipeMap[d.recipeId];
        if (recipe != null) {
          expect(recipe.isSoupOrStarter, isFalse,
              reason: 'Dessert ${d.recipeId} is a soup/starter');
        }
      }
    });

    test('no recipe repeats on same day within same meal type across courses', () {
      for (int day = 1; day <= 30; day++) {
        final dayMeals = plan.days.where((d) => d.dayIndex == day && !d.isLeftover).toList();
        for (final mt in MealType.values) {
          final entries = dayMeals.where((d) => d.mealType == mt).toList();
          final ids = entries.map((d) => d.recipeId).toSet();
          expect(ids.length, entries.length,
              reason: 'Duplicate recipe on day $day for ${mt.name}: ${entries.map((d) => d.recipeId).toList()}');
        }
      }
    });

    test('soup courses are actually soup/starter recipes', () {
      final recipeMap = service.recipeMap;
      for (final d in plan.days.where((d) => d.courseType == CourseType.soupOrStarter)) {
        final recipe = recipeMap[d.recipeId];
        expect(recipe, isNotNull);
        expect(recipe!.courseType, CourseType.soupOrStarter,
            reason: 'Soup course ${d.recipeId} is not a soup/starter recipe');
      }
    });

    test('recipe variety: at least 5 unique main recipes per week', () {
      final weeklyRecipes = <int, Set<String>>{};
      for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover)) {
        final week = ((d.dayIndex - 1) / 7).floor();
        weeklyRecipes.putIfAbsent(week, () => {}).add(d.recipeId);
      }
      for (final entry in weeklyRecipes.entries) {
        expect(entry.value.length, greaterThanOrEqualTo(5),
            reason: 'Week ${entry.key} has only ${entry.value.length} unique main recipes');
      }
    });

    test('cost estimates are positive and reasonable', () {
      for (final d in plan.days.where((d) => !d.isLeftover)) {
        expect(d.costEstimate, greaterThanOrEqualTo(0));
        expect(d.costEstimate, lessThan(100));
      }
    });

    test('prints analysis', () {
      _analyzeAndPrint('Config 3: Soup + Main + Dessert', plan, service);
    });
  });

  group('Config 4: Vegetarian objective', () {
    late MealPlan plan;

    setUpAll(() {
      final settings = _makeSettings(
        ms: const MealSettings(objective: MealObjective.vegetarian),
      );
      plan = service.generate(settings, forMonth);
    });

    test('no recipe repeats on the same day for the same meal type', () {
      final dayMealRecipes = <String, Set<String>>{};
      for (final d in plan.days.where((d) => !d.isLeftover)) {
        final key = '${d.dayIndex}_${d.mealType.name}_${d.courseType.name}';
        final set = dayMealRecipes.putIfAbsent(key, () => {});
        expect(set.contains(d.recipeId), isFalse,
            reason: 'Recipe ${d.recipeId} repeated for $key');
        set.add(d.recipeId);
      }
    });

    test('no recipe appears more than 3 times per week', () {
      final weeklyRecipeCounts = <int, Map<String, int>>{};
      for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover)) {
        final week = ((d.dayIndex - 1) / 7).floor();
        final counts = weeklyRecipeCounts.putIfAbsent(week, () => {});
        counts[d.recipeId] = (counts[d.recipeId] ?? 0) + 1;
      }
      for (final weekEntry in weeklyRecipeCounts.entries) {
        for (final recipeEntry in weekEntry.value.entries) {
          expect(recipeEntry.value, lessThanOrEqualTo(3),
              reason: 'Recipe ${recipeEntry.key} appears ${recipeEntry.value} times in week ${weekEntry.key}');
        }
      }
    });

    test('recipe variety: at least 5 unique recipes per week', () {
      final weeklyRecipes = <int, Set<String>>{};
      for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover)) {
        final week = ((d.dayIndex - 1) / 7).floor();
        weeklyRecipes.putIfAbsent(week, () => {}).add(d.recipeId);
      }
      for (final entry in weeklyRecipes.entries) {
        expect(entry.value.length, greaterThanOrEqualTo(5),
            reason: 'Week ${entry.key} has only ${entry.value.length} unique main recipes');
      }
    });

    test('cost estimates are positive and reasonable', () {
      for (final d in plan.days.where((d) => !d.isLeftover)) {
        expect(d.costEstimate, greaterThanOrEqualTo(0));
        expect(d.costEstimate, lessThan(100));
      }
    });

    test('prints analysis', () {
      _analyzeAndPrint('Config 4: Vegetarian', plan, service);
    });
  });

  group('Config 5: Minimize cost objective', () {
    late MealPlan plan;

    setUpAll(() {
      final settings = _makeSettings(
        ms: const MealSettings(objective: MealObjective.minimizeCost),
      );
      plan = service.generate(settings, forMonth);
    });

    test('no recipe repeats on the same day for the same meal type', () {
      final dayMealRecipes = <String, Set<String>>{};
      for (final d in plan.days.where((d) => !d.isLeftover)) {
        final key = '${d.dayIndex}_${d.mealType.name}_${d.courseType.name}';
        final set = dayMealRecipes.putIfAbsent(key, () => {});
        expect(set.contains(d.recipeId), isFalse,
            reason: 'Recipe ${d.recipeId} repeated for $key');
        set.add(d.recipeId);
      }
    });

    test('no recipe appears more than 3 times per week', () {
      final weeklyRecipeCounts = <int, Map<String, int>>{};
      for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover)) {
        final week = ((d.dayIndex - 1) / 7).floor();
        final counts = weeklyRecipeCounts.putIfAbsent(week, () => {});
        counts[d.recipeId] = (counts[d.recipeId] ?? 0) + 1;
      }
      for (final weekEntry in weeklyRecipeCounts.entries) {
        for (final recipeEntry in weekEntry.value.entries) {
          expect(recipeEntry.value, lessThanOrEqualTo(3),
              reason: 'Recipe ${recipeEntry.key} appears ${recipeEntry.value} times in week ${weekEntry.key}');
        }
      }
    });

    test('cost estimates are positive and reasonable', () {
      for (final d in plan.days.where((d) => !d.isLeftover)) {
        expect(d.costEstimate, greaterThanOrEqualTo(0));
        expect(d.costEstimate, lessThan(100));
      }
    });

    test('prints analysis', () {
      _analyzeAndPrint('Config 5: Minimize Cost', plan, service);
    });
  });

  group('Config 6: High protein objective', () {
    late MealPlan plan;

    setUpAll(() {
      final settings = _makeSettings(
        ms: const MealSettings(objective: MealObjective.highProtein),
      );
      plan = service.generate(settings, forMonth);
    });

    test('no recipe repeats on the same day for the same meal type', () {
      final dayMealRecipes = <String, Set<String>>{};
      for (final d in plan.days.where((d) => !d.isLeftover)) {
        final key = '${d.dayIndex}_${d.mealType.name}_${d.courseType.name}';
        final set = dayMealRecipes.putIfAbsent(key, () => {});
        expect(set.contains(d.recipeId), isFalse,
            reason: 'Recipe ${d.recipeId} repeated for $key');
        set.add(d.recipeId);
      }
    });

    test('main courses are never soups or desserts', () {
      final recipeMap = service.recipeMap;
      for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover)) {
        final recipe = recipeMap[d.recipeId];
        if (recipe != null) {
          expect(recipe.isSoupOrStarter, isFalse,
              reason: 'Main course ${d.recipeId} is a soup/starter');
          expect(recipe.isDessert, isFalse,
              reason: 'Main course ${d.recipeId} is a dessert');
        }
      }
    });

    test('no recipe appears more than 3 times per week', () {
      final weeklyRecipeCounts = <int, Map<String, int>>{};
      for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover)) {
        final week = ((d.dayIndex - 1) / 7).floor();
        final counts = weeklyRecipeCounts.putIfAbsent(week, () => {});
        counts[d.recipeId] = (counts[d.recipeId] ?? 0) + 1;
      }
      for (final weekEntry in weeklyRecipeCounts.entries) {
        for (final recipeEntry in weekEntry.value.entries) {
          expect(recipeEntry.value, lessThanOrEqualTo(3),
              reason: 'Recipe ${recipeEntry.key} appears ${recipeEntry.value} times in week ${weekEntry.key}');
        }
      }
    });

    test('recipe variety: at least 5 unique recipes per week', () {
      final weeklyRecipes = <int, Set<String>>{};
      for (final d in plan.days.where((d) => d.courseType == CourseType.mainCourse && !d.isLeftover)) {
        final week = ((d.dayIndex - 1) / 7).floor();
        weeklyRecipes.putIfAbsent(week, () => {}).add(d.recipeId);
      }
      for (final entry in weeklyRecipes.entries) {
        expect(entry.value.length, greaterThanOrEqualTo(5),
            reason: 'Week ${entry.key} has only ${entry.value.length} unique main recipes');
      }
    });

    test('cost estimates are positive and reasonable', () {
      for (final d in plan.days.where((d) => !d.isLeftover)) {
        expect(d.costEstimate, greaterThanOrEqualTo(0));
        expect(d.costEstimate, lessThan(100));
      }
    });

    test('prints analysis', () {
      _analyzeAndPrint('Config 6: High Protein', plan, service);
    });
  });
}
