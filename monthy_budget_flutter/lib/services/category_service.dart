import '../models/custom_category.dart';
import '../repositories/settings_repository.dart';

class CategoryService {
  final SettingsRepository _repository;

  CategoryService({SettingsRepository? repository})
    : _repository = repository ?? SupabaseSettingsRepository();

  Future<List<CustomCategory>> load(String householdId) {
    return _repository.loadCategories(householdId);
  }

  Future<void> save(CustomCategory category, String householdId) {
    return _repository.saveCategory(category, householdId);
  }

  Future<void> delete(String id) {
    return _repository.deleteCategory(id);
  }
}
