import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grocery_data.dart';

/// Service that loads grocery price data.
///
/// Fetch order:
///   1. Remote (GitHub Pages) — if TTL has expired
///   2. SharedPreferences cache — if remote fails or TTL hasn't expired
///   3. Bundled asset — first-launch fallback
class GroceryService {
  static const _cacheKey = 'grocery_prices_cache';
  static const _lastFetchKey = 'grocery_prices_last_fetch';
  static const _assetPath = 'assets/grocery_prices.json';

  /// GitHub Pages URL where the daily-scraped JSON is published.
  /// Repo: lfrmonteiro99/monthy_budget  →  gh-pages branch
  static const _remoteUrl =
      'https://lfrmonteiro99.github.io/monthy_budget/grocery_prices.json';

  /// How often the app should try fetching fresh data (12 hours).
  static const _fetchTtl = Duration(hours: 12);

  /// Load grocery data.
  /// Tries remote first (if stale), then cache, then bundled asset.
  Future<GroceryData> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we should attempt a remote fetch
    if (_shouldFetchRemote(prefs)) {
      final remoteData = await _fetchRemote(prefs);
      if (remoteData != null) return remoteData;
    }

    // Try cached data
    final cached = _loadFromPrefs(prefs);
    if (cached != null) return cached;

    // First launch fallback: load from bundled asset
    return _loadFromAsset(prefs);
  }

  /// Returns true when the cache is older than [_fetchTtl] or doesn't exist.
  bool _shouldFetchRemote(SharedPreferences prefs) {
    final lastFetch = prefs.getInt(_lastFetchKey);
    if (lastFetch == null) return true;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastFetch;
    return elapsed >= _fetchTtl.inMilliseconds;
  }

  /// Fetch JSON from GitHub Pages, parse it, cache it. Returns null on failure.
  Future<GroceryData?> _fetchRemote(SharedPreferences prefs) async {
    try {
      final response = await http
          .get(Uri.parse(_remoteUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final raw = response.body;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final data = GroceryData.fromJson(json);

      // Persist to cache
      await prefs.setString(_cacheKey, raw);
      await prefs.setInt(
          _lastFetchKey, DateTime.now().millisecondsSinceEpoch);

      return data;
    } catch (_) {
      return null;
    }
  }

  /// Load from SharedPreferences cache. Returns null if empty.
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

  /// Load from the bundled asset and seed the cache.
  Future<GroceryData> _loadFromAsset(SharedPreferences prefs) async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final data = GroceryData.fromJson(json);

      // Seed the cache so subsequent loads don't need the asset
      await prefs.setString(_cacheKey, raw);

      return data;
    } catch (_) {
      return const GroceryData();
    }
  }
}
