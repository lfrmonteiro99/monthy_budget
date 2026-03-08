import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orcamento_mensal/l10n/generated/app_localizations.dart';
import 'package:orcamento_mensal/models/product.dart';
import 'package:orcamento_mensal/models/scanned_product_candidate.dart';
import 'package:orcamento_mensal/models/shopping_item.dart';
import 'package:orcamento_mensal/widgets/barcode_result_card.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  group('BarcodeResultCard', () {
    testWidgets('shows matched product confirmation when match found',
        (tester) async {
      const product = Product(
        id: 'p1',
        name: 'Leite Meio-Gordo',
        category: 'Laticinios',
        avgPrice: 0.79,
        unit: 'L',
        barcode: '5601234567890',
      );

      final candidate = ScannedProductCandidate(
        barcode: '5601234567890',
        matchedProduct: product,
        confidence: 1.0,
        source: BarcodeLookupSource.cached,
      );

      ShoppingItem? addedItem;

      await tester.pumpWidget(_wrap(
        BarcodeResultCard(
          candidate: candidate,
          onAddToList: (item) => addedItem = item,
        ),
      ));
      await tester.pumpAndSettle();

      // Should display the product name
      expect(find.text('Leite Meio-Gordo'), findsOneWidget);
      // Should display "Product Found"
      expect(find.text('Product Found'), findsOneWidget);
      // Should show the barcode
      expect(find.textContaining('5601234567890'), findsOneWidget);
      // Should show add button
      expect(find.text('Add to List'), findsOneWidget);

      // Tap add button
      await tester.tap(find.text('Add to List'));
      await tester.pumpAndSettle();

      expect(addedItem, isNotNull);
      expect(addedItem!.productName, 'Leite Meio-Gordo');
      expect(addedItem!.price, 0.79);
    });

    testWidgets('shows manual entry fields when no match found',
        (tester) async {
      const candidate = ScannedProductCandidate(
        barcode: '9999999999999',
        source: BarcodeLookupSource.manual,
      );

      await tester.pumpWidget(_wrap(
        BarcodeResultCard(
          candidate: candidate,
          onAddToList: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Should display "Product Not Found"
      expect(find.text('Product Not Found'), findsOneWidget);
      // Should display barcode
      expect(find.textContaining('9999999999999'), findsOneWidget);
      // Should show manual entry hint
      expect(
          find.text('No matching product found. Enter details manually:'),
          findsOneWidget);
      // Should show text fields for name and price
      expect(find.text('Product name'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
    });

    testWidgets('manual entry submits with user-entered data',
        (tester) async {
      const candidate = ScannedProductCandidate(
        barcode: '9999999999999',
        source: BarcodeLookupSource.manual,
      );

      ShoppingItem? addedItem;

      await tester.pumpWidget(_wrap(
        BarcodeResultCard(
          candidate: candidate,
          onAddToList: (item) => addedItem = item,
        ),
      ));
      await tester.pumpAndSettle();

      // Enter product name
      await tester.enterText(
          find.widgetWithText(TextField, 'Product name'), 'Custom Product');
      // Enter price
      await tester.enterText(
          find.widgetWithText(TextField, 'Price'), '2.99');

      // Tap add button
      await tester.tap(find.text('Add to List'));
      await tester.pumpAndSettle();

      expect(addedItem, isNotNull);
      expect(addedItem!.productName, 'Custom Product');
      expect(addedItem!.price, 2.99);
    });

    testWidgets('manual entry does not submit with empty name',
        (tester) async {
      const candidate = ScannedProductCandidate(
        barcode: '9999999999999',
        source: BarcodeLookupSource.manual,
      );

      ShoppingItem? addedItem;

      await tester.pumpWidget(_wrap(
        BarcodeResultCard(
          candidate: candidate,
          onAddToList: (item) => addedItem = item,
        ),
      ));
      await tester.pumpAndSettle();

      // Don't enter any name, just tap add
      await tester.tap(find.text('Add to List'));
      await tester.pumpAndSettle();

      expect(addedItem, isNull);
    });
  });
}
