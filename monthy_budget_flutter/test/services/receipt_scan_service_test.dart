import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/services/receipt_scan_service.dart';
import 'package:orcamento_mensal/models/parsed_receipt.dart';

void main() {
  group('ReceiptScanService', () {
    group('parseQrCode', () {
      test('parses valid ATCUD QR and returns ParsedReceipt', () {
        const qr = 'A:500100144*B:999999990*C:PT*D:FT*E:N*'
            'F:20260309*G:FT 001/123*H:ABCD1234-1*'
            'I1:39.44*I7:39.44*I8:9.07*N:9.07*O:48.51*'
            'Q:abcd*R:1234*S:PT';
        final receipt = ReceiptScanService.parseQrCode(qr);
        expect(receipt, isNotNull);
        expect(receipt!.merchantNif, '500100144');
        expect(receipt.totalAmount, 48.51);
      });

      test('returns null for non-ATCUD QR', () {
        expect(ReceiptScanService.parseQrCode('https://example.com'), isNull);
      });

      test('returns null for empty string', () {
        expect(ReceiptScanService.parseQrCode(''), isNull);
      });
    });

    group('buildExpense', () {
      test('creates ActualExpense with merchant name in description', () {
        final receipt = ParsedReceipt(
          merchantNif: '500100144',
          merchantName: 'Continente',
          totalAmount: 47.32,
          date: DateTime(2026, 3, 9),
        );
        final expense = ReceiptScanService.buildExpense(
          receipt: receipt,
          category: 'alimentacao',
        );
        expect(expense.amount, 47.32);
        expect(expense.date, DateTime(2026, 3, 9));
        expect(expense.category, 'alimentacao');
        expect(expense.description, contains('Continente'));
      });

      test('uses NIF in description when merchantName is null', () {
        final receipt = ParsedReceipt(
          merchantNif: '500100144',
          totalAmount: 10.0,
          date: DateTime(2026, 3, 9),
        );
        final expense = ReceiptScanService.buildExpense(
          receipt: receipt,
          category: 'alimentacao',
        );
        expect(expense.description, contains('500100144'));
      });
    });

    group('buildPurchaseRecord', () {
      test('creates PurchaseRecord from receipt with line items', () {
        final receipt = ParsedReceipt(
          merchantNif: '500100144',
          totalAmount: 3.37,
          date: DateTime(2026, 3, 9),
          lineItems: [
            ReceiptLineItem(
                rawText: 'A',
                productName: 'Leite',
                quantity: 1,
                totalPrice: 0.79),
            ReceiptLineItem(
                rawText: 'B',
                productName: 'Pão',
                quantity: 1,
                totalPrice: 1.29),
            ReceiptLineItem(
                rawText: 'C',
                productName: 'Banana',
                quantity: 1,
                totalPrice: 1.29),
          ],
        );
        final record = ReceiptScanService.buildPurchaseRecord(receipt);
        expect(record.amount, 3.37);
        expect(record.itemCount, 3);
        expect(record.items, ['Leite', 'Pão', 'Banana']);
      });

      test('creates PurchaseRecord with empty items when no line items', () {
        final receipt = ParsedReceipt(
          merchantNif: '500100144',
          totalAmount: 10.0,
          date: DateTime(2026, 3, 9),
        );
        final record = ReceiptScanService.buildPurchaseRecord(receipt);
        expect(record.amount, 10.0);
        expect(record.itemCount, 0);
        expect(record.items, isEmpty);
      });
    });
  });
}
