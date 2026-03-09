// ignore_for_file: avoid_redundant_argument_values
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/parsed_receipt.dart';
import 'package:orcamento_mensal/services/receipt_scan_service.dart';

// Re-export is not automatic; ParsedReceipt and ReceiptLineItem must be
// imported directly from the models barrel.

void main() {
  group('ReceiptScanService', () {
    group('parseQrCode', () {
      test('parses valid ATCUD QR code', () {
        const qr = 'A:500100144*B:999999990*F:20260309*H:ATCUD12345*N:0.48*O:2.08';
        final receipt = ReceiptScanService.parseQrCode(qr);
        expect(receipt, isNotNull);
        expect(receipt!.merchantNif, '500100144');
        expect(receipt.totalAmount, 2.08);
        expect(receipt.date, DateTime(2026, 3, 9));
      });

      test('returns null for invalid QR data', () {
        expect(ReceiptScanService.parseQrCode(''), isNull);
        expect(ReceiptScanService.parseQrCode('random text'), isNull);
      });
    });

    group('buildExpense', () {
      test('creates ActualExpense from receipt with merchant name', () {
        final receipt = ParsedReceipt(
          merchantNif: '500100144',
          merchantName: 'Continente',
          totalAmount: 15.50,
          date: DateTime(2026, 3, 9),
        );
        final expense = ReceiptScanService.buildExpense(
          receipt: receipt,
          category: 'alimentacao',
        );
        expect(expense.category, 'alimentacao');
        expect(expense.amount, 15.50);
        expect(expense.date, DateTime(2026, 3, 9));
        expect(expense.description, 'Recibo: Continente');
      });

      test('falls back to NIF when merchant name is null', () {
        final receipt = ParsedReceipt(
          merchantNif: '500100144',
          totalAmount: 10.00,
          date: DateTime(2026, 3, 9),
        );
        final expense = ReceiptScanService.buildExpense(
          receipt: receipt,
          category: 'alimentacao',
        );
        expect(expense.description, 'Recibo: NIF 500100144');
      });
    });

    group('buildPurchaseRecord', () {
      test('creates PurchaseRecord from receipt', () {
        final receipt = ParsedReceipt(
          merchantNif: '500100144',
          totalAmount: 2.08,
          date: DateTime(2026, 3, 9),
          lineItems: [
            const ReceiptLineItem(
              rawText: 'LEITE',
              productName: 'LEITE',
              quantity: 1,
              totalPrice: 0.79,
            ),
            const ReceiptLineItem(
              rawText: 'PAO',
              productName: 'PAO',
              quantity: 1,
              totalPrice: 1.29,
            ),
          ],
        );
        final record = ReceiptScanService.buildPurchaseRecord(receipt);
        expect(record.amount, 2.08);
        expect(record.itemCount, 2);
        expect(record.items, ['LEITE', 'PAO']);
      });
    });

    group('processOcrText', () {
      test('creates receipt from OCR text lines', () {
        final receipt = ReceiptScanService.processOcrText(
          textLines: [
            'LEITE M/G UHT 1L          1 x 0.79    0.79',
            'PÃO FORMA INTEGRAL        1 x 1.29    1.29',
            'TOTAL                                  2.08',
          ],
        );
        expect(receipt, isNotNull);
        expect(receipt!.lineItems, hasLength(2));
        expect(receipt.totalAmount, 2.08);
      });

      test('complements existing QR receipt with OCR line items', () {
        final qrReceipt = ParsedReceipt(
          merchantNif: '500100144',
          merchantName: 'Continente',
          totalAmount: 2.08,
          date: DateTime(2026, 3, 9),
        );
        final receipt = ReceiptScanService.processOcrText(
          textLines: [
            'LEITE M/G UHT 1L          1 x 0.79    0.79',
            'PÃO FORMA INTEGRAL        1 x 1.29    1.29',
          ],
          existingQrReceipt: qrReceipt,
        );
        expect(receipt, isNotNull);
        expect(receipt!.merchantName, 'Continente');
        expect(receipt.lineItems, hasLength(2));
        expect(receipt.totalAmount, 2.08); // preserves QR total
      });

      test('returns null when no items and no QR receipt', () {
        final receipt = ReceiptScanService.processOcrText(textLines: []);
        expect(receipt, isNull);
      });
    });

    group('reconcileItems', () {
      test('matches receipt items to shopping list via fuzzy matching', () {
        final lineItems = [
          const ReceiptLineItem(
            rawText: 'LEITE M/G UHT 1L',
            productName: 'LEITE M/G UHT 1L',
            quantity: 1,
            totalPrice: 0.79,
          ),
          const ReceiptLineItem(
            rawText: 'SACO PLASTICO',
            productName: 'SACO PLASTICO',
            quantity: 1,
            totalPrice: 0.10,
          ),
        ];
        final shoppingItems = {'item-1': 'Leite'};

        final matched = ReceiptScanService.reconcileItems(
          lineItems: lineItems,
          shoppingItems: shoppingItems,
        );

        expect(matched, hasLength(2));
        // Leite should match
        final leiteItem =
            matched.firstWhere((i) => i.productName == 'LEITE M/G UHT 1L');
        expect(leiteItem.matchedShoppingItemId, isNotNull);
        // Saco plastico should NOT match
        final sacoItem =
            matched.firstWhere((i) => i.productName == 'SACO PLASTICO');
        expect(sacoItem.matchedShoppingItemId, isNull);
      });

      test('returns unchanged items when shopping list is empty', () {
        final lineItems = [
          const ReceiptLineItem(
            rawText: 'X',
            productName: 'Leite',
            quantity: 1,
            totalPrice: 0.79,
          ),
        ];
        final matched = ReceiptScanService.reconcileItems(
          lineItems: lineItems,
          shoppingItems: {},
        );
        expect(matched, hasLength(1));
        expect(matched.first.matchedShoppingItemId, isNull);
      });
    });
  });
}
