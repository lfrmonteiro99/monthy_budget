import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/grocery_data.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/services/grocery_service.dart';
import 'package:monthly_management/services/meal_planner_service.dart';

AppSettings _settings({
  double foodBudget = 400,
  MealSettings ms = const MealSettings(),
}) {
  return AppSettings(
    salaries: [
      const SalaryInfo(label: 'S1', enabled: true, titulares: 1),
    ],
    personalInfo: const PersonalInfo(dependentes: 1),
    expenses: [
      ExpenseItem(
        id: 'food',
        label: 'Alimentacao',
        amount: foodBudget,
        category: 'alimentacao',
      ),
    ],
    mealSettings: ms,
  );
}

void main() {
  // ─────────────────────────────────────────────────────────────────
  // GroceryService.extractCurrentPrices
  // ─────────────────────────────────────────────────────────────────
  group('GroceryService.extractCurrentPrices', () {
    test('returns empty map for empty product list', () {
      const data = GroceryData(products: []);
      final prices = GroceryService.extractCurrentPrices(data);
      expect(prices, isEmpty);
    });

    test('maps product names lowercased to prices', () {
      const data = GroceryData(products: [
        GroceryProduct(name: 'Frango', price: 5.50),
        GroceryProduct(name: 'Arroz', price: 1.20),
      ]);
      final prices = GroceryService.extractCurrentPrices(data);
      expect(prices['frango'], 5.50);
      expect(prices['arroz'], 1.20);
    });

    test('keeps cheapest price for duplicate names', () {
      const data = GroceryData(products: [
        GroceryProduct(name: 'Frango', price: 6.00),
        GroceryProduct(name: 'frango', price: 4.50),
      ]);
      final prices = GroceryService.extractCurrentPrices(data);
      expect(prices['frango'], 4.50);
    });

    test('skips products with zero or negative price', () {
      const data = GroceryData(products: [
        GroceryProduct(name: 'Free', price: 0),
        GroceryProduct(name: 'Negative', price: -1.0),
        GroceryProduct(name: 'Valid', price: 2.0),
      ]);
      final prices = GroceryService.extractCurrentPrices(data);
      expect(prices.containsKey('free'), isFalse);
      expect(prices.containsKey('negative'), isFalse);
      expect(prices['valid'], 2.0);
    });

    test('skips products with empty name', () {
      const data = GroceryData(products: [
        GroceryProduct(name: '', price: 3.0),
      ]);
      final prices = GroceryService.extractCurrentPrices(data);
      expect(prices, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // MealPlannerService.isSeasonallyCheap
  // ─────────────────────────────────────────────────────────────────
  group('MealPlannerService.isSeasonallyCheap', () {
    test('returns true when current price is below 80% of average', () {
      // avg = 10.0, 80% threshold = 8.0, current = 7.0 -> cheap
      final result = MealPlannerService.isSeasonallyCheap(
        'frango',
        {'frango': 7.0},
        {'frango': 10.0},
      );
      expect(result, isTrue);
    });

    test('returns false when current price is at 80% of average', () {
      // avg = 10.0, 80% threshold = 8.0, current = 8.0 -> NOT cheap
      final result = MealPlannerService.isSeasonallyCheap(
        'frango',
        {'frango': 8.0},
        {'frango': 10.0},
      );
      expect(result, isFalse);
    });

    test('returns false when current price is above average', () {
      final result = MealPlannerService.isSeasonallyCheap(
        'frango',
        {'frango': 12.0},
        {'frango': 10.0},
      );
      expect(result, isFalse);
    });

    test('returns false when ingredient not in current prices', () {
      final result = MealPlannerService.isSeasonallyCheap(
        'frango',
        {},
        {'frango': 10.0},
      );
      expect(result, isFalse);
    });

    test('returns false when ingredient not in avg prices', () {
      final result = MealPlannerService.isSeasonallyCheap(
        'frango',
        {'frango': 5.0},
        {},
      );
      expect(result, isFalse);
    });

    test('returns false when average price is zero', () {
      final result = MealPlannerService.isSeasonallyCheap(
        'frango',
        {'frango': 5.0},
        {'frango': 0.0},
      );
      expect(result, isFalse);
    });

    test('performs case-insensitive lookup', () {
      final result = MealPlannerService.isSeasonallyCheap(
        'FRANGO',
        {'frango': 7.0},
        {'frango': 10.0},
      );
      expect(result, isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // generate() with groceryPrices integration
  // ─────────────────────────────────────────────────────────────────
  group('Seasonal pricing boost in generate()', () {
    late MealPlannerService service;

    setUpAll(() {
      final ingFile = File('assets/meal_planner/ingredients.json');
      final recFile = File('assets/meal_planner/recipes.json');
      final ingredientsJson = ingFile.readAsStringSync();
      final recipesJson = recFile.readAsStringSync();
      service = MealPlannerService();
      service.loadCatalogFromJson(ingredientsJson, recipesJson);
    });

    final march2026 = DateTime(2026, 3);

    test('generates valid plan when groceryPrices is null', () {
      final plan = service.generate(
        _settings(),
        march2026,
        groceryPrices: null,
      );
      expect(plan.days.isNotEmpty, isTrue);
      expect(plan.days.length, 31 * 2); // lunch + dinner for 31 days
    });

    test('generates valid plan when groceryPrices is empty', () {
      final plan = service.generate(
        _settings(),
        march2026,
        groceryPrices: {},
      );
      expect(plan.days.isNotEmpty, isTrue);
      expect(plan.days.length, 31 * 2);
    });

    test('generates valid plan when groceryPrices has data', () {
      // Build a price map where some ingredients are very cheap
      final cheapPrices = <String, double>{};
      for (final ing in service.ingredients) {
        // Set current price to 50% of average (well below 80% threshold)
        cheapPrices[ing.name.toLowerCase()] = ing.avgPricePerUnit * 0.5;
      }

      final plan = service.generate(
        _settings(foodBudget: 9999),
        march2026,
        groceryPrices: cheapPrices,
      );
      expect(plan.days.isNotEmpty, isTrue);
      expect(plan.days.length, 31 * 2);
      // Every meal should reference a valid recipe
      for (final day in plan.days) {
        expect(service.recipeMap.containsKey(day.recipeId), isTrue);
      }
    });

    test('plan structure unchanged when no ingredient is cheap', () {
      // Set all current prices to 200% of average (nothing is cheap)
      final expensivePrices = <String, double>{};
      for (final ing in service.ingredients) {
        expensivePrices[ing.name.toLowerCase()] = ing.avgPricePerUnit * 2.0;
      }

      final planWithout = service.generate(
        _settings(foodBudget: 9999),
        march2026,
        groceryPrices: null,
      );
      final planWith = service.generate(
        _settings(foodBudget: 9999),
        march2026,
        groceryPrices: expensivePrices,
      );
      // Both should produce valid plans with same day count
      expect(planWith.days.length, planWithout.days.length);
    });
  });
}
