import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/grocery_data.dart';
import 'package:monthly_management/models/product.dart';
import 'package:monthly_management/screens/grocery_screen.dart';

import '../helpers/test_app.dart';

void main() {
  group('Store freshness indicators', () {
    testWidgets('shows colored status dot for each store in availability card',
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

      // Each store name should appear in the availability card
      expect(find.text('Continente'), findsOneWidget);
      expect(find.text('Pingo Doce'), findsOneWidget);
      expect(find.text('Auchan'), findsOneWidget);

      // Each store should have a human-readable status label
      expect(find.text('Fresh'), findsOneWidget);
      expect(find.text('Partial'), findsOneWidget);
      expect(find.text('Unavailable'), findsOneWidget);
    });

    testWidgets('shows stale status label for stale stores', (tester) async {
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
                  status: GroceryStoreStatus.stale,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Continente'), findsOneWidget);
      expect(find.text('Stale'), findsOneWidget);
    });

    testWidgets('shows freshness age when lastUpdatedAt is provided',
        (tester) async {
      // Use a timestamp 3 hours ago
      final threeHoursAgo =
          DateTime.now().toUtc().subtract(const Duration(hours: 3));

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
            groceryData: GroceryData(
              countryCode: 'PT',
              currencyCode: 'EUR',
              storeSummaries: [
                GroceryStoreSummary(
                  countryCode: 'PT',
                  storeId: 'continente',
                  storeName: 'Continente',
                  status: GroceryStoreStatus.fresh,
                  lastUpdatedAt: threeHoursAgo.toIso8601String(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Continente'), findsOneWidget);
      // Should display "Updated 3h ago"
      expect(find.text('Updated 3h ago'), findsOneWidget);
    });

    testWidgets('shows freshness age in days when older than 24h',
        (tester) async {
      final twoDaysAgo =
          DateTime.now().toUtc().subtract(const Duration(hours: 50));

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
            groceryData: GroceryData(
              countryCode: 'PT',
              currencyCode: 'EUR',
              storeSummaries: [
                GroceryStoreSummary(
                  countryCode: 'PT',
                  storeId: 'continente',
                  storeName: 'Continente',
                  status: GroceryStoreStatus.stale,
                  lastUpdatedAt: twoDaysAgo.toIso8601String(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Continente'), findsOneWidget);
      // 50 hours = 2 days
      expect(find.text('Updated 2d ago'), findsOneWidget);
    });

    testWidgets('all-fresh stores show green success styling',
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
                  status: GroceryStoreStatus.fresh,
                ),
              ],
            ),
          ),
        ),
      );

      // Both store names should be visible
      expect(find.text('Continente'), findsOneWidget);
      expect(find.text('Pingo Doce'), findsOneWidget);
      // Both should show Fresh label
      expect(find.text('Fresh'), findsNWidgets(2));
    });

    testWidgets(
        'availability card does not appear when there are no store summaries',
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
              countryCode: '',
              currencyCode: '',
              storeSummaries: [],
            ),
          ),
        ),
      );

      // No availability card elements
      expect(find.text('Data availability'), findsNothing);
    });
  });
}
