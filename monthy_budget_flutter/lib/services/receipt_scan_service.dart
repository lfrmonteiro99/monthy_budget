import '../models/actual_expense.dart';
import '../models/parsed_receipt.dart';
import '../models/purchase_record.dart';
import '../utils/atcud_parser.dart';
import '../utils/receipt_matcher.dart';
import '../utils/receipt_text_parser.dart';

class ReceiptScanService {
  ReceiptScanService._();

  static ParsedReceipt? parseQrCode(String qrData) {
    return AtcudParser.parse(qrData);
  }

  static ActualExpense buildExpense({
    required ParsedReceipt receipt,
    required String category,
  }) {
    final merchantLabel = receipt.merchantName ?? 'NIF ${receipt.merchantNif}';
    return ActualExpense.create(
      category: category,
      amount: receipt.totalAmount,
      date: receipt.date,
      description: 'Recibo: $merchantLabel',
    );
  }

  static PurchaseRecord buildPurchaseRecord(ParsedReceipt receipt) {
    return PurchaseRecord(
      id: 'pr_${DateTime.now().millisecondsSinceEpoch}',
      date: receipt.date,
      amount: receipt.totalAmount,
      itemCount: receipt.lineItems.length,
      items: receipt.lineItems.map((i) => i.productName).toList(),
    );
  }

  /// Process OCR text lines into a [ParsedReceipt].
  ///
  /// When [existingQrReceipt] is provided, OCR line items are merged into it
  /// (preserving the QR-sourced metadata like NIF, total, date).
  /// When no QR receipt exists and no items are parsed, returns null.
  static ParsedReceipt? processOcrText({
    required List<String> textLines,
    ParsedReceipt? existingQrReceipt,
  }) {
    final lineItems = ReceiptTextParser.parseLines(textLines);
    if (lineItems.isEmpty && existingQrReceipt == null) return null;

    final ocrTotal = ReceiptTextParser.extractTotal(textLines);

    if (existingQrReceipt != null) {
      return existingQrReceipt.copyWith(lineItems: lineItems);
    }

    return ParsedReceipt(
      merchantNif: '',
      totalAmount: ocrTotal ?? lineItems.fold(0.0, (s, i) => s + i.totalPrice),
      date: DateTime.now(),
      lineItems: lineItems,
    );
  }

  /// Reconcile receipt line items with a shopping list using fuzzy matching.
  ///
  /// Returns a new list of [ReceiptLineItem] with [matchedShoppingItemId] and
  /// [matchConfidence] populated for items that matched a shopping list entry.
  static List<ReceiptLineItem> reconcileItems({
    required List<ReceiptLineItem> lineItems,
    required Map<String, String> shoppingItems,
  }) {
    final matches = ReceiptMatcher.matchItems(
      lineItems.map((i) => i.productName).toList(),
      shoppingItems,
    );

    return lineItems.map((item) {
      final match = matches[item.productName];
      if (match != null) {
        return item.copyWith(
          matchedShoppingItemId: match.itemId,
          matchConfidence: match.confidence,
        );
      }
      return item;
    }).toList();
  }
}
