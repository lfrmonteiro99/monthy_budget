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

  testWidgets('Grocery screen shows degraded store availability summary',
      (tester) async {
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
          groceryData: const GroceryData(
            countryCode: 'PT',
            currencyCode: 'EUR',
            storeSummaries: [
              GroceryStoreSummary(
                countryCode: 'PT',
                storeId: 'continente',
                storeName: 'Continente',
                status: GroceryStoreStatus.fresh,
              ),
              GroceryStoreSummary(
                countryCode: 'PT',
                storeId: 'pingo_doce',
                storeName: 'Pingo Doce',
                status: GroceryStoreStatus.partial,
              ),
              GroceryStoreSummary(
                countryCode: 'PT',
                storeId: 'auchan',
                storeName: 'Auchan',
                status: GroceryStoreStatus.failed,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Data availability'), findsOneWidget);
    expect(find.text('Market: PT'), findsOneWidget);
    expect(
      find.text('1 fresh · 1 partial · 1 unavailable'),
      findsOneWidget,
    );
  });

  testWidgets('Grocery screen shows empty state when no data is available',
      (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        const GroceryScreen(
          products: [],
        ),
      ),
    );

    expect(find.text('No grocery data available'), findsOneWidget);
    expect(find.textContaining('Try again later'), findsOneWidget);
  });
}
