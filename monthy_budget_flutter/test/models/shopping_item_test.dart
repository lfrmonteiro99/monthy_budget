import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/shopping_item.dart';

void main() {
  group('ShoppingItem', () {
    group('fromJson', () {
      test('with all fields', () {
        final json = {
          'id': 'si_1',
          'productName': 'Milk',
          'store': 'Continente',
          'price': 1.29,
          'unitPrice': '1.29/L',
          'checked': true,
        };

        final item = ShoppingItem.fromJson(json);

        expect(item.id, 'si_1');
        expect(item.productName, 'Milk');
        expect(item.store, 'Continente');
        expect(item.price, 1.29);
        expect(item.unitPrice, '1.29/L');
        expect(item.checked, true);
      });

      test('with defaults for missing fields', () {
        final json = <String, dynamic>{};

        final item = ShoppingItem.fromJson(json);

        expect(item.id, '');
        expect(item.productName, '');
        expect(item.store, '');
        expect(item.price, 0);
        expect(item.unitPrice, isNull);
        expect(item.checked, false);
      });

      test('with null values uses defaults', () {
        final json = {
          'id': null,
          'productName': null,
          'store': null,
          'price': null,
          'unitPrice': null,
          'checked': null,
        };

        final item = ShoppingItem.fromJson(json);

        expect(item.id, '');
        expect(item.productName, '');
        expect(item.store, '');
        expect(item.price, 0);
        expect(item.unitPrice, isNull);
        expect(item.checked, false);
      });
    });

    group('toJson', () {
      test('includes unitPrice when present', () {
        final item = ShoppingItem(
          id: 'si_2',
          productName: 'Bread',
          store: 'Pingo Doce',
          price: 0.99,
          unitPrice: '0.99/un',
          checked: false,
        );

        final json = item.toJson();

        expect(json['id'], 'si_2');
        expect(json['productName'], 'Bread');
        expect(json['store'], 'Pingo Doce');
        expect(json['price'], 0.99);
        expect(json['unitPrice'], '0.99/un');
        expect(json['checked'], false);
      });

      test('conditional unitPrice: omits when null', () {
        final item = ShoppingItem(
          productName: 'Eggs',
          store: 'Lidl',
          price: 2.50,
        );

        final json = item.toJson();

        expect(json.containsKey('unitPrice'), false);
      });
    });

    group('fromSupabase', () {
      test('maps snake_case column names', () {
        final row = {
          'id': 'uuid-123',
          'product_name': 'Cheese',
          'store': 'Auchan',
          'price': 3.50,
          'unit_price': '7.00/kg',
          'checked': true,
        };

        final item = ShoppingItem.fromSupabase(row);

        expect(item.id, 'uuid-123');
        expect(item.productName, 'Cheese');
        expect(item.store, 'Auchan');
        expect(item.price, 3.50);
        expect(item.unitPrice, '7.00/kg');
        expect(item.checked, true);
      });

      test('maps with null optional fields', () {
        final row = {
          'id': 'uuid-456',
          'product_name': 'Water',
          'store': null,
          'price': null,
          'unit_price': null,
          'checked': null,
        };

        final item = ShoppingItem.fromSupabase(row);

        expect(item.store, '');
        expect(item.price, 0);
        expect(item.unitPrice, isNull);
        expect(item.checked, false);
      });
    });

    group('toSupabase', () {
      test('maps to snake_case with household_id', () {
        final item = ShoppingItem(
          id: 'si_3',
          productName: 'Rice',
          store: 'Minipreco',
          price: 1.10,
          unitPrice: '1.10/kg',
          checked: false,
        );

        final map = item.toSupabase('hh_house');

        expect(map['household_id'], 'hh_house');
        expect(map['product_name'], 'Rice');
        expect(map['store'], 'Minipreco');
        expect(map['price'], 1.10);
        expect(map['unit_price'], '1.10/kg');
        expect(map['checked'], false);
        // toSupabase should NOT include 'id' (Supabase generates it)
        expect(map.containsKey('id'), false);
      });

      test('omits unit_price when null', () {
        final item = ShoppingItem(
          productName: 'Banana',
          store: 'Lidl',
          price: 0.50,
        );

        final map = item.toSupabase('hh_1');

        expect(map.containsKey('unit_price'), false);
      });
    });

    test('checked is mutable', () {
      final item = ShoppingItem(
        productName: 'Yogurt',
        store: 'Continente',
        price: 0.75,
        checked: false,
      );

      expect(item.checked, false);
      item.checked = true;
      expect(item.checked, true);
      item.checked = false;
      expect(item.checked, false);
    });

    test('default constructor id is empty string', () {
      final item = ShoppingItem(
        productName: 'Test',
        store: 'Test Store',
        price: 1.0,
      );
      expect(item.id, '');
    });
  });
}
