import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_settings.dart';
import '../models/custom_category.dart';

abstract class SettingsRepository {
  Future<AppSettings> loadSettings(String householdId);
  Future<void> saveSettings(AppSettings settings, String householdId);
  Future<List<CustomCategory>> loadCategories(String householdId);
  Future<void> saveCategory(CustomCategory category, String householdId);
  Future<void> deleteCategory(String id);
  Future<List<String>> loadFavorites(String householdId);
  Future<void> saveFavorites(List<String> favorites, String householdId);
}

class SupabaseSettingsRepository implements SettingsRepository {
  final SupabaseClient _client;

  SupabaseSettingsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<AppSettings> loadSettings(String householdId) async {
    final row = await _client
        .from('household_settings')
        .select('settings_json')
        .eq('household_id', householdId)
        .maybeSingle();

    if (row == null) return const AppSettings();
    try {
      return AppSettings.fromJsonString(row['settings_json'] as String);
    } catch (_) {
      return const AppSettings();
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings, String householdId) {
    return _client.from('household_settings').upsert({
      'household_id': householdId,
      'settings_json': settings.toJsonString(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<CustomCategory>> loadCategories(String householdId) async {
    final rows = await _client
        .from('custom_categories')
        .select()
        .eq('household_id', householdId)
        .order('sort_order');

    return (rows as List<dynamic>)
        .map((r) => CustomCategory.fromSupabase(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveCategory(CustomCategory category, String householdId) {
    return _client
        .from('custom_categories')
        .upsert(category.toSupabase(householdId));
  }

  @override
  Future<void> deleteCategory(String id) {
    return _client.from('custom_categories').delete().eq('id', id);
  }

  @override
  Future<List<String>> loadFavorites(String householdId) async {
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

  @override
  Future<void> saveFavorites(List<String> favorites, String householdId) {
    return _client.from('household_favorites').upsert({
      'household_id': householdId,
      'favorites_json': jsonEncode(favorites),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
