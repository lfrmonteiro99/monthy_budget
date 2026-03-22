import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/coach_insight.dart';

void main() {
  group('CoachInsight', () {
    test('constructor assigns all fields', () {
      final insight = CoachInsight(
        id: 'ci_1',
        timestamp: DateTime(2026, 3, 15, 10, 30),
        content: 'Your spending is on track.',
        stressScore: 42,
      );
      expect(insight.id, 'ci_1');
      expect(insight.timestamp, DateTime(2026, 3, 15, 10, 30));
      expect(insight.content, 'Your spending is on track.');
      expect(insight.stressScore, 42);
    });

    group('equality', () {
      test('equal with same fields', () {
        final a = CoachInsight(
          id: 'ci_1',
          timestamp: DateTime(2026, 3, 15),
          content: 'Test',
          stressScore: 50,
        );
        final b = CoachInsight(
          id: 'ci_1',
          timestamp: DateTime(2026, 3, 15),
          content: 'Test',
          stressScore: 50,
        );
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('not equal when content differs', () {
        final a = CoachInsight(
          id: 'ci_1',
          timestamp: DateTime(2026, 3, 15),
          content: 'A',
          stressScore: 50,
        );
        final b = CoachInsight(
          id: 'ci_1',
          timestamp: DateTime(2026, 3, 15),
          content: 'B',
          stressScore: 50,
        );
        expect(a, isNot(equals(b)));
      });

      test('not equal to different type', () {
        final a = CoachInsight(
          id: 'ci_1',
          timestamp: DateTime(2026, 3, 15),
          content: 'X',
          stressScore: 0,
        );
        expect(a == 'not an insight', isFalse);
      });

      test('identical objects are equal', () {
        final a = CoachInsight(
          id: 'ci_1',
          timestamp: DateTime(2026, 3, 15),
          content: 'X',
          stressScore: 0,
        );
        expect(identical(a, a), isTrue);
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct map', () {
        final insight = CoachInsight(
          id: 'ci_1',
          timestamp: DateTime(2026, 3, 15, 10, 30),
          content: 'All good',
          stressScore: 35,
        );
        final json = insight.toJson();
        expect(json['id'], 'ci_1');
        expect(json['content'], 'All good');
        expect(json['stressScore'], 35);
      });

      test('fromJson parses correctly', () {
        final json = {
          'id': 'ci_2',
          'timestamp': '2026-03-20T14:00:00.000',
          'content': 'Watch your spending',
          'stressScore': 75,
        };
        final insight = CoachInsight.fromJson(json);
        expect(insight.id, 'ci_2');
        expect(insight.content, 'Watch your spending');
        expect(insight.stressScore, 75);
      });

      test('roundtrip toJson -> fromJson preserves data', () {
        final original = CoachInsight(
          id: 'ci_rt',
          timestamp: DateTime(2026, 6, 1, 8, 0),
          content: 'Roundtrip test',
          stressScore: 60,
        );
        final json = original.toJson();
        final restored = CoachInsight.fromJson(json);
        expect(restored, equals(original));
      });
    });

    group('list serialization', () {
      test('listToJsonString and listFromJsonString roundtrip', () {
        final insights = [
          CoachInsight(
            id: 'ci_1',
            timestamp: DateTime(2026, 3, 10),
            content: 'First',
            stressScore: 30,
          ),
          CoachInsight(
            id: 'ci_2',
            timestamp: DateTime(2026, 3, 15),
            content: 'Second',
            stressScore: 50,
          ),
        ];
        final jsonStr = CoachInsight.listToJsonString(insights);
        final restored = CoachInsight.listFromJsonString(jsonStr);
        expect(restored, hasLength(2));
        expect(restored[0], equals(insights[0]));
        expect(restored[1], equals(insights[1]));
      });

      test('listFromJsonString with empty list', () {
        final restored = CoachInsight.listFromJsonString('[]');
        expect(restored, isEmpty);
      });
    });
  });
}
