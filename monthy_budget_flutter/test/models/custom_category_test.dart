import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/custom_category.dart';

void main() {
  group('CustomCategory', () {
    test('constructor with all fields', () {
      const cat = CustomCategory(
        id: 'cat_1',
        name: 'Groceries',
        iconName: 'shopping_cart',
        colorHex: '#FF5733',
        sortOrder: 3,
      );
      expect(cat.id, 'cat_1');
      expect(cat.name, 'Groceries');
      expect(cat.iconName, 'shopping_cart');
      expect(cat.colorHex, '#FF5733');
      expect(cat.sortOrder, 3);
    });

    test('constructor defaults', () {
      const cat = CustomCategory(id: 'cat_2', name: 'Misc');
      expect(cat.iconName, isNull);
      expect(cat.colorHex, isNull);
      expect(cat.sortOrder, 0);
    });

    group('equality', () {
      test('equal when all fields match', () {
        const a = CustomCategory(
          id: 'cat_1',
          name: 'Food',
          iconName: 'food',
          colorHex: '#000',
          sortOrder: 1,
        );
        const b = CustomCategory(
          id: 'cat_1',
          name: 'Food',
          iconName: 'food',
          colorHex: '#000',
          sortOrder: 1,
        );
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('not equal when fields differ', () {
        const a = CustomCategory(id: 'cat_1', name: 'Food');
        const b = CustomCategory(id: 'cat_1', name: 'Drinks');
        expect(a, isNot(equals(b)));
      });

      test('not equal to different type', () {
        const a = CustomCategory(id: 'cat_1', name: 'Food');
        expect(a == 'not a category', isFalse);
      });

      test('identical objects are equal', () {
        const a = CustomCategory(id: 'cat_1', name: 'Food');
        expect(identical(a, a), isTrue);
        expect(a, equals(a));
      });
    });

    group('copyWith', () {
      const original = CustomCategory(
        id: 'cat_1',
        name: 'Food',
        iconName: 'food',
        colorHex: '#FF0000',
        sortOrder: 2,
      );

      test('returns copy with no changes when no args', () {
        final copy = original.copyWith();
        expect(copy, equals(original));
      });

      test('updates id', () {
        final copy = original.copyWith(id: 'cat_2');
        expect(copy.id, 'cat_2');
        expect(copy.name, original.name);
      });

      test('updates name', () {
        final copy = original.copyWith(name: 'Drinks');
        expect(copy.name, 'Drinks');
      });

      test('updates iconName', () {
        final copy = original.copyWith(iconName: 'drink');
        expect(copy.iconName, 'drink');
      });

      test('updates colorHex', () {
        final copy = original.copyWith(colorHex: '#00FF00');
        expect(copy.colorHex, '#00FF00');
      });

      test('updates sortOrder', () {
        final copy = original.copyWith(sortOrder: 10);
        expect(copy.sortOrder, 10);
      });

      test('updates multiple fields at once', () {
        final copy = original.copyWith(name: 'Transport', sortOrder: 5);
        expect(copy.name, 'Transport');
        expect(copy.sortOrder, 5);
        expect(copy.id, original.id);
        expect(copy.iconName, original.iconName);
      });
    });

    group('fromSupabase', () {
      test('parses all fields', () {
        final map = {
          'id': 'cat_abc',
          'name': 'Entertainment',
          'icon_name': 'movie',
          'color_hex': '#AABB00',
          'sort_order': 7,
        };
        final cat = CustomCategory.fromSupabase(map);
        expect(cat.id, 'cat_abc');
        expect(cat.name, 'Entertainment');
        expect(cat.iconName, 'movie');
        expect(cat.colorHex, '#AABB00');
        expect(cat.sortOrder, 7);
      });

      test('handles null optional fields', () {
        final map = {
          'id': 'cat_xyz',
          'name': 'Other',
          'icon_name': null,
          'color_hex': null,
          'sort_order': null,
        };
        final cat = CustomCategory.fromSupabase(map);
        expect(cat.iconName, isNull);
        expect(cat.colorHex, isNull);
        expect(cat.sortOrder, 0);
      });

      test('handles missing sort_order key', () {
        final map = {
          'id': 'cat_no_sort',
          'name': 'No Sort',
        };
        final cat = CustomCategory.fromSupabase(map);
        expect(cat.sortOrder, 0);
      });
    });

    group('toSupabase', () {
      test('serializes all fields including householdId', () {
        const cat = CustomCategory(
          id: 'cat_1',
          name: 'Food',
          iconName: 'food',
          colorHex: '#AABBCC',
          sortOrder: 3,
        );
        final map = cat.toSupabase('hh_123');
        expect(map['id'], 'cat_1');
        expect(map['household_id'], 'hh_123');
        expect(map['name'], 'Food');
        expect(map['icon_name'], 'food');
        expect(map['color_hex'], '#AABBCC');
        expect(map['sort_order'], 3);
      });

      test('serializes null optional fields as null', () {
        const cat = CustomCategory(id: 'cat_2', name: 'Misc');
        final map = cat.toSupabase('hh_456');
        expect(map['icon_name'], isNull);
        expect(map['color_hex'], isNull);
        expect(map['sort_order'], 0);
      });
    });

    test('roundtrip fromSupabase -> toSupabase preserves data', () {
      final original = {
        'id': 'cat_rt',
        'name': 'Roundtrip',
        'icon_name': 'loop',
        'color_hex': '#112233',
        'sort_order': 5,
      };
      final cat = CustomCategory.fromSupabase(original);
      final serialized = cat.toSupabase('hh_rt');
      expect(serialized['id'], original['id']);
      expect(serialized['name'], original['name']);
      expect(serialized['icon_name'], original['icon_name']);
      expect(serialized['color_hex'], original['color_hex']);
      expect(serialized['sort_order'], original['sort_order']);
    });
  });
}
