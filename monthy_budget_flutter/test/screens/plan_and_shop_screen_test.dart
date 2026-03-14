import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/screens/plan_and_shop_screen.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  PlanAndShopScreen buildScreen() {
    return PlanAndShopScreen(
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
    );
  }

  testWidgets('Plan & Shop screen shows three tabs', (tester) async {
    await tester.pumpWidget(wrapWithTestApp(buildScreen()));
    await tester.pumpAndSettle();

    // Should show the three tab labels
    expect(find.text('Shopping List'), findsOneWidget);
    expect(find.text('Grocery'), findsOneWidget);
    expect(find.text('Meal Planner'), findsOneWidget);
  });

  testWidgets('Plan & Shop screen switches tabs on tap', (tester) async {
    await tester.pumpWidget(wrapWithTestApp(buildScreen()));
    await tester.pumpAndSettle();

    // Default tab is Shopping List — verify it's visible
    expect(find.text('Shopping List'), findsOneWidget);

    // Tap on Grocery tab — this is safe because GroceryScreen does not
    // require Supabase initialization.
    await tester.tap(find.text('Grocery'));
    await tester.pumpAndSettle();

    // All three tab headers should still be visible after switching.
    expect(find.text('Shopping List'), findsOneWidget);
    expect(find.text('Grocery'), findsOneWidget);
    expect(find.text('Meal Planner'), findsOneWidget);

    // NOTE: Switching to the Meal Planner tab is not tested here because
    // MealPlannerScreen eagerly creates MealPlannerAiService which calls
    // Supabase.instance in its constructor, causing an assertion failure
    // in test environments where Supabase is not initialized.
  });
}
