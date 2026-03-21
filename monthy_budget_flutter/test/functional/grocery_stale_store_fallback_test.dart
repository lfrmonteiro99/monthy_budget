import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/grocery_data.dart';
import 'package:monthly_management/models/product.dart';
import 'package:monthly_management/models/shopping_item.dart';
import 'package:monthly_management/screens/grocery_screen.dart';

import '../helpers/test_app.dart';

void main() {
  const freshStore = GroceryStoreSummary(
    countryCode: 'PT',
    storeId: 'continente',
    storeName: 'Continente',
    status: GroceryStoreStatus.fresh,
  );
  const partialStore = GroceryStoreSummary(
    countryCode: 'PT',
    storeId: 'pingo_doce',
    storeName: 'Pingo Doce',
    status: GroceryStoreStatus.partial,
  );
  const failedStore = GroceryStoreSummary(
    countryCode: 'PT',
    storeId: 'auchan',
    storeName: 'Auchan',
    status: GroceryStoreStatus.failed,
  );

  const sampleProducts = [
    Product(id: 'p1', name: 'Milk', category: 'Laticinios', avgPrice: 1.5, unit: 'L'),
    Product(id: 'p2', name: 'Apple', category: 'Frutas', avgPrice: 2.1, unit: 'kg'),
  ];

  testWidgets('partial store shows store name with Partial status badge',
      (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        GroceryScreen(
          products: sampleProducts,
          groceryData: const GroceryData(
            countryCode: 'PT',
            currencyCode: 'EUR',
            storeSummaries: [freshStore, partialStore],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The partial store should show its name and a Partial status badge
    expect(find.text('Pingo Doce'), findsOneWidget);
    expect(find.text('Partial'), findsOneWidget);
  });

  testWidgets('failed store shows store name with Unavailable status badge',
      (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        GroceryScreen(
          products: sampleProducts,
          groceryData: const GroceryData(
            countryCode: 'PT',
            currencyCode: 'EUR',
            storeSummaries: [freshStore, failedStore],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The failed store should show its name and an Unavailable status badge
    expect(find.text('Auchan'), findsOneWidget);
    expect(find.text('Unavailable'), findsOneWidget);
  });

  testWidgets('both partial and failed stores show distinct status badges',
      (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        GroceryScreen(
          products: sampleProducts,
          groceryData: const GroceryData(
            countryCode: 'PT',
            currencyCode: 'EUR',
            storeSummaries: [freshStore, partialStore, failedStore],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Both degraded stores should have individual status badges
    expect(find.text('Pingo Doce'), findsOneWidget);
    expect(find.text('Partial'), findsOneWidget);
    expect(find.text('Auchan'), findsOneWidget);
    expect(find.text('Unavailable'), findsOneWidget);
  });

  testWidgets('grocery list remains browsable with degraded store data',
      (tester) async {
    ShoppingItem? addedItem;

    await tester.pumpWidget(
      wrapWithTestApp(
        GroceryScreen(
          products: sampleProducts,
          groceryData: const GroceryData(
            countryCode: 'PT',
            currencyCode: 'EUR',
            storeSummaries: [freshStore, partialStore, failedStore],
          ),
          onAddToShoppingList: (item) => addedItem = item,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Products should still be visible despite degraded stores
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);

    // Filtering should still work
    await tester.enterText(find.byType(TextField), 'milk');
    await tester.pumpAndSettle();
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);

    // Adding to cart should still work
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(addedItem, isNotNull);
    expect(addedItem!.productName, 'Milk');
  });

  testWidgets('no fallback messages shown when all stores are fresh',
      (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        GroceryScreen(
          products: sampleProducts,
          groceryData: const GroceryData(
            countryCode: 'PT',
            currencyCode: 'EUR',
            storeSummaries: [
              freshStore,
              GroceryStoreSummary(
                countryCode: 'PT',
                storeId: 'lidl',
                storeName: 'Lidl',
                status: GroceryStoreStatus.fresh,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // No per-store stale fallback messages should be shown
    expect(find.textContaining('has partial data'), findsNothing);
    expect(find.textContaining('is unavailable'), findsNothing);
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
  });

  testWidgets('degraded stores show status badges in availability card',
      (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        GroceryScreen(
          products: sampleProducts,
          groceryData: const GroceryData(
            countryCode: 'PT',
            currencyCode: 'EUR',
            storeSummaries: [freshStore, partialStore, failedStore],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Each store should have a visible status badge
    expect(find.text('Fresh'), findsOneWidget);
    expect(find.text('Partial'), findsOneWidget);
    expect(find.text('Unavailable'), findsOneWidget);
  });
}
