import 'dart:convert';

class AiMatchResult {
  final String shoppingItemName;
  final double confidence;

  const AiMatchResult({
    required this.shoppingItemName,
    required this.confidence,
  });
}

class ReceiptAiMatcher {
  ReceiptAiMatcher._();

  static String buildMatchingPrompt({
    required List<String> unmatchedItems,
    required List<String> shoppingList,
  }) {
    final receiptSection = unmatchedItems.map((i) => '- $i').join('\n');
    final listSection = shoppingList.map((i) => '- $i').join('\n');

    return '''
Match each receipt item to the most likely shopping list item.
Return ONLY valid JSON with this structure:
{"matches": [{"receipt_item": "<name>", "shopping_item": "<name>", "confidence": <0.0-1.0>}]}

Receipt items:
$receiptSection

Shopping list:
$listSection
''';
  }

  static Map<String, AiMatchResult> parseAiResponse(String response) {
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) {
        return {};
      }

      final jsonStr = response.substring(jsonStart, jsonEnd + 1);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final matches = decoded['matches'] as List<dynamic>? ?? [];

      final result = <String, AiMatchResult>{};
      for (final match in matches) {
        final m = match as Map<String, dynamic>;
        final receiptItem = m['receipt_item'] as String?;
        final shoppingItem = m['shopping_item'] as String?;
        final confidence = (m['confidence'] as num?)?.toDouble();

        if (receiptItem != null && shoppingItem != null && confidence != null) {
          result[receiptItem] = AiMatchResult(
            shoppingItemName: shoppingItem,
            confidence: confidence,
          );
        }
      }

      return result;
    } catch (_) {
      return {};
    }
  }
}
