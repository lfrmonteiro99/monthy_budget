import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/grocery_data.dart';
import 'package:monthly_management/models/product.dart';
import 'package:monthly_management/screens/grocery_screen.dart';

import '../helpers/test_app.dart';

void main() {
  // Build a GroceryData with mixed store statuses so the filter chip appears
  final groceryData = GroceryData.fromJson({
    'country_code': 'PT',
    'currency_code': 'EUR',
    'generated_at': '2026-03-21T10:00:00Z',
    'products': [
      {
        'id': 'milk_1l',
        'display_name': 'Whole Milk 1L',
        'category': 'Dairy',
        'size_unit': 'L',
      },
    ],
    'stores': [
      {'store_id': 'continente', 'store_name': 'Continente'},
      {'store_id': 'pingo_doce', 'store_name': 'Pingo Doce'},
    ],
    'store_statuses': [
      {
        'store_id': 'continente',
        'store_name': 'Continente',
        'status': 'fresh',
        'listing_count': 10,
      },
      {
        'store_id': 'pingo_doce',
        'store_name': 'Pingo Doce',
        'status': 'partial',
        'listing_count': 5,
      },
    ],
    'listings': [
      {
        'canonical_product_id': 'milk_1l',
        'product_name': 'Whole Milk 1L',
        'store_id': 'continente',
        'category': 'Dairy',
        'price': 1.29,
        'price_per_base_unit': 1.29,
        'base_unit': 'L',
      },
      {
        'canonical_product_id': 'milk_1l',
        'product_name': 'Whole Milk 1L',
        'store_id': 'pingo_doce',
        'category': 'Dairy',
        'price': 1.39,
        'price_per_base_unit': 1.39,
        'base_unit': 'L',
      },
    ],
  });

  testWidgets('Hide stale stores chip appears when degraded stores exist',
      (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        GroceryScreen(
          products: groceryData.toCatalogProducts(),
          groceryData: groceryData,
        ),
      ),
    );

    expect(find.text('Hide stale stores'), findsOneWidget);
  });

  testWidgets('Hide stale stores chip does not appear when no degraded stores',
      (tester) async {
    final allFreshData = const GroceryData(
      countryCode: 'PT',
      currencyCode: 'EUR',
      storeSummaries: [
        GroceryStoreSummary(
          storeId: 'continente',
          storeName: 'Continente',
          status: GroceryStoreStatus.fresh,
        ),
      ],
    );

    await tester.pumpWidget(
      wrapWithTestApp(
        GroceryScreen(
          products: const [
            Product(
              id: 'p1',
              name: 'Milk',
              category: 'Dairy',
              avgPrice: 1.5,
              unit: 'L',
            ),
          ],
          groceryData: allFreshData,
        ),
      ),
    );

    expect(find.text('Hide stale stores'), findsNothing);
  });

  testWidgets('Toggling filter does not crash and product list remains visible',
      (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        GroceryScreen(
          products: groceryData.toCatalogProducts(),
          groceryData: groceryData,
        ),
      ),
    );

    // Products are visible before toggling
    expect(find.text('Whole Milk 1L'), findsOneWidget);

    // Toggle the filter on
    await tester.tap(find.text('Hide stale stores'));
    await tester.pumpAndSettle();

    // Products should still be visible (fresh store data remains)
    expect(find.text('Whole Milk 1L'), findsOneWidget);

    // Toggle the filter off
    await tester.tap(find.text('Hide stale stores'));
    await tester.pumpAndSettle();

    // Products still visible
    expect(find.text('Whole Milk 1L'), findsOneWidget);
  });

  testWidgets('Filter chip does not appear when products list is empty',
      (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        GroceryScreen(
          products: const [],
          groceryData: groceryData,
        ),
      ),
    );

    // Empty state should show, no filter chip
    expect(find.text('Hide stale stores'), findsNothing);
  });
}
