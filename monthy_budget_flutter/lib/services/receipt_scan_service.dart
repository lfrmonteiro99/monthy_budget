import '../models/actual_expense.dart';
import '../models/parsed_receipt.dart';
import '../models/purchase_record.dart';
import '../utils/atcud_parser.dart';

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
}
