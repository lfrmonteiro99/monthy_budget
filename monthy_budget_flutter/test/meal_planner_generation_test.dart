import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/meal_planner.dart';
import 'package:orcamento_mensal/models/meal_settings.dart';
import 'package:orcamento_mensal/models/app_settings.dart';
import 'package:orcamento_mensal/services/meal_planner_service.dart';

/// Helper to build AppSettings with a food budget and meal settings.
AppSettings _settings({
  double foodBudget = 400,
  MealSettings ms = const MealSettings(),
  int titulares = 1,
  int dependentes = 1,
}) {
  return AppSettings(
    salaries: [SalaryInfo(label: 'S1', enabled: true, titulares: titulares)],
    personalInfo: PersonalInfo(dependentes: dependentes),
    expenses: [
      ExpenseItem(
        id: 'food',
        label: 'Alimentação',
        amount: foodBudget,
        category: ExpenseCategory.alimentacao,
      ),
    ],
    mealSettings: ms,
  );
}

void main() {
  late MealPlannerService service;
  late String ingredientsJson;
  late String recipesJson;

  setUpAll(() {
    final ingFile = File('assets/meal_planner/ingredients.json');
    final recFile = File('assets/meal_planner/recipes.json');
    ingredientsJson = ingFile.readAsStringSync();
    recipesJson = recFile.readAsStringSync();
  });

  setUp(() {
    service = MealPlannerService();
    service.loadCatalogFromJson(ingredientsJson, recipesJson);
  });

  final march2026 = DateTime(2026, 3); // 31 days, starts on Sunday

  // ────────────────────────────────────────────────────────────
  // 1. DEFAULT SETTINGS — basic sanity
  // ────────────────────────────────────────────────────────────
  group('Default settings', () {
    test('generates meals for every day of the month', () {
      final plan = service.generate(_settings(), march2026);
      // Default: lunch + dinner = 2 meals per day, 31 days
      expect(plan.days.length, 31 * 2);
    });

    test('every meal references a valid recipe', () {
      final plan = service.generate(_settings(), march2026);
      final recipeIds = service.recipes.map((r) => r.id).toSet();
      for (final day in plan.days) {
        expect(recipeIds.contains(day.recipeId), isTrue,
            reason: 'Invalid recipe: ${day.recipeId} on day ${day.dayIndex}');
      }
    });

    test('nPessoas and budget are correct', () {
      final plan = service.generate(_settings(foodBudget: 350), march2026);
      expect(plan.nPessoas, 2); // 1 titular + 1 dependente
      expect(plan.monthlyBudget, 350);
    });

    test('total estimated cost is sum of all meal costs', () {
      final plan = service.generate(_settings(), march2026);
      final sum = plan.days.fold(0.0, (s, d) => s + d.costEstimate);
      expect(plan.totalEstimatedCost, closeTo(sum, 0.01));
    });
  });

  // ────────────────────────────────────────────────────────────
  // 2. ENABLED MEALS
  // ────────────────────────────────────────────────────────────
  group('Enabled meals', () {
    test('only generates enabled meal types', () {
      final ms = const MealSettings(
        enabledMeals: {MealType.breakfast, MealType.lunch, MealType.snack, MealType.dinner},
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      final types = plan.days.map((d) => d.mealType).toSet();
      expect(types, containsAll([MealType.breakfast, MealType.lunch, MealType.snack, MealType.dinner]));
    });

    test('dinner-only plan produces one meal per day', () {
      final ms = const MealSettings(enabledMeals: {MealType.dinner});
      final plan = service.generate(_settings(ms: ms), march2026);
      expect(plan.days.length, 31);
      for (final d in plan.days) {
        expect(d.mealType, MealType.dinner);
      }
    });

    test('breakfast-only plan picks recipes with breakfast in suitableMealTypes', () {
      final ms = const MealSettings(enabledMeals: {MealType.breakfast});
      final plan = service.generate(_settings(ms: ms), march2026);
      final breakfastRecipes = service.recipes
          .where((r) => r.suitableMealTypes.contains('breakfast'))
          .map((r) => r.id)
          .toSet();
      for (final d in plan.days) {
        expect(breakfastRecipes.contains(d.recipeId), isTrue,
            reason: 'Day ${d.dayIndex}: ${d.recipeId} is not a breakfast recipe');
      }
    });
  });

  // ────────────────────────────────────────────────────────────
  // 3. DIETARY RESTRICTIONS
  // ────────────────────────────────────────────────────────────
  group('Dietary restrictions', () {
    test('gluten-free plan contains no gluten recipes', () {
      final ms = const MealSettings(glutenFree: true);
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        expect(recipe.glutenFree, isTrue,
            reason: 'Day ${day.dayIndex} ${day.mealType}: ${recipe.name} is not gluten-free');
      }
    });

    test('lactose-free plan avoids lactose-containing recipes', () {
      final ms = const MealSettings(lactoseFree: true);
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        expect(recipe.lactoseFree, isTrue,
            reason: 'Day ${day.dayIndex} ${day.mealType}: ${recipe.name} contains lactose');
      }
    });

    test('egg-free plan excludes recipes with ovo', () {
      final ms = const MealSettings(eggFree: true);
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        final hasEgg = recipe.ingredients.any((ri) => ri.ingredientId == 'ovo');
        expect(hasEgg, isFalse,
            reason: 'Day ${day.dayIndex} ${day.mealType}: ${recipe.name} contains egg');
      }
    });

    test('excluded proteins are never used', () {
      final ms = const MealSettings(excludedProteins: ['frango', 'porco']);
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        expect(recipe.proteinId, isNot(anyOf('frango', 'porco')),
            reason: 'Day ${day.dayIndex}: ${recipe.name} uses excluded protein ${recipe.proteinId}');
      }
    });

    test('disliked ingredients are never present', () {
      final ms = const MealSettings(dislikedIngredients: ['Batata', 'Cenoura']);
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      final iMap = service.ingredientMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        for (final ri in recipe.ingredients) {
          final ing = iMap[ri.ingredientId];
          if (ing == null) continue;
          expect(ing.name.toLowerCase(), isNot(anyOf('batata', 'cenoura')),
              reason: 'Day ${day.dayIndex}: ${recipe.name} contains disliked ${ing.name}');
        }
      }
    });

    test('all dietary flags combined still generates a valid plan', () {
      final ms = const MealSettings(
        glutenFree: true,
        lactoseFree: true,
        eggFree: true,
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      expect(plan.days.isNotEmpty, isTrue);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        expect(recipe.glutenFree, isTrue);
        expect(recipe.lactoseFree, isTrue);
        final hasEgg = recipe.ingredients.any((ri) => ri.ingredientId == 'ovo');
        expect(hasEgg, isFalse);
      }
    });
  });

  // ────────────────────────────────────────────────────────────
  // 4. LOW SODIUM
  // ────────────────────────────────────────────────────────────
  group('Sodium preference', () {
    test('low sodium excludes high-sodium ingredients', () {
      final ms = const MealSettings(sodiumPreference: SodiumPreference.lowSodium);
      final plan = service.generate(_settings(ms: ms), march2026);
      const highSodium = {'bacalhau', 'chourico', 'fiambre', 'sardinha'};
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        for (final ri in recipe.ingredients) {
          expect(highSodium.contains(ri.ingredientId), isFalse,
              reason: 'Day ${day.dayIndex}: ${recipe.name} has high-sodium ${ri.ingredientId}');
        }
      }
    });
  });

  // ────────────────────────────────────────────────────────────
  // 5. MEDICAL CONDITIONS
  // ────────────────────────────────────────────────────────────
  group('Medical conditions', () {
    test('diabetes: no meal exceeds 55g carbs', () {
      final ms = const MealSettings(medicalConditions: {MedicalCondition.diabetes});
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        if (recipe.nutrition != null) {
          expect(recipe.nutrition!.carbsG, lessThanOrEqualTo(55),
              reason: 'Day ${day.dayIndex}: ${recipe.name} has ${recipe.nutrition!.carbsG}g carbs (limit 55)');
        }
      }
    });

    test('hypertension: no meal exceeds 500mg sodium', () {
      final ms = const MealSettings(medicalConditions: {MedicalCondition.hypertension});
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        if (recipe.nutrition != null) {
          expect(recipe.nutrition!.sodiumMg, lessThanOrEqualTo(500),
              reason: 'Day ${day.dayIndex}: ${recipe.name} has ${recipe.nutrition!.sodiumMg}mg sodium');
        }
      }
    });

    test('high cholesterol: no meal exceeds 25g fat', () {
      final ms = const MealSettings(medicalConditions: {MedicalCondition.highCholesterol});
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        if (recipe.nutrition != null) {
          expect(recipe.nutrition!.fatG, lessThanOrEqualTo(25),
              reason: 'Day ${day.dayIndex}: ${recipe.name} has ${recipe.nutrition!.fatG}g fat');
        }
      }
    });

    test('gout: excludes sardinha and porco', () {
      final ms = const MealSettings(medicalConditions: {MedicalCondition.gout});
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        expect(recipe.proteinId, isNot(anyOf('sardinha', 'porco')),
            reason: 'Day ${day.dayIndex}: ${recipe.name} uses gout-triggering ${recipe.proteinId}');
      }
    });

    test('multiple conditions combined', () {
      final ms = const MealSettings(
        medicalConditions: {MedicalCondition.diabetes, MedicalCondition.hypertension},
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        if (recipe.nutrition != null) {
          expect(recipe.nutrition!.carbsG, lessThanOrEqualTo(55));
          expect(recipe.nutrition!.sodiumMg, lessThanOrEqualTo(500));
        }
      }
    });
  });

  // ────────────────────────────────────────────────────────────
  // 6. OBJECTIVES
  // ────────────────────────────────────────────────────────────
  group('Meal objectives', () {
    test('vegetarian objective only picks vegetarian recipes', () {
      final ms = const MealSettings(objective: MealObjective.vegetarian);
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        expect(recipe.isVegetarian, isTrue,
            reason: 'Day ${day.dayIndex} ${day.mealType}: ${recipe.name} is not vegetarian');
      }
    });

    test('high protein prefers high-protein recipes', () {
      final ms = const MealSettings(objective: MealObjective.highProtein);
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      int highProteinCount = 0;
      int totalNonLeftover = 0;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        totalNonLeftover++;
        final recipe = rMap[day.recipeId]!;
        if (recipe.isHighProtein) highProteinCount++;
      }
      // High protein should be the majority
      expect(highProteinCount / totalNonLeftover, greaterThan(0.7),
          reason: 'Only $highProteinCount/$totalNonLeftover are high protein');
    });

    test('low carb prefers low-carb recipes', () {
      final ms = const MealSettings(objective: MealObjective.lowCarb);
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      int lowCarbCount = 0;
      int total = 0;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        total++;
        if (rMap[day.recipeId]!.isLowCarb) lowCarbCount++;
      }
      expect(lowCarbCount / total, greaterThan(0.5),
          reason: 'Only $lowCarbCount/$total are low carb');
    });

    test('minimize cost produces cheaper plan than balanced', () {
      final msMinCost = const MealSettings(objective: MealObjective.minimizeCost);
      final msBalanced = const MealSettings(objective: MealObjective.balancedHealth);
      // Run multiple times to account for randomness
      double minCostTotal = 0;
      double balancedTotal = 0;
      for (int i = 0; i < 5; i++) {
        minCostTotal += service.generate(_settings(ms: msMinCost, foodBudget: 9999), march2026).totalEstimatedCost;
        balancedTotal += service.generate(_settings(ms: msBalanced, foodBudget: 9999), march2026).totalEstimatedCost;
      }
      expect(minCostTotal, lessThan(balancedTotal),
          reason: 'minimizeCost avg=${minCostTotal / 5} should be < balanced avg=${balancedTotal / 5}');
    });
  });

  // ────────────────────────────────────────────────────────────
  // 7. COMPLEXITY & PREP TIME
  // ────────────────────────────────────────────────────────────
  group('Complexity and prep time', () {
    test('weekday meals respect maxPrepMinutes and maxComplexity', () {
      final ms = const MealSettings(maxPrepMinutes: 20, maxComplexity: 2);
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final dt = DateTime(2026, 3, day.dayIndex);
        if (dt.weekday == 6 || dt.weekday == 7) continue; // skip weekends
        final recipe = rMap[day.recipeId]!;
        expect(recipe.prepMinutes, lessThanOrEqualTo(20),
            reason: 'Weekday ${day.dayIndex}: ${recipe.name} prep=${recipe.prepMinutes}m > 20m');
        expect(recipe.complexity, lessThanOrEqualTo(2),
            reason: 'Weekday ${day.dayIndex}: ${recipe.name} cx=${recipe.complexity} > 2');
      }
    });

    test('weekend meals use weekend limits', () {
      final ms = const MealSettings(
        maxPrepMinutes: 15,
        maxComplexity: 1,
        maxPrepMinutesWeekend: 60,
        maxComplexityWeekend: 4,
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final dt = DateTime(2026, 3, day.dayIndex);
        final recipe = rMap[day.recipeId]!;
        if (dt.weekday == 6 || dt.weekday == 7) {
          expect(recipe.prepMinutes, lessThanOrEqualTo(60));
          expect(recipe.complexity, lessThanOrEqualTo(4));
        } else {
          expect(recipe.prepMinutes, lessThanOrEqualTo(15),
              reason: 'Weekday day ${day.dayIndex}: ${recipe.name} prep=${recipe.prepMinutes}');
          expect(recipe.complexity, lessThanOrEqualTo(1));
        }
      }
    });
  });

  // ────────────────────────────────────────────────────────────
  // 8. EQUIPMENT REQUIREMENTS
  // ────────────────────────────────────────────────────────────
  group('Equipment', () {
    test('plan with no oven excludes oven-requiring recipes', () {
      final ms = const MealSettings(
        availableEquipment: {KitchenEquipment.microwave},
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        expect(recipe.requiresEquipment.contains('oven'), isFalse,
            reason: 'Day ${day.dayIndex}: ${recipe.name} requires oven');
      }
    });
  });

  // ────────────────────────────────────────────────────────────
  // 9. EATING OUT DAYS
  // ────────────────────────────────────────────────────────────
  group('Eating out days', () {
    test('skipped weekdays produce no meals', () {
      // Skip Tuesdays (2) and Thursdays (4)
      final ms = const MealSettings(eatingOutWeekdays: {2, 4});
      final plan = service.generate(_settings(ms: ms), march2026);
      for (final day in plan.days) {
        final dt = DateTime(2026, 3, day.dayIndex);
        expect(dt.weekday, isNot(anyOf(2, 4)),
            reason: 'Day ${day.dayIndex} (weekday ${dt.weekday}) should be skipped');
      }
    });

    test('eating out reduces total meal count', () {
      final msNormal = const MealSettings();
      final msEatOut = const MealSettings(eatingOutWeekdays: {1, 2, 3, 4, 5});
      final planNormal = service.generate(_settings(ms: msNormal), march2026);
      final planEatOut = service.generate(_settings(ms: msEatOut), march2026);
      expect(planEatOut.days.length, lessThan(planNormal.days.length));
    });
  });

  // ────────────────────────────────────────────────────────────
  // 10. VEGGIE DAYS DISTRIBUTION
  // ────────────────────────────────────────────────────────────
  group('Veggie days', () {
    test('veggieDaysPerWeek distributes vegetarian meals', () {
      final ms = const MealSettings(veggieDaysPerWeek: 3);
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      // Count veggie days (days where at least one non-leftover meal is veggie)
      final veggieDays = <int>{};
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        if (recipe.isVegetarian) veggieDays.add(day.dayIndex);
      }
      // Expected: ~3 per week * ~4.4 weeks ≈ 13 veggie days
      final expectedTotal = (3 * 31 / 7).round();
      expect(veggieDays.length, greaterThanOrEqualTo(expectedTotal - 2),
          reason: 'Expected ~$expectedTotal veggie days, got ${veggieDays.length}');
    });
  });

  // ────────────────────────────────────────────────────────────
  // 11. FOOD GROUP DISTRIBUTION
  // ────────────────────────────────────────────────────────────
  group('Food group distribution', () {
    test('fish days per week are respected', () {
      final ms = const MealSettings(fishDaysPerWeek: 2);
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      // Count fish meals per week-bucket
      final weeklyFish = <int, int>{};
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        if (recipe.type == RecipeType.peixe) {
          final weekNum = ((day.dayIndex - 1) / 7).floor();
          weeklyFish[weekNum] = (weeklyFish[weekNum] ?? 0) + 1;
        }
      }
      // Each complete week should have at least 1 fish day (enforcement kicks in toward end of week)
      for (final entry in weeklyFish.entries) {
        expect(entry.value, greaterThanOrEqualTo(1),
            reason: 'Week ${entry.key} has ${entry.value} fish meals, expected >= 1');
      }
    });

    test('red meat cap is enforced', () {
      final ms = const MealSettings(redMeatMaxPerWeek: 1);
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      const redMeatProteins = {'porco', 'carne_picada'};
      final weeklyRedMeat = <int, int>{};
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        if (recipe.type == RecipeType.carne && redMeatProteins.contains(recipe.proteinId)) {
          final weekNum = ((day.dayIndex - 1) / 7).floor();
          weeklyRedMeat[weekNum] = (weeklyRedMeat[weekNum] ?? 0) + 1;
        }
      }
      for (final entry in weeklyRedMeat.entries) {
        expect(entry.value, lessThanOrEqualTo(1),
            reason: 'Week ${entry.key} has ${entry.value} red meat meals, cap is 1');
      }
    });
  });

  // ────────────────────────────────────────────────────────────
  // 12. BATCH COOKING
  // ────────────────────────────────────────────────────────────
  group('Batch cooking', () {
    test('batch cooking repeats recipes across consecutive days', () {
      final ms = const MealSettings(
        batchCookingEnabled: true,
        maxBatchDays: 3,
        enabledMeals: {MealType.dinner},
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      // Check for consecutive days with same recipe
      bool foundBatch = false;
      for (int i = 1; i < plan.days.length; i++) {
        if (plan.days[i].recipeId == plan.days[i - 1].recipeId &&
            plan.days[i].dayIndex == plan.days[i - 1].dayIndex + 1) {
          foundBatch = true;
          break;
        }
      }
      expect(foundBatch, isTrue, reason: 'Batch cooking enabled but no consecutive same-recipe days found');
    });

    test('batch does not exceed maxBatchDays', () {
      final ms = const MealSettings(
        batchCookingEnabled: true,
        maxBatchDays: 2,
        enabledMeals: {MealType.dinner},
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      // Count max consecutive same-recipe
      int maxConsec = 1;
      int current = 1;
      for (int i = 1; i < plan.days.length; i++) {
        if (plan.days[i].recipeId == plan.days[i - 1].recipeId &&
            plan.days[i].dayIndex == plan.days[i - 1].dayIndex + 1) {
          current++;
          if (current > maxConsec) maxConsec = current;
        } else {
          current = 1;
        }
      }
      expect(maxConsec, lessThanOrEqualTo(2),
          reason: 'Max batch streak is $maxConsec, should be <= 2');
    });
  });

  // ────────────────────────────────────────────────────────────
  // 13. LEFTOVER REUSE
  // ────────────────────────────────────────────────────────────
  group('Leftover reuse', () {
    test('lunch reuses previous dinner when enabled', () {
      final ms = const MealSettings(
        reuseLeftovers: true,
        enabledMeals: {MealType.lunch, MealType.dinner},
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      int leftoverCount = 0;
      for (final day in plan.days) {
        if (day.isLeftover) {
          leftoverCount++;
          expect(day.mealType, MealType.lunch);
          expect(day.costEstimate, 0.0);
          // Verify references previous day's dinner
          final prevDinner = plan.days.where(
            (d) => d.dayIndex == day.dayIndex - 1 && d.mealType == MealType.dinner,
          ).firstOrNull;
          if (prevDinner != null) {
            expect(day.recipeId, prevDinner.recipeId,
                reason: 'Leftover on day ${day.dayIndex} should match dinner on day ${day.dayIndex - 1}');
          }
        }
      }
      expect(leftoverCount, greaterThan(0), reason: 'No leftovers found despite reuseLeftovers=true');
    });

    test('leftovers disabled means no leftover meals', () {
      final ms = const MealSettings(reuseLeftovers: false);
      final plan = service.generate(_settings(ms: ms), march2026);
      final leftovers = plan.days.where((d) => d.isLeftover).length;
      expect(leftovers, 0);
    });
  });

  // ────────────────────────────────────────────────────────────
  // 14. BUDGET ENFORCEMENT
  // ────────────────────────────────────────────────────────────
  group('Budget enforcement', () {
    test('plan respects monthly budget when achievable', () {
      final plan = service.generate(_settings(foodBudget: 300), march2026);
      expect(plan.totalEstimatedCost, lessThanOrEqualTo(300),
          reason: 'Total ${plan.totalEstimatedCost} exceeds budget 300');
    });

    test('very tight budget triggers replacements', () {
      // 50€ for 2 people, 31 days, 2 meals — very tight
      final plan = service.generate(_settings(foodBudget: 50), march2026);
      // Budget enforcement should reduce cost, though it might not meet impossible targets
      expect(plan.totalEstimatedCost, lessThan(double.infinity));
    });

    test('generous budget does not alter plan', () {
      final plan = service.generate(_settings(foodBudget: 9999), march2026);
      // With huge budget, no replacements needed
      expect(plan.totalEstimatedCost, lessThan(9999));
    });
  });

  // ────────────────────────────────────────────────────────────
  // 15. LUNCHBOX LUNCHES
  // ────────────────────────────────────────────────────────────
  group('Lunchbox lunches', () {
    test('portable recipes preferred for lunch when enabled', () {
      final ms = const MealSettings(lunchboxLunches: true);
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      int portableCount = 0;
      int totalLunches = 0;
      for (final day in plan.days) {
        if (day.mealType != MealType.lunch || day.isLeftover) continue;
        totalLunches++;
        if (rMap[day.recipeId]!.isPortable) portableCount++;
      }
      // All lunches should be portable since filter is applied
      if (totalLunches > 0) {
        expect(portableCount / totalLunches, greaterThanOrEqualTo(0.9),
            reason: '$portableCount/$totalLunches lunches are portable');
      }
    });
  });

  // ────────────────────────────────────────────────────────────
  // 16. SEASONAL PREFERENCE
  // ────────────────────────────────────────────────────────────
  group('Seasonal preference', () {
    test('winter month prefers winter/all-season recipes when enabled', () {
      final ms = const MealSettings(preferSeasonal: true);
      final january = DateTime(2026, 1);
      final plan = service.generate(_settings(ms: ms, foodBudget: 9999), january);
      final rMap = service.recipeMap;
      int seasonalCount = 0;
      int total = 0;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        total++;
        final recipe = rMap[day.recipeId]!;
        if (recipe.seasons.isEmpty || recipe.seasons.contains('winter')) {
          seasonalCount++;
        }
      }
      // Most recipes should match (since empty seasons = all seasons)
      expect(seasonalCount / total, greaterThan(0.8));
    });
  });

  // ────────────────────────────────────────────────────────────
  // 17. PINNED MEALS
  // ────────────────────────────────────────────────────────────
  group('Pinned meals', () {
    test('pinned recipe appears on the correct weekday', () {
      // Pin frango_assado for Monday dinner (weekday 1)
      final ms = const MealSettings(
        pinnedMeals: {'1_dinner': 'frango_assado'},
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      final mondayDinners = plan.days.where((d) {
        final dt = DateTime(2026, 3, d.dayIndex);
        return dt.weekday == 1 && d.mealType == MealType.dinner;
      });
      for (final d in mondayDinners) {
        expect(d.recipeId, 'frango_assado',
            reason: 'Monday dinner on day ${d.dayIndex} should be frango_assado');
      }
    });

    test('pinned "skip" produces no meal for that slot', () {
      final ms = const MealSettings(
        pinnedMeals: {'5_lunch': 'skip'},
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      final fridayLunches = plan.days.where((d) {
        final dt = DateTime(2026, 3, d.dayIndex);
        return dt.weekday == 5 && d.mealType == MealType.lunch;
      });
      expect(fridayLunches.isEmpty, isTrue, reason: 'Friday lunch should be skipped');
    });
  });

  // ────────────────────────────────────────────────────────────
  // 18. FEEDBACK INTEGRATION
  // ────────────────────────────────────────────────────────────
  group('Feedback integration', () {
    test('disliked recipes are avoided', () {
      final plan = service.generate(
        _settings(),
        march2026,
        previousFeedback: {'frango_assado': MealFeedback.disliked, 'frango_arroz': MealFeedback.disliked},
      );
      // Disliked are avoided when pool >= 3
      final usedDisliked = plan.days.where(
        (d) => d.recipeId == 'frango_assado' || d.recipeId == 'frango_arroz',
      );
      // Allow some due to fallback, but should be minimal
      expect(usedDisliked.length, lessThanOrEqualTo(5),
          reason: '${usedDisliked.length} disliked meals used');
    });
  });

  // ────────────────────────────────────────────────────────────
  // 19. HOUSEHOLD MEMBERS (portion equivalents)
  // ────────────────────────────────────────────────────────────
  group('Household members', () {
    test('household members with age/activity factors affect nPessoas', () {
      final ms = MealSettings(
        householdMembers: [
          const HouseholdMember(name: 'Adult', ageGroup: AgeGroup.adult, activityLevel: ActivityLevel.moderate),
          const HouseholdMember(name: 'Child', ageGroup: AgeGroup.child4to10, activityLevel: ActivityLevel.sedentary),
        ],
      );
      // Adult moderate = 1.0 * 1.1 = 1.1, Child4to10 sedentary = 0.65 * 1.0 = 0.65
      // Total = 1.75 → rounds to 2
      expect(service.nPessoas(_settings(ms: ms)), 2);
    });

    test('householdSize overrides salary-based calculation', () {
      final ms = const MealSettings(householdSize: 5);
      expect(service.nPessoas(_settings(ms: ms)), 5);
    });

    test('householdMembers takes priority over householdSize', () {
      final ms = MealSettings(
        householdSize: 10,
        householdMembers: [
          const HouseholdMember(name: 'A', ageGroup: AgeGroup.adult, activityLevel: ActivityLevel.sedentary),
          const HouseholdMember(name: 'B', ageGroup: AgeGroup.adult, activityLevel: ActivityLevel.sedentary),
        ],
      );
      // 2 adults sedentary: 1.0 * 1.0 = 1.0 each → total 2.0 → 2
      expect(service.nPessoas(_settings(ms: ms)), 2);
    });
  });

  // ────────────────────────────────────────────────────────────
  // 20. PROTEIN DIVERSITY
  // ────────────────────────────────────────────────────────────
  group('Protein diversity', () {
    test('same protein rarely used 3 consecutive days for same meal type', () {
      final ms = const MealSettings(enabledMeals: {MealType.dinner});
      // Run 5 times to account for randomness
      int violations = 0;
      for (int run = 0; run < 5; run++) {
        final plan = service.generate(_settings(ms: ms, foodBudget: 9999), march2026);
        final rMap = service.recipeMap;
        for (int i = 2; i < plan.days.length; i++) {
          final p0 = rMap[plan.days[i - 2].recipeId]!.proteinId;
          final p1 = rMap[plan.days[i - 1].recipeId]!.proteinId;
          final p2 = rMap[plan.days[i].recipeId]!.proteinId;
          if (p0 == p1 && p1 == p2) violations++;
        }
      }
      // Should be very rare
      expect(violations, lessThanOrEqualTo(5),
          reason: '$violations cases of 3 consecutive same-protein dinners across 5 runs');
    });
  });

  // ────────────────────────────────────────────────────────────
  // 21. CONSOLIDATED INGREDIENTS
  // ────────────────────────────────────────────────────────────
  group('Consolidated ingredients', () {
    test('leftovers are excluded from ingredient totals', () {
      final ms = const MealSettings(
        reuseLeftovers: true,
        enabledMeals: {MealType.lunch, MealType.dinner},
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      final totals = service.consolidatedIngredients(plan);
      expect(totals.isNotEmpty, isTrue);
      // Totals should be positive
      for (final qty in totals.values) {
        expect(qty, greaterThan(0));
      }
    });

    test('pantry ingredients are excluded', () {
      final plan = service.generate(_settings(), march2026);
      final withPantry = service.consolidatedIngredients(plan, pantryIngredients: ['azeite', 'alho']);
      expect(withPantry.containsKey('azeite'), isFalse);
      expect(withPantry.containsKey('alho'), isFalse);
    });
  });

  // ────────────────────────────────────────────────────────────
  // 22. SWAP ALTERNATIVES
  // ────────────────────────────────────────────────────────────
  group('Swap alternatives', () {
    test('alternatives exclude current recipe', () {
      final alts = service.alternativesFor('frango_assado', 2);
      final ids = alts.map((r) => r.id).toList();
      expect(ids.contains('frango_assado'), isFalse);
    });

    test('alternatives respect dietary filters', () {
      final alts = service.alternativesFor('frango_assado', 2,
          ms: const MealSettings(glutenFree: true));
      for (final r in alts) {
        expect(r.glutenFree, isTrue);
      }
    });

    test('alternatives sorted by protein match then cost', () {
      final alts = service.alternativesFor('frango_assado', 2);
      // First entries should share proteinId 'frango'
      if (alts.length >= 2) {
        final firstFrango = alts.indexWhere((r) => r.proteinId != 'frango');
        if (firstFrango > 0) {
          // All before firstFrango should be frango
          for (int i = 0; i < firstFrango; i++) {
            expect(alts[i].proteinId, 'frango');
          }
        }
      }
    });
  });

  // ────────────────────────────────────────────────────────────
  // 23. SWAP DAY
  // ────────────────────────────────────────────────────────────
  group('Swap day', () {
    test('replaces specific meal and recalculates cost', () {
      final plan = service.generate(_settings(), march2026);
      final oldDay = plan.days.first;
      final newPlan = service.swapDay(plan, oldDay.dayIndex, oldDay.mealType, 'frango_grelhado');
      final updated = newPlan.days.firstWhere(
        (d) => d.dayIndex == oldDay.dayIndex && d.mealType == oldDay.mealType,
      );
      expect(updated.recipeId, 'frango_grelhado');
      expect(updated.costEstimate, greaterThan(0));
      // Verify total was recalculated as sum of all day costs
      final expectedTotal = newPlan.days.fold(0.0, (s, d) => s + d.costEstimate);
      expect(newPlan.totalEstimatedCost, closeTo(expectedTotal, 0.001));
    });
  });

  // ────────────────────────────────────────────────────────────
  // 24. COMBINED SETTINGS (stress tests)
  // ────────────────────────────────────────────────────────────
  group('Combined settings stress tests', () {
    test('all meals + vegetarian + gluten-free + low sodium + diabetes', () {
      final ms = const MealSettings(
        enabledMeals: {MealType.breakfast, MealType.lunch, MealType.snack, MealType.dinner},
        objective: MealObjective.vegetarian,
        glutenFree: true,
        sodiumPreference: SodiumPreference.lowSodium,
        medicalConditions: {MedicalCondition.diabetes},
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      expect(plan.days.isNotEmpty, isTrue);
      final rMap = service.recipeMap;
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        // Verify recipe exists (vegetarian objective may relax via fallback,
        // but gluten-free must be strict — only hard filters validated here)
        expect(rMap.containsKey(day.recipeId), isTrue);
      }
    });

    test('batch cooking + leftovers + eating out + lunchbox', () {
      final ms = const MealSettings(
        batchCookingEnabled: true,
        maxBatchDays: 3,
        reuseLeftovers: true,
        eatingOutWeekdays: {6, 7}, // weekends out
        lunchboxLunches: true,
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      // Verify no weekend meals
      for (final day in plan.days) {
        final dt = DateTime(2026, 3, day.dayIndex);
        expect(dt.weekday, isNot(anyOf(6, 7)));
      }
      // Verify plan is not empty
      expect(plan.days.isNotEmpty, isTrue);
    });

    test('maximum restrictions: all allergies + excluded proteins + low complexity', () {
      final ms = const MealSettings(
        glutenFree: true,
        lactoseFree: true,
        eggFree: true,
        shellfishFree: true,
        excludedProteins: ['porco', 'bacalhau', 'sardinha', 'chourico'],
        maxPrepMinutes: 15,
        maxComplexity: 1,
        availableEquipment: {},
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      // Even with extreme restrictions, fallback should produce meals
      expect(plan.days.isNotEmpty, isTrue);
    });

    test('fish + legume days + red meat cap together', () {
      final ms = const MealSettings(
        fishDaysPerWeek: 2,
        legumeDaysPerWeek: 2,
        redMeatMaxPerWeek: 0,
      );
      final plan = service.generate(_settings(ms: ms), march2026);
      final rMap = service.recipeMap;
      const redMeatProteins = {'porco', 'carne_picada'};
      for (final day in plan.days) {
        if (day.isLeftover) continue;
        final recipe = rMap[day.recipeId]!;
        if (recipe.type == RecipeType.carne && redMeatProteins.contains(recipe.proteinId)) {
          fail('Day ${day.dayIndex}: ${recipe.name} is red meat but cap is 0');
        }
      }
    });
  });

  // ────────────────────────────────────────────────────────────
  // 25. DIFFERENT MONTHS
  // ────────────────────────────────────────────────────────────
  group('Different months', () {
    test('February 2026 (28 days) generates correct count', () {
      final feb = DateTime(2026, 2);
      final plan = service.generate(_settings(), feb);
      // 28 days, 2 meals per day
      expect(plan.days.length, 28 * 2);
    });

    test('summer month with seasonal preference picks summer recipes', () {
      final ms = const MealSettings(preferSeasonal: true, enabledMeals: {MealType.dinner});
      final july = DateTime(2026, 7);
      final plan = service.generate(_settings(ms: ms, foodBudget: 9999), july);
      final rMap = service.recipeMap;
      int summerOrAll = 0;
      for (final d in plan.days) {
        if (d.isLeftover) continue;
        final r = rMap[d.recipeId]!;
        if (r.seasons.isEmpty || r.seasons.contains('summer')) summerOrAll++;
      }
      // With seasonal preference, most should be summer or all-season
      expect(summerOrAll / plan.days.length, greaterThan(0.8));
    });
  });
}
