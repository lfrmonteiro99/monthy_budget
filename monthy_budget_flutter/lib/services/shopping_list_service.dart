import 'package:supabase_flutter/supabase_flutter.dart';
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
    final row = await _client
        .from('shopping_items')
        .insert(item.toSupabase(householdId))
        .select()
        .single();
    return ShoppingItem.fromSupabase(row);
  }

  Future<void> toggle(String id, bool checked) async {
    await _client.from('shopping_items').update({
      'checked': checked,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> remove(String id) async {
    await _client.from('shopping_items').delete().eq('id', id);
  }

  Future<void> clearChecked(String householdId) async {
    await _client
        .from('shopping_items')
        .delete()
        .eq('household_id', householdId)
        .eq('checked', true);
  }
}
