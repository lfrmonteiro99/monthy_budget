import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/screens/dashboard_screen.dart';
import 'package:monthly_management/screens/meal_wizard_screen.dart';
import 'package:monthly_management/screens/settings_screen.dart';

import '../helpers/test_app.dart';

void main() {
  // ── Issue #428: Dashboard should show full (detailed) layout by default ──

  group('Issue #428 – full dashboard as home', () {
    testWidgets('focusedMode defaults to false in DashboardScreen constructor',
        (tester) async {
      // Verify the DashboardScreen default value for focusedMode is false
      final screen = DashboardScreen(
        settings: const AppSettings(),
        summary: const BudgetSummary(),
        purchaseHistory: const PurchaseHistory(),
        dashboardConfig: const LocalDashboardConfig(),
        expenseHistory: const {},
        actualExpenses: const [],
        monthlyBudgets: const {},
        recurringExpenses: const [],
        actualExpenseHistory: const {},
        onOpenSettings: () {},
        onSaveSettings: (_) {},
        onSnapshotExpenses: () {},
        onAddExpense: () {},
        onOpenExpenseTracker: () {},
        // focusedMode intentionally not set — should default to false
      );
      expect(screen.focusedMode, isFalse);
    });
  });

  // ── Issue #429: Settings should have all sections collapsed ──

  group('Issue #429 – settings all collapsed', () {
    SettingsScreen buildSettings({String? initialSection}) {
      return SettingsScreen(
        settings: const AppSettings(),
        onSave: (_) {},
        favorites: const [],
        onSaveFavorites: (_) {},
        apiKey: '',
        onSaveApiKey: (_) {},
        isAdmin: true,
        householdId: 'hh_test',
        initialSection: initialSection,
      );
    }

    testWidgets('no section expanded by default (salary fields not visible)',
        (tester) async {
      await tester.pumpWidget(wrapWithTestApp(buildSettings()));
      await tester.pumpAndSettle();

      // When all sections are collapsed, salary helper text should NOT
      // be in the tree (it's inside the expanded body).
      expect(find.text('A name to identify this income source'), findsNothing);
    });

    testWidgets('initialSection opens that section', (tester) async {
      await tester.pumpWidget(
          wrapWithTestApp(buildSettings(initialSection: 'salaries')));
      await tester.pumpAndSettle();

      // With salaries section explicitly opened, the helper text should appear
      expect(find.text('A name to identify this income source'),
          findsWidgets);
    });
  });

  // ── Issue #430: Meal wizard should exit after completion ──

  group('Issue #430 – meal wizard exits after completion', () {
    testWidgets('wizard finish calls onComplete with wizardCompleted: true',
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

    testWidgets('MealPlannerScreen shows wizard when wizardCompleted is false',
        (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Builder(builder: (context) {
            // We can't easily pump MealPlannerScreen because it loads catalogs
            // from assets. Instead, test the condition directly.
            final settings = const AppSettings();
            expect(settings.mealSettings.wizardCompleted, isFalse);
            return const SizedBox();
          }),
        ),
      );
    });

    testWidgets('MealSettings.copyWith(wizardCompleted: true) works correctly',
        (tester) async {
      const original = MealSettings();
      expect(original.wizardCompleted, isFalse);

      final completed = original.copyWith(wizardCompleted: true);
      expect(completed.wizardCompleted, isTrue);
    });
  });
}
