import '../models/app_settings.dart';
import '../repositories/settings_repository.dart';

class SettingsService {
  final SettingsRepository _repository;

  SettingsService({SettingsRepository? repository})
    : _repository = repository ?? SupabaseSettingsRepository();

  Future<AppSettings> load(String householdId) {
    return _repository.loadSettings(householdId);
  }

  Future<void> save(AppSettings settings, String householdId) {
    return _repository.saveSettings(settings, householdId);
  }
}
