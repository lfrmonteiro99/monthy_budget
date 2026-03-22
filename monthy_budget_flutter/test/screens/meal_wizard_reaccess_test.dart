import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/screens/meal_wizard_screen.dart';
import 'package:monthly_management/screens/settings_screen.dart';

import '../helpers/test_app.dart';

void main() {
  group('Issue #16 – meal wizard re-access', () {
    testWidgets(
        'Settings > Meals contains Advanced section with l10n strings',
        (tester) async {
      final screen = SettingsScreen(
        settings: const AppSettings(),
        onSave: (_) {},
        favorites: const [],
        onSaveFavorites: (_) {},
        apiKey: '',
        onSaveApiKey: (_) {},
        isAdmin: true,
        householdId: 'hh_test',
        initialSection: 'meals',
      );

      await tester.pumpWidget(wrapWithTestApp(screen));
      await tester.pumpAndSettle();

      // Advanced section title and subtitle are rendered via l10n
      expect(find.text('Advanced'), findsOneWidget);
      expect(find.text('Reset meal setup wizard'), findsOneWidget);
    });

    testWidgets(
        'MealWizardScreen renders when wizardCompleted is false',
        (tester) async {
      const settings = AppSettings();
      expect(settings.mealSettings.wizardCompleted, isFalse);

      final widget = MealWizardScreen(
        initial: settings.mealSettings,
        onComplete: (_) {},
      );

      await tester.pumpWidget(wrapWithTestApp(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MealWizardScreen), findsOneWidget);
    });

    testWidgets(
        'MealWizardScreen onComplete returns wizardCompleted: true',
        (tester) async {
      MealSettings? received;

      await tester.pumpWidget(
        wrapWithTestApp(
          MealWizardScreen(
            initial: const MealSettings(),
            onComplete: (ms) => received = ms,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate through all 5 steps
      for (var i = 0; i < 5; i++) {
        final buttons = find.byType(FilledButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.last);
          await tester.pumpAndSettle();
        }
      }

      expect(received, isNotNull);
      expect(received!.wizardCompleted, isTrue);
    });

    testWidgets(
        'wizardCompleted roundtrip: set true then reset to false',
        (tester) async {
      final completed = const MealSettings().copyWith(wizardCompleted: true);
      expect(completed.wizardCompleted, isTrue);

      final reset = completed.copyWith(wizardCompleted: false);
      expect(reset.wizardCompleted, isFalse);
    });
  });
}
