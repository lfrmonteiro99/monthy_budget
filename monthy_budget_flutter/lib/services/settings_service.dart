import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

const _storageKey = 'orcamento_settings';

class SettingsService {
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJsonString(raw);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, settings.toJsonString());
  }
}
