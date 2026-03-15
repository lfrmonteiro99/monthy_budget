import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/custom_category.dart';
import 'package:monthly_management/utils/category_helpers.dart';
import 'package:monthly_management/utils/category_icons.dart';

void main() {
  group('categoryIconByName', () {
    test('returns predefined icon for known category', () {
      expect(categoryIconByName('telecomunicacoes'), equals(Icons.phone));
      expect(categoryIconByName('energia'), equals(Icons.bolt));
      expect(categoryIconByName('agua'), equals(Icons.water_drop));
      expect(categoryIconByName('alimentacao'), equals(Icons.restaurant));
      expect(categoryIconByName('educacao'), equals(Icons.school));
      expect(categoryIconByName('habitacao'), equals(Icons.home));
      expect(categoryIconByName('transportes'), equals(Icons.directions_car));
      expect(categoryIconByName('saude'), equals(Icons.local_hospital));
      expect(categoryIconByName('lazer'), equals(Icons.sports_esports));
      expect(categoryIconByName('outros'), equals(Icons.more_horiz));
    });

    test('returns default icon for unknown category without custom categories',
        () {
      expect(categoryIconByName('my_custom'), equals(Icons.category));
    });

    test('returns custom category icon when custom categories list is provided',
        () {
      const custom = CustomCategory(
        id: 'c1',
        name: 'Groceries',
        iconName: 'shopping_cart',
      );

      final icon = categoryIconByName(
        'Groceries',
        customCategories: [custom],
      );

      expect(icon, equals(Icons.shopping_cart));
    });

    test('returns correct icon for custom category with different iconName',
        () {
      const custom = CustomCategory(
        id: 'c2',
        name: 'Travel',
        iconName: 'flight',
      );

      final icon = categoryIconByName(
        'Travel',
        customCategories: [custom],
      );

      expect(icon, equals(Icons.flight));
    });

    test(
        'falls back to getCategoryIcon(iconName) when category not in predefined or custom list',
        () {
      const custom = CustomCategory(
        id: 'c1',
        name: 'Groceries',
        iconName: 'shopping_cart',
      );

      final icon = categoryIconByName(
        'Unknown',
        iconName: 'pets',
        customCategories: [custom],
      );

      expect(icon, equals(Icons.pets));
    });

    test('returns default icon when custom category has null iconName', () {
      const custom = CustomCategory(
        id: 'c3',
        name: 'NoIcon',
        iconName: null,
      );

      final icon = categoryIconByName(
        'NoIcon',
        customCategories: [custom],
      );

      // getCategoryIcon(null) returns Icons.category
      expect(icon, equals(Icons.category));
    });

    test('predefined category takes precedence over custom category', () {
      // If someone creates a custom category with the same name as a predefined one
      const custom = CustomCategory(
        id: 'c4',
        name: 'energia',
        iconName: 'flight',
      );

      final icon = categoryIconByName(
        'energia',
        customCategories: [custom],
      );

      // Predefined should win
      expect(icon, equals(Icons.bolt));
    });

    test('returns default when custom categories list is empty', () {
      final icon = categoryIconByName(
        'SomeCustom',
        customCategories: [],
      );

      expect(icon, equals(Icons.category));
    });
  });
}
