import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/services/meal_planner_service.dart';

void main() {
  group('MealDay backward-compatible deserialization', () {
    test('legacy JSON without mealKind defaults to recipe', () {
      final json = {
        'dayIndex': 1,
        'recipeId': 'frango_assado',
        'isLeftover': false,
        'costEstimate': 3.86,
        'mealType': 'dinner',
        'feedback': 'none',
      };
      final day = MealDay.fromJson(json);
      expect(day.mealKind, MealKind.recipe);
      expect(day.recipeId, 'frango_assado');
      expect(day.isFreeform, false);
      expect(day.freeformTitle, isNull);
      expect(day.freeformTags, isEmpty);
      expect(day.freeformShoppingItems, isEmpty);
    });

    test('legacy JSON without recipeId still defaults to recipe', () {
      final json = {
        'dayIndex': 2,
        'costEstimate': 0,
        'mealType': 'lunch',
      };
      final day = MealDay.fromJson(json);
      expect(day.mealKind, MealKind.recipe);
      expect(day.recipeId, '');
    });

    test('freeform JSON round-trips correctly', () {
      final original = MealDay(
        dayIndex: 5,
        mealKind: MealKind.freeform,
        costEstimate: 8.50,
        mealType: MealType.dinner,
        freeformTitle: 'Leftover pasta',
        freeformNote: 'From yesterday',
        freeformEstimatedCost: 8.50,
        freeformTags: ['leftovers', 'quick_meal'],
        freeformShoppingItems: [
          FreeformMealItem(
            name: 'Parmesan',
            quantity: 100,
            unit: 'g',
            estimatedPrice: 2.50,
            store: 'Lidl',
          ),
        ],
      );

      final json = original.toJson();
      final restored = MealDay.fromJson(json);

      expect(restored.mealKind, MealKind.freeform);
      expect(restored.isFreeform, true);
      expect(restored.freeformTitle, 'Leftover pasta');
      expect(restored.freeformNote, 'From yesterday');
      expect(restored.freeformEstimatedCost, 8.50);
      expect(restored.freeformTags, ['leftovers', 'quick_meal']);
      expect(restored.freeformShoppingItems.length, 1);
      expect(restored.freeformShoppingItems[0].name, 'Parmesan');
      expect(restored.freeformShoppingItems[0].quantity, 100);
      expect(restored.freeformShoppingItems[0].unit, 'g');
      expect(restored.freeformShoppingItems[0].estimatedPrice, 2.50);
      expect(restored.freeformShoppingItems[0].store, 'Lidl');
    });

    test('mealKind=recipe round-trips correctly', () {
      final original = MealDay(
        dayIndex: 3,
        mealKind: MealKind.recipe,
        recipeId: 'bacalhau_natas',
        costEstimate: 5.20,
        mealType: MealType.lunch,
      );

      final json = original.toJson();
      final restored = MealDay.fromJson(json);

      expect(restored.mealKind, MealKind.recipe);
      expect(restored.recipeId, 'bacalhau_natas');
      expect(restored.isFreeform, false);
    });

    test('full MealPlan with mixed recipe and freeform round-trips', () {
      final plan = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 4,
        monthlyBudget: 500,
        days: [
          MealDay(
            dayIndex: 1,
            mealKind: MealKind.recipe,
            recipeId: 'frango_assado',
            costEstimate: 3.86,
          ),
          MealDay(
            dayIndex: 2,
            mealKind: MealKind.freeform,
            costEstimate: 10.0,
            freeformTitle: 'Pizza takeout',
            freeformEstimatedCost: 10.0,
            freeformTags: ['takeout'],
          ),
        ],
        totalEstimatedCost: 13.86,
        generatedAt: DateTime(2026, 3, 1),
      );

      final jsonStr = plan.toJsonString();
      final restored = MealPlan.fromJsonString(jsonStr);

      expect(restored.days.length, 2);
      expect(restored.days[0].mealKind, MealKind.recipe);
      expect(restored.days[1].mealKind, MealKind.freeform);
      expect(restored.days[1].freeformTitle, 'Pizza takeout');
    });
  });

  group('FreeformMealItem serialization', () {
    test('minimal item round-trips', () {
      final item = FreeformMealItem(name: 'Bread');
      final json = item.toJson();
      final restored = FreeformMealItem.fromJson(json);
      expect(restored.name, 'Bread');
      expect(restored.quantity, isNull);
      expect(restored.unit, isNull);
      expect(restored.estimatedPrice, isNull);
      expect(restored.store, isNull);
    });

    test('full item round-trips', () {
      final item = FreeformMealItem(
        name: 'Cheese',
        quantity: 200,
        unit: 'g',
        estimatedPrice: 3.99,
        store: 'Continente',
      );
      final json = item.toJson();
      final restored = FreeformMealItem.fromJson(json);
      expect(restored.name, 'Cheese');
      expect(restored.quantity, 200);
      expect(restored.unit, 'g');
      expect(restored.estimatedPrice, 3.99);
      expect(restored.store, 'Continente');
    });
  });

  group('MealDay.copyWith for freeform', () {
    test('preserves freeform fields', () {
      final day = MealDay(
        dayIndex: 1,
        mealKind: MealKind.freeform,
        costEstimate: 5.0,
        freeformTitle: 'Test',
        freeformTags: ['leftovers'],
      );
      final copy = day.copyWith(costEstimate: 7.0);
      expect(copy.mealKind, MealKind.freeform);
      expect(copy.freeformTitle, 'Test');
      expect(copy.freeformTags, ['leftovers']);
      expect(copy.costEstimate, 7.0);
    });

    test('can override freeform fields', () {
      final day = MealDay(
        dayIndex: 1,
        mealKind: MealKind.freeform,
        costEstimate: 5.0,
        freeformTitle: 'Old title',
      );
      final copy = day.copyWith(freeformTitle: 'New title');
      expect(copy.freeformTitle, 'New title');
    });
  });

  group('freeform cost in plan summary', () {
    test('totalEstimatedCost includes freeform costEstimate', () {
      final days = [
        MealDay(
          dayIndex: 1,
          mealKind: MealKind.recipe,
          recipeId: 'r1',
          costEstimate: 5.0,
        ),
        MealDay(
          dayIndex: 2,
          mealKind: MealKind.freeform,
          costEstimate: 12.0,
          freeformTitle: 'Takeout',
          freeformEstimatedCost: 12.0,
        ),
      ];

      final plan = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 4,
        monthlyBudget: 500,
        days: days,
        totalEstimatedCost: 17.0,
        generatedAt: DateTime(2026, 3, 1),
      );

      final updated = plan.copyWithDays(days);
      expect(updated.totalEstimatedCost, 17.0);
    });

    test('copyWithDays recalculates total including freeform', () {
      final plan = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 4,
        monthlyBudget: 500,
        days: [
          MealDay(dayIndex: 1, recipeId: 'r1', costEstimate: 5.0),
        ],
        totalEstimatedCost: 5.0,
        generatedAt: DateTime(2026, 3, 1),
      );

      final newDays = [
        ...plan.days,
        MealDay(
          dayIndex: 2,
          mealKind: MealKind.freeform,
          costEstimate: 8.0,
          freeformTitle: 'Pizza',
        ),
      ];

      final updated = plan.copyWithDays(newDays);
      expect(updated.totalEstimatedCost, 13.0);
    });
  });

  group('freeform shopping items merged in service', () {
    final service = MealPlannerService();

    final testIngredients = [
      Ingredient(
        id: 'frango',
        name: 'Frango',
        category: IngredientCategory.proteina,
        unit: 'kg',
        avgPricePerUnit: 3.50,
        minPurchaseQty: 1.0,
      ),
      Ingredient(
        id: 'batata',
        name: 'Batata',
        category: IngredientCategory.vegetal,
        unit: 'kg',
        avgPricePerUnit: 0.60,
        minPurchaseQty: 1.5,
      ),
    ];

    final testRecipes = [
      Recipe(
        id: 'frango_assado',
        name: 'Frango Assado',
        proteinId: 'frango',
        type: RecipeType.carne,
        complexity: 1,
        prepMinutes: 15,
        servings: 4,
        ingredients: [
          RecipeIngredient(ingredientId: 'frango', quantity: 1.0),
          RecipeIngredient(ingredientId: 'batata', quantity: 0.6),
        ],
      ),
    ];

    setUp(() {
      service.loadCatalogFromJson(
        jsonEncode(testIngredients.map((i) => {
          'id': i.id,
          'name': i.name,
          'category': i.category.name,
          'unit': i.unit,
          'avgPricePerUnit': i.avgPricePerUnit,
          'minPurchaseQty': i.minPurchaseQty,
        }).toList()),
        jsonEncode(testRecipes.map((r) => r.toJson()).toList()),
      );
    });

    test('consolidatedIngredients excludes freeform days', () {
      final plan = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 4,
        monthlyBudget: 500,
        days: [
          MealDay(dayIndex: 1, recipeId: 'frango_assado', costEstimate: 3.86),
          MealDay(
            dayIndex: 2,
            mealKind: MealKind.freeform,
            costEstimate: 10.0,
            freeformTitle: 'Takeout',
            freeformShoppingItems: [
              FreeformMealItem(name: 'Pizza dough', estimatedPrice: 3.0),
            ],
          ),
        ],
        totalEstimatedCost: 13.86,
        generatedAt: DateTime(2026, 3, 1),
      );

      final totals = service.consolidatedIngredients(plan);
      // Should only contain recipe ingredients, not freeform
      expect(totals.containsKey('frango'), true);
      expect(totals.containsKey('batata'), true);
      expect(totals.length, 2);
    });

    test('freeformShoppingItems returns items from freeform days only', () {
      final plan = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 4,
        monthlyBudget: 500,
        days: [
          MealDay(dayIndex: 1, recipeId: 'frango_assado', costEstimate: 3.86),
          MealDay(
            dayIndex: 2,
            mealKind: MealKind.freeform,
            costEstimate: 10.0,
            freeformTitle: 'Takeout',
            freeformShoppingItems: [
              FreeformMealItem(name: 'Pizza dough', estimatedPrice: 3.0),
              FreeformMealItem(name: 'Mozzarella', quantity: 200, unit: 'g'),
            ],
          ),
          MealDay(
            dayIndex: 3,
            mealKind: MealKind.freeform,
            costEstimate: 0,
            freeformTitle: 'Leftovers',
          ),
        ],
        totalEstimatedCost: 13.86,
        generatedAt: DateTime(2026, 3, 1),
      );

      final items = service.freeformShoppingItems(plan);
      expect(items.length, 2);
      expect(items[0].name, 'Pizza dough');
      expect(items[1].name, 'Mozzarella');
    });

    test('freeformShoppingItemsForWeek filters by week days', () {
      final day1 = MealDay(
        dayIndex: 1,
        mealKind: MealKind.freeform,
        costEstimate: 5.0,
        freeformTitle: 'Week 1 meal',
        freeformShoppingItems: [
          FreeformMealItem(name: 'Item A'),
        ],
      );
      final day8 = MealDay(
        dayIndex: 8,
        mealKind: MealKind.freeform,
        costEstimate: 5.0,
        freeformTitle: 'Week 2 meal',
        freeformShoppingItems: [
          FreeformMealItem(name: 'Item B'),
        ],
      );

      final plan = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 4,
        monthlyBudget: 500,
        days: [day1, day8],
        totalEstimatedCost: 10.0,
        generatedAt: DateTime(2026, 3, 1),
      );

      // Week 1 only
      final week1Items = service.freeformShoppingItemsForWeek(plan, [day1]);
      expect(week1Items.length, 1);
      expect(week1Items[0].name, 'Item A');

      // Week 2 only
      final week2Items = service.freeformShoppingItemsForWeek(plan, [day8]);
      expect(week2Items.length, 1);
      expect(week2Items[0].name, 'Item B');
    });
  });

  group('MealDay.displayTitle', () {
    test('returns freeformTitle for freeform meals', () {
      final day = MealDay(
        dayIndex: 1,
        mealKind: MealKind.freeform,
        costEstimate: 0,
        freeformTitle: 'My Meal',
      );
      expect(day.displayTitle, 'My Meal');
    });

    test('returns empty string for recipe meals', () {
      final day = MealDay(
        dayIndex: 1,
        recipeId: 'some_recipe',
        costEstimate: 5.0,
      );
      expect(day.displayTitle, '');
    });
  });

  group('MealKind enum', () {
    test('has recipe and freeform values', () {
      expect(MealKind.values.length, 2);
      expect(MealKind.values.contains(MealKind.recipe), true);
      expect(MealKind.values.contains(MealKind.freeform), true);
    });
  });
}
