import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/utils/receipt_text_parser.dart';

void main() {
  group('ReceiptTextParser.parseLines', () {
    test('parses standard QTD x PRICE TOTAL line', () {
      final items = ReceiptTextParser.parseLines([
        'LEITE M/G UHT 1L          1 x 0.79    0.79',
      ]);

      expect(items.length, 1);
      expect(items.first.productName, 'LEITE M/G UHT 1L');
      expect(items.first.quantity, 1.0);
      expect(items.first.unitPrice, 0.79);
      expect(items.first.totalPrice, 0.79);
    });

    test('parses weight-based QTDkg TOTAL line', () {
      final items = ReceiptTextParser.parseLines([
        'BANANA                     1.234kg     1.85',
      ]);

      expect(items.length, 1);
      expect(items.first.productName, 'BANANA');
      expect(items.first.quantity, closeTo(1.234, 0.001));
      expect(items.first.totalPrice, 1.85);
      expect(items.first.unitPrice, isNotNull);
      expect(items.first.unitPrice!, closeTo(1.85 / 1.234, 0.01));
    });

    test('skips SUBTOTAL, TOTAL, and IVA lines', () {
      final items = ReceiptTextParser.parseLines([
        'LEITE M/G UHT 1L          1 x 0.79    0.79',
        'SUBTOTAL                                5.00',
        'TOTAL                                   5.00',
        'IVA                                     0.50',
      ]);

      expect(items.length, 1);
      expect(items.first.productName, 'LEITE M/G UHT 1L');
    });

    test('skips header lines (NIF, address, store name)', () {
      final items = ReceiptTextParser.parseLines([
        'CONTINENTE MODELO',
        'NIF 500100144',
        'RUA DO COMERCIO 123',
        '1000-001 LISBOA',
        'LEITE M/G UHT 1L          1 x 0.79    0.79',
      ]);

      expect(items.length, 1);
      expect(items.first.productName, 'LEITE M/G UHT 1L');
    });

    test('parses multiple items from real receipt block', () {
      final lines = [
        'CONTINENTE MODELO',
        'NIF 500100144',
        'RUA DO COMERCIO 123',
        '1000-001 LISBOA',
        '',
        'LEITE M/G UHT 1L          1 x 0.79    0.79',
        'BANANA                     1.234kg     1.85',
        'PÃO DE FORMA               2 x 1.29    2.58',
        'SACO PLASTICO                           0.10',
        '',
        'SUBTOTAL                                5.32',
        'TOTAL                                   5.32',
        'IVA 6%                                  0.30',
        'MULTIBANCO                              5.32',
      ];

      final items = ReceiptTextParser.parseLines(lines);

      expect(items.length, 4);
      expect(items[0].productName, 'LEITE M/G UHT 1L');
      expect(items[1].productName, 'BANANA');
      expect(items[2].productName, contains('DE FORMA'));
      expect(items[3].productName, 'SACO PLASTICO');
    });

    test('handles line with only price at end', () {
      final items = ReceiptTextParser.parseLines([
        'SACO PLASTICO                           0.10',
      ]);

      expect(items.length, 1);
      expect(items.first.productName, 'SACO PLASTICO');
      expect(items.first.quantity, 1.0);
      expect(items.first.totalPrice, 0.10);
      expect(items.first.unitPrice, isNull);
    });

    test('returns empty list for empty input', () {
      expect(ReceiptTextParser.parseLines([]), isEmpty);
      expect(ReceiptTextParser.parseLines(['']), isEmpty);
      expect(ReceiptTextParser.parseLines(['   ']), isEmpty);
    });
  });

  group('ReceiptTextParser.extractTotal', () {
    test('finds the TOTAL value', () {
      final lines = [
        'LEITE M/G UHT 1L          1 x 0.79    0.79',
        'SUBTOTAL                                5.32',
        'TOTAL                                   5.32',
        'IVA 6%                                  0.30',
        'MULTIBANCO                              5.32',
      ];

      expect(ReceiptTextParser.extractTotal(lines), 5.32);
    });

    test('returns null when no total found', () {
      final lines = [
        'LEITE M/G UHT 1L          1 x 0.79    0.79',
        'BANANA                     1.234kg     1.85',
      ];

      expect(ReceiptTextParser.extractTotal(lines), isNull);
    });
  });
}
