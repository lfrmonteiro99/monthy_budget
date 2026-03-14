import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/utils/receipt_matcher.dart';

void main() {
  group('normalizeText', () {
    test('lowercases and removes accents', () {
      expect(ReceiptMatcher.normalizeText('PÃO INTEGRAL'), 'pao integral');
      expect(ReceiptMatcher.normalizeText('Café'), 'cafe');
      expect(ReceiptMatcher.normalizeText('Açúcar'), 'acucar');
      expect(ReceiptMatcher.normalizeText('Água'), 'agua');
    });

    test('expands abbreviations', () {
      final result = ReceiptMatcher.normalizeText('LT M/G UHT');
      expect(result, contains('leite'));
    });
  });

  group('similarity', () {
    test('identical strings return 1.0', () {
      expect(ReceiptMatcher.similarity('leite', 'leite'), 1.0);
    });

    test('completely different strings return less than 0.5', () {
      expect(ReceiptMatcher.similarity('xyz123', 'abcdef'), lessThan(0.5));
    });
  });

  group('matchItems', () {
    test('matches exact product names', () {
      final receiptItems = ['Leite Meio Gordo'];
      final shoppingItems = {
        'item-1': 'Leite Meio Gordo',
        'item-2': 'Pão Integral',
      };

      final results = ReceiptMatcher.matchItems(receiptItems, shoppingItems);

      expect(results.length, 1);
      expect(results['Leite Meio Gordo'], isNotNull);
      expect(results['Leite Meio Gordo']!.itemId, 'item-1');
      expect(results['Leite Meio Gordo']!.confidence, 1.0);
    });

    test('unmatched items return null', () {
      final receiptItems = ['Produto Desconhecido XYZ'];
      final shoppingItems = {'item-1': 'Leite'};

      final results = ReceiptMatcher.matchItems(receiptItems, shoppingItems);

      expect(results['Produto Desconhecido XYZ'], isNull);
    });

    test('respects minimum confidence threshold', () {
      final receiptItems = ['Leite Gordo'];
      final shoppingItems = {'item-1': 'Leite Meio Gordo UHT'};

      final highThreshold =
          ReceiptMatcher.matchItems(receiptItems, shoppingItems, minConfidence: 0.99);
      final lowThreshold =
          ReceiptMatcher.matchItems(receiptItems, shoppingItems, minConfidence: 0.3);

      expect(highThreshold['Leite Gordo'], isNull);
      expect(lowThreshold['Leite Gordo'], isNotNull);
    });

    test('empty inputs return empty map', () {
      expect(ReceiptMatcher.matchItems([], {}), isEmpty);
      expect(
        ReceiptMatcher.matchItems(['a'], {}),
        equals({'a': null}),
      );
      expect(ReceiptMatcher.matchItems([], {'id': 'b'}), isEmpty);
    });
  });
}
