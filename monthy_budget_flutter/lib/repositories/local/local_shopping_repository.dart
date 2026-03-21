import 'dart:async';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/shopping_item.dart';
import '../shopping_repository.dart';
import 'app_database.dart';
import 'shopping_storage.dart';
import '../../services/sync_service.dart';

class LocalShoppingRepository implements ShoppingRepository {
  LocalShoppingRepository({
    required AppDatabase database,
    required SyncService syncService,
  }) : _database = database,
       _syncService = syncService;

  final AppDatabase _database;
  final SyncService _syncService;
  final Uuid _uuid = const Uuid();

  @override
  Stream<List<ShoppingItem>> stream(String householdId) {
    final query = _database.select(_database.localShoppingItems)
      ..where((tbl) => tbl.householdId.equals(householdId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.pendingSync, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (rows) => rows.map(ShoppingStorage.fromRow).toList(),
    );
  }

  @override
  Future<List<ShoppingItem>> load(String householdId) async {
    final rows = await (_database.select(
      _database.localShoppingItems,
    )..where((tbl) => tbl.householdId.equals(householdId))).get();
    return rows.map(ShoppingStorage.fromRow).toList();
  }

  @override
  Future<ShoppingItem> add(ShoppingItem item, String householdId) async {
    final normalized = item.id.isNotEmpty
        ? item.copyWith(pendingSync: true)
        : item.copyWith(id: _uuid.v4(), pendingSync: true);
    await _database
        .into(_database.localShoppingItems)
        .insert(
          ShoppingStorage.companionOf(
            householdId,
            normalized,
            pendingSync: true,
          ),
        );
    await _syncService.enqueue(
      householdId: householdId,
      domain: SyncQueueDomain.shopping,
      action: SyncAction.add,
      payload: {'item': normalized.toJson()},
    );
    return normalized;
  }

  @override
  Future<void> updateItem(
    String id, {
    required double price,
    double? quantity,
    String? unit,
  }) async {
    final row = await _selectRowById(id);
    if (row == null) return;
    final existing = ShoppingStorage.fromRow(row);
    final updated = existing.copyWith(
      price: price,
      quantity: quantity ?? existing.quantity,
      unit: unit ?? existing.unit,
      pendingSync: true,
    );
    await _database
        .into(_database.localShoppingItems)
        .insertOnConflictUpdate(
          ShoppingStorage.companionOf(
            row.householdId,
            updated,
            pendingSync: true,
          ),
        );
    await _syncService.enqueue(
      householdId: row.householdId,
      domain: SyncQueueDomain.shopping,
      action: SyncAction.update,
      payload: {
        'id': id,
        'price': price,
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit,
      },
    );
  }

  @override
  Future<void> toggle(String id, bool checked) async {
    final row = await _selectRowById(id);
    if (row == null) return;
    final existing = ShoppingStorage.fromRow(row);
    final updated = existing.copyWith(checked: checked, pendingSync: true);
    await _database
        .into(_database.localShoppingItems)
        .insertOnConflictUpdate(
          ShoppingStorage.companionOf(
            row.householdId,
            updated,
            pendingSync: true,
          ),
        );
    await _syncService.enqueue(
      householdId: row.householdId,
      domain: SyncQueueDomain.shopping,
      action: SyncAction.toggle,
      payload: {'id': id, 'checked': checked},
    );
  }

  @override
  Future<void> remove(String id) async {
    final row = await _selectRowById(id);
    if (row == null) return;
    await (_database.delete(
      _database.localShoppingItems,
    )..where((tbl) => tbl.id.equals(id))).go();
    await _syncService.enqueue(
      householdId: row.householdId,
      domain: SyncQueueDomain.shopping,
      action: SyncAction.remove,
      payload: {'id': id},
    );
  }

  @override
  Future<void> clearChecked(String householdId) async {
    await (_database.delete(_database.localShoppingItems)
          ..where((tbl) => tbl.householdId.equals(householdId))
          ..where((tbl) => tbl.checked.equals(true)))
        .go();
    await _syncService.enqueue(
      householdId: householdId,
      domain: SyncQueueDomain.shopping,
      action: SyncAction.clear,
      payload: {},
    );
  }

  Future<LocalShoppingItem?> _selectRowById(String id) async {
    return (_database.select(
      _database.localShoppingItems,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }
}
