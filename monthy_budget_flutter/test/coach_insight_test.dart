import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/coach_insight.dart';

void main() {
  group('CoachInsight', () {
    test('toJson/fromJson roundtrip preserves fields', () {
      final insight = CoachInsight(
        id: 'i1',
        timestamp: DateTime.utc(2026, 3, 4, 12, 30),
        content: 'Reduce variable spending this week.',
        stressScore: 7,
      );

      final decoded = CoachInsight.fromJson(insight.toJson());

      expect(decoded.id, insight.id);
      expect(decoded.timestamp.toUtc(), insight.timestamp.toUtc());
      expect(decoded.content, insight.content);
      expect(decoded.stressScore, insight.stressScore);
    });

    test('list helpers serialize and deserialize insight lists', () {
      final insights = [
        CoachInsight(
          id: 'a',
          timestamp: DateTime.utc(2026, 1, 1),
          content: 'A',
          stressScore: 1,
        ),
        CoachInsight(
          id: 'b',
          timestamp: DateTime.utc(2026, 1, 2),
          content: 'B',
          stressScore: 9,
        ),
      ];

      final json = CoachInsight.listToJsonString(insights);
      final restored = CoachInsight.listFromJsonString(json);

      expect(restored.length, 2);
      expect(restored.first.id, 'a');
      expect(restored.last.id, 'b');
      expect(restored.last.stressScore, 9);
    });

    test('fromJson converts numeric stress score to int', () {
      final insight = CoachInsight.fromJson({
        'id': 'num',
        'timestamp': DateTime.utc(2026, 3, 4).toIso8601String(),
        'content': 'numeric score',
        'stressScore': 4.9,
      });

      expect(insight.stressScore, 4);
    });
  });
}
