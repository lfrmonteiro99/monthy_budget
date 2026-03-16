/// Utility for converting between compatible measurement units (mass, volume).
///
/// Supports: kg ↔ g, L ↔ mL (case-sensitive keys except 'l' alias for 'L').
/// Unknown units pass through unchanged.
class UnitConverter {
  static const _toBase = <String, ({String base, double factor})>{
    'kg': (base: 'kg', factor: 1.0),
    'g': (base: 'kg', factor: 0.001),
    'L': (base: 'L', factor: 1.0),
    'l': (base: 'L', factor: 1.0),
    'mL': (base: 'L', factor: 0.001),
    'ml': (base: 'L', factor: 0.001),
  };

  /// Normalize quantity to base unit (kg, L). Returns (normalizedQty, baseUnit).
  static (double, String) normalize(double qty, String unit) {
    final entry = _toBase[unit];
    if (entry == null) return (qty, unit);
    return (qty * entry.factor, entry.base);
  }

  /// Check if two units are compatible (same dimension).
  static bool compatible(String a, String b) {
    final baseA = _toBase[a]?.base ?? a;
    final baseB = _toBase[b]?.base ?? b;
    return baseA == baseB;
  }

  /// Convert qty from [from] unit to [to] unit. Returns null if incompatible.
  static double? convert(double qty, String from, String to) {
    if (!compatible(from, to)) return null;
    final (normalized, _) = normalize(qty, from);
    final toEntry = _toBase[to];
    if (toEntry == null) return null;
    return normalized / toEntry.factor;
  }

  /// Format quantity for display: 1500 g → 1.5 kg, 2000 mL → 2 L.
  /// Quantities >= 1 in the base unit use the base (kg / L);
  /// quantities < 1 in the base unit use the sub-unit (g / mL).
  static (double, String) displayFriendly(double qty, String unit) {
    final (baseQty, baseUnit) = normalize(qty, unit);
    if (baseUnit == 'kg' && baseQty >= 1) return (baseQty, 'kg');
    if (baseUnit == 'kg' && baseQty < 1) return (baseQty * 1000, 'g');
    if (baseUnit == 'L' && baseQty >= 1) return (baseQty, 'L');
    if (baseUnit == 'L' && baseQty < 1) return (baseQty * 1000, 'mL');
    return (qty, unit);
  }
}
