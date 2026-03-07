import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CachedPattern {
  final String action;
  final Map<String, dynamic> params;

  const CachedPattern({required this.action, required this.params});

  Map<String, dynamic> toJson() => {
        'action': action,
        'params': params,
      };

  factory CachedPattern.fromJson(Map<String, dynamic> json) => CachedPattern(
        action: json['action'] as String,
        params: Map<String, dynamic>.from(json['params'] as Map),
      );
}

class CommandPatternCache {
  static const _prefsKey = 'command_pattern_cache';
  static final _numberPattern = RegExp(r'\d+([.,]\d+)?');

  final int maxEntries;
  final Map<String, CachedPattern> _cache = {};

  CommandPatternCache({this.maxEntries = 100});

  // ── Public API ─────────────────────────────────────────────────────

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;

    final map = jsonDecode(raw) as Map<String, dynamic>;
    _cache.clear();
    for (final entry in map.entries) {
      _cache[entry.key] =
          CachedPattern.fromJson(entry.value as Map<String, dynamic>);
    }
  }

  CachedPattern? match(String input) {
    final normalized = _normalize(input);
    final cached = _cache[normalized];
    if (cached == null) return null;

    // LRU: move to end
    _cache.remove(normalized);
    _cache[normalized] = cached;

    // If the new input contains numbers, substitute `amount` param
    final numbers = _extractNumbers(input);
    if (numbers.isNotEmpty && cached.params.containsKey('amount')) {
      final updatedParams = Map<String, dynamic>.from(cached.params);
      updatedParams['amount'] = numbers.first;
      return CachedPattern(action: cached.action, params: updatedParams);
    }

    return cached;
  }

  Future<void> store({
    required String input,
    required String action,
    required Map<String, dynamic> params,
  }) async {
    final normalized = _normalize(input);

    // LRU eviction
    if (!_cache.containsKey(normalized) && _cache.length >= maxEntries) {
      _cache.remove(_cache.keys.first);
    }

    // Remove if exists so re-insert moves to end
    _cache.remove(normalized);
    _cache[normalized] = CachedPattern(action: action, params: params);

    await _persist();
  }

  Future<void> clear() async {
    _cache.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  // ── Private helpers ────────────────────────────────────────────────

  String _normalize(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll(_numberPattern, '#NUM')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  List<double> _extractNumbers(String input) {
    return _numberPattern
        .allMatches(input)
        .map((m) => double.tryParse(m.group(0)!.replaceAll(',', '.')))
        .whereType<double>()
        .toList();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _cache.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_prefsKey, jsonEncode(map));
  }
}
