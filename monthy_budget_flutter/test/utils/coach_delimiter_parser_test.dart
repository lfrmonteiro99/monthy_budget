import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/utils/coach_delimiter_parser.dart';

void main() {
  group('sessionInsightRegex', () {
    test('matches single-line insight with value', () {
      const input =
          'Some text [SESSION_INSIGHT]insight topic|€42[/SESSION_INSIGHT] end';
      final match = sessionInsightRegex.firstMatch(input);
      expect(match, isNotNull);
      expect(match!.group(1), 'insight topic');
      expect(match.group(2), '€42');
    });

    test('matches multiline content inside delimiter', () {
      const input =
          '[SESSION_INSIGHT]line one\nline two|value\nmore[/SESSION_INSIGHT]';
      final match = sessionInsightRegex.firstMatch(input);
      expect(match, isNotNull);
      expect(match!.group(1), 'line one\nline two');
      expect(match.group(2), 'value\nmore');
    });

    test('returns null when no match', () {
      const input = 'No delimiters here';
      expect(sessionInsightRegex.firstMatch(input), isNull);
    });
  });

  group('microActionRegex', () {
    test('matches single-line micro action', () {
      const input =
          'Reply text [MICRO_ACTION]Review subscriptions this week[/MICRO_ACTION] done';
      final match = microActionRegex.firstMatch(input);
      expect(match, isNotNull);
      expect(match!.group(1), 'Review subscriptions this week');
    });

    test('matches multiline content inside delimiter', () {
      const input =
          '[MICRO_ACTION]Step 1: open app\nStep 2: cancel unused sub[/MICRO_ACTION]';
      final match = microActionRegex.firstMatch(input);
      expect(match, isNotNull);
      expect(match!.group(1), 'Step 1: open app\nStep 2: cancel unused sub');
    });

    test('returns null when no match', () {
      const input = 'No delimiters here';
      expect(microActionRegex.firstMatch(input), isNull);
    });
  });
}
