import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/grocery_data.dart';

typedef GroceryAssetLoader = Future<String> Function(String path);

/// Service that loads grocery price data.
///
/// Fetch order:
///   1. Remote - if TTL has expired
///   2. SharedPreferences cache - if remote fails or TTL hasn't expired
///   3. Bundled asset - first-launch fallback
class GroceryService {
  GroceryService({
    GroceryAssetLoader? assetLoader,
    http.Client? httpClient,
  }) : _assetLoader = assetLoader ?? rootBundle.loadString,
       _httpClient = httpClient ?? http.Client();

  final GroceryAssetLoader _assetLoader;
  final http.Client _httpClient;

  static const _cacheKeyPrefix = 'grocery_prices_cache';
  static const _lastFetchKeyPrefix = 'grocery_prices_last_fetch';
  static const _cacheVersionKeyPrefix = 'grocery_prices_cache_version';
  static const _legacyAssetPath = 'assets/grocery_prices.json';
  static const _remoteBaseUrl =
      'https://lfrmonteiro99.github.io/monthy_budget';

  // Bump this constant to force-invalidate stale caches on all devices.
  static const _cacheVersion = 2;

  /// How often the app should try fetching fresh data (12 hours).
  static const _fetchTtl = Duration(hours: 12);

  /// Load grocery data.
  /// Tries remote first (if stale), then cache, then bundled asset.
  Future<GroceryData> load({String countryCode = 'PT'}) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedCountryCode = _normalizeCountryCode(countryCode);

    if (_shouldFetchRemote(prefs, normalizedCountryCode)) {
      final remoteData = await _fetchRemote(prefs, normalizedCountryCode);
      if (remoteData != null) return remoteData;
    }

    final cached = _loadFromPrefs(prefs, normalizedCountryCode);
    if (cached != null) return cached;

    return _loadFromAsset(prefs, normalizedCountryCode);
  }

  bool _shouldFetchRemote(SharedPreferences prefs, String countryCode) {
    final lastFetch = prefs.getInt(_lastFetchKey(countryCode));
    if (lastFetch == null) return true;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastFetch;
    return elapsed >= _fetchTtl.inMilliseconds;
  }

  Future<GroceryData?> _fetchRemote(
    SharedPreferences prefs,
    String countryCode,
  ) async {
    for (final remoteUrl in _remoteUrlsForCountry(countryCode)) {
      try {
        final response = await _httpClient
            .get(Uri.parse(remoteUrl))
            .timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) continue;

        final raw = response.body;
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final data = GroceryData.fromJson(json);

        await prefs.setString(_cacheKey(countryCode), raw);
        await prefs.setInt(
          _lastFetchKey(countryCode),
          DateTime.now().millisecondsSinceEpoch,
        );
        await prefs.setInt(_cacheVersionKey(countryCode), _cacheVersion);

        return data;
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  GroceryData? _loadFromPrefs(SharedPreferences prefs, String countryCode) {
    try {
      final storedVersion = prefs.getInt(_cacheVersionKey(countryCode)) ?? 1;
      if (storedVersion != _cacheVersion) {
        prefs.remove(_cacheKey(countryCode));
        prefs.remove(_lastFetchKey(countryCode));
        prefs.remove(_cacheVersionKey(countryCode));
        return null;
      }
      final raw = prefs.getString(_cacheKey(countryCode));
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return GroceryData.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<GroceryData> _loadFromAsset(
    SharedPreferences prefs,
    String countryCode,
  ) async {
    for (final assetPath in _assetPathsForCountry(countryCode)) {
      try {
        final raw = await _assetLoader(assetPath);
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final data = GroceryData.fromJson(json);

        await prefs.setString(_cacheKey(countryCode), raw);
        await prefs.setInt(_cacheVersionKey(countryCode), _cacheVersion);

        return data;
      } catch (_) {
        continue;
      }
    }
    return const GroceryData();
  }

  static String _normalizeCountryCode(String countryCode) =>
      countryCode.trim().toUpperCase();

  static String _cacheKey(String countryCode) =>
      '${_cacheKeyPrefix}_${_normalizeCountryCode(countryCode)}';

  static String _lastFetchKey(String countryCode) =>
      '${_lastFetchKeyPrefix}_${_normalizeCountryCode(countryCode)}';

  static String _cacheVersionKey(String countryCode) =>
      '${_cacheVersionKeyPrefix}_${_normalizeCountryCode(countryCode)}';

  static List<String> _assetPathsForCountry(String countryCode) {
    final normalized = _normalizeCountryCode(countryCode);
    final paths = <String>['assets/grocery/$normalized/catalog.json'];
    if (normalized == 'PT') {
      paths.add(_legacyAssetPath);
    }
    return paths;
  }

  static List<String> _remoteUrlsForCountry(String countryCode) {
    final normalized = _normalizeCountryCode(countryCode);
    final urls = <String>[
      '$_remoteBaseUrl/assets/grocery/$normalized/catalog.json',
    ];
    if (normalized == 'PT') {
      urls.add('$_remoteBaseUrl/grocery_prices.json');
    }
    return urls;
  }
}
