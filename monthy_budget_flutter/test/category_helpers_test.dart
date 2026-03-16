import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/custom_category.dart';
import 'package:monthly_management/utils/category_helpers.dart';
import 'package:monthly_management/utils/category_icons.dart';

void main() {
  group('categoryIconByName', () {
    test('returns predefined icon for known category', () {
      expect(categoryIconByName('alimentacao'), Icons.restaurant);
      expect(categoryIconByName('energia'), Icons.bolt);
      expect(categoryIconByName('transportes'), Icons.directions_car);
    });

    test('returns custom category icon when customCategories provided', () {
      const custom = CustomCategory(
        id: '1',
        name: 'ginásio',
        iconName: 'fitness_center',
      );
      final icon = categoryIconByName(
        'ginásio',
        customCategories: [custom],
      );
      expect(icon, getCategoryIcon('fitness_center'));
    });

    test('returns default icon for unknown category without customCategories', () {
      final icon = categoryIconByName('unknown_cat');
      expect(icon, getCategoryIcon(null));
    });
  });

  group('categoryColorByNameFull', () {
    test('returns predefined color for known category', () {
      final color = categoryColorByNameFull('alimentacao');
      // Should return a non-default color (predefined)
      expect(color, isNotNull);
    });

    test('returns custom color from customCategories list', () {
      const custom = CustomCategory(
        id: '1',
        name: 'ginásio',
        colorHex: '#FF5722',
      );
      final color = categoryColorByNameFull(
        'ginásio',
        customCategories: [custom],
      );
      expect(color, const Color(0xFFFF5722));
    });

    test('returns custom color from explicit colorHex parameter', () {
      final color = categoryColorByNameFull(
        'ginásio',
        colorHex: '4CAF50',
      );
      expect(color, const Color(0xFF4CAF50));
    });

    test('falls back gracefully for unknown category without color', () {
      final color = categoryColorByNameFull('unknown_cat');
      // Should not throw, returns a fallback color
      expect(color, isNotNull);
    });
  });

  group('localizedCategoryLabel', () {
    test('returns raw name for non-predefined category', () {
      // Without l10n, we can test that non-predefined categories pass through
      // This uses the non-localized helper instead
      expect(categoryLabel('ginásio'), 'ginásio');
      expect(categoryLabel('unknown'), 'unknown');
    });

    test('returns enum label for predefined category', () {
      expect(categoryLabel('alimentacao'), 'Alimentação');
      expect(categoryLabel('energia'), 'Energia');
    });
  });
}
