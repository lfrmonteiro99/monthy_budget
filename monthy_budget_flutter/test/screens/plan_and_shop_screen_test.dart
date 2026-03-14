import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/screens/plan_and_shop_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('Plan & Shop screen shows three tabs', (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        PlanAndShopScreen(
          shoppingItems: const [],
          onToggleChecked: (_) {},
          onRemove: (_) {},
          onClearChecked: () {},
          onFinalize: (_, __, {bool isMealPurchase = false}) {},
          purchaseHistory: const PurchaseHistory(),
          products: const [],
          settings: const AppSettings(),
          apiKey: '',
          favorites: const [],
          householdId: 'test',
          onSaveSettings: (_) {},
          onOpenMealSettings: () {},
        ),
      ),
    );

    // Should show the three tab labels
    expect(find.text('Shopping List'), findsOneWidget);
    expect(find.text('Grocery'), findsOneWidget);
    expect(find.text('Meal Planner'), findsOneWidget);
  });

  testWidgets('Plan & Shop screen switches tabs on tap', (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        PlanAndShopScreen(
          shoppingItems: const [],
          onToggleChecked: (_) {},
          onRemove: (_) {},
          onClearChecked: () {},
          onFinalize: (_, __, {bool isMealPurchase = false}) {},
          purchaseHistory: const PurchaseHistory(),
          products: const [],
          settings: const AppSettings(),
          apiKey: '',
          favorites: const [],
          householdId: 'test',
          onSaveSettings: (_) {},
          onOpenMealSettings: () {},
        ),
      ),
    );

    // Default tab is Shopping List — verify it's visible
    expect(find.text('Shopping List'), findsOneWidget);

    // Tap on Grocery tab
    await tester.tap(find.text('Grocery'));
    await tester.pumpAndSettle();

    // Tap on Meal Planner tab
    await tester.tap(find.text('Meal Planner'));
    await tester.pumpAndSettle();

    // All three tabs should still be visible as tab headers
    expect(find.text('Shopping List'), findsOneWidget);
    expect(find.text('Grocery'), findsOneWidget);
    expect(find.text('Meal Planner'), findsOneWidget);
  });
}
