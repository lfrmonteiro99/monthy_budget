import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/grocery_data.dart';
import 'package:orcamento_mensal/models/product.dart';
import 'package:orcamento_mensal/models/shopping_item.dart';
import 'package:orcamento_mensal/screens/grocery_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('Grocery screen filters products and adds item to shopping list',
      (tester) async {
    ShoppingItem? addedItem;

    await tester.pumpWidget(
      wrapWithTestApp(
        GroceryScreen(
          products: const [
            Product(
              id: 'p1',
              name: 'Milk',
              category: 'Laticinios',
              avgPrice: 1.5,
              unit: 'L',
            ),
            Product(
              id: 'p2',
              name: 'Apple',
              category: 'Frutas',
              avgPrice: 2.1,
              unit: 'kg',
            ),
          ],
          onAddToShoppingList: (item) => addedItem = item,
        ),
      ),
    );

    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'milk');
    await tester.pumpAndSettle();

    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    expect(addedItem, isNotNull);
    expect(addedItem!.productName, 'Milk');
  });

  testWidgets('Grocery screen category chip filters visible products',
      (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        const GroceryScreen(
          products: [
            Product(
              id: 'p1',
              name: 'Milk',
              category: 'Laticinios',
              avgPrice: 1.5,
              unit: 'L',
            ),
            Product(
              id: 'p2',
              name: 'Apple',
              category: 'Frutas',
              avgPrice: 2.1,
              unit: 'kg',
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Frutas'));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Milk'), findsNothing);
  });

  testWidgets('Grocery screen surfaces stale-store status and lets user hide degraded stores',
      (tester) async {
    final groceryData = GroceryData.fromJson({
      'store_statuses': [
        {
          'store_id': 'continente',
          'store_name': 'Continente',
          'status': 'fresh',
          'scraped_at': '2026-03-09T09:00:00Z',
          'listing_count': 100,
          'matched_count': 98,
          'unmatched_count': 2,
          'validation_warnings': [],
        },
        {
          'store_id': 'pingo_doce',
          'store_name': 'Pingo Doce',
          'status': 'partial',
          'scraped_at': '2026-03-09T08:00:00Z',
          'listing_count': 80,
          'matched_count': 70,
          'unmatched_count': 10,
          'validation_warnings': ['high unmatched'],
        },
        {
          'store_id': 'auchan',
          'store_name': 'Auchan',
          'status': 'failed',
          'scraped_at': '2026-03-08T08:00:00Z',
          'listing_count': 0,
          'matched_count': 0,
          'unmatched_count': 0,
          'validation_warnings': ['timeout'],
        },
      ],
      'comparisons': [
        {
          'product_name': 'Milk',
          'prices': [
            {'store': 'Continente', 'price': 1.20},
            {'store': 'Pingo Doce', 'price': 1.10},
            {'store': 'Auchan', 'price': 1.05},
          ],
          'cheapest_store': 'Auchan',
          'cheapest_price': 1.05,
          'potential_savings': 0.15,
          'savings_percent': 12.5,
        },
      ],
    });

    await tester.pumpWidget(
      wrapWithTestApp(
        GroceryScreen(
          products: const [
            Product(
              id: 'p1',
              name: 'Milk',
              category: 'Laticinios',
              avgPrice: 1.5,
              unit: 'L',
            ),
          ],
          groceryData: groceryData,
          marketCode: 'PT',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PT market data'), findsOneWidget);
    expect(find.text('1 active of 3 stores'), findsOneWidget);
    expect(find.text('Hide stale stores'), findsOneWidget);

    await tester.tap(find.text('Hide stale stores'));
    await tester.pumpAndSettle();

    expect(find.text('Showing 1 fresh store in comparisons'), findsOneWidget);
  });
}
