import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/shopping_item.dart';
import 'package:monthly_management/repositories/local/app_database.dart';
import 'package:monthly_management/repositories/local/local_shopping_repository.dart';
import 'package:monthly_management/repositories/shopping_repository.dart';
import 'package:monthly_management/services/connectivity_service.dart';
import 'package:monthly_management/services/sync_service.dart';

class _FakeConnectivity implements ConnectivityStateSource {
  bool _isOnline = false;
  final _controller = StreamController<bool>.broadcast();

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  @override
  Future<bool> checkConnectivity() async => _isOnline;

  void setOnline(bool v) {
    _isOnline = v;
    _controller.add(v);
  }

  Future<void> dispose() async => _controller.close();
}

class _FakeRemoteRepo implements ShoppingRepository {
  int addCalls = 0;
  final Map<String, ShoppingItem> _items = {};

  @override
  Stream<List<ShoppingItem>> stream(String householdId) async* {
    yield _items.values.toList();
  }

  @override
  Future<List<ShoppingItem>> load(String householdId) async =>
      _items.values.toList();

  @override
  Future<ShoppingItem> add(ShoppingItem item, String householdId) async {
    addCalls++;
    final remote = item.copyWith(
      id: item.id.isEmpty ? 'remote-$addCalls' : item.id,
      pendingSync: false,
    );
    _items[remote.id] = remote;
    return remote;
  }

  @override
  Future<void> updateItem(String id,
      {required double price, double? quantity, String? unit}) async {
    final existing = _items[id];
    if (existing == null) return;
    _items[id] = existing.copyWith(price: price, pendingSync: false);
  }

  @override
  Future<void> toggle(String id, bool checked) async {
    final existing = _items[id];
    if (existing == null) return;
    _items[id] = existing.copyWith(checked: checked, pendingSync: false);
  }

  @override
  Future<void> remove(String id) async => _items.remove(id);

  @override
  Future<void> clearChecked(String householdId) async =>
      _items.removeWhere((_, item) => item.checked);
}

void main() {
  group('LocalShoppingRepository', () {
    late AppDatabase database;
    late _FakeConnectivity connectivity;
    late _FakeRemoteRepo remoteRepo;
    late SyncService syncService;
    late LocalShoppingRepository repo;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      connectivity = _FakeConnectivity();
      remoteRepo = _FakeRemoteRepo();
      syncService = SyncService(
        database: database,
        connectivity: connectivity,
        shoppingRepository: remoteRepo,
      );
      repo = LocalShoppingRepository(
        database: database,
        syncService: syncService,
      );
    });

    tearDown(() async {
      await syncService.dispose();
      await connectivity.dispose();
      await database.close();
    });

    test('add inserts item and enqueues sync entry', () async {
      await repo.add(
        ShoppingItem(productName: 'Milk', store: 'Lidl', price: 1.0),
        'hh-1',
      );

      final items = await repo.load('hh-1');
      expect(items, hasLength(1));
      expect(items.first.productName, 'Milk');
      expect(items.first.pendingSync, true);

      final pending = await syncService.watchPendingCount('hh-1').first;
      expect(pending, 1);
    });

    test('add generates UUID when item id is empty', () async {
      final added = await repo.add(
        ShoppingItem(productName: 'Eggs', store: 'Auchan', price: 2.0),
        'hh-1',
      );

      expect(added.id, isNotEmpty);
      expect(added.id.length, greaterThan(8));
    });

    test('add preserves existing id when non-empty', () async {
      final added = await repo.add(
        ShoppingItem(
          id: 'my-custom-id',
          productName: 'Rice',
          store: 'Pingo Doce',
          price: 1.5,
        ),
        'hh-1',
      );

      expect(added.id, 'my-custom-id');
    });

    test('load returns stored items for given household', () async {
      await repo.add(
        ShoppingItem(productName: 'A', store: 'S', price: 1.0),
        'hh-1',
      );
      await repo.add(
        ShoppingItem(productName: 'B', store: 'S', price: 2.0),
        'hh-1',
      );
      await repo.add(
        ShoppingItem(productName: 'C', store: 'S', price: 3.0),
        'hh-2',
      );

      final hh1Items = await repo.load('hh-1');
      final hh2Items = await repo.load('hh-2');

      expect(hh1Items, hasLength(2));
      expect(hh2Items, hasLength(1));
    });

    test('toggle updates checked state', () async {
      final item = await repo.add(
        ShoppingItem(productName: 'Bread', store: 'Lidl', price: 0.5),
        'hh-1',
      );

      await repo.toggle(item.id, true);
      final items = await repo.load('hh-1');
      expect(items.first.checked, true);

      await repo.toggle(item.id, false);
      final items2 = await repo.load('hh-1');
      expect(items2.first.checked, false);
    });

    test('remove deletes item from database', () async {
      final item = await repo.add(
        ShoppingItem(productName: 'Butter', store: 'S', price: 1.0),
        'hh-1',
      );

      await repo.remove(item.id);
      final items = await repo.load('hh-1');
      expect(items, isEmpty);
    });

    test('clearChecked removes only checked items', () async {
      final a = await repo.add(
        ShoppingItem(productName: 'A', store: 'S', price: 1.0),
        'hh-1',
      );
      await repo.add(
        ShoppingItem(productName: 'B', store: 'S', price: 2.0),
        'hh-1',
      );

      await repo.toggle(a.id, true);
      await repo.clearChecked('hh-1');

      final items = await repo.load('hh-1');
      expect(items, hasLength(1));
      expect(items.first.productName, 'B');
    });

    test('updateItem changes price in database', () async {
      final item = await repo.add(
        ShoppingItem(productName: 'Cheese', store: 'S', price: 3.0),
        'hh-1',
      );

      await repo.updateItem(item.id, price: 4.50);
      final items = await repo.load('hh-1');
      expect(items.first.price, 4.50);
    });
  });
}
