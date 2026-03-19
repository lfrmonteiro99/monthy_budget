import '../repositories/settings_repository.dart';

class FavoritesService {
  final SettingsRepository _repository;

  FavoritesService({SettingsRepository? repository})
    : _repository = repository ?? SupabaseSettingsRepository();

  Future<List<String>> load(String householdId) {
    return _repository.loadFavorites(householdId);
  }

  Future<void> save(List<String> favorites, String householdId) {
    return _repository.saveFavorites(favorites, householdId);
  }
}
