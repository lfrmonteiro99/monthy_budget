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

    group('new optional fields - backward compatibility', () {
      test('constructor defaults new fields to null', () {
        final item = ShoppingItem(
          productName: 'Milk',
          store: 'Lidl',
          price: 1.29,
        );

        expect(item.sourceMealId, isNull);
        expect(item.sourceMealLabel, isNull);
        expect(item.preferredStore, isNull);
        expect(item.cheapestKnownStore, isNull);
        expect(item.cheapestKnownPrice, isNull);
      });

      test('fromJson without new fields produces null values', () {
        final json = {
          'id': 'si_1',
          'productName': 'Milk',
          'store': 'Lidl',
          'price': 1.29,
          'checked': false,
        };

        final item = ShoppingItem.fromJson(json);

        expect(item.sourceMealId, isNull);
        expect(item.sourceMealLabel, isNull);
        expect(item.preferredStore, isNull);
        expect(item.cheapestKnownStore, isNull);
        expect(item.cheapestKnownPrice, isNull);
      });

      test('fromJson with new fields parses correctly', () {
        final json = {
          'id': 'si_2',
          'productName': 'Chicken',
          'store': 'Continente',
          'price': 5.0,
          'checked': false,
          'sourceMealId': 'meal_1',
          'sourceMealLabel': 'Grilled Chicken',
          'preferredStore': 'Lidl',
          'cheapestKnownStore': 'Auchan',
          'cheapestKnownPrice': 4.50,
        };

        final item = ShoppingItem.fromJson(json);

        expect(item.sourceMealId, 'meal_1');
        expect(item.sourceMealLabel, 'Grilled Chicken');
        expect(item.preferredStore, 'Lidl');
        expect(item.cheapestKnownStore, 'Auchan');
        expect(item.cheapestKnownPrice, 4.50);
      });

      test('toJson omits new fields when null', () {
        final item = ShoppingItem(
          productName: 'Eggs',
          store: 'Lidl',
          price: 2.50,
        );

        final json = item.toJson();

        expect(json.containsKey('sourceMealId'), false);
        expect(json.containsKey('sourceMealLabel'), false);
        expect(json.containsKey('preferredStore'), false);
        expect(json.containsKey('cheapestKnownStore'), false);
        expect(json.containsKey('cheapestKnownPrice'), false);
      });

      test('toJson includes new fields when present', () {
        final item = ShoppingItem(
          productName: 'Chicken',
          store: 'Continente',
          price: 5.0,
          sourceMealId: 'meal_1',
          sourceMealLabel: 'Grilled Chicken',
          preferredStore: 'Lidl',
          cheapestKnownStore: 'Auchan',
          cheapestKnownPrice: 4.50,
        );

        final json = item.toJson();

        expect(json['sourceMealId'], 'meal_1');
        expect(json['sourceMealLabel'], 'Grilled Chicken');
        expect(json['preferredStore'], 'Lidl');
        expect(json['cheapestKnownStore'], 'Auchan');
        expect(json['cheapestKnownPrice'], 4.50);
      });

      test('fromSupabase without new columns produces null values', () {
        final row = {
          'id': 'uuid-old',
          'product_name': 'Water',
          'store': 'Lidl',
          'price': 0.50,
          'unit_price': null,
          'checked': false,
        };

        final item = ShoppingItem.fromSupabase(row);

        expect(item.sourceMealId, isNull);
        expect(item.sourceMealLabel, isNull);
        expect(item.preferredStore, isNull);
        expect(item.cheapestKnownStore, isNull);
        expect(item.cheapestKnownPrice, isNull);
      });

      test('fromSupabase with new columns parses correctly', () {
        final row = {
          'id': 'uuid-new',
          'product_name': 'Chicken',
          'store': 'Continente',
          'price': 5.0,
          'unit_price': null,
          'checked': false,
          'source_meal_id': 'meal_1',
          'source_meal_label': 'Grilled Chicken',
          'preferred_store': 'Lidl',
          'cheapest_known_store': 'Auchan',
          'cheapest_known_price': 4.50,
        };

        final item = ShoppingItem.fromSupabase(row);

        expect(item.sourceMealId, 'meal_1');
        expect(item.sourceMealLabel, 'Grilled Chicken');
        expect(item.preferredStore, 'Lidl');
        expect(item.cheapestKnownStore, 'Auchan');
        expect(item.cheapestKnownPrice, 4.50);
      });

      test('toSupabase omits new fields when null', () {
        final item = ShoppingItem(
          productName: 'Banana',
          store: 'Lidl',
          price: 0.50,
        );

        final map = item.toSupabase('hh_1');

        expect(map.containsKey('source_meal_id'), false);
        expect(map.containsKey('source_meal_label'), false);
        expect(map.containsKey('preferred_store'), false);
        expect(map.containsKey('cheapest_known_store'), false);
        expect(map.containsKey('cheapest_known_price'), false);
      });

      test('toSupabase includes new fields when present', () {
        final item = ShoppingItem(
          productName: 'Chicken',
          store: 'Continente',
          price: 5.0,
          sourceMealId: 'meal_1',
          sourceMealLabel: 'Grilled Chicken',
          preferredStore: 'Lidl',
          cheapestKnownStore: 'Auchan',
          cheapestKnownPrice: 4.50,
        );

        final map = item.toSupabase('hh_1');

        expect(map['source_meal_id'], 'meal_1');
        expect(map['source_meal_label'], 'Grilled Chicken');
        expect(map['preferred_store'], 'Lidl');
        expect(map['cheapest_known_store'], 'Auchan');
        expect(map['cheapest_known_price'], 4.50);
      });

      test('constructor defaults quantity and unit to null', () {
        final item = ShoppingItem(
          productName: 'Milk',
          store: 'Lidl',
          price: 1.29,
        );

        expect(item.quantity, isNull);
        expect(item.unit, isNull);
      });

      test('constructor accepts quantity and unit', () {
        final item = ShoppingItem(
          productName: 'Frango',
          store: 'Continente',
          price: 5.25,
          quantity: 0.7,
          unit: 'kg',
        );

        expect(item.quantity, 0.7);
        expect(item.unit, 'kg');
      });

      test('fromJson parses quantity and unit', () {
        final json = {
          'productName': 'Arroz',
          'store': 'Lidl',
          'price': 1.10,
          'quantity': 1.0,
          'unit': 'kg',
        };

        final item = ShoppingItem.fromJson(json);

        expect(item.quantity, 1.0);
        expect(item.unit, 'kg');
      });

      test('fromJson without quantity/unit produces null', () {
        final json = {
          'productName': 'Água',
          'store': 'Lidl',
          'price': 0.30,
        };

        final item = ShoppingItem.fromJson(json);

        expect(item.quantity, isNull);
        expect(item.unit, isNull);
      });

      test('toJson includes quantity and unit when present', () {
        final item = ShoppingItem(
          productName: 'Cebola',
          store: 'Pingo Doce',
          price: 0.80,
          quantity: 0.5,
          unit: 'kg',
        );

        final json = item.toJson();

        expect(json['quantity'], 0.5);
        expect(json['unit'], 'kg');
      });

      test('toJson omits quantity and unit when null', () {
        final item = ShoppingItem(
          productName: 'Pão',
          store: 'Lidl',
          price: 0.99,
        );

        final json = item.toJson();

        expect(json.containsKey('quantity'), false);
        expect(json.containsKey('unit'), false);
      });

      test('fromSupabase parses quantity and unit columns', () {
        final row = {
          'id': 'uuid-qty',
          'product_name': 'Azeite',
          'store': 'Continente',
          'price': 4.50,
          'unit_price': null,
          'checked': false,
          'quantity': 0.75,
          'unit': 'L',
        };

        final item = ShoppingItem.fromSupabase(row);

        expect(item.quantity, 0.75);
        expect(item.unit, 'L');
      });

      test('fromSupabase without quantity/unit columns produces null', () {
        final row = {
          'id': 'uuid-old2',
          'product_name': 'Sal',
          'store': 'Lidl',
          'price': 0.50,
          'unit_price': null,
          'checked': false,
        };

        final item = ShoppingItem.fromSupabase(row);

        expect(item.quantity, isNull);
        expect(item.unit, isNull);
      });

      test('toSupabase includes quantity and unit when present', () {
        final item = ShoppingItem(
          productName: 'Leite',
          store: 'Pingo Doce',
          price: 0.89,
          quantity: 2.0,
          unit: 'L',
        );

        final map = item.toSupabase('hh_1');

        expect(map['quantity'], 2.0);
        expect(map['unit'], 'L');
      });

      test('toSupabase omits quantity and unit when null', () {
        final item = ShoppingItem(
          productName: 'Manteiga',
          store: 'Lidl',
          price: 1.50,
        );

        final map = item.toSupabase('hh_1');

        expect(map.containsKey('quantity'), false);
        expect(map.containsKey('unit'), false);
      });

      test('equality includes quantity and unit', () {
        final a = ShoppingItem(
          id: '1', productName: 'A', store: 'S', price: 1.0,
          quantity: 0.5, unit: 'kg',
        );
        final b = ShoppingItem(
          id: '1', productName: 'A', store: 'S', price: 1.0,
          quantity: 1.0, unit: 'kg',
        );

        expect(a == b, isFalse);
      });

      test('equality includes new fields', () {
        final a = ShoppingItem(
          id: '1',
          productName: 'A',
          store: 'S',
          price: 1.0,
          sourceMealId: 'm1',
        );
        final b = ShoppingItem(
          id: '1',
          productName: 'A',
          store: 'S',
          price: 1.0,
          sourceMealId: 'm2',
        );

        expect(a == b, isFalse);
      });
    });
  });
}
