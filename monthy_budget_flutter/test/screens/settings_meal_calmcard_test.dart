import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/screens/settings_screen.dart';
import 'package:monthly_management/widgets/calm/calm_card.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget buildMealSettings() {
    final settings = AppSettings().copyWith(
      mealSettings: const MealSettings(wizardCompleted: true),
    );
    return wrapWithTestApp(
      SettingsScreen(
        settings: settings,
        onSave: (_) {},
        favorites: const [],
        onSaveFavorites: (_) {},
        apiKey: '',
        onSaveApiKey: (_) {},
        isAdmin: false,
        householdId: 'hh_1',
        initialSection: 'meals',
        loadAssociatedMembers: (_) async => const [],
      ),
    );
  }

  group('#1072 meal cards use CalmCard', () {
    testWidgets('meals section renders CalmCard widgets', (tester) async {
      await tester.pumpWidget(buildMealSettings());
      await tester.pumpAndSettle();

      // _mealCard and _mealExpansionCard now wrap in CalmCard.
      // 6 static cards + 4 expansion cards = at least 4 visible CalmCards.
      expect(find.byType(CalmCard), findsAtLeastNWidgets(4));
    });
  });
}
