import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/screens/settings_screen.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget buildMealSettings({MealSettings? mealSettings}) {
    final settings = AppSettings().copyWith(
      mealSettings: mealSettings ?? const MealSettings(wizardCompleted: true),
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

  group('Meal settings section titles are localized', () {
    testWidgets('shows localized section titles in cards', (tester) async {
      await tester.pumpWidget(buildMealSettings());
      await tester.pumpAndSettle();

      // Essential sections (always visible in cards)
      expect(find.text('Who eats?'), findsOneWidget);
      expect(find.text('Goals'), findsOneWidget);
      expect(find.text('Eating out'), findsOneWidget);
      expect(find.text('Dietary restrictions'), findsOneWidget);
      expect(find.text('Preparation'), findsOneWidget);
      expect(find.text('Strategies'), findsOneWidget);

      // Collapsed sections (in ExpansionTile -- titles still visible)
      expect(find.text('Protein variety'), findsOneWidget);
      expect(find.text('Nutrition & health'), findsOneWidget);
      expect(find.text('Pantry'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('shows subtitles for card sections', (tester) async {
      await tester.pumpWidget(buildMealSettings());
      await tester.pumpAndSettle();

      expect(find.text('Household and members'), findsOneWidget);
      expect(find.text('Planning and active meals'), findsOneWidget);
    });
  });

  group('Complexity uses SegmentedButton', () {
    testWidgets('weekday complexity shows segmented button with Easy/Medium/Pro',
        (tester) async {
      await tester.pumpWidget(buildMealSettings());
      await tester.pumpAndSettle();

      // Should find SegmentedButton widgets (2: weekday + weekend)
      expect(find.byType(SegmentedButton<int>), findsAtLeast(1));

      // The labels should be present
      expect(find.text('Easy'), findsAtLeast(1));
      expect(find.text('Medium'), findsAtLeast(1));
      expect(find.text('Pro'), findsAtLeast(1));
    });

    testWidgets('two SegmentedButtons for weekday and weekend complexity',
        (tester) async {
      await tester.pumpWidget(buildMealSettings());
      await tester.pumpAndSettle();

      final segmented = find.byType(SegmentedButton<int>);
      expect(segmented, findsNWidgets(2));
    });

    testWidgets('tapping Medium sets complexity to 3', (tester) async {
      await tester.pumpWidget(buildMealSettings(
        mealSettings: const MealSettings(
          wizardCompleted: true,
          maxComplexity: 1,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap first "Medium" (weekday complexity)
      final mediumButtons = find.text('Medium');
      expect(mediumButtons, findsAtLeast(1));
      await tester.ensureVisible(mediumButtons.first);
      await tester.tap(mediumButtons.first);
      await tester.pumpAndSettle();

      // Verify the SegmentedButton updated to selected=3
      final segBtns = tester.widgetList<SegmentedButton<int>>(
        find.byType(SegmentedButton<int>),
      );
      expect(segBtns.first.selected, contains(3));
    });
  });

  group('Card structure', () {
    testWidgets('meal sections are wrapped in Card widgets', (tester) async {
      await tester.pumpWidget(buildMealSettings());
      await tester.pumpAndSettle();

      // At least 10 cards (6 normal + 4 expansion)
      expect(find.byType(Card), findsAtLeast(10));
    });

    testWidgets('non-essential sections use ExpansionTile', (tester) async {
      await tester.pumpWidget(buildMealSettings());
      await tester.pumpAndSettle();

      // 4 expansion tiles: protein, nutrition, pantry, advanced
      expect(find.byType(ExpansionTile), findsAtLeast(4));
    });
  });

  group('_nearestComplexity mapping', () {
    testWidgets('complexity 2 maps to Easy segment', (tester) async {
      await tester.pumpWidget(buildMealSettings(
        mealSettings: const MealSettings(
          wizardCompleted: true,
          maxComplexity: 2,
        ),
      ));
      await tester.pumpAndSettle();

      final segBtns = tester.widgetList<SegmentedButton<int>>(
        find.byType(SegmentedButton<int>),
      );
      expect(segBtns.first.selected, contains(1));
    });

    testWidgets('complexity 4 maps to Medium segment', (tester) async {
      await tester.pumpWidget(buildMealSettings(
        mealSettings: const MealSettings(
          wizardCompleted: true,
          maxComplexity: 4,
        ),
      ));
      await tester.pumpAndSettle();

      final segBtns = tester.widgetList<SegmentedButton<int>>(
        find.byType(SegmentedButton<int>),
      );
      expect(segBtns.first.selected, contains(3));
    });
  });
}
