import 'dart:convert';

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'content': content,
        'stressScore': stressScore,
      };

  factory CoachInsight.fromJson(Map<String, dynamic> json) => CoachInsight(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        content: json['content'] as String,
        stressScore: (json['stressScore'] as num).toInt(),
      );

  static List<CoachInsight> listFromJsonString(String s) {
    final list = jsonDecode(s) as List<dynamic>;
    return list.map((e) => CoachInsight.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJsonString(List<CoachInsight> insights) =>
      jsonEncode(insights.map((e) => e.toJson()).toList());
}
