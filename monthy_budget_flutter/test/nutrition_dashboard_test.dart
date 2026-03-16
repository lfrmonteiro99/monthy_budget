import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/widgets/nutrition_dashboard_card.dart';

Recipe _makeRecipe({
  required String id,
  String proteinId = 'frango',
  int servings = 4,
  NutritionInfo? nutrition,
}) {
  return Recipe(
    id: id,
    name: 'Recipe $id',
    proteinId: proteinId,
    type: RecipeType.carne,
    complexity: 1,
    prepMinutes: 30,
    servings: servings,
    ingredients: [],
    nutrition: nutrition,
  );
}

MealDay _makeMealDay({
  required int dayIndex,
  required String recipeId,
  bool isLeftover = false,
  MealKind mealKind = MealKind.recipe,
  MealType mealType = MealType.dinner,
}) {
  return MealDay(
    dayIndex: dayIndex,
    recipeId: recipeId,
    isLeftover: isLeftover,
    costEstimate: 5.0,
    mealKind: mealKind,
    mealType: mealType,
  );
}

void main() {
  group('computeWeekNutritionStats', () {
    test('returns null when no days have nutrition data', () {
      final recipes = {
        'r1': _makeRecipe(id: 'r1', nutrition: null),
      };
      final days = [_makeMealDay(dayIndex: 1, recipeId: 'r1')];

      final stats = computeWeekNutritionStats(
        weekDays: days,
        recipeMap: recipes,
        nPessoas: 2,
      );

      expect(stats, isNull);
    });

    test('returns null when all days are freeform or leftover', () {
      final recipes = {
        'r1': _makeRecipe(
          id: 'r1',
          nutrition: const NutritionInfo(
            kcal: 800, proteinG: 40, carbsG: 60, fatG: 20, fiberG: 8, sodiumMg: 500,
          ),
        ),
      };
      final days = [
        _makeMealDay(dayIndex: 1, recipeId: 'r1', isLeftover: true),
        _makeMealDay(dayIndex: 2, recipeId: '', mealKind: MealKind.freeform),
      ];

      final stats = computeWeekNutritionStats(
        weekDays: days,
        recipeMap: recipes,
        nPessoas: 2,
      );

      expect(stats, isNull);
    });

    test('calculates daily averages correctly for single day, single meal', () {
      final nutrition = const NutritionInfo(
        kcal: 800, proteinG: 40, carbsG: 60, fatG: 20, fiberG: 8, sodiumMg: 500,
      );
      final recipes = {'r1': _makeRecipe(id: 'r1', nutrition: nutrition)};
      final days = [_makeMealDay(dayIndex: 1, recipeId: 'r1')];

      final stats = computeWeekNutritionStats(
        weekDays: days,
        recipeMap: recipes,
        nPessoas: 2,
      );

      expect(stats, isNotNull);
      expect(stats!.daysCount, 1);
      // 800 kcal / 2 people = 400 per person per day
      expect(stats.avgKcal, 400.0);
      expect(stats.avgProteinG, 20.0);
      expect(stats.avgCarbsG, 30.0);
      expect(stats.avgFatG, 10.0);
      expect(stats.avgFiberG, 4.0);
    });

    test('averages across multiple days', () {
      final n1 = const NutritionInfo(
        kcal: 800, proteinG: 40, carbsG: 60, fatG: 20, fiberG: 8, sodiumMg: 500,
      );
      final n2 = const NutritionInfo(
        kcal: 600, proteinG: 30, carbsG: 50, fatG: 15, fiberG: 6, sodiumMg: 400,
      );
      final recipes = {
        'r1': _makeRecipe(id: 'r1', nutrition: n1),
        'r2': _makeRecipe(id: 'r2', proteinId: 'salmao', nutrition: n2),
      };
      final days = [
        _makeMealDay(dayIndex: 1, recipeId: 'r1'),
        _makeMealDay(dayIndex: 2, recipeId: 'r2'),
      ];

      final stats = computeWeekNutritionStats(
        weekDays: days,
        recipeMap: recipes,
        nPessoas: 1,
      );

      expect(stats, isNotNull);
      expect(stats!.daysCount, 2);
      // Day 1: 800 kcal, Day 2: 600 kcal, avg = 700
      expect(stats.avgKcal, 700.0);
      expect(stats.avgProteinG, 35.0);
    });

    test('sums multiple meals within same day then averages across days', () {
      final n1 = const NutritionInfo(
        kcal: 400, proteinG: 20, carbsG: 30, fatG: 10, fiberG: 4, sodiumMg: 200,
      );
      final n2 = const NutritionInfo(
        kcal: 600, proteinG: 30, carbsG: 50, fatG: 15, fiberG: 6, sodiumMg: 300,
      );
      final recipes = {
        'r1': _makeRecipe(id: 'r1', nutrition: n1),
        'r2': _makeRecipe(id: 'r2', nutrition: n2),
      };
      // Two meals on the same day
      final days = [
        _makeMealDay(dayIndex: 1, recipeId: 'r1', mealType: MealType.lunch),
        _makeMealDay(dayIndex: 1, recipeId: 'r2', mealType: MealType.dinner),
      ];

      final stats = computeWeekNutritionStats(
        weekDays: days,
        recipeMap: recipes,
        nPessoas: 1,
      );

      expect(stats, isNotNull);
      expect(stats!.daysCount, 1);
      // One day total: 400 + 600 = 1000 kcal, avg for 1 day = 1000
      expect(stats.avgKcal, 1000.0);
      expect(stats.avgProteinG, 50.0);
    });

    test('skips recipes with null nutrition but counts day if others have it', () {
      final nutrition = const NutritionInfo(
        kcal: 800, proteinG: 40, carbsG: 60, fatG: 20, fiberG: 8, sodiumMg: 500,
      );
      final recipes = {
        'r1': _makeRecipe(id: 'r1', nutrition: nutrition),
        'r2': _makeRecipe(id: 'r2', nutrition: null),
      };
      final days = [
        _makeMealDay(dayIndex: 1, recipeId: 'r1', mealType: MealType.lunch),
        _makeMealDay(dayIndex: 1, recipeId: 'r2', mealType: MealType.dinner),
      ];

      final stats = computeWeekNutritionStats(
        weekDays: days,
        recipeMap: recipes,
        nPessoas: 2,
      );

      expect(stats, isNotNull);
      expect(stats!.daysCount, 1);
      expect(stats.avgKcal, 400.0); // 800 / 2 people
    });

    test('skips leftover and freeform meals', () {
      final nutrition = const NutritionInfo(
        kcal: 800, proteinG: 40, carbsG: 60, fatG: 20, fiberG: 8, sodiumMg: 500,
      );
      final recipes = {
        'r1': _makeRecipe(id: 'r1', nutrition: nutrition),
      };
      final days = [
        _makeMealDay(dayIndex: 1, recipeId: 'r1'),
        _makeMealDay(dayIndex: 1, recipeId: 'r1', isLeftover: true),
        _makeMealDay(dayIndex: 2, recipeId: '', mealKind: MealKind.freeform),
      ];

      final stats = computeWeekNutritionStats(
        weekDays: days,
        recipeMap: recipes,
        nPessoas: 1,
      );

      expect(stats, isNotNull);
      expect(stats!.daysCount, 1);
      // Only day 1 non-leftover counts: 800 kcal / 1 person
      expect(stats.avgKcal, 800.0);
    });

    test('tracks top protein sources correctly', () {
      final nutrition = const NutritionInfo(
        kcal: 500, proteinG: 25, carbsG: 40, fatG: 15, fiberG: 5, sodiumMg: 300,
      );
      final recipes = {
        'r1': _makeRecipe(id: 'r1', proteinId: 'frango', nutrition: nutrition),
        'r2': _makeRecipe(id: 'r2', proteinId: 'salmao', nutrition: nutrition),
        'r3': _makeRecipe(id: 'r3', proteinId: 'frango', nutrition: nutrition),
      };
      final days = [
        _makeMealDay(dayIndex: 1, recipeId: 'r1'),
        _makeMealDay(dayIndex: 2, recipeId: 'r2'),
        _makeMealDay(dayIndex: 3, recipeId: 'r3'),
      ];

      final stats = computeWeekNutritionStats(
        weekDays: days,
        recipeMap: recipes,
        nPessoas: 1,
      );

      expect(stats, isNotNull);
      expect(stats!.topProteins['frango'], 2);
      expect(stats.topProteins['salmao'], 1);
      // First entry should be frango (most used)
      expect(stats.topProteins.entries.first.key, 'frango');
    });

    test('macro percentages sum close to 100', () {
      final nutrition = const NutritionInfo(
        kcal: 600, proteinG: 30, carbsG: 60, fatG: 10, fiberG: 5, sodiumMg: 300,
      );
      final recipes = {'r1': _makeRecipe(id: 'r1', nutrition: nutrition)};
      final days = [_makeMealDay(dayIndex: 1, recipeId: 'r1')];

      final stats = computeWeekNutritionStats(
        weekDays: days,
        recipeMap: recipes,
        nPessoas: 1,
      );

      expect(stats, isNotNull);
      final totalPct = stats!.proteinPct + stats.carbsPct + stats.fatPct;
      // Due to rounding, total should be within 1 of 100
      expect(totalPct, inInclusiveRange(99, 101));
      // protein: 30/100 = 30%, carbs: 60/100 = 60%, fat: 10/100 = 10%
      expect(stats.proteinPct, 30);
      expect(stats.carbsPct, 60);
      expect(stats.fatPct, 10);
    });

    test('handles nPessoas of zero gracefully (defaults to 1)', () {
      final nutrition = const NutritionInfo(
        kcal: 800, proteinG: 40, carbsG: 60, fatG: 20, fiberG: 8, sodiumMg: 500,
      );
      final recipes = {'r1': _makeRecipe(id: 'r1', nutrition: nutrition)};
      final days = [_makeMealDay(dayIndex: 1, recipeId: 'r1')];

      final stats = computeWeekNutritionStats(
        weekDays: days,
        recipeMap: recipes,
        nPessoas: 0,
      );

      expect(stats, isNotNull);
      expect(stats!.avgKcal, 800.0); // Falls back to dividing by 1
    });
  });
}
