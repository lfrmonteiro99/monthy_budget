import 'dart:convert';

import 'package:csv/csv.dart';

import '../models/meal_planner.dart';
import '../models/planning_export_envelope.dart';
import '../models/shopping_item.dart';
import 'export_service.dart';

/// Service responsible for serializing, parsing, and normalizing
/// planning artifacts (shopping lists, meal plans, pantry snapshots,
/// freeform meals) for import/export.
///
/// Reuses [ExportService] for temp-file writing.
class PlanningInterchangeService {
  final ExportService _exportService;

  PlanningInterchangeService({ExportService? exportService})
      : _exportService = exportService ?? ExportService();

  // ---------------------------------------------------------------------------
  // Export helpers
  // ---------------------------------------------------------------------------

  /// Wraps a payload in a [PlanningExportEnvelope] with current timestamp.
  PlanningExportEnvelope _wrap(
    String artifactType,
    Map<String, dynamic> payload, {
    String? locale,
  }) =>
      PlanningExportEnvelope(
        schemaVersion: PlanningExportEnvelope.currentSchemaVersion,
        exportedAt: DateTime.now(),
        artifactType: artifactType,
        locale: locale,
        payload: payload,
      );

  // -- Shopping list ----------------------------------------------------------

  /// Export shopping items as a JSON envelope string.
  String exportShoppingListJson(List<ShoppingItem> items, {String? locale}) {
    final envelope = _wrap(
      PlanningExportEnvelope.typeShoppingList,
      {'items': items.map((i) => i.toJson()).toList()},
      locale: locale,
    );
    return jsonEncode(envelope.toJson());
  }

  /// Export shopping items as CSV (no envelope – human-editable format).
  String exportShoppingListCsv(
    List<ShoppingItem> items, {
    List<String> headerRow = const [
      'productName',
      'store',
      'price',
      'unitPrice',
      'checked',
    ],
  }) {
    final rows = <List<String>>[
      headerRow,
      ...items.map((i) => [
            i.productName,
            i.store,
            i.price.toStringAsFixed(2),
            i.unitPrice ?? '',
            i.checked.toString(),
          ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  /// Parse shopping items from CSV string.
  List<ShoppingItem> importShoppingListCsv(String csv) {
    final rows = const CsvToListConverter(eol: '\n').convert(csv);
    if (rows.isEmpty) return [];

    // First row is header – skip it.
    return rows.skip(1).map((row) {
      return ShoppingItem(
        productName: row[0].toString(),
        store: row.length > 1 ? row[1].toString() : '',
        price: row.length > 2 ? double.tryParse(row[2].toString()) ?? 0 : 0,
        unitPrice: row.length > 3 && row[3].toString().isNotEmpty
            ? row[3].toString()
            : null,
        checked: row.length > 4 && row[4].toString().toLowerCase() == 'true',
      );
    }).toList();
  }

  /// Parse shopping items from a JSON envelope string.
  List<ShoppingItem> importShoppingListJson(String jsonStr) {
    final envelope =
        PlanningExportEnvelope.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    if (envelope.artifactType != PlanningExportEnvelope.typeShoppingList) {
      throw FormatException(
        'Expected artifactType ${PlanningExportEnvelope.typeShoppingList}, '
        'got ${envelope.artifactType}',
      );
    }
    final items = envelope.payload['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // -- Meal plan --------------------------------------------------------------

  /// Export a [MealPlan] as a JSON envelope string.
  String exportMealPlanJson(MealPlan plan, {String? locale}) {
    final envelope = _wrap(
      PlanningExportEnvelope.typeMealPlan,
      plan.toJson(),
      locale: locale,
    );
    return jsonEncode(envelope.toJson());
  }

  /// Parse a [MealPlan] from a JSON envelope string.
  MealPlan importMealPlanJson(String jsonStr) {
    final envelope =
        PlanningExportEnvelope.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    if (envelope.artifactType != PlanningExportEnvelope.typeMealPlan) {
      throw FormatException(
        'Expected artifactType ${PlanningExportEnvelope.typeMealPlan}, '
        'got ${envelope.artifactType}',
      );
    }
    return MealPlan.fromJson(envelope.payload);
  }

  // -- Pantry snapshot --------------------------------------------------------

  /// Export a list of pantry ingredient IDs as a JSON envelope string.
  String exportPantrySnapshotJson(
    List<String> pantryIngredients, {
    String? locale,
  }) {
    final envelope = _wrap(
      PlanningExportEnvelope.typePantrySnapshot,
      {'ingredients': pantryIngredients},
      locale: locale,
    );
    return jsonEncode(envelope.toJson());
  }

  /// Parse pantry ingredient IDs from a JSON envelope string.
  List<String> importPantrySnapshotJson(String jsonStr) {
    final envelope =
        PlanningExportEnvelope.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    if (envelope.artifactType != PlanningExportEnvelope.typePantrySnapshot) {
      throw FormatException(
        'Expected artifactType ${PlanningExportEnvelope.typePantrySnapshot}, '
        'got ${envelope.artifactType}',
      );
    }
    final raw = envelope.payload['ingredients'] as List<dynamic>? ?? [];
    return raw.map((e) => e.toString()).toList();
  }

  // -- Freeform meals ---------------------------------------------------------

  /// Export freeform meals as a JSON envelope string.
  String exportFreeformMealsJson(
    List<FreeformMeal> meals, {
    String? locale,
  }) {
    final envelope = _wrap(
      PlanningExportEnvelope.typeFreeformMeals,
      {'meals': meals.map((m) => m.toJson()).toList()},
      locale: locale,
    );
    return jsonEncode(envelope.toJson());
  }

  /// Parse freeform meals from a JSON envelope string.
  List<FreeformMeal> importFreeformMealsJson(String jsonStr) {
    final envelope =
        PlanningExportEnvelope.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    if (envelope.artifactType != PlanningExportEnvelope.typeFreeformMeals) {
      throw FormatException(
        'Expected artifactType ${PlanningExportEnvelope.typeFreeformMeals}, '
        'got ${envelope.artifactType}',
      );
    }
    final raw = envelope.payload['meals'] as List<dynamic>? ?? [];
    return raw
        .map((e) => FreeformMeal.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // File I/O delegate
  // ---------------------------------------------------------------------------

  /// Write content to a temp file via [ExportService].
  Future<String> writeToTempFile(String filename, String content) async {
    final file = await _exportService.writeTempFile(
      filename,
      utf8.encode(content),
    );
    return file.path;
  }
}
