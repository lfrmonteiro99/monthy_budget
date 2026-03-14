import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/utils/pantry_matching.dart';

void main() {
  group('resolveActivePantry', () {
    test('merges staples, weekly, and legacy pantry ingredients', () {
      const ms = MealSettings(
        pantryIngredients: ['salt', 'pepper'],
        stapleIngredients: ['olive_oil', 'salt'],
        weeklyPantryIngredients: ['tomato', 'onion'],
      );

      final active = resolveActivePantry(ms);

      expect(active, containsAll(['salt', 'pepper', 'olive_oil', 'tomato', 'onion']));
      // Duplicates are collapsed (salt appears in both)
      expect(active.length, 5);
    });

    test('returns empty set when all lists are empty', () {
      const ms = MealSettings();
      expect(resolveActivePantry(ms), isEmpty);
    });
  });

  group('computePantryCoverage', () {
    final recipe = Recipe(
      id: 'r1',
      name: 'Test Recipe',
      proteinId: 'chicken',
      type: RecipeType.carne,
      complexity: 2,
      prepMinutes: 30,
      servings: 4,
      ingredients: const [
        RecipeIngredient(ingredientId: 'chicken', quantity: 1.0),
        RecipeIngredient(ingredientId: 'rice', quantity: 0.5),
        RecipeIngredient(ingredientId: 'onion', quantity: 0.2),
        RecipeIngredient(ingredientId: 'garlic', quantity: 0.1),
      ],
    );

    test('full coverage when all ingredients in pantry', () {
      final coverage = computePantryCoverage(
        recipe,
        {'chicken', 'rice', 'onion', 'garlic'},
      );

      expect(coverage.coverageRatio, 1.0);
      expect(coverage.matchedIngredients.length, 4);
      expect(coverage.missingIngredients, isEmpty);
    });

    test('partial coverage returns correct ratio', () {
      final coverage = computePantryCoverage(
        recipe,
        {'chicken', 'rice'},
      );

      expect(coverage.coverageRatio, 0.5);
      expect(coverage.matchedIngredients, ['chicken', 'rice']);
      expect(coverage.missingIngredients, ['onion', 'garlic']);
    });

    test('zero coverage when pantry is empty', () {
      final coverage = computePantryCoverage(recipe, {});

      expect(coverage.coverageRatio, 0.0);
      expect(coverage.matchedIngredients, isEmpty);
      expect(coverage.missingIngredients.length, 4);
    });

    test('handles recipe with no ingredients', () {
      final emptyRecipe = Recipe(
        id: 'r2',
        name: 'Empty',
        proteinId: 'none',
        type: RecipeType.carne,
        complexity: 1,
        prepMinutes: 5,
        servings: 1,
        ingredients: const [],
      );

      final coverage = computePantryCoverage(emptyRecipe, {'salt'});
      expect(coverage.coverageRatio, 0.0);
      expect(coverage.matchedIngredients, isEmpty);
      expect(coverage.missingIngredients, isEmpty);
    });
  });

  group('excludePantryFromConsolidated', () {
    test('removes pantry items from consolidated list', () {
      final consolidated = {
        'chicken': 2.0,
        'rice': 1.0,
        'salt': 0.1,
        'onion': 0.3,
      };

      final result = excludePantryFromConsolidated(
        consolidated,
        {'salt', 'onion', 'garlic'},
      );

      expect(result.keys, containsAll(['chicken', 'rice']));
      expect(result.containsKey('salt'), isFalse);
      expect(result.containsKey('onion'), isFalse);
      expect(result.length, 2);
    });

    test('returns same map when pantry is empty', () {
      final consolidated = {'chicken': 2.0, 'rice': 1.0};
      final result = excludePantryFromConsolidated(consolidated, {});
      expect(result, consolidated);
    });

    test('does not modify original map', () {
      final consolidated = {'chicken': 2.0, 'salt': 0.1};
      excludePantryFromConsolidated(consolidated, {'salt'});
      expect(consolidated.containsKey('salt'), isTrue);
    });
  });

  group('generatePantryHints', () {
    final recipes = [
      Recipe(
        id: 'r1',
        name: 'Full Coverage',
        proteinId: 'chicken',
        type: RecipeType.carne,
        complexity: 2,
        prepMinutes: 30,
        servings: 4,
        ingredients: const [
          RecipeIngredient(ingredientId: 'chicken', quantity: 1.0),
          RecipeIngredient(ingredientId: 'rice', quantity: 0.5),
        ],
      ),
      Recipe(
        id: 'r2',
        name: 'High Coverage',
        proteinId: 'fish',
        type: RecipeType.peixe,
        complexity: 2,
        prepMinutes: 20,
        servings: 2,
        ingredients: const [
          RecipeIngredient(ingredientId: 'fish', quantity: 1.0),
          RecipeIngredient(ingredientId: 'rice', quantity: 0.3),
          RecipeIngredient(ingredientId: 'lemon', quantity: 0.1),
          RecipeIngredient(ingredientId: 'salt', quantity: 0.05),
        ],
      ),
    ];

    test('generates hints for fully and highly covered recipes', () {
      final hints = generatePantryHints(
        recipes: recipes,
        pantryIds: {'chicken', 'rice', 'fish', 'salt'},
        ingredientMap: {},
      );

      expect(hints.any((h) => h.contains('fully covered')), isTrue);
      expect(hints.any((h) => h.contains('Average pantry coverage')), isTrue);
    });

    test('returns empty hints when pantry is empty', () {
      final hints = generatePantryHints(
        recipes: recipes,
        pantryIds: {},
        ingredientMap: {},
      );

      expect(hints, isEmpty);
    });
  });

  group('MealSettings pantry serialization', () {
    test('new pantry fields survive toJson/fromJson roundtrip', () {
      final settings = MealSettings(
        stapleIngredients: const ['olive_oil', 'salt'],
        weeklyPantryIngredients: const ['tomato', 'onion'],
        weeklyPantryUpdatedAt: DateTime(2026, 3, 8, 10, 30),
      );

      final decoded = MealSettings.fromJson(settings.toJson());

      expect(decoded.stapleIngredients, ['olive_oil', 'salt']);
      expect(decoded.weeklyPantryIngredients, ['tomato', 'onion']);
      expect(decoded.weeklyPantryUpdatedAt, DateTime(2026, 3, 8, 10, 30));
    });

    test('fromJson defaults new fields safely when missing', () {
      final decoded = MealSettings.fromJson(const {});

      expect(decoded.stapleIngredients, isEmpty);
      expect(decoded.weeklyPantryIngredients, isEmpty);
      expect(decoded.weeklyPantryUpdatedAt, isNull);
    });

    test('copyWith supports clearing weeklyPantryUpdatedAt', () {
      final base = MealSettings(
        weeklyPantryUpdatedAt: DateTime(2026, 3, 8),
      );

      final cleared = base.copyWith(weeklyPantryUpdatedAt: null);
      expect(cleared.weeklyPantryUpdatedAt, isNull);

      final kept = base.copyWith(stapleIngredients: ['x']);
      expect(kept.weeklyPantryUpdatedAt, DateTime(2026, 3, 8));
    });
  });
}
