import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/product.dart';

void main() {
  group('Product', () {
    test('constructor assigns all fields', () {
      const product = Product(
        id: 'prod_1',
        name: 'Milk',
        category: 'dairy',
        avgPrice: 1.29,
        unit: 'L',
        barcode: '5601234567890',
      );
      expect(product.id, 'prod_1');
      expect(product.name, 'Milk');
      expect(product.category, 'dairy');
      expect(product.avgPrice, 1.29);
      expect(product.unit, 'L');
      expect(product.barcode, '5601234567890');
    });

    test('constructor defaults barcode to null', () {
      const product = Product(
        id: 'prod_2',
        name: 'Bread',
        category: 'bakery',
        avgPrice: 0.80,
        unit: 'un',
      );
      expect(product.barcode, isNull);
    });

    group('equality', () {
      test('equal when all fields match', () {
        const a = Product(
          id: 'prod_1', name: 'Milk', category: 'dairy',
          avgPrice: 1.29, unit: 'L', barcode: '123',
        );
        const b = Product(
          id: 'prod_1', name: 'Milk', category: 'dairy',
          avgPrice: 1.29, unit: 'L', barcode: '123',
        );
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('not equal when name differs', () {
        const a = Product(
          id: 'prod_1', name: 'Milk', category: 'dairy',
          avgPrice: 1.29, unit: 'L',
        );
        const b = Product(
          id: 'prod_1', name: 'Cheese', category: 'dairy',
          avgPrice: 1.29, unit: 'L',
        );
        expect(a, isNot(equals(b)));
      });

      test('not equal to different type', () {
        const a = Product(
          id: 'prod_1', name: 'Milk', category: 'dairy',
          avgPrice: 1.0, unit: 'L',
        );
        expect(a == 'not a product', isFalse);
      });

      test('identical objects are equal', () {
        const a = Product(
          id: 'prod_1', name: 'Milk', category: 'dairy',
          avgPrice: 1.0, unit: 'L',
        );
        expect(identical(a, a), isTrue);
        expect(a, equals(a));
      });

      test('not equal when barcode differs', () {
        const a = Product(
          id: 'prod_1', name: 'Milk', category: 'dairy',
          avgPrice: 1.0, unit: 'L', barcode: '111',
        );
        const b = Product(
          id: 'prod_1', name: 'Milk', category: 'dairy',
          avgPrice: 1.0, unit: 'L', barcode: '222',
        );
        expect(a, isNot(equals(b)));
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct map', () {
        const product = Product(
          id: 'prod_1',
          name: 'Milk',
          category: 'dairy',
          avgPrice: 1.29,
          unit: 'L',
          barcode: '123',
        );
        final json = product.toJson();
        expect(json['id'], 'prod_1');
        expect(json['name'], 'Milk');
        expect(json['category'], 'dairy');
        expect(json['avg_price'], 1.29);
        expect(json['unit'], 'L');
        expect(json['barcode'], '123');
      });

      test('toJson omits null barcode', () {
        const product = Product(
          id: 'prod_2',
          name: 'Bread',
          category: 'bakery',
          avgPrice: 0.80,
          unit: 'un',
        );
        final json = product.toJson();
        expect(json.containsKey('barcode'), isFalse);
      });

      test('fromJson parses correctly', () {
        final json = {
          'id': 'prod_3',
          'name': 'Eggs',
          'category': 'protein',
          'avg_price': 2.50,
          'unit': 'dozen',
          'barcode': '456',
        };
        final product = Product.fromJson(json);
        expect(product.id, 'prod_3');
        expect(product.name, 'Eggs');
        expect(product.category, 'protein');
        expect(product.avgPrice, 2.50);
        expect(product.unit, 'dozen');
        expect(product.barcode, '456');
      });

      test('fromJson handles null barcode', () {
        final json = {
          'id': 'prod_4',
          'name': 'Rice',
          'category': 'grains',
          'avg_price': 1.10,
          'unit': 'kg',
        };
        final product = Product.fromJson(json);
        expect(product.barcode, isNull);
      });

      test('roundtrip toJson -> fromJson preserves data', () {
        const original = Product(
          id: 'prod_rt',
          name: 'Olive Oil',
          category: 'condiments',
          avgPrice: 5.99,
          unit: 'L',
          barcode: '789',
        );
        final json = original.toJson();
        final restored = Product.fromJson(json);
        expect(restored, equals(original));
      });
    });
  });
}
