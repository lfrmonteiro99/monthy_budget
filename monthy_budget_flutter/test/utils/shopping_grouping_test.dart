import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/shopping_item.dart';
import 'package:orcamento_mensal/utils/shopping_grouping.dart';

void main() {
  group('groupByMeal', () {
    test('groups items by sourceMealLabel', () {
      final items = [
        ShoppingItem(
          id: '1',
          productName: 'Chicken',
          store: 'Continente',
          price: 5.0,
          sourceMealId: 'm1',
          sourceMealLabel: 'Grilled Chicken',
        ),
        ShoppingItem(
          id: '2',
          productName: 'Rice',
          store: 'Continente',
          price: 1.5,
          sourceMealId: 'm1',
          sourceMealLabel: 'Grilled Chicken',
        ),
        ShoppingItem(
          id: '3',
          productName: 'Pasta',
          store: 'Lidl',
          price: 0.80,
          sourceMealId: 'm2',
          sourceMealLabel: 'Pasta Bolognese',
        ),
      ];

      final groups = groupByMeal(items);

      expect(groups.length, 2);
      final chickenGroup =
          groups.firstWhere((g) => g.label == 'Grilled Chicken');
      final pastaGroup =
          groups.firstWhere((g) => g.label == 'Pasta Bolognese');
      expect(chickenGroup.items.length, 2);
      expect(pastaGroup.items.length, 1);
    });

    test('items without sourceMealLabel go to ungrouped', () {
      final items = [
        ShoppingItem(
          id: '1',
          productName: 'Milk',
          store: 'Lidl',
          price: 1.29,
        ),
        ShoppingItem(
          id: '2',
          productName: 'Bread',
          store: 'Lidl',
          price: 0.99,
          sourceMealLabel: 'Breakfast',
        ),
      ];

      final groups = groupByMeal(items, ungroupedLabel: 'Other');

      expect(groups.length, 2);
      final otherGroup = groups.firstWhere((g) => g.label == 'Other');
      expect(otherGroup.items.length, 1);
      expect(otherGroup.items.first.productName, 'Milk');
    });

    test('all items without meal label produce single group', () {
      final items = [
        ShoppingItem(id: '1', productName: 'A', store: 'S', price: 1.0),
        ShoppingItem(id: '2', productName: 'B', store: 'S', price: 2.0),
      ];

      final groups = groupByMeal(items);

      expect(groups.length, 1);
      expect(groups.first.label, 'Other');
      expect(groups.first.items.length, 2);
    });

    test('empty list returns empty groups', () {
      final groups = groupByMeal([]);
      expect(groups, isEmpty);
    });
  });

  group('groupByStore', () {
    test('groups items by preferredStore when available', () {
      final items = [
        ShoppingItem(
          id: '1',
          productName: 'Milk',
          store: 'Continente',
          price: 1.29,
          preferredStore: 'Lidl',
        ),
        ShoppingItem(
          id: '2',
          productName: 'Bread',
          store: 'Continente',
          price: 0.99,
          preferredStore: 'Lidl',
        ),
        ShoppingItem(
          id: '3',
          productName: 'Cheese',
          store: 'Auchan',
          price: 3.50,
        ),
      ];

      final groups = groupByStore(items);

      expect(groups.length, 2);
      final lidlGroup = groups.firstWhere((g) => g.label == 'Lidl');
      final auchanGroup = groups.firstWhere((g) => g.label == 'Auchan');
      expect(lidlGroup.items.length, 2);
      expect(auchanGroup.items.length, 1);
    });

    test('falls back to store field when preferredStore is null', () {
      final items = [
        ShoppingItem(
          id: '1',
          productName: 'Eggs',
          store: 'Pingo Doce',
          price: 2.50,
        ),
      ];

      final groups = groupByStore(items);

      expect(groups.length, 1);
      expect(groups.first.label, 'Pingo Doce');
    });

    test('items without any store go to ungrouped label', () {
      final items = [
        ShoppingItem(
          id: '1',
          productName: 'Water',
          store: '',
          price: 0.50,
        ),
      ];

      final groups = groupByStore(items, ungroupedLabel: 'Unknown');

      expect(groups.length, 1);
      expect(groups.first.label, 'Unknown');
    });

    test('empty list returns empty groups', () {
      final groups = groupByStore([]);
      expect(groups, isEmpty);
    });
  });

  group('computeStoreSummaries', () {
    test('computes correct summaries per store', () {
      final items = [
        ShoppingItem(id: '1', productName: 'A', store: 'Lidl', price: 2.0),
        ShoppingItem(id: '2', productName: 'B', store: 'Lidl', price: 3.0),
        ShoppingItem(
          id: '3',
          productName: 'C',
          store: 'Continente',
          price: 5.0,
        ),
      ];

      final summaries = computeStoreSummaries(items);

      expect(summaries.length, 2);
      // Sorted by totalPrice descending
      expect(summaries.first.storeName, 'Lidl');
      expect(summaries.first.itemCount, 2);
      expect(summaries.first.totalPrice, closeTo(5.0, 0.001));
      expect(summaries.last.storeName, 'Continente');
      expect(summaries.last.itemCount, 1);
      expect(summaries.last.totalPrice, closeTo(5.0, 0.001));
    });

    test('prefers preferredStore over store field', () {
      final items = [
        ShoppingItem(
          id: '1',
          productName: 'A',
          store: 'Lidl',
          price: 2.0,
          preferredStore: 'Auchan',
        ),
      ];

      final summaries = computeStoreSummaries(items);

      expect(summaries.length, 1);
      expect(summaries.first.storeName, 'Auchan');
    });

    test('empty list returns empty summaries', () {
      final summaries = computeStoreSummaries([]);
      expect(summaries, isEmpty);
    });
  });

  group('ShoppingGroup', () {
    test('totalPrice sums all items', () {
      final group = ShoppingGroup(
        label: 'Test',
        items: [
          ShoppingItem(id: '1', productName: 'A', store: 'S', price: 1.5),
          ShoppingItem(id: '2', productName: 'B', store: 'S', price: 2.5),
        ],
      );

      expect(group.totalPrice, closeTo(4.0, 0.001));
    });

    test('uncheckedCount counts only unchecked items', () {
      final group = ShoppingGroup(
        label: 'Test',
        items: [
          ShoppingItem(
              id: '1', productName: 'A', store: 'S', price: 1.0, checked: true),
          ShoppingItem(
              id: '2', productName: 'B', store: 'S', price: 2.0, checked: false),
          ShoppingItem(
              id: '3', productName: 'C', store: 'S', price: 3.0, checked: false),
        ],
      );

      expect(group.uncheckedCount, 2);
    });
  });
}
