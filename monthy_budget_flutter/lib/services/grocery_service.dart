import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grocery_data.dart';

/// Service that loads grocery price data from the bundled JSON asset
/// and caches it in SharedPreferences (same pattern as SettingsService).
class GroceryService {
  static const _cacheKey = 'grocery_prices_cache';
  static const _assetPath = 'assets/grocery_prices.json';

  /// Load grocery data. Tries the bundled asset first, falls back to cache.
  Future<GroceryData> load() async {
    try {
      // Load from the bundled asset (updated by GitHub Actions daily)
      final raw = await rootBundle.loadString(_assetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final data = GroceryData.fromJson(json);

      // Cache it in SharedPreferences for offline access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, raw);

      return data;
    } catch (_) {
      // Fallback: try loading from cache
      return _loadFromCache();
    }
  }

  Future<GroceryData> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return GroceryData.fromJson(json);
      }
    } catch (_) {}
    return const GroceryData();
  }
}
