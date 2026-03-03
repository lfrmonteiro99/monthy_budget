import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/purchase_record.dart';

class PurchaseHistoryService {
  final _client = Supabase.instance.client;

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

  Future<void> saveRecord(PurchaseRecord record, String householdId) async {
    await _client.from('purchase_records').insert({
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
