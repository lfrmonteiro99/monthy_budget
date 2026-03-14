import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/utils/receipt_ai_matcher.dart';

void main() {
  group('ReceiptAiMatcher', () {
    group('buildMatchingPrompt', () {
      test('contains item names and mentions JSON', () {
        final prompt = ReceiptAiMatcher.buildMatchingPrompt(
          unmatchedItems: ['BIFE ACÉM 1KG', 'LEITE MEIO GORDO'],
          shoppingList: ['Carne de Vaca', 'Leite'],
        );

        expect(prompt, contains('BIFE ACÉM 1KG'));
        expect(prompt, contains('LEITE MEIO GORDO'));
        expect(prompt, contains('Carne de Vaca'));
        expect(prompt, contains('Leite'));
        expect(prompt.toLowerCase(), contains('json'));
      });
    });

    group('parseAiResponse', () {
      test('extracts matches from valid JSON', () {
        const response = '''
{"matches": [{"receipt_item": "BIFE ACÉM 1KG", "shopping_item": "Carne de Vaca", "confidence": 0.9}]}
''';

        final result = ReceiptAiMatcher.parseAiResponse(response);

        expect(result, hasLength(1));
        expect(result, contains('BIFE ACÉM 1KG'));
        expect(result['BIFE ACÉM 1KG']!.shoppingItemName, 'Carne de Vaca');
        expect(result['BIFE ACÉM 1KG']!.confidence, 0.9);
      });

      test('handles malformed JSON and returns empty map', () {
        const response = 'This is not valid JSON at all {{{';

        final result = ReceiptAiMatcher.parseAiResponse(response);

        expect(result, isEmpty);
      });

      test('handles empty matches array', () {
        const response = '{"matches": []}';

        final result = ReceiptAiMatcher.parseAiResponse(response);

        expect(result, isEmpty);
      });
    });
  });
}
