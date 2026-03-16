import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/utils/waste_calculator.dart';

void main() {
  final testIngredients = {
    'frango': const Ingredient(
      id: 'frango',
      name: 'Frango',
      category: IngredientCategory.proteina,
      unit: 'kg',
      avgPricePerUnit: 5.0,
      minPurchaseQty: 1.0,
    ),
    'batata': const Ingredient(
      id: 'batata',
      name: 'Batata',
      category: IngredientCategory.vegetal,
      unit: 'kg',
      avgPricePerUnit: 1.5,
      minPurchaseQty: 1.0,
    ),
    'cebola': const Ingredient(
      id: 'cebola',
      name: 'Cebola',
      category: IngredientCategory.vegetal,
      unit: 'kg',
      avgPricePerUnit: 1.0,
      minPurchaseQty: 0.5,
    ),
  };

  group('WasteCalculator.excessIngredients', () {
    test('detects excess from minPurchaseQty', () {
      // Need 0.3kg frango (minPurchase 1kg) -> buy 1kg -> excess 0.7kg
      final totals = {'frango': 0.3};
      final items =
          WasteCalculator.excessIngredients(totals, testIngredients);
      expect(items.length, 1);
      expect(items[0].ingredientId, 'frango');
      expect(items[0].excessQty, closeTo(0.7, 0.01));
      expect(items[0].estimatedWasteCost, closeTo(3.5, 0.01)); // 0.7 * 5.0
    });

    test('no excess when needed matches purchase exactly', () {
      final totals = {'frango': 1.0}; // exactly 1 minPurchase
      final items =
          WasteCalculator.excessIngredients(totals, testIngredients);
      expect(items, isEmpty);
    });

    test('no excess when needed is exact multiple of minPurchase', () {
      final totals = {'frango': 3.0}; // exactly 3 minPurchases
      final items =
          WasteCalculator.excessIngredients(totals, testIngredients);
      expect(items, isEmpty);
    });

    test('handles multiple ingredients with different excess levels', () {
      final totals = {'frango': 0.3, 'batata': 0.2, 'cebola': 0.5};
      final items =
          WasteCalculator.excessIngredients(totals, testIngredients);
      // frango: excess 0.7, batata: excess 0.8, cebola: 0.5 matches exactly
      expect(items.length, 2);
      // Sorted by cost descending: frango (3.5) > batata (1.2)
      expect(items[0].ingredientId, 'frango');
      expect(items[1].ingredientId, 'batata');
    });

    test('skips ingredients not in ingredient map', () {
      final totals = {'unknown_ingredient': 0.5};
      final items =
          WasteCalculator.excessIngredients(totals, testIngredients);
      expect(items, isEmpty);
    });

    test('skips ingredients with zero minPurchaseQty', () {
      final zeroMinIngredients = {
        'sal': const Ingredient(
          id: 'sal',
          name: 'Sal',
          category: IngredientCategory.condimento,
          unit: 'kg',
          avgPricePerUnit: 0.5,
          minPurchaseQty: 0.0,
        ),
      };
      final totals = {'sal': 0.1};
      final items =
          WasteCalculator.excessIngredients(totals, zeroMinIngredients);
      expect(items, isEmpty);
    });
  });

  group('WasteCalculator.wasteRisk', () {
    test('returns 0 for efficient recipes (exact minPurchaseQty)', () {
      final recipe = Recipe(
        id: 'test',
        name: 'Test',
        proteinId: 'frango',
        type: RecipeType.carne,
        complexity: 1,
        prepMinutes: 15,
        servings: 4,
        ingredients: [
          const RecipeIngredient(ingredientId: 'frango', quantity: 1.0),
        ],
      );
      // 4 servings, 4 people -> scale 1.0, need 1.0kg, buy 1.0kg -> no excess
      final risk = WasteCalculator.wasteRisk(recipe, 4, testIngredients);
      expect(risk, 0.0);
    });

    test('returns positive risk for wasteful recipe', () {
      final recipe = Recipe(
        id: 'test',
        name: 'Test',
        proteinId: 'frango',
        type: RecipeType.carne,
        complexity: 1,
        prepMinutes: 15,
        servings: 4,
        ingredients: [
          const RecipeIngredient(ingredientId: 'frango', quantity: 0.3),
          const RecipeIngredient(ingredientId: 'batata', quantity: 0.2),
        ],
      );
      // 4 servings, 2 people -> scale 0.5
      // frango: need 0.15, buy 1.0 -> excess
      // batata: need 0.1, buy 1.0 -> excess
      final risk = WasteCalculator.wasteRisk(recipe, 2, testIngredients);
      expect(risk, 1.0); // both ingredients have excess -> 2/2 = 1.0
    });

    test('returns 0 for empty recipe', () {
      final recipe = Recipe(
        id: 'test',
        name: 'Test',
        proteinId: 'frango',
        type: RecipeType.carne,
        complexity: 1,
        prepMinutes: 15,
        servings: 4,
        ingredients: const [],
      );
      final risk = WasteCalculator.wasteRisk(recipe, 2, testIngredients);
      expect(risk, 0.0);
    });

    test('clamps to max 1.0', () {
      final recipe = Recipe(
        id: 'test',
        name: 'Test',
        proteinId: 'cebola',
        type: RecipeType.vegetariano,
        complexity: 1,
        prepMinutes: 10,
        servings: 4,
        ingredients: [
          const RecipeIngredient(ingredientId: 'cebola', quantity: 0.1),
        ],
      );
      // 4 servings, 1 person -> scale 0.25, need 0.025, buy 0.5 -> excess
      final risk = WasteCalculator.wasteRisk(recipe, 1, testIngredients);
      expect(risk, lessThanOrEqualTo(1.0));
      expect(risk, greaterThan(0.0));
    });
  });

  group('WasteCalculator.totalWasteCost', () {
    test('sums all waste items', () {
      final totals = {'frango': 0.3, 'batata': 0.2};
      final cost =
          WasteCalculator.totalWasteCost(totals, testIngredients);
      // frango: excess 0.7 * 5.0 = 3.5, batata: excess 0.8 * 1.5 = 1.2
      expect(cost, closeTo(4.7, 0.01));
    });

    test('returns 0 when no waste', () {
      final totals = {'frango': 1.0, 'batata': 2.0};
      final cost =
          WasteCalculator.totalWasteCost(totals, testIngredients);
      expect(cost, 0.0);
    });

    test('returns 0 for empty totals', () {
      final cost =
          WasteCalculator.totalWasteCost(<String, double>{}, testIngredients);
      expect(cost, 0.0);
    });
  });
}
