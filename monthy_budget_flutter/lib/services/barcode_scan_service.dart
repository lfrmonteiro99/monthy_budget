import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/product.dart';
import '../models/scanned_product_candidate.dart';

/// Orchestrates barcode scanning lookup.
///
/// Lookup order:
///   1. In-memory cached product barcode map (from Supabase products)
///   2. Bundled asset barcode map
///   3. Manual fallback (no match)
class BarcodeScanService {
  /// Products loaded from Supabase that have barcodes.
  List<Product> _cachedProducts = [];

  /// Bundled barcode-to-product-name map loaded from asset.
  Map<String, Map<String, dynamic>>? _bundledMap;

  static const _bundledAssetPath = 'assets/barcode_products.json';

  /// Update the cached product list (call when products are loaded from DB).
  void updateCachedProducts(List<Product> products) {
    _cachedProducts = products;
  }

  /// Look up a barcode and return a candidate result.
  Future<ScannedProductCandidate> lookup(String barcode) async {
    // 1. Check cached products (from Supabase)
    final cachedMatch = _findInCachedProducts(barcode);
    if (cachedMatch != null) {
      return ScannedProductCandidate(
        barcode: barcode,
        matchedProduct: cachedMatch,
        confidence: 1.0,
        source: BarcodeLookupSource.cached,
      );
    }

    // 2. Check bundled asset
    final bundledMatch = await _findInBundledAsset(barcode);
    if (bundledMatch != null) {
      return ScannedProductCandidate(
        barcode: barcode,
        matchedProduct: bundledMatch,
        confidence: 0.8,
        source: BarcodeLookupSource.bundled,
      );
    }

    // 3. Manual fallback
    return ScannedProductCandidate(
      barcode: barcode,
      source: BarcodeLookupSource.manual,
    );
  }

  Product? _findInCachedProducts(String barcode) {
    for (final product in _cachedProducts) {
      if (product.barcode != null && product.barcode == barcode) {
        return product;
      }
    }
    return null;
  }

  Future<Product?> _findInBundledAsset(String barcode) async {
    _bundledMap ??= await _loadBundledMap();
    final entry = _bundledMap?[barcode];
    if (entry == null) return null;
    return Product(
      id: 'bundled_$barcode',
      name: entry['name'] as String? ?? '',
      category: entry['category'] as String? ?? '',
      avgPrice: (entry['avg_price'] as num?)?.toDouble() ?? 0,
      unit: entry['unit'] as String? ?? 'un',
      barcode: barcode,
    );
  }

  Future<Map<String, Map<String, dynamic>>> _loadBundledMap() async {
    try {
      final raw = await rootBundle.loadString(_bundledAssetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return json.map(
        (key, value) =>
            MapEntry(key, Map<String, dynamic>.from(value as Map)),
      );
    } catch (_) {
      return {};
    }
  }
}
