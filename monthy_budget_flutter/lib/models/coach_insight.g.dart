// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_insight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachInsight _$CoachInsightFromJson(Map<String, dynamic> json) => CoachInsight(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  content: json['content'] as String,
  stressScore: (json['stressScore'] as num).toInt(),
);

Map<String, dynamic> _$CoachInsightToJson(CoachInsight instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'content': instance.content,
      'stressScore': instance.stressScore,
    };
