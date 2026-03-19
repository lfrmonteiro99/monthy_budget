import '../repositories/settings_repository.dart';

class FavoritesService {
  SettingsRepository? _repository;

  FavoritesService({SettingsRepository? repository})
    : _repository = repository;

  SettingsRepository get _resolvedRepository =>
      _repository ??= SupabaseSettingsRepository();

  Future<List<String>> load(String householdId) {
    return _resolvedRepository.loadFavorites(householdId);
  }

  Future<void> save(List<String> favorites, String householdId) {
    return _resolvedRepository.saveFavorites(favorites, householdId);
  }
}
