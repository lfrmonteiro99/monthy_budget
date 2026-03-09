import 'package:flutter/foundation.dart';

class ReceiptLineItem {
  final String rawText;
  final String productName;
  final double quantity;
  final double? unitPrice;
  final double totalPrice;
  final String? matchedShoppingItemId;
  final double matchConfidence;

  const ReceiptLineItem({
    required this.rawText,
    required this.productName,
    required this.quantity,
    this.unitPrice,
    required this.totalPrice,
    this.matchedShoppingItemId,
    this.matchConfidence = 0.0,
  });

  ReceiptLineItem copyWith({
    String? rawText,
    String? productName,
    double? quantity,
    double? unitPrice,
    double? totalPrice,
    String? matchedShoppingItemId,
    double? matchConfidence,
  }) {
    return ReceiptLineItem(
      rawText: rawText ?? this.rawText,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      matchedShoppingItemId:
          matchedShoppingItemId ?? this.matchedShoppingItemId,
      matchConfidence: matchConfidence ?? this.matchConfidence,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptLineItem &&
          rawText == other.rawText &&
          productName == other.productName &&
          quantity == other.quantity &&
          unitPrice == other.unitPrice &&
          totalPrice == other.totalPrice &&
          matchedShoppingItemId == other.matchedShoppingItemId &&
          matchConfidence == other.matchConfidence;

  @override
  int get hashCode => Object.hash(
        rawText,
        productName,
        quantity,
        unitPrice,
        totalPrice,
        matchedShoppingItemId,
        matchConfidence,
      );
}

class ParsedReceipt {
  final String merchantNif;
  final String? merchantName;
  final String? consumerNif;
  final double totalAmount;
  final double? taxAmount;
  final DateTime date;
  final String? atcud;
  final List<ReceiptLineItem> lineItems;
  final String? rawQrData;

  const ParsedReceipt({
    required this.merchantNif,
    this.merchantName,
    this.consumerNif,
    required this.totalAmount,
    this.taxAmount,
    required this.date,
    this.atcud,
    this.lineItems = const [],
    this.rawQrData,
  });

  bool get hasLineItems => lineItems.isNotEmpty;

  double get itemsTotal =>
      lineItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  ParsedReceipt copyWith({
    String? merchantNif,
    String? merchantName,
    String? consumerNif,
    double? totalAmount,
    double? taxAmount,
    DateTime? date,
    String? atcud,
    List<ReceiptLineItem>? lineItems,
    String? rawQrData,
  }) {
    return ParsedReceipt(
      merchantNif: merchantNif ?? this.merchantNif,
      merchantName: merchantName ?? this.merchantName,
      consumerNif: consumerNif ?? this.consumerNif,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      date: date ?? this.date,
      atcud: atcud ?? this.atcud,
      lineItems: lineItems ?? this.lineItems,
      rawQrData: rawQrData ?? this.rawQrData,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsedReceipt &&
          merchantNif == other.merchantNif &&
          merchantName == other.merchantName &&
          consumerNif == other.consumerNif &&
          totalAmount == other.totalAmount &&
          taxAmount == other.taxAmount &&
          date == other.date &&
          atcud == other.atcud &&
          listEquals(lineItems, other.lineItems) &&
          rawQrData == other.rawQrData;

  @override
  int get hashCode => Object.hash(
        merchantNif,
        merchantName,
        consumerNif,
        totalAmount,
        taxAmount,
        date,
        atcud,
        Object.hashAll(lineItems),
        rawQrData,
      );
}
