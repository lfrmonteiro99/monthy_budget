import 'dart:convert';

import '../../models/app_settings.dart';
import '../../models/custom_category.dart';
import '../local/qa_local_store.dart';
import '../settings_repository.dart';
import 'qa_collections.dart';

class QaSettingsRepository implements SettingsRepository {
  QaSettingsRepository(this._store, {required DateTime Function() now})
    : _now = now;

  final QaLocalStore _store;
  final DateTime Function() _now;

  // Single-row tables in Supabase, keyed by household — one fixed doc id here.
  static const _settingsDoc = 'settings';
  static const _favoritesDoc = 'favorites';

  @override
  Future<AppSettings> loadSettings(String householdId) async {
    final row = await _store.get(
      QaCollections.householdSettings,
      householdId,
      _settingsDoc,
    );
    if (row == null) return const AppSettings();
    try {
      return AppSettings.fromJsonString(row['settings_json'] as String);
    } catch (_) {
      return const AppSettings();
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings, String householdId) {
    return _store
        .put(QaCollections.householdSettings, householdId, _settingsDoc, {
          'household_id': householdId,
          'settings_json': settings.toJsonString(),
          'updated_at': _now().toIso8601String(),
        });
  }

  @override
  Future<List<CustomCategory>> loadCategories(String householdId) async {
    final rows = await _store.query(
      QaCollections.customCategories,
      householdId,
    );
    final categories = rows.map(CustomCategory.fromSupabase).toList();
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return categories;
  }

  @override
  Future<void> saveCategory(CustomCategory category, String householdId) {
    return _store.put(
      QaCollections.customCategories,
      householdId,
      category.id,
      category.toSupabase(householdId),
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    final rows = await _store.queryAll(QaCollections.customCategories);
    for (final row in rows) {
      if (row['id'] != id) continue;
      await _store.delete(
        QaCollections.customCategories,
        row['household_id'] as String,
        id,
      );
      return;
    }
  }

  @override
  Future<List<String>> loadFavorites(String householdId) async {
    final row = await _store.get(
      QaCollections.householdFavorites,
      householdId,
      _favoritesDoc,
    );
    if (row == null) return [];
    try {
      return List<String>.from(jsonDecode(row['favorites_json'] as String));
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveFavorites(List<String> favorites, String householdId) {
    return _store
        .put(QaCollections.householdFavorites, householdId, _favoritesDoc, {
          'household_id': householdId,
          'favorites_json': jsonEncode(favorites),
          'updated_at': _now().toIso8601String(),
        });
  }
}
