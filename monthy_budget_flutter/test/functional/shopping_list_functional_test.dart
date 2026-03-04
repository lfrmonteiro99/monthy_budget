import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/purchase_record.dart';
import 'package:orcamento_mensal/models/shopping_item.dart';
import 'package:orcamento_mensal/screens/shopping_list_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('Shopping list shows empty state when no items', (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        ShoppingListScreen(
          items: const [],
          purchaseHistory: const PurchaseHistory(),
          onToggleChecked: (_) {},
          onRemove: (_) {},
          onClearChecked: () {},
          onFinalize: (_, _, {isMealPurchase = false}) {},
        ),
      ),
    );

    expect(find.byIcon(Icons.shopping_basket_outlined), findsOneWidget);
  });

  testWidgets('Shopping list toggles item and finalizes checked purchase',
      (tester) async {
    ShoppingItem? toggled;
    double? finalizedAmount;
    List<ShoppingItem> finalizedItems = const [];
    bool finalizedAsMeal = false;

    final items = [
      ShoppingItem(
        id: 'a',
        productName: 'Milk',
        store: 'Store',
        price: 2.0,
        checked: false,
      ),
      ShoppingItem(
        id: 'b',
        productName: 'Bread',
        store: 'Store',
        price: 1.5,
        checked: true,
      ),
    ];

    await tester.pumpWidget(
      wrapWithTestApp(
        ShoppingListScreen(
          items: items,
          purchaseHistory: const PurchaseHistory(),
          onToggleChecked: (item) => toggled = item,
          onRemove: (_) {},
          onClearChecked: () {},
          onFinalize: (amount, checkedItems, {isMealPurchase = false}) {
            finalizedAmount = amount;
            finalizedItems = checkedItems;
            finalizedAsMeal = isMealPurchase;
          },
        ),
      ),
    );

    await tester.tap(find.text('Milk'));
    await tester.pump();
    expect(toggled, isNotNull);
    expect(toggled!.id, 'a');

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '19.90');
    await tester.tap(find.byType(FilledButton).last);
    await tester.pumpAndSettle();

    expect(finalizedAmount, closeTo(19.9, 0.001));
    expect(finalizedItems.map((e) => e.id).toList(), ['b']);
    expect(finalizedAsMeal, isFalse);
  });
}
