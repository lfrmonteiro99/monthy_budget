import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grocery_data.dart';

class GroceryService {
  static const _cacheVersion = 3;
  static const _fetchTtl = Duration(hours: 12);

  Future<GroceryData> load({String countryCode = 'PT'}) async {
    final prefs = await SharedPreferences.getInstance();
    final market = countryCode.toUpperCase();

    if (_shouldFetchRemote(prefs, market)) {
      final remoteData = await _fetchRemote(prefs, market);
      if (remoteData != null) return remoteData;
    }

    final cached = _loadFromPrefs(prefs, market);
    if (cached != null) return cached;

    return _loadFromAsset(prefs, market);
  }

  bool _shouldFetchRemote(SharedPreferences prefs, String countryCode) {
    final lastFetch = prefs.getInt(_lastFetchKey(countryCode));
    if (lastFetch == null) return true;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastFetch;
    return elapsed >= _fetchTtl.inMilliseconds;
  }

  Future<GroceryData?> _fetchRemote(SharedPreferences prefs, String countryCode) async {
    try {
      final response = await http
          .get(Uri.parse(_remoteUrl(countryCode)))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        if (countryCode == 'PT') {
          return _fetchRemoteFallback(prefs);
        }
        return null;
      }

      final raw = response.body;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final data = GroceryData.fromJson(json);
      await prefs.setString(_cacheKey(countryCode), raw);
      await prefs.setInt(_lastFetchKey(countryCode), DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt(_cacheVersionKey(countryCode), _cacheVersion);
      return data;
    } catch (_) {
      if (countryCode == 'PT') {
        return _fetchRemoteFallback(prefs);
      }
      return null;
    }
  }

  Future<GroceryData?> _fetchRemoteFallback(SharedPreferences prefs) async {
    try {
      final response = await http
          .get(Uri.parse('https://lfrmonteiro99.github.io/monthy_budget/grocery_prices.json'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;
      final raw = response.body;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final data = GroceryData.fromJson(json);
      await prefs.setString(_cacheKey('PT'), raw);
      await prefs.setInt(_lastFetchKey('PT'), DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt(_cacheVersionKey('PT'), _cacheVersion);
      return data;
    } catch (_) {
      return null;
    }
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

  Future<GroceryData> _loadFromAsset(SharedPreferences prefs, String countryCode) async {
    try {
      final raw = await rootBundle.loadString(_assetPath(countryCode));
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final data = GroceryData.fromJson(json);
      await prefs.setString(_cacheKey(countryCode), raw);
      await prefs.setInt(_cacheVersionKey(countryCode), _cacheVersion);
      return data;
    } catch (_) {
      if (countryCode == 'PT') {
        try {
          final raw = await rootBundle.loadString('assets/grocery_prices.json');
          final json = jsonDecode(raw) as Map<String, dynamic>;
          final data = GroceryData.fromJson(json);
          await prefs.setString(_cacheKey('PT'), raw);
          await prefs.setInt(_cacheVersionKey('PT'), _cacheVersion);
          return data;
        } catch (_) {
          return const GroceryData();
        }
      }
      return const GroceryData();
    }
  }

  String _cacheKey(String countryCode) => 'grocery_prices_cache_${countryCode.toUpperCase()}';
  String _lastFetchKey(String countryCode) => 'grocery_prices_last_fetch_${countryCode.toUpperCase()}';
  String _cacheVersionKey(String countryCode) => 'grocery_prices_cache_version_${countryCode.toUpperCase()}';
  String _assetPath(String countryCode) => 'assets/grocery/${countryCode.toUpperCase()}/catalog.json';
  String _remoteUrl(String countryCode) => 'https://lfrmonteiro99.github.io/monthy_budget/assets/grocery/${countryCode.toUpperCase()}/catalog.json';
}
