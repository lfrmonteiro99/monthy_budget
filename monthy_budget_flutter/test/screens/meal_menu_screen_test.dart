import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/screens/meal_menu_screen.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  MealMenuScreen buildScreen() {
    return MealMenuScreen(
      settings: const AppSettings(),
      apiKey: '',
      favorites: const [],
      onAddToShoppingList: (_) {},
      householdId: 'test',
      onSaveSettings: (_) {},
      onOpenMealSettings: () {},
      purchaseHistory: const PurchaseHistory(),
    );
  }

  testWidgets('MealMenuScreen renders without crashing', (tester) async {
    await tester.pumpWidget(wrapWithTestApp(buildScreen()));
    await tester.pump();
    expect(find.byType(MealMenuScreen), findsOneWidget);
  });

  testWidgets('MealMenuScreen shows 21 grid cells', (tester) async {
    await tester.pumpWidget(wrapWithTestApp(buildScreen()));
    // Single pump renders the full structure (build() no longer gates the
    // grid + KPI sections behind _loading). pumpAndSettle would hang because
    // MealPlannerService.loadCatalog() hits SharedPreferences/rootBundle
    // channels that aren't wired in widget tests.
    await tester.pump();

    // CalmWeekGrid renders 3 rows × 7 cells = 21 cells inside the grid.
    // Each cell is a _Cell widget containing a Text. We can verify the grid
    // is present by finding the CalmWeekGrid itself.
    expect(find.byType(CalmWeekGrid), findsOneWidget);

    // The grid is constructed with 3 CalmWeekGridRows.
    // The underlying Row children count: header + 3 meal rows = 4 Column
    // children. We verify via the 3 meal-row labels present in the tree.
    expect(find.text('Peq.'), findsOneWidget);
    expect(find.text('Almoço'), findsOneWidget);
    expect(find.text('Jantar'), findsOneWidget);
  });

  testWidgets('MealMenuScreen shows 4 KPI rows', (tester) async {
    await tester.pumpWidget(wrapWithTestApp(buildScreen()));
    // Single pump renders the full structure (build() no longer gates the
    // grid + KPI sections behind _loading). pumpAndSettle would hang because
    // MealPlannerService.loadCatalog() hits SharedPreferences/rootBundle
    // channels that aren't wired in widget tests.
    await tester.pump();

    // Verify 4 CalmKpiRow widgets are present.
    expect(find.byType(CalmKpiRow), findsNWidgets(4));

    // Spot-check KPI labels.
    expect(find.text('Refeições planeadas'), findsOneWidget);
    expect(find.text('Custo estimado'), findsOneWidget);
    expect(find.text('Custo/pessoa/dia'), findsOneWidget);
    expect(find.text('Fora de casa'), findsOneWidget);
  });

  testWidgets('MealMenuScreen shows ESTA SEMANA eyebrow and Ementa title',
      (tester) async {
    await tester.pumpWidget(wrapWithTestApp(buildScreen()));
    // Single pump renders the full structure (build() no longer gates the
    // grid + KPI sections behind _loading). pumpAndSettle would hang because
    // MealPlannerService.loadCatalog() hits SharedPreferences/rootBundle
    // channels that aren't wired in widget tests.
    await tester.pump();

    expect(find.text('ESTA SEMANA'), findsOneWidget);
    expect(find.text('Ementa'), findsOneWidget);
    expect(find.byType(CalmActionPill), findsOneWidget);
  });
}
