import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'grocery_favorites';

class FavoritesService {
  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];
    try {
      return List<String>.from(json.decode(raw));
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(favorites));
  }
}
