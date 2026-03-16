import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';

void main() {
  group('Recipe prep time split', () {
    test('parses activeMinutes and passiveMinutes from JSON', () {
      final json = {
        'id': 'test',
        'name': 'Test',
        'proteinId': 'frango',
        'type': 'carne',
        'complexity': 1,
        'prepMinutes': 60,
        'servings': 4,
        'ingredients': <Map<String, dynamic>>[],
        'activeMinutes': 15,
        'passiveMinutes': 45,
      };
      final recipe = Recipe.fromJson(json);
      expect(recipe.activeMinutes, 15);
      expect(recipe.passiveMinutes, 45);
      expect(recipe.prepMinutes, 60);
    });

    test('fallback to prepMinutes when split absent', () {
      final json = {
        'id': 'test',
        'name': 'Test',
        'proteinId': 'frango',
        'type': 'carne',
        'complexity': 1,
        'prepMinutes': 30,
        'servings': 4,
        'ingredients': <Map<String, dynamic>>[],
      };
      final recipe = Recipe.fromJson(json);
      expect(recipe.activeMinutes, isNull);
      expect(recipe.passiveMinutes, isNull);
      expect(recipe.prepMinutes, 30);
    });

    test('toJson includes activeMinutes and passiveMinutes when set', () {
      final recipe = Recipe(
        id: 'test',
        name: 'Test',
        proteinId: 'frango',
        type: RecipeType.carne,
        complexity: 1,
        prepMinutes: 60,
        servings: 4,
        ingredients: [],
        activeMinutes: 15,
        passiveMinutes: 45,
      );
      final json = recipe.toJson();
      expect(json['activeMinutes'], 15);
      expect(json['passiveMinutes'], 45);
      expect(json['prepMinutes'], 60);
    });

    test('toJson omits activeMinutes and passiveMinutes when null', () {
      final recipe = Recipe(
        id: 'test',
        name: 'Test',
        proteinId: 'frango',
        type: RecipeType.carne,
        complexity: 1,
        prepMinutes: 30,
        servings: 4,
        ingredients: [],
      );
      final json = recipe.toJson();
      expect(json.containsKey('activeMinutes'), isFalse);
      expect(json.containsKey('passiveMinutes'), isFalse);
      expect(json['prepMinutes'], 30);
    });

    test('round-trip JSON preserves split values', () {
      final original = Recipe(
        id: 'roundtrip',
        name: 'Round Trip',
        proteinId: 'peixe',
        type: RecipeType.peixe,
        complexity: 2,
        prepMinutes: 50,
        servings: 2,
        ingredients: [],
        activeMinutes: 15,
        passiveMinutes: 35,
      );
      final restored = Recipe.fromJson(original.toJson());
      expect(restored.activeMinutes, original.activeMinutes);
      expect(restored.passiveMinutes, original.passiveMinutes);
      expect(restored.prepMinutes, original.prepMinutes);
    });
  });
}
