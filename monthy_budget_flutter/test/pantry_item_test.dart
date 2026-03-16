import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/pantry_item.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/services/meal_planner_service.dart';
import 'package:monthly_management/utils/unit_converter.dart';

void main() {
  group('PantryItem', () {
    test('serialization round-trip', () {
      final item = PantryItem(
        ingredientId: 'frango',
        quantity: 1.5,
        unit: 'kg',
        lastRestocked: DateTime(2026, 3, 15),
        lowThreshold: 0.5,
      );

      final json = item.toJson();
      final restored = PantryItem.fromJson(json);

      expect(restored.ingredientId, 'frango');
      expect(restored.quantity, 1.5);
      expect(restored.unit, 'kg');
      expect(restored.lastRestocked, DateTime(2026, 3, 15));
      expect(restored.lowThreshold, 0.5);
    });

    test('toJson omits null optional fields', () {
      const item = PantryItem(
        ingredientId: 'batata',
        quantity: 2.0,
        unit: 'kg',
      );

      final json = item.toJson();

      expect(json.containsKey('lastRestocked'), isFalse);
      expect(json.containsKey('lowThreshold'), isFalse);
    });

    test('isLow returns true when at threshold', () {
      const item = PantryItem(
        ingredientId: 'azeite',
        quantity: 0.5,
        unit: 'l',
        lowThreshold: 0.5,
      );

      expect(item.isLow, isTrue);
    });

    test('isLow returns true when below threshold', () {
      const item = PantryItem(
        ingredientId: 'azeite',
        quantity: 0.3,
        unit: 'l',
        lowThreshold: 0.5,
      );

      expect(item.isLow, isTrue);
    });

    test('isLow returns false when above threshold', () {
      const item = PantryItem(
        ingredientId: 'azeite',
        quantity: 1.0,
        unit: 'l',
        lowThreshold: 0.5,
      );

      expect(item.isLow, isFalse);
    });

    test('isLow returns false when no threshold set', () {
      const item = PantryItem(
        ingredientId: 'azeite',
        quantity: 0.1,
        unit: 'l',
      );

      expect(item.isLow, isFalse);
    });

    test('isDepleted returns true at zero', () {
      const item = PantryItem(
        ingredientId: 'sal',
        quantity: 0,
        unit: 'kg',
      );

      expect(item.isDepleted, isTrue);
    });

    test('isDepleted returns false when quantity > 0', () {
      const item = PantryItem(
        ingredientId: 'sal',
        quantity: 0.01,
        unit: 'kg',
      );

      expect(item.isDepleted, isFalse);
    });

    test('copyWith preserves unmodified fields', () {
      final item = PantryItem(
        ingredientId: 'frango',
        quantity: 1.0,
        unit: 'kg',
        lastRestocked: DateTime(2026, 3, 10),
        lowThreshold: 0.5,
      );

      final updated = item.copyWith(quantity: 2.0);

      expect(updated.ingredientId, 'frango');
      expect(updated.quantity, 2.0);
      expect(updated.unit, 'kg');
      expect(updated.lastRestocked, DateTime(2026, 3, 10));
      expect(updated.lowThreshold, 0.5);
    });
  });

  group('UnitConverter', () {
    test('converts kg to g', () {
      expect(UnitConverter.convert(1.0, 'kg', 'g'), 1000.0);
    });

    test('converts g to kg', () {
      expect(UnitConverter.convert(500, 'g', 'kg'), 0.5);
    });

    test('converts l to ml', () {
      expect(UnitConverter.convert(1.0, 'l', 'ml'), 1000.0);
    });

    test('returns null for incompatible units', () {
      expect(UnitConverter.convert(1.0, 'kg', 'ml'), isNull);
    });

    test('returns same value for same unit', () {
      expect(UnitConverter.convert(5.0, 'kg', 'kg'), 5.0);
    });

    test('compatible returns true for same family', () {
      expect(UnitConverter.compatible('kg', 'g'), isTrue);
      expect(UnitConverter.compatible('ml', 'l'), isTrue);
    });

    test('compatible returns false for different families', () {
      expect(UnitConverter.compatible('kg', 'l'), isFalse);
    });

    test('compatible returns true for same unit', () {
      expect(UnitConverter.compatible('kg', 'kg'), isTrue);
    });
  });

  group('consolidatedIngredients with pantryItems', () {
    late MealPlannerService svc;

    setUp(() {
      svc = MealPlannerService();

      final ingredientsJson = jsonEncode([
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
          'id': 'azeite',
          'name': 'Azeite',
          'category': 'gordura',
          'unit': 'l',
          'avgPricePerUnit': 5.00,
          'minPurchaseQty': 0.5,
        },
      ]);

      final recipesJson = jsonEncode([
        {
          'id': 'frango_assado',
          'name': 'Frango Assado',
          'proteinId': 'frango',
          'type': 'carne',
          'complexity': 1,
          'prepMinutes': 15,
          'servings': 4,
          'ingredients': [
            {'ingredientId': 'frango', 'quantity': 1.0},
            {'ingredientId': 'batata', 'quantity': 0.6},
            {'ingredientId': 'azeite', 'quantity': 0.05},
          ],
        },
      ]);

      svc.loadCatalogFromJson(ingredientsJson, recipesJson);
    });

    test('quantity subtraction reduces shopping list', () {
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
          ),
        ],
        totalEstimatedCost: 3.86,
        generatedAt: DateTime(2026, 3, 1),
      );

      // Recipe needs 1kg frango, pantry has 0.5kg -> shopping list gets 0.5kg
      final totals = svc.consolidatedIngredients(
        plan,
        pantryItems: [
          const PantryItem(
            ingredientId: 'frango',
            quantity: 0.5,
            unit: 'kg',
          ),
        ],
      );

      expect(totals['frango'], closeTo(0.5, 0.001));
      // batata and azeite should remain unchanged
      expect(totals['batata'], closeTo(0.6, 0.001));
      expect(totals['azeite'], closeTo(0.05, 0.001));
    });

    test('pantry covers fully removes from list', () {
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
          ),
        ],
        totalEstimatedCost: 3.86,
        generatedAt: DateTime(2026, 3, 1),
      );

      // Recipe needs 1kg frango, pantry has 2kg -> ingredient removed
      final totals = svc.consolidatedIngredients(
        plan,
        pantryItems: [
          const PantryItem(
            ingredientId: 'frango',
            quantity: 2.0,
            unit: 'kg',
          ),
        ],
      );

      expect(totals.containsKey('frango'), isFalse);
    });

    test('unit conversion in pantry subtraction', () {
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
          ),
        ],
        totalEstimatedCost: 3.86,
        generatedAt: DateTime(2026, 3, 1),
      );

      // Recipe needs 1kg frango (unit: kg), pantry has 500g -> 0.5kg available
      final totals = svc.consolidatedIngredients(
        plan,
        pantryItems: [
          const PantryItem(
            ingredientId: 'frango',
            quantity: 500,
            unit: 'g',
          ),
        ],
      );

      // 1.0kg needed - 0.5kg available = 0.5kg remaining
      expect(totals['frango'], closeTo(0.5, 0.001));
    });

    test('incompatible units leaves quantity unchanged', () {
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
          ),
        ],
        totalEstimatedCost: 3.86,
        generatedAt: DateTime(2026, 3, 1),
      );

      // Pantry item has 'un' unit (units) which is incompatible with 'kg'
      // Conversion returns null, so raw quantity is used as-is
      final totals = svc.consolidatedIngredients(
        plan,
        pantryItems: [
          const PantryItem(
            ingredientId: 'frango',
            quantity: 0.3,
            unit: 'un',
          ),
        ],
      );

      // 1.0 - 0.3 = 0.7 (raw subtraction, no conversion possible)
      expect(totals['frango'], closeTo(0.7, 0.001));
    });

    test('pantryItems does not affect ingredients not in plan', () {
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
          ),
        ],
        totalEstimatedCost: 3.86,
        generatedAt: DateTime(2026, 3, 1),
      );

      // Pantry has ingredient 'arroz' which is not in the recipe
      final totals = svc.consolidatedIngredients(
        plan,
        pantryItems: [
          const PantryItem(
            ingredientId: 'arroz',
            quantity: 2.0,
            unit: 'kg',
          ),
        ],
      );

      // All recipe ingredients should remain unchanged
      expect(totals['frango'], closeTo(1.0, 0.001));
      expect(totals['batata'], closeTo(0.6, 0.001));
    });
  });

  group('MealSettings pantryItems migration', () {
    test('fromJson handles missing pantryItems', () {
      final json = {
        'householdSize': 4,
        'enabledMeals': ['lunch', 'dinner'],
        'objective': 'balancedHealth',
      };

      final settings = MealSettings.fromJson(json);
      expect(settings.pantryItems, isEmpty);
    });

    test('pantryItems round-trips through MealSettings JSON', () {
      final settings = MealSettings(
        pantryItems: [
          PantryItem(
            ingredientId: 'frango',
            quantity: 1.5,
            unit: 'kg',
            lastRestocked: DateTime(2026, 3, 15),
            lowThreshold: 0.5,
          ),
          const PantryItem(
            ingredientId: 'azeite',
            quantity: 0.75,
            unit: 'l',
          ),
        ],
      );

      final json = settings.toJson();
      final restored = MealSettings.fromJson(json);

      expect(restored.pantryItems.length, 2);
      expect(restored.pantryItems[0].ingredientId, 'frango');
      expect(restored.pantryItems[0].quantity, 1.5);
      expect(restored.pantryItems[0].unit, 'kg');
      expect(restored.pantryItems[0].lowThreshold, 0.5);
      expect(restored.pantryItems[1].ingredientId, 'azeite');
      expect(restored.pantryItems[1].quantity, 0.75);
      expect(restored.pantryItems[1].unit, 'l');
    });

    test('copyWith updates pantryItems', () {
      const original = MealSettings();
      final updated = original.copyWith(
        pantryItems: [
          const PantryItem(
            ingredientId: 'sal',
            quantity: 1.0,
            unit: 'kg',
          ),
        ],
      );

      expect(updated.pantryItems.length, 1);
      expect(updated.pantryItems[0].ingredientId, 'sal');
      // Original unchanged
      expect(original.pantryItems, isEmpty);
    });
  });
}
