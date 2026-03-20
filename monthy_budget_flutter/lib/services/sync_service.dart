import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../models/shopping_item.dart';
import '../repositories/local/app_database.dart';
import '../repositories/local/shopping_storage.dart';
import '../repositories/shopping_repository.dart';
import 'connectivity_service.dart';
import 'log_service.dart';

class SyncQueueDomain {
  static const shopping = 'shopping';
}

class SyncAction {
  static const add = 'add';
  static const update = 'update';
  static const toggle = 'toggle';
  static const remove = 'remove';
  static const clear = 'clear';
}

class SyncService {
  SyncService({
    required AppDatabase database,
    ConnectivityStateSource? connectivity,
    ShoppingRepository? shoppingRepository,
  }) : _database = database,
       _connectivity = connectivity ?? ConnectivityService(),
       _shoppingRepository = shoppingRepository ?? SupabaseShoppingRepository();

  final AppDatabase _database;
  final ConnectivityStateSource _connectivity;
  final ShoppingRepository _shoppingRepository;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;

  Future<void> start() async {
    _connectivitySubscription ??= _connectivity.onStatusChange.listen((online) {
      if (online) syncPending();
    });
    final online = await _connectivity.checkConnectivity();
    if (online) {
      await syncPending();
    }
  }

  Future<void> enqueue({
    required String householdId,
    required String domain,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    await _database
        .into(_database.syncQueueEntries)
        .insert(
          SyncQueueEntriesCompanion.insert(
            id: const Uuid().v4(),
            householdId: householdId,
            domain: domain,
            action: action,
            payload: jsonEncode(payload),
            createdAt: Value(DateTime.now()),
          ),
        );
    if (await _connectivity.checkConnectivity()) {
      await syncPending();
    }
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final entries =
          await (_database.select(_database.syncQueueEntries)
                ..where((tbl) => tbl.completed.equals(false))
                ..orderBy([
                  (t) => OrderingTerm(
                    expression: t.createdAt,
                    mode: OrderingMode.asc,
                  ),
                ]))
              .get();
      final shoppingEntries = entries
          .where((entry) => entry.domain == SyncQueueDomain.shopping)
          .toList();
      if (shoppingEntries.isNotEmpty) {
        await _syncShoppingEntries(shoppingEntries);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  Stream<int> watchPendingCount(String householdId) {
    final query = _database.select(_database.syncQueueEntries)
      ..where((tbl) => tbl.householdId.equals(householdId))
      ..where((tbl) => tbl.completed.equals(false));
    return query.watch().map((rows) => rows.length);
  }

  Future<void> refreshShoppingForHousehold(String householdId) async {
    await _refreshShoppingFromRemote(householdId);
  }

  Future<void> _syncShoppingEntries(List<SyncQueueEntry> entries) async {
    final households = <String>{};
    for (final entry in entries) {
      try {
        final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
        await _applyShoppingEntry(entry.householdId, entry.action, payload);
        await _markEntryComplete(entry.id);
        households.add(entry.householdId);
      } catch (e, stack) {
        LogService.error(
          'Shopping sync failed',
          error: e,
          stackTrace: stack,
          category: 'sync.shopping',
          data: {'entryId': entry.id},
        );
        return;
      }
    }
    for (final householdId in households) {
      await _refreshShoppingFromRemote(householdId);
    }
  }

  Future<void> _applyShoppingEntry(
    String householdId,
    String action,
    Map<String, dynamic> payload,
  ) async {
    switch (action) {
      case SyncAction.add:
        final item = ShoppingItem.fromJson(
          payload['item'] as Map<String, dynamic>,
        );
        final remote = await _shoppingRepository.add(item, householdId);
        if (remote.id != item.id && item.id.isNotEmpty) {
          await (_database.delete(
            _database.localShoppingItems,
          )..where((tbl) => tbl.id.equals(item.id))).go();
        }
        await _database
            .into(_database.localShoppingItems)
            .insertOnConflictUpdate(
              ShoppingStorage.companionOf(
                householdId,
                remote,
                pendingSync: false,
              ),
            );
        break;
      case SyncAction.update:
        final id = payload['id'] as String;
        await _shoppingRepository.updateItem(
          id,
          price: (payload['price'] as num).toDouble(),
          quantity: payload['quantity'] != null
              ? (payload['quantity'] as num).toDouble()
              : null,
          unit: payload['unit'] as String?,
        );
        await _markLocalShoppingSynced(
          householdId: householdId,
          id: id,
          price: (payload['price'] as num).toDouble(),
          quantity: payload['quantity'] != null
              ? (payload['quantity'] as num).toDouble()
              : null,
          unit: payload['unit'] as String?,
        );
        break;
      case SyncAction.toggle:
        final id = payload['id'] as String;
        final checked = payload['checked'] as bool;
        await _shoppingRepository.toggle(id, checked);
        await _markLocalShoppingSynced(
          householdId: householdId,
          id: id,
          checked: checked,
        );
        break;
      case SyncAction.remove:
        final id = payload['id'] as String;
        await _shoppingRepository.remove(id);
        await (_database.delete(
          _database.localShoppingItems,
        )..where((tbl) => tbl.id.equals(id))).go();
        break;
      case SyncAction.clear:
        await _shoppingRepository.clearChecked(householdId);
        break;
      default:
        throw UnimplementedError('Unknown shopping action $action');
    }
  }

  Future<void> _markLocalShoppingSynced({
    required String householdId,
    required String id,
    bool? checked,
    double? price,
    double? quantity,
    String? unit,
  }) async {
    final row = await (_database.select(
      _database.localShoppingItems,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    final existing = ShoppingStorage.fromRow(row);
    final updated = existing.copyWith(
      checked: checked ?? existing.checked,
      price: price ?? existing.price,
      quantity: quantity ?? existing.quantity,
      unit: unit ?? existing.unit,
      pendingSync: false,
    );
    await _database
        .into(_database.localShoppingItems)
        .insertOnConflictUpdate(
          ShoppingStorage.companionOf(householdId, updated, pendingSync: false),
        );
  }

  Future<void> _refreshShoppingFromRemote(String householdId) async {
    final remoteItems = await _shoppingRepository.load(householdId);
    for (final item in remoteItems) {
      await _database
          .into(_database.localShoppingItems)
          .insertOnConflictUpdate(
            ShoppingStorage.companionOf(householdId, item, pendingSync: false),
          );
    }
  }

  Future<void> _markEntryComplete(String entryId) async {
    await (_database.update(_database.syncQueueEntries)
          ..where((tbl) => tbl.id.equals(entryId)))
        .write(const SyncQueueEntriesCompanion(completed: Value(true)));
  }
}
