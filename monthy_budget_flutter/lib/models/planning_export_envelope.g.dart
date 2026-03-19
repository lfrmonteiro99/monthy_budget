// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planning_export_envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanningExportEnvelope _$PlanningExportEnvelopeFromJson(
  Map<String, dynamic> json,
) => PlanningExportEnvelope(
  schemaVersion: (json['schemaVersion'] as num).toInt(),
  exportedAt: DateTime.parse(json['exportedAt'] as String),
  artifactType: json['artifactType'] as String,
  locale: json['locale'] as String?,
  payload: json['payload'] as Map<String, dynamic>,
);

Map<String, dynamic> _$PlanningExportEnvelopeToJson(
  PlanningExportEnvelope instance,
) => <String, dynamic>{
  'schemaVersion': instance.schemaVersion,
  'exportedAt': instance.exportedAt.toIso8601String(),
  'artifactType': instance.artifactType,
  'locale': ?instance.locale,
  'payload': instance.payload,
};

FreeformMeal _$FreeformMealFromJson(Map<String, dynamic> json) => FreeformMeal(
  name: json['name'] as String,
  notes: json['notes'] as String?,
  dayIndex: (json['dayIndex'] as num).toInt(),
  mealType: json['mealType'] as String,
);

Map<String, dynamic> _$FreeformMealToJson(FreeformMeal instance) =>
    <String, dynamic>{
      'name': instance.name,
      'notes': ?instance.notes,
      'dayIndex': instance.dayIndex,
      'mealType': instance.mealType,
    };
