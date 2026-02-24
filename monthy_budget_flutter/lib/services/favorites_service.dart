import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesService {
  final _client = Supabase.instance.client;

  Future<List<String>> load(String householdId) async {
    final row = await _client
        .from('household_favorites')
        .select('favorites_json')
        .eq('household_id', householdId)
        .maybeSingle();

    if (row == null) return [];
    try {
      return List<String>.from(jsonDecode(row['favorites_json'] as String));
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<String> favorites, String householdId) async {
    await _client.from('household_favorites').upsert({
      'household_id': householdId,
      'favorites_json': jsonEncode(favorites),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
