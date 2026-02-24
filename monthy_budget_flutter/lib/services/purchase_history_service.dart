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

    final records = rows
        .map((r) => PurchaseRecord(
              id: r['id'] as String,
              date: DateTime.parse(r['purchased_at'] as String),
              amount: (r['amount'] as num).toDouble(),
              itemCount: r['item_count'] as int,
            ))
        .toList();

    return PurchaseHistory(records: records);
  }

  Future<void> saveRecord(PurchaseRecord record, String householdId) async {
    await _client.from('purchase_records').upsert({
      'id': record.id,
      'household_id': householdId,
      'amount': record.amount,
      'item_count': record.itemCount,
      'purchased_at': record.date.toIso8601String(),
    });
  }
}
