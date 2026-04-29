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

  testWidgets('Plan & Shop hub renders the page header and three tiles',
      (tester) async {
    await tester.pumpWidget(wrapWithTestApp(buildScreen()));
    await tester.pumpAndSettle();

    // Page header title (Calm rewrite — was a 3-tab TabBar before #951).
    expect(find.text('Plano & compras'), findsOneWidget);

    // Three navigation tiles (CalmTile labels).
    expect(find.text('Lista'), findsOneWidget);
    expect(find.text('Ementa'), findsOneWidget);
    expect(find.text('Despensa'), findsOneWidget);
  });

  testWidgets('Plan & Shop hub shows the weekly budget eyebrow',
      (tester) async {
    await tester.pumpWidget(wrapWithTestApp(buildScreen()));
    await tester.pumpAndSettle();

    expect(find.text('ORÇAMENTO SEMANAL'), findsOneWidget);
  });
}
