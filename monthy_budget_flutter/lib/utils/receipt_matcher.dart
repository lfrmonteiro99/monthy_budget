import 'dart:math';

/// Result of matching a receipt item to a shopping list item.
class MatchResult {
  final String itemId;
  final double confidence;

  const MatchResult({required this.itemId, required this.confidence});
}

/// Fuzzy matching utility for receipt items → shopping list matching.
class ReceiptMatcher {
  /// Common Portuguese receipt abbreviations mapped to full words.
  static const _abbreviations = <String, String>{
    'lt': 'leite',
    'fr': 'fruta',
    'mg': 'meio gordo',
    'm/g': 'meio gordo',
    'uht': 'uht',
    'choc': 'chocolate',
    'marg': 'margarina',
    'iog': 'iogurte',
    'nat': 'natural',
    'desc': 'desnatado',
    'arrz': 'arroz',
    'azeit': 'azeite',
    'bac': 'bacalhau',
  };

  /// Portuguese diacritical mappings.
  static const _accentMap = <String, String>{
    'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
  };

  /// Normalize text: lowercase, strip accents, expand abbreviations.
  static String normalizeText(String input) {
    var text = input.toLowerCase();

    // Remove accents
    final buffer = StringBuffer();
    for (final char in text.split('')) {
      buffer.write(_accentMap[char] ?? char);
    }
    text = buffer.toString();

    // Expand abbreviations (word-boundary aware)
    final words = text.split(RegExp(r'\s+'));
    final expanded = words.map((w) => _abbreviations[w] ?? w).toList();

    return expanded.join(' ').trim();
  }

  /// Compute similarity between two strings (0.0 to 1.0).
  ///
  /// Combines Levenshtein distance, substring containment, and word overlap.
  static double similarity(String a, String b) {
    final na = normalizeText(a);
    final nb = normalizeText(b);

    if (na == nb) return 1.0;
    if (na.isEmpty || nb.isEmpty) return 0.0;

    // Levenshtein-based similarity
    final maxLen = max(na.length, nb.length);
    final levDist = _levenshtein(na, nb);
    final levSim = 1.0 - (levDist / maxLen);

    // Substring containment boost — strong signal when the shorter string
    // is fully contained in the longer one (common for short shopping-list
    // keywords matched against verbose receipt product names).
    double substringBoost = 0.0;
    if (na.contains(nb) || nb.contains(na)) {
      substringBoost = 1.0;
    }

    // Word overlap: use recall against the *shorter* word set so that a
    // single-word shopping item like "leite" scores 1.0 when it appears
    // anywhere in a multi-word receipt name.
    final wordsA = na.split(RegExp(r'\s+')).toSet();
    final wordsB = nb.split(RegExp(r'\s+')).toSet();
    final intersection = wordsA.intersection(wordsB).length;
    final smaller = min(wordsA.length, wordsB.length);
    final wordRecall = smaller > 0 ? intersection / smaller : 0.0;

    // Weighted combination
    final combined =
        (levSim * 0.3) + (substringBoost * 0.35) + (wordRecall * 0.35);

    return min(1.0, combined);
  }

  /// Match receipt items to shopping list items.
  ///
  /// [receiptItems] — list of product names from the receipt.
  /// [shoppingItems] — map of item ID → product name from the shopping list.
  /// [minConfidence] — minimum similarity to accept a match (default 0.7).
  ///
  /// Returns a map from receipt item name → [MatchResult] or null if no match.
  static Map<String, MatchResult?> matchItems(
    List<String> receiptItems,
    Map<String, String> shoppingItems, {
    double minConfidence = 0.7,
  }) {
    final results = <String, MatchResult?>{};

    for (final receiptItem in receiptItems) {
      String? bestId;
      double bestScore = 0.0;

      for (final entry in shoppingItems.entries) {
        final score = similarity(receiptItem, entry.value);
        if (score > bestScore) {
          bestScore = score;
          bestId = entry.key;
        }
      }

      if (bestId != null && bestScore >= minConfidence) {
        results[receiptItem] = MatchResult(itemId: bestId, confidence: bestScore);
      } else {
        results[receiptItem] = null;
      }
    }

    return results;
  }

  /// Standard Levenshtein distance between two strings.
  static int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final matrix = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );

    for (var i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce(min);
      }
    }

    return matrix[a.length][b.length];
  }
}
