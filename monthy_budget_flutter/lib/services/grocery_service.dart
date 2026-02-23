import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grocery_data.dart';

/// Service that loads grocery price data.
///
/// Strategy: always load the bundled asset as the baseline, then layer a
/// remote/cached version on top — but ONLY if it contains strictly more
/// products.  This prevents a stale or empty remote from wiping out data
/// that is already baked into the app bundle.
class GroceryService {
  // v2 suffix intentionally evicts any cached empty JSON from earlier builds.
  static const _cacheKey = 'grocery_prices_cache_v2';
  static const _lastFetchKey = 'grocery_prices_last_fetch_v2';
  static const _assetPath = 'assets/grocery_prices.json';

  /// GitHub Pages URL where the daily-scraped JSON is published.
  static const _remoteUrl =
      'https://lfrmonteiro99.github.io/monthy_budget/grocery_prices.json';

  /// How often the app should try fetching fresh data (12 hours).
  static const _fetchTtl = Duration(hours: 12);

  Future<GroceryData> load() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Always load bundled asset — it is the guaranteed baseline.
    final bundled = await _loadBundledAsset();

    // 2. Try to get fresher data from remote or cache.
    GroceryData? external;
    if (_shouldFetchRemote(prefs)) {
      external = await _fetchRemote(prefs);
    }
    external ??= _loadFromPrefs(prefs);

    // 3. Only replace bundled data if external has strictly more products.
    //    This means a stale/empty remote (0 products) can never win.
    if (external != null &&
        external.products.length > bundled.products.length) {
      return external;
    }

    // 4. Bundled is our best source — persist it so the cache is warm.
    return bundled;
  }

  bool _shouldFetchRemote(SharedPreferences prefs) {
    final lastFetch = prefs.getInt(_lastFetchKey);
    if (lastFetch == null) return true;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastFetch;
    return elapsed >= _fetchTtl.inMilliseconds;
  }

  Future<GroceryData?> _fetchRemote(SharedPreferences prefs) async {
    try {
      final response = await http
          .get(Uri.parse(_remoteUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final raw = response.body;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final data = GroceryData.fromJson(json);

      await prefs.setString(_cacheKey, raw);
      await prefs.setInt(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);

      return data;
    } catch (_) {
      return null;
    }
  }

  GroceryData? _loadFromPrefs(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return GroceryData.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<GroceryData> _loadBundledAsset() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return GroceryData.fromJson(json);
    } catch (_) {
      return const GroceryData();
    }
  }
}
