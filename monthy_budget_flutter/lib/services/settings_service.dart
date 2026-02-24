import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_settings.dart';

class SettingsService {
  final _client = Supabase.instance.client;

  Future<AppSettings> load(String householdId) async {
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

  Future<void> save(AppSettings settings, String householdId) async {
    await _client.from('household_settings').upsert({
      'household_id': householdId,
      'settings_json': settings.toJsonString(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
