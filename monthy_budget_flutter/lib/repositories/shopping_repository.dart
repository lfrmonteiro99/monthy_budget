import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/purchase_record.dart';
import '../models/shopping_item.dart';

abstract class ShoppingRepository {
  Stream<List<ShoppingItem>> stream(String householdId);
  Future<ShoppingItem> add(ShoppingItem item, String householdId);
  Future<void> updateItem(
    String id, {
    required double price,
    double? quantity,
    String? unit,
  });
  Future<void> toggle(String id, bool checked);
  Future<void> remove(String id);
  Future<void> clearChecked(String householdId);
}

class SupabaseShoppingRepository implements ShoppingRepository {
  final SupabaseClient _client;

  SupabaseShoppingRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Stream<List<ShoppingItem>> stream(String householdId) {
    return _client
        .from('shopping_items')
        .stream(primaryKey: ['id'])
        .eq('household_id', householdId)
        .order('created_at')
        .map((rows) => rows.map((row) => ShoppingItem.fromSupabase(row)).toList());
  }

  @override
  Future<ShoppingItem> add(ShoppingItem item, String householdId) async {
    final row = await _client
        .from('shopping_items')
        .insert(item.toSupabase(householdId))
        .select()
        .single();
    return ShoppingItem.fromSupabase(row);
  }

  @override
  Future<void> updateItem(
    String id, {
    required double price,
    double? quantity,
    String? unit,
  }) {
    final data = <String, dynamic>{
      'price': price,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (quantity != null) data['quantity'] = quantity;
    if (unit != null) data['unit'] = unit;
    return _client.from('shopping_items').update(data).eq('id', id);
  }

  @override
  Future<void> toggle(String id, bool checked) {
    return _client.from('shopping_items').update({
      'checked': checked,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  @override
  Future<void> remove(String id) {
    return _client.from('shopping_items').delete().eq('id', id);
  }

  @override
  Future<void> clearChecked(String householdId) {
    return _client
        .from('shopping_items')
        .delete()
        .eq('household_id', householdId)
        .eq('checked', true);
  }
}

abstract class PurchaseRepository {
  Future<PurchaseHistory> load(String householdId);
  Future<void> saveRecord(PurchaseRecord record, String householdId);
}

class SupabasePurchaseRepository implements PurchaseRepository {
  final SupabaseClient _client;

  SupabasePurchaseRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<PurchaseHistory> load(String householdId) async {
    final rows = await _client
        .from('purchase_records')
        .select()
        .eq('household_id', householdId)
        .order('purchased_at', ascending: false);

    final records = (rows as List<dynamic>).map((r) {
      final map = r as Map<String, dynamic>;
      List<String> items = [];
      if (map['items_json'] != null) {
        try {
          items = (jsonDecode(map['items_json'] as String) as List<dynamic>)
              .map((e) => e as String)
              .toList();
        } catch (_) {}
      }
      return PurchaseRecord(
        id: map['id'] as String,
        date: DateTime.parse(map['purchased_at'] as String),
        amount: (map['amount'] as num).toDouble(),
        itemCount: map['item_count'] as int,
        items: items,
        isMealPurchase: map['is_meal_purchase'] as bool? ?? false,
      );
    }).toList();

    return PurchaseHistory(records: records);
  }

  @override
  Future<void> saveRecord(PurchaseRecord record, String householdId) {
    return _client.from('purchase_records').insert({
      'id': record.id,
      'household_id': householdId,
      'amount': record.amount,
      'item_count': record.itemCount,
      'purchased_at': record.date.toIso8601String(),
      'items_json': jsonEncode(record.items),
      'is_meal_purchase': record.isMealPurchase,
    });
  }
}
