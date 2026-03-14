import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/models/planning_export_envelope.dart';
import 'package:monthly_management/models/shopping_item.dart';
import 'package:monthly_management/services/planning_interchange_service.dart';

void main() {
  late PlanningInterchangeService service;

  setUp(() {
    service = PlanningInterchangeService();
  });

  group('PlanningExportEnvelope', () {
    test('rejects future schema version', () {
      final json = {
        'schemaVersion': 999,
        'exportedAt': DateTime.now().toIso8601String(),
        'artifactType': 'shopping_list',
        'payload': <String, dynamic>{},
      };
      expect(
        () => PlanningExportEnvelope.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects missing schemaVersion', () {
      final json = {
        'exportedAt': DateTime.now().toIso8601String(),
        'artifactType': 'shopping_list',
        'payload': <String, dynamic>{},
      };
      expect(
        () => PlanningExportEnvelope.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects unknown artifactType', () {
      final json = {
        'schemaVersion': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'artifactType': 'unknown_type',
        'payload': <String, dynamic>{},
      };
      expect(
        () => PlanningExportEnvelope.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects missing payload', () {
      final json = {
        'schemaVersion': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'artifactType': 'shopping_list',
      };
      expect(
        () => PlanningExportEnvelope.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('round-trips valid envelope', () {
      final original = PlanningExportEnvelope(
        schemaVersion: 1,
        exportedAt: DateTime.utc(2026, 3, 8),
        artifactType: PlanningExportEnvelope.typeShoppingList,
        locale: 'pt',
        payload: {'items': []},
      );
      final json = original.toJson();
      final decoded = PlanningExportEnvelope.fromJson(json);
      expect(decoded.schemaVersion, 1);
      expect(decoded.artifactType, PlanningExportEnvelope.typeShoppingList);
      expect(decoded.locale, 'pt');
      expect(decoded.payload, {'items': []});
    });
  });

  group('Shopping list CSV roundtrip', () {
    test('export and import preserves items', () {
      final items = [
        ShoppingItem(productName: 'Milk', store: 'Lidl', price: 1.29),
        ShoppingItem(
          productName: 'Bread',
          store: 'Pingo Doce',
          price: 0.89,
          unitPrice: '0.89/un',
          checked: true,
        ),
      ];

      final csv = service.exportShoppingListCsv(items);
      final imported = service.importShoppingListCsv(csv);

      expect(imported.length, 2);
      expect(imported[0].productName, 'Milk');
      expect(imported[0].store, 'Lidl');
      expect(imported[0].price, 1.29);
      expect(imported[0].checked, false);
      expect(imported[1].productName, 'Bread');
      expect(imported[1].unitPrice, '0.89/un');
      expect(imported[1].checked, true);
    });

    test('empty CSV returns empty list', () {
      final imported = service.importShoppingListCsv('');
      expect(imported, isEmpty);
    });
  });

  group('Shopping list JSON roundtrip', () {
    test('export and import preserves items', () {
      final items = [
        ShoppingItem(productName: 'Eggs', store: 'Continente', price: 2.49),
      ];

      final json = service.exportShoppingListJson(items, locale: 'en');
      final imported = service.importShoppingListJson(json);

      expect(imported.length, 1);
      expect(imported[0].productName, 'Eggs');
      expect(imported[0].store, 'Continente');
      expect(imported[0].price, 2.49);
    });

    test('rejects wrong artifactType', () {
      final envelope = PlanningExportEnvelope(
        schemaVersion: 1,
        exportedAt: DateTime.now(),
        artifactType: PlanningExportEnvelope.typeMealPlan,
        payload: {'month': 3},
      );
      final jsonStr = jsonEncode(envelope.toJson());
      expect(
        () => service.importShoppingListJson(jsonStr),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Meal plan JSON roundtrip', () {
    test('export and import preserves plan', () {
      final plan = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 4,
        monthlyBudget: 400.0,
        days: [
          const MealDay(dayIndex: 0, recipeId: 'r1', costEstimate: 5.0),
          const MealDay(dayIndex: 1, recipeId: 'r2', costEstimate: 6.0),
        ],
        totalEstimatedCost: 11.0,
        generatedAt: DateTime.utc(2026, 3, 1),
      );

      final json = service.exportMealPlanJson(plan, locale: 'pt');
      final imported = service.importMealPlanJson(json);

      expect(imported.month, 3);
      expect(imported.year, 2026);
      expect(imported.nPessoas, 4);
      expect(imported.days.length, 2);
      expect(imported.days[0].recipeId, 'r1');
      expect(imported.totalEstimatedCost, 11.0);
    });

    test('rejects wrong artifactType', () {
      final envelope = PlanningExportEnvelope(
        schemaVersion: 1,
        exportedAt: DateTime.now(),
        artifactType: PlanningExportEnvelope.typeShoppingList,
        payload: {'items': []},
      );
      final jsonStr = jsonEncode(envelope.toJson());
      expect(
        () => service.importMealPlanJson(jsonStr),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Pantry snapshot JSON roundtrip', () {
    test('export and import preserves ingredients', () {
      final ingredients = ['salt', 'pepper', 'olive_oil'];

      final json = service.exportPantrySnapshotJson(ingredients);
      final imported = service.importPantrySnapshotJson(json);

      expect(imported, ['salt', 'pepper', 'olive_oil']);
    });
  });

  group('Freeform meals JSON roundtrip', () {
    test('export and import preserves meals', () {
      final meals = [
        const FreeformMeal(
          name: 'Leftover pasta',
          notes: 'From yesterday',
          dayIndex: 3,
          mealType: 'lunch',
        ),
        const FreeformMeal(
          name: 'Eat out',
          dayIndex: 5,
          mealType: 'dinner',
        ),
      ];

      final json = service.exportFreeformMealsJson(meals, locale: 'en');
      final imported = service.importFreeformMealsJson(json);

      expect(imported.length, 2);
      expect(imported[0].name, 'Leftover pasta');
      expect(imported[0].notes, 'From yesterday');
      expect(imported[0].dayIndex, 3);
      expect(imported[1].name, 'Eat out');
      expect(imported[1].notes, isNull);
    });
  });

  group('Invalid import error handling', () {
    test('malformed JSON throws FormatException', () {
      expect(
        () => service.importShoppingListJson('not json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('missing envelope fields throws FormatException', () {
      expect(
        () => service.importMealPlanJson('{"foo": "bar"}'),
        throwsA(isA<FormatException>()),
      );
    });

    test('null payload throws FormatException', () {
      final badJson = jsonEncode({
        'schemaVersion': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'artifactType': 'shopping_list',
        'payload': null,
      });
      expect(
        () => service.importShoppingListJson(badJson),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
