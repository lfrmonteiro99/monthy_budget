import '../models/custom_category.dart';
import '../repositories/settings_repository.dart';

class CategoryService {
  SettingsRepository? _repository;

  CategoryService({SettingsRepository? repository})
    : _repository = repository;

  SettingsRepository get _resolvedRepository =>
      _repository ??= SupabaseSettingsRepository();

  Future<List<CustomCategory>> load(String householdId) {
    return _resolvedRepository.loadCategories(householdId);
  }

  Future<void> save(CustomCategory category, String householdId) {
    return _resolvedRepository.saveCategory(category, householdId);
  }

  Future<void> delete(String id) {
    return _resolvedRepository.deleteCategory(id);
  }
}
