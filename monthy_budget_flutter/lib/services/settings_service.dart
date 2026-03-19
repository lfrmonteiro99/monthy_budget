import '../models/app_settings.dart';
import '../repositories/settings_repository.dart';

class SettingsService {
  SettingsRepository? _repository;

  SettingsService({SettingsRepository? repository})
    : _repository = repository;

  SettingsRepository get _resolvedRepository =>
      _repository ??= SupabaseSettingsRepository();

  Future<AppSettings> load(String householdId) {
    return _resolvedRepository.loadSettings(householdId);
  }

  Future<void> save(AppSettings settings, String householdId) {
    return _resolvedRepository.saveSettings(settings, householdId);
  }
}
