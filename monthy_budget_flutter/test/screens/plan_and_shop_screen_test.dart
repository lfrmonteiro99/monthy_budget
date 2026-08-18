import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/app_shell.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/models/shopping_item.dart';
import 'package:monthly_management/screens/plan_and_shop_screen.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  PlanAndShopScreen buildScreen({
    List<ShoppingItem> shoppingItems = const [],
    Set<String> weeklyPantryIds = const {},
  }) {
    return PlanAndShopScreen(
      shoppingItems: shoppingItems,
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
      weeklyPantryIds: weeklyPantryIds,
    );
  }

  testWidgets('Plan & Shop hub renders the page header and three tiles',
      (tester) async {
    await tester.pumpWidget(wrapWithTestApp(buildScreen()));
    // Single pump — the static structure (page header, tiles) renders on
    // the first frame. Avoid pumpAndSettle: the hero card initially shows a
    // CircularProgressIndicator while MealPlannerService.loadCatalog()
    // resolves, which never settles in widget-test envs without platform
    // channels (assets, SharedPreferences) wired up.
    await tester.pump();

    expect(find.text('Plan & Shop'), findsOneWidget);
    expect(find.text('List'), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Pantry'), findsOneWidget);
  });

  testWidgets(
      'List and Pantry tiles show "0 itens" (not "1 item") when empty, pt locale (#1235)',
      (tester) async {
    await tester.pumpWidget(wrapWithTestApp(
      buildScreen(shoppingItems: const [], weeklyPantryIds: const {}),
      controller: AppShellController(locale: const Locale('pt')),
    ));
    await tester.pump();

    // Both the shopping-list tile and the pantry tile use planShopItemCount
    // with the same empty collection, so both must read '0 itens'.
    expect(find.text('0 itens'), findsNWidgets(2));
    expect(find.text('1 item'), findsNothing);
  });

  testWidgets(
      'List tile shows "1 item" with exactly one item, pt locale (#1235)',
      (tester) async {
    await tester.pumpWidget(wrapWithTestApp(
      buildScreen(
        shoppingItems: [ShoppingItem(productName: 'Leite', store: 'Loja', price: 1.0)],
        weeklyPantryIds: const {},
      ),
      controller: AppShellController(locale: const Locale('pt')),
    ));
    await tester.pump();

    expect(find.text('1 item'), findsOneWidget);
  });

  testWidgets(
      'List tile shows "2 itens" with two items, pt locale (#1235)',
      (tester) async {
    await tester.pumpWidget(wrapWithTestApp(
      buildScreen(
        shoppingItems: [
          ShoppingItem(productName: 'Leite', store: 'Loja', price: 1.0),
          ShoppingItem(productName: 'Pão', store: 'Loja', price: 2.0),
        ],
        weeklyPantryIds: const {},
      ),
      controller: AppShellController(locale: const Locale('pt')),
    ));
    await tester.pump();

    expect(find.text('2 itens'), findsOneWidget);
  });
}
