import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/utils/atcud_parser.dart';

void main() {
  group('AtcudParser.isAtcudQrCode', () {
    test('returns true for valid ATCUD QR code string', () {
      const qr = 'A:999999999*B:123456789*F:20260311*O:42.50*H:ATCUD1234*N:5.20';
      expect(AtcudParser.isAtcudQrCode(qr), true);
    });

    test('returns true for minimal ATCUD (A + O + separator)', () {
      const qr = 'A:999999999*O:10.00';
      expect(AtcudParser.isAtcudQrCode(qr), true);
    });

    test('returns false for EAN-13 product barcode', () {
      expect(AtcudParser.isAtcudQrCode('5601234567890'), false);
    });

    test('returns false for EAN-8 product barcode', () {
      expect(AtcudParser.isAtcudQrCode('12345678'), false);
    });

    test('returns false for empty string', () {
      expect(AtcudParser.isAtcudQrCode(''), false);
    });

    test('returns false for random alphanumeric string', () {
      expect(AtcudParser.isAtcudQrCode('ABC123DEF456'), false);
    });
  });

  group('AtcudParser.parse', () {
    test('parses valid ATCUD QR code', () {
      const qr = 'A:999999999*F:20260311*O:42.50*B:123456789*H:ATCUD1234*N:5.20';
      final receipt = AtcudParser.parse(qr);

      expect(receipt, isNotNull);
      expect(receipt!.merchantNif, '999999999');
      expect(receipt.totalAmount, 42.50);
      expect(receipt.date, DateTime(2026, 3, 11));
      expect(receipt.consumerNif, '123456789');
      expect(receipt.atcud, 'ATCUD1234');
      expect(receipt.taxAmount, 5.20);
    });

    test('returns null for missing required field A', () {
      const qr = 'F:20260311*O:42.50';
      expect(AtcudParser.parse(qr), isNull);
    });

    test('returns null for missing required field F', () {
      const qr = 'A:999999999*O:42.50';
      expect(AtcudParser.parse(qr), isNull);
    });

    test('returns null for missing required field O', () {
      const qr = 'A:999999999*F:20260311';
      expect(AtcudParser.parse(qr), isNull);
    });

    test('returns null for empty string', () {
      expect(AtcudParser.parse(''), isNull);
    });

    test('returns null for product barcode', () {
      expect(AtcudParser.parse('5601234567890'), isNull);
    });

    test('returns null for malformed date', () {
      const qr = 'A:999999999*F:2026031*O:42.50';
      expect(AtcudParser.parse(qr), isNull);
    });

    test('returns null for malformed amount', () {
      const qr = 'A:999999999*F:20260311*O:abc';
      expect(AtcudParser.parse(qr), isNull);
    });

    test('parses without optional fields', () {
      const qr = 'A:999999999*F:20260311*O:10.00';
      final receipt = AtcudParser.parse(qr);

      expect(receipt, isNotNull);
      expect(receipt!.consumerNif, isNull);
      expect(receipt.atcud, isNull);
      expect(receipt.taxAmount, isNull);
    });
  });
}
