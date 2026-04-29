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
    // Single pump — the static structure (page header, tiles) renders on
    // the first frame. Avoid pumpAndSettle: the hero card initially shows a
    // CircularProgressIndicator while MealPlannerService.loadCatalog()
    // resolves, which never settles in widget-test envs without platform
    // channels (assets, SharedPreferences) wired up.
    await tester.pump();

    expect(find.text('Plano & compras'), findsOneWidget);
    expect(find.text('Lista'), findsOneWidget);
    expect(find.text('Ementa'), findsOneWidget);
    expect(find.text('Despensa'), findsOneWidget);
  });
}
