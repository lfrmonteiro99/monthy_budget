import '../exceptions/app_exceptions.dart';
import '../models/shopping_item.dart';
import '../repositories/shopping_repository.dart';

class ShoppingListService {
  final ShoppingRepository _repository;

  ShoppingListService({ShoppingRepository? repository})
    : _repository = repository ?? SupabaseShoppingRepository();

  Stream<List<ShoppingItem>> stream(String householdId) {
    return _repository.stream(householdId);
  }

  Future<ShoppingItem> add(ShoppingItem item, String householdId) async {
    try {
      return await _repository.add(item, householdId);
    } catch (e, stack) {
      throw DataException('Failed to add shopping item', e, stack);
    }
  }

  Future<void> updateItem(
    String id, {
    required double price,
    double? quantity,
    String? unit,
  }) async {
    try {
      await _repository.updateItem(
        id,
        price: price,
        quantity: quantity,
        unit: unit,
      );
    } catch (e, stack) {
      throw DataException('Failed to update shopping item $id', e, stack);
    }
  }

  Future<void> toggle(String id, bool checked) async {
    try {
      await _repository.toggle(id, checked);
    } catch (e, stack) {
      throw DataException('Failed to toggle shopping item $id', e, stack);
    }
  }

  Future<void> remove(String id) async {
    try {
      await _repository.remove(id);
    } catch (e, stack) {
      throw DataException('Failed to remove shopping item $id', e, stack);
    }
  }

  Future<void> clearChecked(String householdId) async {
    try {
      await _repository.clearChecked(householdId);
    } catch (e, stack) {
      throw DataException('Failed to clear checked shopping items', e, stack);
    }
  }
}
