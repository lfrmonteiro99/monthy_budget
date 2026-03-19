import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'coach_insight.g.dart';

@JsonSerializable()
class CoachInsight {
  final String id;
  final DateTime timestamp;
  final String content;
  final int stressScore;

  const CoachInsight({
    required this.id,
    required this.timestamp,
    required this.content,
    required this.stressScore,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoachInsight &&
          id == other.id &&
          timestamp == other.timestamp &&
          content == other.content &&
          stressScore == other.stressScore;

  @override
  int get hashCode => Object.hash(id, timestamp, content, stressScore);

  Map<String, dynamic> toJson() => _$CoachInsightToJson(this);

  factory CoachInsight.fromJson(Map<String, dynamic> json) =>
      _$CoachInsightFromJson(json);

  static List<CoachInsight> listFromJsonString(String s) {
    final list = jsonDecode(s) as List<dynamic>;
    return list.map((e) => CoachInsight.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJsonString(List<CoachInsight> insights) =>
      jsonEncode(insights.map((e) => e.toJson()).toList());
}
