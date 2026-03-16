/// Lightweight unit converter for pantry quantity subtraction.
///
/// Supports mass (g, kg) and volume (ml, l, cl, dl) families.
/// Returns null when units are incompatible (e.g., kg vs ml).
class UnitConverter {
  UnitConverter._();

  // Conversion factors to a canonical base unit per family.
  // Mass family base: g
  // Volume family base: ml
  static const _massToGrams = <String, double>{
    'g': 1.0,
    'kg': 1000.0,
  };

  static const _volumeToMl = <String, double>{
    'ml': 1.0,
    'cl': 10.0,
    'dl': 100.0,
    'l': 1000.0,
  };

  /// Returns true if [a] and [b] are in the same unit family.
  static bool compatible(String a, String b) {
    final aLower = a.toLowerCase();
    final bLower = b.toLowerCase();
    if (aLower == bLower) return true;
    if (_massToGrams.containsKey(aLower) && _massToGrams.containsKey(bLower)) {
      return true;
    }
    if (_volumeToMl.containsKey(aLower) && _volumeToMl.containsKey(bLower)) {
      return true;
    }
    return false;
  }

  /// Converts [value] from [fromUnit] to [toUnit].
  /// Returns null if units are incompatible.
  static double? convert(double value, String fromUnit, String toUnit) {
    final from = fromUnit.toLowerCase();
    final to = toUnit.toLowerCase();
    if (from == to) return value;

    // Mass family
    final fromMass = _massToGrams[from];
    final toMass = _massToGrams[to];
    if (fromMass != null && toMass != null) {
      return value * fromMass / toMass;
    }

    // Volume family
    final fromVol = _volumeToMl[from];
    final toVol = _volumeToMl[to];
    if (fromVol != null && toVol != null) {
      return value * fromVol / toVol;
    }

    return null;
  }

  /// Normalize a quantity to its base unit (kg for mass, L for volume).
  /// Unknown units pass through unchanged.
  static (double, String) normalize(double qty, String unit) {
    final u = unit.toLowerCase();
    // Mass → kg
    if (_massToGrams.containsKey(u)) {
      final inGrams = qty * _massToGrams[u]!;
      return (inGrams / 1000, 'kg');
    }
    // Volume → L
    if (_volumeToMl.containsKey(u)) {
      final inMl = qty * _volumeToMl[u]!;
      return (inMl / 1000, 'L');
    }
    return (qty, unit);
  }

  /// Normalize a quantity to a display-friendly unit.
  /// E.g., 1500 g → (1.5, 'kg'), 2000 ml → (2.0, 'L').
  static (double, String) displayFriendly(double qty, String unit) {
    final u = unit.toLowerCase();
    // Mass: if ≥ 1000 g, show as kg
    if (u == 'g' && qty >= 1000) {
      return (qty / 1000, 'kg');
    }
    // Mass: if < 1 kg, show as g
    if (u == 'kg' && qty < 1) {
      return (qty * 1000, 'g');
    }
    // Volume: if ≥ 1000 ml, show as L
    if (u == 'ml' && qty >= 1000) {
      return (qty / 1000, 'L');
    }
    // Volume: if < 1 L, show as mL
    if (u == 'l' && qty < 1) {
      return (qty * 1000, 'mL');
    }
    return (qty, unit);
  }
}
