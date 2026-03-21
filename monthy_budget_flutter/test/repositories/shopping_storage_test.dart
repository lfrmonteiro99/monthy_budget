import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/shopping_item.dart';
import 'package:monthly_management/repositories/local/app_database.dart';
import 'package:monthly_management/repositories/local/shopping_storage.dart';

void main() {
  group('ShoppingStorage', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    // ---------------------------------------------------------------------------
    // companionOf — field mapping
    // ---------------------------------------------------------------------------
    group('companionOf', () {
      test('creates companion with correct fields from ShoppingItem', () {
        final item = ShoppingItem(
          id: 'item-001',
          productName: 'Milk',
          store: 'Continente',
          price: 1.29,
          unitPrice: '1.29/L',
          checked: true,
          sourceMealLabels: ['Breakfast'],
          preferredStore: 'Lidl',
          cheapestKnownStore: 'Auchan',
          cheapestKnownPrice: 1.10,
          quantity: 2.0,
          unit: 'L',
          pendingSync: false,
        );

        final companion = ShoppingStorage.companionOf('hh-1', item);

        expect(companion.id.value, 'item-001');
        expect(companion.householdId.value, 'hh-1');
        expect(companion.productName.value, 'Milk');
        expect(companion.store.value, 'Continente');
        expect(companion.price.value, 1.29);
        expect(companion.unitPrice.value, '1.29/L');
        expect(companion.checked.value, true);
        expect(companion.sourceMealLabels.value, ['Breakfast']);
        expect(companion.preferredStore.value, 'Lidl');
        expect(companion.cheapestKnownStore.value, 'Auchan');
        expect(companion.cheapestKnownPrice.value, 1.10);
        expect(companion.quantity.value, 2.0);
        expect(companion.unit.value, 'L');
      });

      test('companion maps nullable fields as null when item fields are null', () {
        final item = ShoppingItem(
          id: 'item-002',
          productName: 'Eggs',
          store: 'Lidl',
          price: 2.50,
        );

        final companion = ShoppingStorage.companionOf('hh-2', item);

        expect(companion.unitPrice.value, isNull);
        expect(companion.preferredStore.value, isNull);
        expect(companion.cheapestKnownStore.value, isNull);
        expect(companion.cheapestKnownPrice.value, isNull);
        expect(companion.quantity.value, isNull);
        expect(companion.unit.value, isNull);
        expect(companion.sourceMealLabels.value, isEmpty);
      });

      // -------------------------------------------------------------------------
      // companionOf — pendingSync parameter
      // -------------------------------------------------------------------------
      test('uses pendingSync=true by default', () {
        final item = ShoppingItem(
          id: 'item-003',
          productName: 'Rice',
          store: 'Pingo Doce',
          price: 1.10,
          pendingSync: false, // item field is false; default arg should win
        );

        final companion = ShoppingStorage.companionOf('hh-1', item);

        expect(companion.pendingSync.value, true);
      });

      test('uses pendingSync=false when explicitly passed false', () {
        final item = ShoppingItem(
          id: 'item-004',
          productName: 'Bread',
          store: 'Auchan',
          price: 0.99,
          pendingSync: true, // item field is true; explicit arg should win
        );

        final companion = ShoppingStorage.companionOf(
          'hh-1',
          item,
          pendingSync: false,
        );

        expect(companion.pendingSync.value, false);
      });

      test('uses pendingSync=true when explicitly passed true', () {
        final item = ShoppingItem(
          id: 'item-005',
          productName: 'Butter',
          store: 'Minipreco',
          price: 1.50,
        );

        final companion = ShoppingStorage.companionOf(
          'hh-1',
          item,
          pendingSync: true,
        );

        expect(companion.pendingSync.value, true);
      });
    });

    // ---------------------------------------------------------------------------
    // Round-trip: companionOf → insert → select → fromRow
    // ---------------------------------------------------------------------------
    group('round-trip', () {
      test('all fields survive insert and fromRow conversion', () async {
        final original = ShoppingItem(
          id: 'rt-001',
          productName: 'Chicken',
          store: 'Continente',
          price: 5.49,
          unitPrice: '7.84/kg',
          checked: true,
          sourceMealLabels: ['Grilled Chicken', 'Chicken Soup'],
          preferredStore: 'Lidl',
          cheapestKnownStore: 'Auchan',
          cheapestKnownPrice: 4.99,
          quantity: 0.7,
          unit: 'kg',
          pendingSync: true,
        );

        final companion = ShoppingStorage.companionOf(
          'hh-rt',
          original,
          pendingSync: true,
        );
        await database.into(database.localShoppingItems).insert(companion);

        final rows = await (database.select(database.localShoppingItems)
              ..where((t) => t.id.equals('rt-001')))
            .get();

        expect(rows, hasLength(1));
        final result = ShoppingStorage.fromRow(rows.single);

        expect(result.id, original.id);
        expect(result.productName, original.productName);
        expect(result.store, original.store);
        expect(result.price, original.price);
        expect(result.unitPrice, original.unitPrice);
        expect(result.checked, original.checked);
        expect(result.sourceMealLabels, original.sourceMealLabels);
        expect(result.preferredStore, original.preferredStore);
        expect(result.cheapestKnownStore, original.cheapestKnownStore);
        expect(result.cheapestKnownPrice, original.cheapestKnownPrice);
        expect(result.quantity, original.quantity);
        expect(result.unit, original.unit);
        expect(result.pendingSync, true);
      });

      test('null optional fields survive round-trip as null', () async {
        final original = ShoppingItem(
          id: 'rt-002',
          productName: 'Water',
          store: 'Lidl',
          price: 0.30,
        );

        final companion = ShoppingStorage.companionOf('hh-rt', original);
        await database.into(database.localShoppingItems).insert(companion);

        final rows = await (database.select(database.localShoppingItems)
              ..where((t) => t.id.equals('rt-002')))
            .get();

        expect(rows, hasLength(1));
        final result = ShoppingStorage.fromRow(rows.single);

        expect(result.unitPrice, isNull);
        expect(result.preferredStore, isNull);
        expect(result.cheapestKnownStore, isNull);
        expect(result.cheapestKnownPrice, isNull);
        expect(result.quantity, isNull);
        expect(result.unit, isNull);
        expect(result.sourceMealLabels, isEmpty);
      });

      test('pendingSync=false is persisted and read back correctly', () async {
        final original = ShoppingItem(
          id: 'rt-003',
          productName: 'Yogurt',
          store: 'Pingo Doce',
          price: 0.75,
        );

        final companion = ShoppingStorage.companionOf(
          'hh-rt',
          original,
          pendingSync: false,
        );
        await database.into(database.localShoppingItems).insert(companion);

        final rows = await (database.select(database.localShoppingItems)
              ..where((t) => t.id.equals('rt-003')))
            .get();

        expect(rows, hasLength(1));
        final result = ShoppingStorage.fromRow(rows.single);

        expect(result.pendingSync, false);
      });

      test('fromRow result equals ShoppingItem constructed with same data', () async {
        final original = ShoppingItem(
          id: 'rt-004',
          productName: 'Cheese',
          store: 'Auchan',
          price: 3.99,
          unitPrice: '19.95/kg',
          checked: false,
          sourceMealLabels: ['Pasta'],
          preferredStore: 'Continente',
          cheapestKnownStore: 'Lidl',
          cheapestKnownPrice: 3.50,
          quantity: 0.2,
          unit: 'kg',
          pendingSync: true,
        );

        final companion = ShoppingStorage.companionOf(
          'hh-rt',
          original,
          pendingSync: true,
        );
        await database.into(database.localShoppingItems).insert(companion);

        final rows = await (database.select(database.localShoppingItems)
              ..where((t) => t.id.equals('rt-004')))
            .get();
        final result = ShoppingStorage.fromRow(rows.single);

        // ShoppingItem.== covers all fields including sourceMealLabels via ListEquality
        expect(result, equals(original));
      });
    });
  });
}
