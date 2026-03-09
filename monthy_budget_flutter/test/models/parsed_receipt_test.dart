import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/parsed_receipt.dart';

void main() {
  group('ReceiptLineItem', () {
    test('creates with required fields only', () {
      const item = ReceiptLineItem(
        rawText: 'LEITE UHT 1L 1.29',
        productName: 'Leite UHT 1L',
        quantity: 1,
        totalPrice: 1.29,
      );

      expect(item.rawText, 'LEITE UHT 1L 1.29');
      expect(item.productName, 'Leite UHT 1L');
      expect(item.quantity, 1);
      expect(item.totalPrice, 1.29);
      expect(item.unitPrice, isNull);
      expect(item.matchedShoppingItemId, isNull);
      expect(item.matchConfidence, 0.0);
    });

    test('creates with all optional fields', () {
      const item = ReceiptLineItem(
        rawText: 'OVOS L 2x 2.19',
        productName: 'Ovos L',
        quantity: 2,
        unitPrice: 2.19,
        totalPrice: 4.38,
        matchedShoppingItemId: 'item-42',
        matchConfidence: 0.85,
      );

      expect(item.unitPrice, 2.19);
      expect(item.matchedShoppingItemId, 'item-42');
      expect(item.matchConfidence, 0.85);
    });

    test('copyWith replaces fields', () {
      const original = ReceiptLineItem(
        rawText: 'PAN 500G 0.89',
        productName: 'Pan 500g',
        quantity: 1,
        totalPrice: 0.89,
      );

      final updated = original.copyWith(
        matchedShoppingItemId: 'item-7',
        matchConfidence: 0.92,
      );

      expect(updated.rawText, original.rawText);
      expect(updated.productName, original.productName);
      expect(updated.matchedShoppingItemId, 'item-7');
      expect(updated.matchConfidence, 0.92);
    });

    test('equality holds for identical field values', () {
      const a = ReceiptLineItem(
        rawText: 'X',
        productName: 'X',
        quantity: 1,
        totalPrice: 1.0,
      );
      const b = ReceiptLineItem(
        rawText: 'X',
        productName: 'X',
        quantity: 1,
        totalPrice: 1.0,
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('ParsedReceipt', () {
    final receiptDate = DateTime(2026, 3, 9, 14, 30);

    test('creates from QR data with no line items', () {
      final receipt = ParsedReceipt(
        merchantNif: '123456789',
        totalAmount: 42.50,
        date: receiptDate,
        rawQrData: 'A:123456789*B:999999990*C:PT*D:FT 1/1*E:N*F:20260309*H:0*I1:PT42.50*N:0.00*O:42.50*Q:ABCD*R:1234',
      );

      expect(receipt.merchantNif, '123456789');
      expect(receipt.merchantName, isNull);
      expect(receipt.consumerNif, isNull);
      expect(receipt.totalAmount, 42.50);
      expect(receipt.taxAmount, isNull);
      expect(receipt.date, receiptDate);
      expect(receipt.atcud, isNull);
      expect(receipt.lineItems, isEmpty);
      expect(receipt.hasLineItems, isFalse);
      expect(receipt.rawQrData, isNotNull);
    });

    test('creates with full data including line items', () {
      const items = [
        ReceiptLineItem(
          rawText: 'LEITE 1.29',
          productName: 'Leite',
          quantity: 2,
          unitPrice: 1.29,
          totalPrice: 2.58,
        ),
        ReceiptLineItem(
          rawText: 'PAO 0.79',
          productName: 'Pao',
          quantity: 1,
          totalPrice: 0.79,
        ),
      ];

      final receipt = ParsedReceipt(
        merchantNif: '987654321',
        merchantName: 'Pingo Doce',
        consumerNif: '111222333',
        totalAmount: 3.37,
        taxAmount: 0.52,
        date: receiptDate,
        atcud: 'ABCD-1234',
        lineItems: items,
        rawQrData: 'raw-qr-string',
      );

      expect(receipt.merchantName, 'Pingo Doce');
      expect(receipt.consumerNif, '111222333');
      expect(receipt.taxAmount, 0.52);
      expect(receipt.atcud, 'ABCD-1234');
      expect(receipt.lineItems, hasLength(2));
      expect(receipt.hasLineItems, isTrue);
    });

    test('itemsTotal sums line item prices correctly', () {
      final receipt = ParsedReceipt(
        merchantNif: '123456789',
        totalAmount: 10.0,
        date: receiptDate,
        lineItems: const [
          ReceiptLineItem(
            rawText: 'A',
            productName: 'A',
            quantity: 1,
            totalPrice: 3.50,
          ),
          ReceiptLineItem(
            rawText: 'B',
            productName: 'B',
            quantity: 2,
            totalPrice: 4.00,
          ),
          ReceiptLineItem(
            rawText: 'C',
            productName: 'C',
            quantity: 1,
            totalPrice: 2.50,
          ),
        ],
      );

      expect(receipt.itemsTotal, 10.0);
    });

    test('hasLineItems returns false when empty', () {
      final receipt = ParsedReceipt(
        merchantNif: '123456789',
        totalAmount: 5.00,
        date: receiptDate,
      );

      expect(receipt.hasLineItems, isFalse);
      expect(receipt.itemsTotal, 0.0);
    });

    test('copyWith replaces fields', () {
      final original = ParsedReceipt(
        merchantNif: '123456789',
        totalAmount: 10.0,
        date: receiptDate,
      );

      final updated = original.copyWith(
        merchantName: 'Continente',
        totalAmount: 15.0,
      );

      expect(updated.merchantNif, original.merchantNif);
      expect(updated.merchantName, 'Continente');
      expect(updated.totalAmount, 15.0);
      expect(updated.date, original.date);
    });

    test('equality holds for identical receipts', () {
      final a = ParsedReceipt(
        merchantNif: '123',
        totalAmount: 5.0,
        date: receiptDate,
        lineItems: const [
          ReceiptLineItem(
            rawText: 'X',
            productName: 'X',
            quantity: 1,
            totalPrice: 5.0,
          ),
        ],
      );
      final b = ParsedReceipt(
        merchantNif: '123',
        totalAmount: 5.0,
        date: receiptDate,
        lineItems: const [
          ReceiptLineItem(
            rawText: 'X',
            productName: 'X',
            quantity: 1,
            totalPrice: 5.0,
          ),
        ],
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
