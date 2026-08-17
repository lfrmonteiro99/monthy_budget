import 'dart:async';
import 'dart:convert';

import '../../models/purchase_record.dart';
import '../../models/shopping_item.dart';
import '../local/qa_local_store.dart';
import '../shopping_repository.dart';
import 'qa_collections.dart';

/// Sqlite-backed shopping list.
///
/// The shopping UI is stream-driven (Supabase realtime), so every mutation
/// re-reads the collection and pushes it onto a broadcast controller — without
/// that, writes would land in sqlite but never reach the widget tree.
class QaShoppingRepository implements ShoppingRepository {
  QaShoppingRepository(this._store, {required DateTime Function() now})
    : _now = now;

  final QaLocalStore _store;
  final DateTime Function() _now;

  final Map<String, StreamController<List<ShoppingItem>>> _controllers = {};

  @override
  Stream<List<ShoppingItem>> stream(String householdId) {
    final controller = _controllers.putIfAbsent(
      householdId,
      () => StreamController<List<ShoppingItem>>.broadcast(),
    );
    // Seed late subscribers with the current rows, then keep them live.
    return Stream<List<ShoppingItem>>.multi((subscriber) {
      final forwarding = controller.stream.listen(
        subscriber.add,
        onError: subscriber.addError,
      );
      subscriber.onCancel = forwarding.cancel;
      load(householdId).then(subscriber.add).catchError(subscriber.addError);
    });
  }

  @override
  Future<List<ShoppingItem>> load(String householdId) async {
    final rows = await _store.query(QaCollections.shoppingItems, householdId);
    rows.sort(
      (a, b) => (a['created_at'] as String).compareTo(b['created_at'] as String),
    );
    return rows.map(ShoppingItem.fromSupabase).toList();
  }

  @override
  Future<ShoppingItem> add(ShoppingItem item, String householdId) async {
    // ShoppingItem.toSupabase() omits the id because Postgres generates it.
    final timestamp = _now();
    final id = 'shop-${timestamp.microsecondsSinceEpoch}';
    final payload = {
      ...item.toSupabase(householdId),
      'id': id,
      'created_at': timestamp.toIso8601String(),
      'updated_at': timestamp.toIso8601String(),
    };
    await _store.put(QaCollections.shoppingItems, householdId, id, payload);
    await _emit(householdId);
    return ShoppingItem.fromSupabase(payload);
  }

  @override
  Future<void> updateItem(
    String id, {
    required double price,
    double? quantity,
    String? unit,
  }) async {
    await _patch(id, (payload) {
      payload['price'] = price;
      if (quantity != null) payload['quantity'] = quantity;
      if (unit != null) payload['unit'] = unit;
    });
  }

  @override
  Future<void> toggle(String id, bool checked) async {
    await _patch(id, (payload) => payload['checked'] = checked);
  }

  @override
  Future<void> remove(String id) async {
    final located = await _locate(id);
    if (located == null) return;
    await _store.delete(QaCollections.shoppingItems, located.householdId, id);
    await _emit(located.householdId);
  }

  @override
  Future<void> clearChecked(String householdId) async {
    await _store.deleteWhere(
      QaCollections.shoppingItems,
      householdId,
      (row) => row['checked'] == true,
    );
    await _emit(householdId);
  }

  Future<void> _patch(
    String id,
    void Function(Map<String, dynamic> payload) mutate,
  ) async {
    final located = await _locate(id);
    if (located == null) return;
    final payload = located.payload;
    mutate(payload);
    payload['updated_at'] = _now().toIso8601String();
    await _store.put(
      QaCollections.shoppingItems,
      located.householdId,
      id,
      payload,
    );
    await _emit(located.householdId);
  }

  Future<_LocatedRow?> _locate(String id) async {
    final rows = await _store.queryAll(QaCollections.shoppingItems);
    for (final row in rows) {
      if (row['id'] == id) {
        return _LocatedRow(row['household_id'] as String, row);
      }
    }
    return null;
  }

  Future<void> _emit(String householdId) async {
    final controller = _controllers[householdId];
    if (controller == null || controller.isClosed) return;
    controller.add(await load(householdId));
  }

  Future<void> dispose() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();
  }
}

class _LocatedRow {
  _LocatedRow(this.householdId, this.payload);

  final String householdId;
  final Map<String, dynamic> payload;
}

class QaPurchaseRepository implements PurchaseRepository {
  QaPurchaseRepository(this._store);

  final QaLocalStore _store;

  @override
  Future<PurchaseHistory> load(String householdId) async {
    final rows = await _store.query(QaCollections.purchaseRecords, householdId);
    final records = rows.map((row) {
      List<String> items = const [];
      if (row['items_json'] != null) {
        try {
          items = (jsonDecode(row['items_json'] as String) as List<dynamic>)
              .map((e) => e as String)
              .toList();
        } catch (_) {}
      }
      return PurchaseRecord(
        id: row['id'] as String,
        date: DateTime.parse(row['purchased_at'] as String),
        amount: (row['amount'] as num).toDouble(),
        itemCount: row['item_count'] as int,
        items: items,
        isMealPurchase: row['is_meal_purchase'] as bool? ?? false,
      );
    }).toList();
    records.sort((a, b) => b.date.compareTo(a.date));
    return PurchaseHistory(records: records);
  }

  @override
  Future<void> saveRecord(PurchaseRecord record, String householdId) {
    return _store.put(
      QaCollections.purchaseRecords,
      householdId,
      record.id,
      {
        'id': record.id,
        'household_id': householdId,
        'amount': record.amount,
        'item_count': record.itemCount,
        'purchased_at': record.date.toIso8601String(),
        'items_json': jsonEncode(record.items),
        'is_meal_purchase': record.isMealPurchase,
      },
    );
  }
}
