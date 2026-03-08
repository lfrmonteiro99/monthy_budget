/// Envelope wrapper for all planning artifact import/export operations.
///
/// Provides schema versioning, timestamp, artifact type, and optional locale
/// so that exported files are self-describing and forward-compatible.
class PlanningExportEnvelope {
  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final DateTime exportedAt;
  final String artifactType;
  final String? locale;
  final Map<String, dynamic> payload;

  const PlanningExportEnvelope({
    required this.schemaVersion,
    required this.exportedAt,
    required this.artifactType,
    this.locale,
    required this.payload,
  });

  /// Known artifact type constants.
  static const String typeShoppingList = 'shopping_list';
  static const String typeMealPlan = 'meal_plan';
  static const String typePantrySnapshot = 'pantry_snapshot';
  static const String typeFreeformMeals = 'freeform_meals';

  static const List<String> validArtifactTypes = [
    typeShoppingList,
    typeMealPlan,
    typePantrySnapshot,
    typeFreeformMeals,
  ];

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'exportedAt': exportedAt.toIso8601String(),
        'artifactType': artifactType,
        if (locale != null) 'locale': locale,
        'payload': payload,
      };

  factory PlanningExportEnvelope.fromJson(Map<String, dynamic> json) {
    final version = json['schemaVersion'];
    if (version == null || version is! int) {
      throw const FormatException('Missing or invalid schemaVersion');
    }
    if (version > currentSchemaVersion) {
      throw FormatException(
        'Unsupported schema version $version (max $currentSchemaVersion)',
      );
    }

    final artifactType = json['artifactType'];
    if (artifactType == null || artifactType is! String) {
      throw const FormatException('Missing or invalid artifactType');
    }
    if (!validArtifactTypes.contains(artifactType)) {
      throw FormatException('Unknown artifactType: $artifactType');
    }

    final exportedAtRaw = json['exportedAt'];
    if (exportedAtRaw == null || exportedAtRaw is! String) {
      throw const FormatException('Missing or invalid exportedAt');
    }

    final payload = json['payload'];
    if (payload == null || payload is! Map<String, dynamic>) {
      throw const FormatException('Missing or invalid payload');
    }

    return PlanningExportEnvelope(
      schemaVersion: version,
      exportedAt: DateTime.parse(exportedAtRaw),
      artifactType: artifactType,
      locale: json['locale'] as String?,
      payload: payload,
    );
  }
}

/// A simple freeform meal entry for import/export.
///
/// This is not backed by the AI planner; it represents user-entered
/// ad-hoc meals (e.g. "leftover pasta", "eat out").
class FreeformMeal {
  final String name;
  final String? notes;
  final int dayIndex;
  final String mealType;

  const FreeformMeal({
    required this.name,
    this.notes,
    required this.dayIndex,
    required this.mealType,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (notes != null) 'notes': notes,
        'dayIndex': dayIndex,
        'mealType': mealType,
      };

  factory FreeformMeal.fromJson(Map<String, dynamic> json) => FreeformMeal(
        name: json['name'] as String? ?? '',
        notes: json['notes'] as String?,
        dayIndex: json['dayIndex'] as int? ?? 0,
        mealType: json['mealType'] as String? ?? 'dinner',
      );
}
