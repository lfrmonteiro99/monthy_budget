import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/planning_export_envelope.dart';

void main() {
  group('PlanningExportEnvelope', () {
    final validJson = {
      'schemaVersion': 1,
      'exportedAt': '2026-03-15T10:00:00.000',
      'artifactType': 'shopping_list',
      'locale': 'pt',
      'payload': {'items': []},
    };

    test('fromJson parses valid envelope', () {
      final envelope = PlanningExportEnvelope.fromJson(validJson);
      expect(envelope.schemaVersion, 1);
      expect(envelope.artifactType, 'shopping_list');
      expect(envelope.locale, 'pt');
      expect(envelope.payload, {'items': []});
    });

    test('fromJson throws on missing schemaVersion', () {
      final json = Map<String, dynamic>.from(validJson)..remove('schemaVersion');
      expect(() => PlanningExportEnvelope.fromJson(json),
          throwsA(isA<FormatException>()));
    });

    test('fromJson throws on non-int schemaVersion', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['schemaVersion'] = 'one';
      expect(() => PlanningExportEnvelope.fromJson(json),
          throwsA(isA<FormatException>()));
    });

    test('fromJson throws on unsupported schema version', () {
      final json = Map<String, dynamic>.from(validJson)..['schemaVersion'] = 99;
      expect(() => PlanningExportEnvelope.fromJson(json),
          throwsA(isA<FormatException>()));
    });

    test('fromJson throws on missing artifactType', () {
      final json = Map<String, dynamic>.from(validJson)..remove('artifactType');
      expect(() => PlanningExportEnvelope.fromJson(json),
          throwsA(isA<FormatException>()));
    });

    test('fromJson throws on unknown artifactType', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['artifactType'] = 'unknown_type';
      expect(() => PlanningExportEnvelope.fromJson(json),
          throwsA(isA<FormatException>()));
    });

    test('fromJson throws on missing exportedAt', () {
      final json = Map<String, dynamic>.from(validJson)..remove('exportedAt');
      expect(() => PlanningExportEnvelope.fromJson(json),
          throwsA(isA<FormatException>()));
    });

    test('fromJson throws on non-string exportedAt', () {
      final json = Map<String, dynamic>.from(validJson)..['exportedAt'] = 12345;
      expect(() => PlanningExportEnvelope.fromJson(json),
          throwsA(isA<FormatException>()));
    });

    test('fromJson throws on missing payload', () {
      final json = Map<String, dynamic>.from(validJson)..remove('payload');
      expect(() => PlanningExportEnvelope.fromJson(json),
          throwsA(isA<FormatException>()));
    });

    test('fromJson throws on non-map payload', () {
      final json = Map<String, dynamic>.from(validJson)..['payload'] = 'text';
      expect(() => PlanningExportEnvelope.fromJson(json),
          throwsA(isA<FormatException>()));
    });

    test('toJson produces correct output', () {
      final envelope = PlanningExportEnvelope(
        schemaVersion: 1,
        exportedAt: DateTime(2026, 3, 15, 10, 0),
        artifactType: 'meal_plan',
        locale: 'en',
        payload: {'days': [1, 2, 3]},
      );
      final json = envelope.toJson();
      expect(json['schemaVersion'], 1);
      expect(json['artifactType'], 'meal_plan');
      expect(json['locale'], 'en');
      expect(json['payload'], {'days': [1, 2, 3]});
    });

    test('toJson omits null locale', () {
      final envelope = PlanningExportEnvelope(
        schemaVersion: 1,
        exportedAt: DateTime(2026, 3, 15),
        artifactType: 'pantry_snapshot',
        payload: const {},
      );
      final json = envelope.toJson();
      expect(json.containsKey('locale'), false);
    });

    test('roundtrip toJson -> fromJson preserves data', () {
      final original = PlanningExportEnvelope(
        schemaVersion: 1,
        exportedAt: DateTime(2026, 3, 15, 10, 0),
        artifactType: 'freeform_meals',
        locale: 'es',
        payload: {'meals': ['pasta', 'salad']},
      );
      final json = original.toJson();
      final restored = PlanningExportEnvelope.fromJson(json);
      expect(restored.schemaVersion, original.schemaVersion);
      expect(restored.artifactType, original.artifactType);
      expect(restored.locale, original.locale);
    });

    test('validArtifactTypes contains all known types', () {
      expect(PlanningExportEnvelope.validArtifactTypes,
          containsAll(['shopping_list', 'meal_plan', 'pantry_snapshot', 'freeform_meals']));
    });

    test('currentSchemaVersion is 1', () {
      expect(PlanningExportEnvelope.currentSchemaVersion, 1);
    });

    test('all valid artifact types pass fromJson', () {
      for (final type in PlanningExportEnvelope.validArtifactTypes) {
        final json = Map<String, dynamic>.from(validJson)..['artifactType'] = type;
        final envelope = PlanningExportEnvelope.fromJson(json);
        expect(envelope.artifactType, type);
      }
    });
  });

  group('FreeformMeal', () {
    test('constructor with all fields', () {
      const meal = FreeformMeal(
        name: 'Pasta',
        notes: 'Use leftovers',
        dayIndex: 2,
        mealType: 'dinner',
      );
      expect(meal.name, 'Pasta');
      expect(meal.notes, 'Use leftovers');
      expect(meal.dayIndex, 2);
      expect(meal.mealType, 'dinner');
    });

    test('constructor with null notes', () {
      const meal = FreeformMeal(name: 'Salad', dayIndex: 0, mealType: 'lunch');
      expect(meal.notes, isNull);
    });

    test('toJson / fromJson roundtrip', () {
      const original = FreeformMeal(
        name: 'Steak',
        notes: 'Special occasion',
        dayIndex: 5,
        mealType: 'dinner',
      );
      final json = original.toJson();
      final restored = FreeformMeal.fromJson(json);
      expect(restored.name, original.name);
      expect(restored.notes, original.notes);
      expect(restored.dayIndex, original.dayIndex);
      expect(restored.mealType, original.mealType);
    });

    test('toJson omits null notes', () {
      const meal = FreeformMeal(name: 'X', dayIndex: 0, mealType: 'lunch');
      final json = meal.toJson();
      expect(json.containsKey('notes'), false);
    });
  });
}
