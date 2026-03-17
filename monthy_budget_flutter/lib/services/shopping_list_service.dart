import 'package:supabase_flutter/supabase_flutter.dart';
import '../exceptions/app_exceptions.dart';
import '../models/shopping_item.dart';

class ShoppingListService {
  final _client = Supabase.instance.client;

  /// Realtime stream — updates automatically whenever the table changes.
  Stream<List<ShoppingItem>> stream(String householdId) {
    return _client
        .from('shopping_items')
        .stream(primaryKey: ['id'])
        .eq('household_id', householdId)
        .order('created_at')
        .map((rows) => rows.map((r) => ShoppingItem.fromSupabase(r)).toList());
  }

  /// Inserts a new item and returns the server-persisted record (with UUID id).
  Future<ShoppingItem> add(ShoppingItem item, String householdId) async {
    try {
      final row = await _client
          .from('shopping_items')
          .insert(item.toSupabase(householdId))
          .select()
          .single();
      return ShoppingItem.fromSupabase(row);
    } catch (e, stack) {
      throw DataException('Failed to add shopping item', e, stack);
    }
  }

  /// Updates an existing item's quantity, price and optionally unit (used for aggregation).
  Future<void> updateItem(String id,
      {required double price, double? quantity, String? unit}) async {
    try {
      final data = <String, dynamic>{
        'price': price,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (quantity != null) data['quantity'] = quantity;
      if (unit != null) data['unit'] = unit;
      await _client.from('shopping_items').update(data).eq('id', id);
    } catch (e, stack) {
      throw DataException('Failed to update shopping item $id', e, stack);
    }
  }

  Future<void> toggle(String id, bool checked) async {
    try {
      await _client.from('shopping_items').update({
        'checked': checked,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e, stack) {
      throw DataException('Failed to toggle shopping item $id', e, stack);
    }
  }

  Future<void> remove(String id) async {
    try {
      await _client.from('shopping_items').delete().eq('id', id);
    } catch (e, stack) {
      throw DataException('Failed to remove shopping item $id', e, stack);
    }
  }

  Future<void> clearChecked(String householdId) async {
    try {
      await _client
          .from('shopping_items')
          .delete()
          .eq('household_id', householdId)
          .eq('checked', true);
    } catch (e, stack) {
      throw DataException('Failed to clear checked shopping items', e, stack);
    }
  }
}
