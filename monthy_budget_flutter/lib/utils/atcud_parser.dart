import '../models/parsed_receipt.dart';

/// Parses Portuguese ATCUD QR code strings into [ParsedReceipt] objects.
///
/// ATCUD QR codes follow the format defined by Portuguese tax authority (AT),
/// with fields separated by '*' and key-value pairs separated by ':'.
///
/// Required fields: A (merchant NIF), F (date YYYYMMDD), O (total amount).
/// Optional fields: B (consumer NIF), H (ATCUD code), N (tax amount).
class AtcudParser {
  AtcudParser._();

  /// Returns true if [data] looks like an ATCUD QR code string.
  ///
  /// Checks for presence of 'A:' field marker, '*' separator, and 'O:' field.
  static bool isAtcudQrCode(String data) {
    return data.contains('A:') && data.contains('*') && data.contains('O:');
  }

  /// Parses an ATCUD QR code [raw] string into a [ParsedReceipt].
  ///
  /// Returns null if [raw] is empty, not a valid ATCUD string, or missing
  /// any required field (A, F, O), or if date/total values are malformed.
  static ParsedReceipt? parse(String raw) {
    if (raw.isEmpty || !isAtcudQrCode(raw)) {
      return null;
    }

    final fields = <String, String>{};
    for (final segment in raw.split('*')) {
      final separatorIndex = segment.indexOf(':');
      if (separatorIndex < 1) continue;
      final key = segment.substring(0, separatorIndex);
      final value = segment.substring(separatorIndex + 1);
      fields[key] = value;
    }

    // Required fields
    final merchantNif = fields['A'];
    final dateStr = fields['F'];
    final totalStr = fields['O'];

    if (merchantNif == null || dateStr == null || totalStr == null) {
      return null;
    }

    // Parse date (YYYYMMDD)
    final date = _parseDate(dateStr);
    if (date == null) return null;

    // Parse total amount
    final total = double.tryParse(totalStr);
    if (total == null) return null;

    // Optional fields
    final consumerNif = fields['B'];
    final atcud = fields['H'];
    final taxStr = fields['N'];
    final tax = taxStr != null ? double.tryParse(taxStr) : null;

    return ParsedReceipt(
      merchantNif: merchantNif,
      consumerNif: consumerNif,
      totalAmount: total,
      taxAmount: tax,
      date: date,
      atcud: atcud,
      rawQrData: raw,
    );
  }

  /// Parses a date string in YYYYMMDD format.
  static DateTime? _parseDate(String s) {
    if (s.length != 8) return null;
    final year = int.tryParse(s.substring(0, 4));
    final month = int.tryParse(s.substring(4, 6));
    final day = int.tryParse(s.substring(6, 8));
    if (year == null || month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return DateTime(year, month, day);
  }
}
