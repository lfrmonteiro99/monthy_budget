import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/services/meal_planner_service.dart';

void main() {
  late MealPlannerService service;

  final ingredients = [
    {
      'id': 'frango',
      'name': 'Frango',
      'category': 'proteina',
      'unit': 'kg',
      'avgPricePerUnit': 3.50,
      'minPurchaseQty': 1.0,
    },
    {
      'id': 'batata',
      'name': 'Batata',
      'category': 'vegetal',
      'unit': 'kg',
      'avgPricePerUnit': 0.60,
      'minPurchaseQty': 1.5,
    },
    {
      'id': 'aveia',
      'name': 'Aveia',
      'category': 'carbo',
      'unit': 'kg',
      'avgPricePerUnit': 1.20,
      'minPurchaseQty': 0.5,
    },
  ];

  final recipes = [
    {
      'id': 'frango_assado',
      'name': 'Frango Assado',
      'proteinId': 'frango',
      'type': 'carne',
      'complexity': 1,
      'prepMinutes': 15,
      'servings': 4,
      'suitableMealTypes': ['lunch', 'dinner'],
      'ingredients': [
        {'ingredientId': 'frango', 'quantity': 1.0},
        {'ingredientId': 'batata', 'quantity': 0.6},
      ],
    },
    {
      'id': 'frango_grelhado',
      'name': 'Frango Grelhado',
      'proteinId': 'frango',
      'type': 'carne',
      'complexity': 1,
      'prepMinutes': 10,
      'servings': 4,
      'suitableMealTypes': ['lunch', 'dinner'],
      'ingredients': [
        {'ingredientId': 'frango', 'quantity': 0.8},
      ],
    },
    {
      'id': 'papas_aveia',
      'name': 'Papas de Aveia',
      'proteinId': 'aveia',
      'type': 'vegetariano',
      'complexity': 1,
      'prepMinutes': 5,
      'servings': 1,
      'suitableMealTypes': ['breakfast'],
      'ingredients': [
        {'ingredientId': 'aveia', 'quantity': 0.1},
      ],
    },
    {
      'id': 'batata_cozida',
      'name': 'Batata Cozida',
      'proteinId': 'batata',
      'type': 'vegetariano',
      'complexity': 1,
      'prepMinutes': 20,
      'servings': 4,
      'suitableMealTypes': ['dinner'],
      'ingredients': [
        {'ingredientId': 'batata', 'quantity': 1.0},
      ],
      'isVegetarian': true,
    },
  ];

  setUp(() {
    service = MealPlannerService();
    service.loadCatalogFromJson(
      jsonEncode(ingredients),
      jsonEncode(recipes),
    );
  });

  group('Cross-meal-type swap', () {
    test('alternativesFor without crossType filters by suitableMealTypes', () {
      // frango_assado has suitableMealTypes: [lunch, dinner]
      // Expected: frango_grelhado (lunch, dinner) and batata_cozida (dinner)
      // Not expected: papas_aveia (breakfast only, no overlap with lunch/dinner)
      final alts = service.alternativesFor('frango_assado', 4);

      final ids = alts.map((r) => r.id).toList();
      expect(ids, contains('frango_grelhado'));
      expect(ids, contains('batata_cozida'));
      expect(ids, isNot(contains('papas_aveia')));
    });

    test('alternativesFor with crossType includes recipes from all meal types', () {
      // With crossType=true, papas_aveia (breakfast only) should be included
      final alts = service.alternativesFor('frango_assado', 4, crossType: true);

      final ids = alts.map((r) => r.id).toList();
      expect(ids, contains('frango_grelhado'));
      expect(ids, contains('batata_cozida'));
      expect(ids, contains('papas_aveia'));
    });

    test('alternativesFor excludes current recipe regardless of crossType', () {
      final altsSame = service.alternativesFor('frango_assado', 4);
      final altsCross = service.alternativesFor('frango_assado', 4, crossType: true);

      expect(altsSame.any((r) => r.id == 'frango_assado'), isFalse);
      expect(altsCross.any((r) => r.id == 'frango_assado'), isFalse);
    });

    test('alternativesFor respects dietary filters with crossType', () {
      final ms = MealSettings(glutenFree: true);
      // papas_aveia is not gluten-free by default (glutenFree defaults to false)
      final alts = service.alternativesFor('frango_assado', 4, ms: ms, crossType: true);

      final ids = alts.map((r) => r.id).toList();
      // papas_aveia has glutenFree=false (default), should be excluded
      expect(ids, isNot(contains('papas_aveia')));
    });

    test('alternativesFor for breakfast-only recipe returns no same-type when no other breakfast exists', () {
      // papas_aveia is the only breakfast recipe
      final alts = service.alternativesFor('papas_aveia', 4);

      // No other recipes have 'breakfast' in suitableMealTypes
      expect(alts, isEmpty);
    });

    test('alternativesFor for breakfast-only recipe with crossType returns other recipes', () {
      final alts = service.alternativesFor('papas_aveia', 4, crossType: true);

      expect(alts.length, 3); // frango_assado, frango_grelhado, batata_cozida
    });

    test('swapDay with newMealType updates the meal type', () {
      final plan = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 4,
        monthlyBudget: 300,
        days: [
          const MealDay(
            dayIndex: 1,
            recipeId: 'frango_assado',
            costEstimate: 3.86,
            mealType: MealType.lunch,
          ),
        ],
        totalEstimatedCost: 3.86,
        generatedAt: DateTime(2026, 3, 1),
      );

      final updated = service.swapDay(
        plan, 1, MealType.lunch, 'papas_aveia',
        newMealType: MealType.breakfast,
      );

      expect(updated.days.first.recipeId, 'papas_aveia');
      expect(updated.days.first.mealType, MealType.breakfast);
    });

    test('swapDay without newMealType preserves original meal type', () {
      final plan = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 4,
        monthlyBudget: 300,
        days: [
          const MealDay(
            dayIndex: 1,
            recipeId: 'frango_assado',
            costEstimate: 3.86,
            mealType: MealType.dinner,
          ),
        ],
        totalEstimatedCost: 3.86,
        generatedAt: DateTime(2026, 3, 1),
      );

      final updated = service.swapDay(plan, 1, MealType.dinner, 'frango_grelhado');

      expect(updated.days.first.recipeId, 'frango_grelhado');
      expect(updated.days.first.mealType, MealType.dinner);
    });
  });
}
