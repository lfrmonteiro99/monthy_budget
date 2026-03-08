import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/shopping_item.dart';
import 'package:orcamento_mensal/utils/shopping_grouping.dart';
import 'package:orcamento_mensal/widgets/shopping_list_grouped_view.dart';

import '../helpers/test_app.dart';

void main() {
  group('ShoppingListGroupedView', () {
    testWidgets('renders group headers and items', (tester) async {
      final groups = [
        ShoppingGroup(
          label: 'Grilled Chicken',
          items: [
            ShoppingItem(
              id: '1',
              productName: 'Chicken Breast',
              store: 'Lidl',
              price: 5.0,
            ),
            ShoppingItem(
              id: '2',
              productName: 'Olive Oil',
              store: 'Lidl',
              price: 3.0,
            ),
          ],
        ),
        ShoppingGroup(
          label: 'Pasta Night',
          items: [
            ShoppingItem(
              id: '3',
              productName: 'Spaghetti',
              store: 'Continente',
              price: 1.0,
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: ShoppingListGroupedView(
              groups: groups,
              mode: ShoppingGroupMode.meals,
              onToggleChecked: (_) {},
              onRemove: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Grilled Chicken'), findsOneWidget);
      expect(find.text('Pasta Night'), findsOneWidget);
      expect(find.text('Chicken Breast'), findsOneWidget);
      expect(find.text('Olive Oil'), findsOneWidget);
      expect(find.text('Spaghetti'), findsOneWidget);
    });

    testWidgets('tapping group header collapses items', (tester) async {
      final groups = [
        ShoppingGroup(
          label: 'Test Group',
          items: [
            ShoppingItem(
              id: '1',
              productName: 'Hidden Item',
              store: 'Store',
              price: 1.0,
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: ShoppingListGroupedView(
              groups: groups,
              mode: ShoppingGroupMode.stores,
              onToggleChecked: (_) {},
              onRemove: (_) {},
            ),
          ),
        ),
      );

      // Item is visible initially
      expect(find.text('Hidden Item'), findsOneWidget);

      // Tap header to collapse
      await tester.tap(find.text('Test Group'));
      await tester.pump();

      // Item should be hidden
      expect(find.text('Hidden Item'), findsNothing);

      // Tap again to expand
      await tester.tap(find.text('Test Group'));
      await tester.pump();

      expect(find.text('Hidden Item'), findsOneWidget);
    });

    testWidgets('tapping item calls onToggleChecked', (tester) async {
      ShoppingItem? toggled;
      final item = ShoppingItem(
        id: '1',
        productName: 'Milk',
        store: 'Lidl',
        price: 1.29,
      );
      final groups = [
        ShoppingGroup(label: 'Store A', items: [item]),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: ShoppingListGroupedView(
              groups: groups,
              mode: ShoppingGroupMode.stores,
              onToggleChecked: (i) => toggled = i,
              onRemove: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Milk'));
      await tester.pump();

      expect(toggled, isNotNull);
      expect(toggled!.id, '1');
    });

    testWidgets('shows cheapest store hint when available', (tester) async {
      final groups = [
        ShoppingGroup(
          label: 'Test',
          items: [
            ShoppingItem(
              id: '1',
              productName: 'Cheese',
              store: 'Continente',
              price: 3.50,
              cheapestKnownStore: 'Auchan',
              cheapestKnownPrice: 2.99,
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: ShoppingListGroupedView(
              groups: groups,
              mode: ShoppingGroupMode.stores,
              onToggleChecked: (_) {},
              onRemove: (_) {},
            ),
          ),
        ),
      );

      // The cheapest-at hint should appear
      expect(find.textContaining('Auchan'), findsWidgets);
    });

    testWidgets('renders empty groups without error', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: ShoppingListGroupedView(
              groups: const [],
              mode: ShoppingGroupMode.meals,
              onToggleChecked: (_) {},
              onRemove: (_) {},
            ),
          ),
        ),
      );

      // Should render without crashing
      expect(find.byType(ShoppingListGroupedView), findsOneWidget);
    });
  });
}
