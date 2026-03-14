import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/shopping_item.dart';
import 'package:monthly_management/utils/shopping_grouping.dart';

void main() {
  group('groupByMeal', () {
    test('groups items by sourceMealLabels', () {
      final items = [
        ShoppingItem(
          id: '1',
          productName: 'Chicken',
          store: 'Continente',
          price: 5.0,
          sourceMealLabels: ['Grilled Chicken'],
        ),
        ShoppingItem(
          id: '2',
          productName: 'Rice',
          store: 'Continente',
          price: 1.5,
          sourceMealLabels: ['Grilled Chicken'],
        ),
        ShoppingItem(
          id: '3',
          productName: 'Pasta',
          store: 'Lidl',
          price: 0.80,
          sourceMealLabels: ['Pasta Bolognese'],
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

    test('item with multiple labels appears in each group', () {
      final items = [
        ShoppingItem(
          id: '1',
          productName: 'Onion',
          store: 'Lidl',
          price: 0.40,
          sourceMealLabels: ['Chicken Soup', 'Pasta Bolognese'],
        ),
        ShoppingItem(
          id: '2',
          productName: 'Pasta',
          store: 'Lidl',
          price: 0.80,
          sourceMealLabels: ['Pasta Bolognese'],
        ),
      ];

      final groups = groupByMeal(items);

      expect(groups.length, 2);
      final soupGroup = groups.firstWhere((g) => g.label == 'Chicken Soup');
      final pastaGroup = groups.firstWhere((g) => g.label == 'Pasta Bolognese');
      expect(soupGroup.items.length, 1);
      expect(soupGroup.items.first.productName, 'Onion');
      expect(pastaGroup.items.length, 2);
    });

    test('items without sourceMealLabels go to ungrouped', () {
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
          sourceMealLabels: ['Breakfast'],
        ),
      ];

      final groups = groupByMeal(items, ungroupedLabel: 'Other');

      expect(groups.length, 2);
      final otherGroup = groups.firstWhere((g) => g.label == 'Other');
      expect(otherGroup.items.length, 1);
      expect(otherGroup.items.first.productName, 'Milk');
    });

    test('all items without meal labels produce single group', () {
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

  group('mergeIntoList', () {
    test('adds new item when no duplicate exists', () {
      final list = [
        ShoppingItem(id: '1', productName: 'Arroz', store: '', price: 1.10, quantity: 1.0, unit: 'kg'),
      ];
      final newItem = ShoppingItem(productName: 'Frango', store: '', price: 5.25, quantity: 0.7, unit: 'kg');

      final result = mergeIntoList(list, newItem);

      expect(result.merged, isNull);
      expect(result.isNew, isTrue);
    });

    test('aggregates quantity and price when duplicate exists', () {
      final list = [
        ShoppingItem(id: 'x', productName: 'Frango', store: '', price: 3.50, quantity: 0.5, unit: 'kg'),
      ];
      final newItem = ShoppingItem(productName: 'Frango', store: '', price: 2.10, quantity: 0.3, unit: 'kg');

      final result = mergeIntoList(list, newItem);

      expect(result.isNew, isFalse);
      expect(result.merged, isNotNull);
      expect(result.merged!.id, 'x');
      expect(result.merged!.quantity, closeTo(0.8, 0.001));
      expect(result.merged!.price, closeTo(5.60, 0.001));
    });

    test('aggregates price even when quantities are null', () {
      final list = [
        ShoppingItem(id: 'y', productName: 'Pão', store: '', price: 0.99),
      ];
      final newItem = ShoppingItem(productName: 'Pão', store: '', price: 0.99);

      final result = mergeIntoList(list, newItem);

      expect(result.isNew, isFalse);
      expect(result.merged!.price, closeTo(1.98, 0.001));
      expect(result.merged!.quantity, isNull);
    });

    test('match is case-insensitive', () {
      final list = [
        ShoppingItem(id: 'z', productName: 'LEITE', store: '', price: 0.89, quantity: 1.0, unit: 'L'),
      ];
      final newItem = ShoppingItem(productName: 'Leite', store: '', price: 0.89, quantity: 1.0, unit: 'L');

      final result = mergeIntoList(list, newItem);

      expect(result.isNew, isFalse);
      expect(result.merged!.quantity, closeTo(2.0, 0.001));
    });

    test('unions sourceMealLabels when merging duplicates', () {
      final list = [
        ShoppingItem(
          id: 'a', productName: 'Cebola', store: '', price: 0.40,
          quantity: 0.2, unit: 'kg',
          sourceMealLabels: ['Sopa de Legumes'],
        ),
      ];
      final newItem = ShoppingItem(
        productName: 'Cebola', store: '', price: 0.20, quantity: 0.1, unit: 'kg',
        sourceMealLabels: ['Frango Assado'],
      );

      final result = mergeIntoList(list, newItem);

      expect(result.merged!.sourceMealLabels, unorderedEquals(['Sopa de Legumes', 'Frango Assado']));
      expect(result.merged!.quantity, closeTo(0.3, 0.001));
    });

    test('unions sourceMealLabels without duplicates', () {
      final list = [
        ShoppingItem(
          id: 'b', productName: 'Arroz', store: '', price: 1.10,
          sourceMealLabels: ['Frango Assado'],
        ),
      ];
      final newItem = ShoppingItem(
        productName: 'Arroz', store: '', price: 0.55,
        sourceMealLabels: ['Frango Assado', 'Risotto'],
      );

      final result = mergeIntoList(list, newItem);

      expect(result.merged!.sourceMealLabels, unorderedEquals(['Frango Assado', 'Risotto']));
    });

    test('merging item with empty labels into item with labels preserves labels', () {
      final list = [
        ShoppingItem(
          id: 'c', productName: 'Tomate', store: '', price: 0.80,
          sourceMealLabels: ['Salada'],
        ),
      ];
      final newItem = ShoppingItem(
        productName: 'Tomate', store: '', price: 0.40,
      );

      final result = mergeIntoList(list, newItem);

      expect(result.merged!.sourceMealLabels, ['Salada']);
    });
  });

  group('availableGroupModes', () {
    test('returns only items when no meal labels or stores', () {
      final items = [
        ShoppingItem(id: '1', productName: 'Milk', store: '', price: 1.0),
        ShoppingItem(id: '2', productName: 'Bread', store: '', price: 0.99),
      ];

      final modes = availableGroupModes(items);

      expect(modes, [ShoppingGroupMode.items]);
    });

    test('includes meals when at least one item has sourceMealLabels', () {
      final items = [
        ShoppingItem(id: '1', productName: 'Frango', store: '', price: 5.0, sourceMealLabels: ['Frango Assado']),
        ShoppingItem(id: '2', productName: 'Arroz', store: '', price: 1.0),
      ];

      final modes = availableGroupModes(items);

      expect(modes, contains(ShoppingGroupMode.meals));
      expect(modes, contains(ShoppingGroupMode.items));
      expect(modes, isNot(contains(ShoppingGroupMode.stores)));
    });

    test('includes stores when at least one item has preferredStore', () {
      final items = [
        ShoppingItem(id: '1', productName: 'Leite', store: '', price: 0.89, preferredStore: 'Lidl'),
      ];

      final modes = availableGroupModes(items);

      expect(modes, contains(ShoppingGroupMode.stores));
    });

    test('includes stores when at least one item has non-empty store', () {
      final items = [
        ShoppingItem(id: '1', productName: 'Pão', store: 'Continente', price: 0.99),
      ];

      final modes = availableGroupModes(items);

      expect(modes, contains(ShoppingGroupMode.stores));
    });

    test('includes both meals and stores when data exists for both', () {
      final items = [
        ShoppingItem(id: '1', productName: 'Frango', store: 'Lidl', price: 5.0, sourceMealLabels: ['Frango Assado']),
      ];

      final modes = availableGroupModes(items);

      expect(modes.length, 3);
    });

    test('empty list returns only items', () {
      final modes = availableGroupModes([]);

      expect(modes, [ShoppingGroupMode.items]);
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
