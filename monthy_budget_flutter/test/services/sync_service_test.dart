import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/shopping_item.dart';
import 'package:monthly_management/repositories/local/app_database.dart';
import 'package:monthly_management/repositories/local/local_shopping_repository.dart';
import 'package:monthly_management/repositories/shopping_repository.dart';
import 'package:monthly_management/services/connectivity_service.dart';
import 'package:monthly_management/services/sync_service.dart';

void main() {
  group('SyncService shopping offline flow', () {
    late AppDatabase database;
    late FakeConnectivity connectivity;
    late FakeShoppingRepository remoteRepository;
    late SyncService syncService;
    late LocalShoppingRepository localRepository;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      connectivity = FakeConnectivity(isOnline: false);
      remoteRepository = FakeShoppingRepository();
      syncService = SyncService(
        database: database,
        connectivity: connectivity,
        shoppingRepository: remoteRepository,
      );
      localRepository = LocalShoppingRepository(
        database: database,
        syncService: syncService,
      );
    });

    tearDown(() async {
      await syncService.dispose();
      await connectivity.dispose();
      await database.close();
    });

    test('queues local add while offline and syncs when online', () async {
      await localRepository.add(
        ShoppingItem(productName: 'Milk', store: 'Store A', price: 1.99),
        'house-1',
      );

      final beforeSyncCount = await syncService
          .watchPendingCount('house-1')
          .first;
      expect(beforeSyncCount, 1);
      expect(remoteRepository.addCalls, 0);

      connectivity.setOnline(true);
      await syncService.syncPending();

      final afterSyncCount = await syncService
          .watchPendingCount('house-1')
          .first;
      expect(afterSyncCount, 0);
      expect(remoteRepository.addCalls, 1);

      final rows = await (database.select(
        database.localShoppingItems,
      )..where((t) => t.householdId.equals('house-1'))).get();
      expect(rows, hasLength(1));
      expect(rows.single.pendingSync, isFalse);
    });

    test('applies remote state after sync (last-write-wins)', () async {
      remoteRepository.nextAddResult = ShoppingItem(
        id: 'remote-id-1',
        productName: 'Rice',
        store: 'Remote Store',
        price: 3.45,
        checked: true,
      );

      await localRepository.add(
        ShoppingItem(
          id: 'local-id-1',
          productName: 'Rice',
          store: 'Local',
          price: 2.10,
        ),
        'house-1',
      );

      connectivity.setOnline(true);
      await syncService.syncPending();

      final rows = await (database.select(
        database.localShoppingItems,
      )..where((t) => t.householdId.equals('house-1'))).get();
      expect(rows, hasLength(1));
      expect(rows.single.id, 'remote-id-1');
      expect(rows.single.store, 'Remote Store');
      expect(rows.single.price, 3.45);
      expect(rows.single.checked, isTrue);
      expect(rows.single.pendingSync, isFalse);
    });
  });
}

class FakeConnectivity implements ConnectivityStateSource {
  FakeConnectivity({required bool isOnline}) : _isOnline = isOnline;

  bool _isOnline;
  final _controller = StreamController<bool>.broadcast();

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  @override
  Future<bool> checkConnectivity() async => _isOnline;

  void setOnline(bool online) {
    _isOnline = online;
    _controller.add(online);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

class FakeShoppingRepository implements ShoppingRepository {
  int addCalls = 0;
  final Map<String, ShoppingItem> _items = {};
  ShoppingItem? nextAddResult;

  @override
  Stream<List<ShoppingItem>> stream(String householdId) async* {
    yield _items.values.toList();
  }

  @override
  Future<List<ShoppingItem>> load(String householdId) async {
    return _items.values.toList();
  }

  @override
  Future<ShoppingItem> add(ShoppingItem item, String householdId) async {
    addCalls += 1;
    final remote =
        nextAddResult ??
        item.copyWith(
          id: item.id.isEmpty ? 'remote-$addCalls' : item.id,
          pendingSync: false,
        );
    _items[remote.id] = remote;
    return remote;
  }

  @override
  Future<void> updateItem(
    String id, {
    required double price,
    double? quantity,
    String? unit,
  }) async {
    final existing = _items[id];
    if (existing == null) return;
    _items[id] = existing.copyWith(
      price: price,
      quantity: quantity ?? existing.quantity,
      unit: unit ?? existing.unit,
      pendingSync: false,
    );
  }

  @override
  Future<void> toggle(String id, bool checked) async {
    final existing = _items[id];
    if (existing == null) return;
    _items[id] = existing.copyWith(checked: checked, pendingSync: false);
  }

  @override
  Future<void> remove(String id) async {
    _items.remove(id);
  }

  @override
  Future<void> clearChecked(String householdId) async {
    _items.removeWhere((_, item) => item.checked);
  }
}
