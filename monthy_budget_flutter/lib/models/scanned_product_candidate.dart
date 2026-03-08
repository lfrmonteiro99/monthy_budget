import 'product.dart';

/// Source of a barcode lookup result.
enum BarcodeLookupSource { cached, bundled, manual }

/// Represents the result of scanning and looking up a barcode.
///
/// [matchedProduct] is non-null when a known product was found.
/// When no match is found the [barcode] is still populated so the UI
/// can present manual-entry fields pre-filled with the raw value.
class ScannedProductCandidate {
  final String barcode;
  final Product? matchedProduct;
  final double confidence;
  final BarcodeLookupSource source;

  const ScannedProductCandidate({
    required this.barcode,
    this.matchedProduct,
    this.confidence = 0.0,
    this.source = BarcodeLookupSource.manual,
  });

  bool get hasMatch => matchedProduct != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedProductCandidate &&
          barcode == other.barcode &&
          matchedProduct == other.matchedProduct &&
          confidence == other.confidence &&
          source == other.source;

  @override
  int get hashCode => Object.hash(barcode, matchedProduct, confidence, source);
}
