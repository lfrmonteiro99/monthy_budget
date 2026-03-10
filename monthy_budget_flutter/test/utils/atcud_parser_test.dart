import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/utils/atcud_parser.dart';

void main() {
  group('AtcudParser', () {
    group('parse', () {
      test('parses complete QR code with all fields', () {
        const qr =
            'A:500100144*B:999999990*C:PT*D:FT*E:N*F:20260309*G:FT 001/123'
            '*H:ABCD1234-1*I1:39.44*I7:39.44*I8:9.07*N:9.07*O:48.51'
            '*Q:abcd*R:1234*S:PT';

        final result = AtcudParser.parse(qr);

        expect(result, isNotNull);
        expect(result!.merchantNif, '500100144');
        expect(result.consumerNif, '999999990');
        expect(result.date, DateTime(2026, 3, 9));
        expect(result.atcud, 'ABCD1234-1');
        expect(result.taxAmount, 9.07);
        expect(result.totalAmount, 48.51);
        expect(result.rawQrData, qr);
      });

      test('parses minimal QR code with only required fields A, F, O', () {
        const qr = 'A:123456789*F:20260101*O:25.00';

        final result = AtcudParser.parse(qr);

        expect(result, isNotNull);
        expect(result!.merchantNif, '123456789');
        expect(result.date, DateTime(2026, 1, 1));
        expect(result.totalAmount, 25.00);
        expect(result.consumerNif, isNull);
        expect(result.atcud, isNull);
        expect(result.taxAmount, isNull);
        expect(result.rawQrData, qr);
      });

      test('returns null for empty string', () {
        expect(AtcudParser.parse(''), isNull);
      });

      test('returns null for non-ATCUD data (URL)', () {
        expect(AtcudParser.parse('https://example.com/receipt/123'), isNull);
      });

      test('returns null when missing field A (merchant NIF)', () {
        const qr = 'F:20260309*O:48.51';
        expect(AtcudParser.parse(qr), isNull);
      });

      test('returns null when missing field F (date)', () {
        const qr = 'A:500100144*O:48.51';
        expect(AtcudParser.parse(qr), isNull);
      });

      test('returns null when missing field O (total)', () {
        const qr = 'A:500100144*F:20260309';
        expect(AtcudParser.parse(qr), isNull);
      });

      test('handles malformed date gracefully', () {
        const qr = 'A:500100144*F:not-a-date*O:48.51';
        expect(AtcudParser.parse(qr), isNull);
      });

      test('handles malformed total gracefully', () {
        const qr = 'A:500100144*F:20260309*O:not-a-number';
        expect(AtcudParser.parse(qr), isNull);
      });
    });

    group('isAtcudQrCode', () {
      test('returns true for valid ATCUD QR string', () {
        const qr = 'A:500100144*F:20260309*O:48.51';
        expect(AtcudParser.isAtcudQrCode(qr), isTrue);
      });

      test('returns false for empty string', () {
        expect(AtcudParser.isAtcudQrCode(''), isFalse);
      });

      test('returns false for URL', () {
        expect(
          AtcudParser.isAtcudQrCode('https://example.com'),
          isFalse,
        );
      });

      test('returns false for string missing asterisk separator', () {
        expect(AtcudParser.isAtcudQrCode('A:500100144'), isFalse);
      });

      test('returns false for string missing O: field marker', () {
        expect(AtcudParser.isAtcudQrCode('A:500100144*F:20260309'), isFalse);
      });
    });
  });
}
