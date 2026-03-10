import '../models/parsed_receipt.dart';

/// Parses OCR text lines from Portuguese supermarket receipts into
/// [ReceiptLineItem] objects.
///
/// Handles three common line formats:
///   1. NAME  QTD x PRICE  TOTAL  (e.g. "LEITE M/G UHT 1L  1 x 0.79  0.79")
///   2. NAME  QTDkg  TOTAL        (e.g. "BANANA  1.234kg  1.85")
///   3. NAME  TOTAL               (e.g. "SACO PLASTICO  0.10")
class ReceiptTextParser {
  ReceiptTextParser._();

  // --- skip patterns -------------------------------------------------------

  static final _skipKeywords = RegExp(
    r'^(SUBTOTAL|SUB[\s-]?TOTAL|TOTAL|IVA|DESCONTO|TROCO|'
    r'MULTIBANCO|VISA|MB\s*WAY|DINHEIRO|NIF|CONTRIB)',
    caseSensitive: false,
  );

  static final _postalCode = RegExp(r'^\d{4}-\d{3}');

  static final _address = RegExp(
    r'^(AV\.|RUA|TRAV\.|LARGO|PRA[CÇ]A|ESTRADA|EN\s)',
    caseSensitive: false,
  );

  static final _allCapsNoDigits = RegExp(r'^[A-ZÀ-ÚÇ\s]{2,}$');

  // --- line patterns -------------------------------------------------------

  /// Pattern 1: NAME  QTD x PRICE  TOTAL
  /// Captures: (1) name, (2) quantity, (3) unit price, (4) total price
  static final _qtyTimesPrice = RegExp(
    r'^(.+?)\s+'
    r'(\d+(?:[.,]\d+)?)\s*[xX]\s*(\d+(?:[.,]\d+)?)\s+'
    r'(\d+(?:[.,]\d+)?)\s*$',
  );

  /// Pattern 2: NAME  QTDkg  TOTAL
  /// Captures: (1) name, (2) weight, (3) total price
  static final _weightBased = RegExp(
    r'^(.+?)\s+'
    r'(\d+(?:[.,]\d+)?)\s*kg\s+'
    r'(\d+(?:[.,]\d+)?)\s*$',
    caseSensitive: false,
  );

  /// Pattern 3: NAME  TOTAL (single price at end)
  /// Captures: (1) name, (2) total price
  static final _nameAndPrice = RegExp(
    r'^(.+?)\s+(\d+(?:[.,]\d+)?)\s*$',
  );

  // --- public API ----------------------------------------------------------

  /// Parse a list of OCR text lines into [ReceiptLineItem] objects.
  ///
  /// Lines that match skip patterns (headers, totals, addresses, etc.) are
  /// silently ignored.
  static List<ReceiptLineItem> parseLines(List<String> lines) {
    final items = <ReceiptLineItem>[];

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (_shouldSkip(line)) continue;

      final item = _parseLine(line);
      if (item != null) items.add(item);
    }

    return items;
  }

  /// Scan [lines] from bottom to top and return the first numeric value on a
  /// line that starts with "TOTAL". Returns `null` when no total is found.
  static double? extractTotal(List<String> lines) {
    final totalPattern = RegExp(
      r'^TOTAL\s+(\d+(?:[.,]\d+)?)\s*$',
      caseSensitive: false,
    );

    for (var i = lines.length - 1; i >= 0; i--) {
      final line = lines[i].trim();
      final m = totalPattern.firstMatch(line);
      if (m != null) {
        return _parseNumber(m.group(1)!);
      }
    }

    return null;
  }

  // --- private helpers -----------------------------------------------------

  static bool _shouldSkip(String line) {
    if (_skipKeywords.hasMatch(line)) return true;
    if (_postalCode.hasMatch(line)) return true;
    if (_address.hasMatch(line)) return true;
    if (_allCapsNoDigits.hasMatch(line)) return true;
    return false;
  }

  static ReceiptLineItem? _parseLine(String line) {
    // Try pattern 1: QTD x PRICE  TOTAL
    var m = _qtyTimesPrice.firstMatch(line);
    if (m != null) {
      final qty = _parseNumber(m.group(2)!);
      final unit = _parseNumber(m.group(3)!);
      final total = _parseNumber(m.group(4)!);
      if (qty != null && unit != null && total != null) {
        return ReceiptLineItem(
          rawText: line,
          productName: _cleanName(m.group(1)!),
          quantity: qty,
          unitPrice: unit,
          totalPrice: total,
        );
      }
    }

    // Try pattern 2: weight-based (kg)
    m = _weightBased.firstMatch(line);
    if (m != null) {
      final weight = _parseNumber(m.group(2)!);
      final total = _parseNumber(m.group(3)!);
      if (weight != null && total != null) {
        return ReceiptLineItem(
          rawText: line,
          productName: _cleanName(m.group(1)!),
          quantity: weight,
          unitPrice: total / weight,
          totalPrice: total,
        );
      }
    }

    // Try pattern 3: NAME  TOTAL
    m = _nameAndPrice.firstMatch(line);
    if (m != null) {
      final total = _parseNumber(m.group(2)!);
      if (total != null) {
        return ReceiptLineItem(
          rawText: line,
          productName: _cleanName(m.group(1)!),
          quantity: 1,
          totalPrice: total,
        );
      }
    }

    return null;
  }

  /// Parse a numeric string that may use comma or dot as decimal separator.
  static double? _parseNumber(String s) {
    final normalized = s.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  /// Trim and collapse whitespace in a product name.
  static String _cleanName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
