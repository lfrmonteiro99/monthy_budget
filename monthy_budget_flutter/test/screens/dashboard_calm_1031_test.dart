import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/screens/dashboard_screen.dart';
import 'package:monthly_management/widgets/calm/calm_card.dart';
import 'package:monthly_management/widgets/calm/calm_hero.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget buildDashboard({
    BudgetSummary summary = const BudgetSummary(
      totalGross: 2000,
      totalNetWithMeal: 1800,
      totalExpenses: 900,
      netLiquidity: 900,
    ),
    String householdName = 'Casa Silva',
    VoidCallback? onOpenSettings,
    VoidCallback? onSnapshotExpenses,
    LocalDashboardConfig dashboardConfig = const LocalDashboardConfig(
      showSummaryCards: false,
      showSalaryBreakdown: false,
      showBudgetVsActual: false,
      showPurchaseHistory: false,
      showCharts: false,
      showStressIndex: false,
      showMonthReview: false,
      showUpcomingBills: false,
      showTaxDeductions: false,
      showSavingsGoals: false,
      showExpensesBreakdown: false,
      showBudgetStreaks: false,
    ),
  }) {
    return wrapWithTestApp(
      DashboardScreen(
        settings: const AppSettings(),
        summary: summary,
        purchaseHistory: const PurchaseHistory(),
        dashboardConfig: dashboardConfig,
        expenseHistory: const {},
        actualExpenses: const [],
        monthlyBudgets: const {},
        recurringExpenses: const [],
        actualExpenseHistory: const {},
        onOpenSettings: onOpenSettings ?? () {},
        onSaveSettings: (_) {},
        onSnapshotExpenses: onSnapshotExpenses ?? () {},
        onAddExpense: () {},
        onOpenExpenseTracker: () {},
        householdName: householdName,
      ),
    );
  }

  group('#1031 dashboard Calm gaps', () {
    testWidgets('CalmHero renders at size 64', (tester) async {
      await tester.pumpWidget(buildDashboard());
      await tester.pumpAndSettle();

      final hero = tester.widget<CalmHero>(find.byType(CalmHero));
      expect(hero.size, 64);
    });

    testWidgets('RefreshIndicator wraps scroll view', (tester) async {
      await tester.pumpWidget(buildDashboard());
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('avatar shows initials from householdName, not gear icon', (tester) async {
      await tester.pumpWidget(buildDashboard(householdName: 'Casa Silva'));
      await tester.pumpAndSettle();

      // Gear icon is gone
      expect(find.byIcon(Icons.settings_outlined), findsNothing);
      // Initials text is present
      expect(find.text('CS'), findsOneWidget);
    });

    testWidgets('avatar single-word name uses first letter', (tester) async {
      await tester.pumpWidget(buildDashboard(householdName: 'Familia'));
      await tester.pumpAndSettle();

      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('avatar tapping calls onOpenSettings', (tester) async {
      var called = 0;
      await tester.pumpWidget(buildDashboard(onOpenSettings: () => called++));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Open settings'));
      await tester.pump();

      expect(called, 1);
    });

    testWidgets('avatar tap target is at least 44x44', (tester) async {
      await tester.pumpWidget(buildDashboard());
      await tester.pumpAndSettle();

      final size = tester.getSize(
        find.descendant(
          of: find.byTooltip('Open settings'),
          matching: find.byType(GestureDetector),
        ),
      );

      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('avatar tap outside the 36x36 circle still opens settings', (tester) async {
      var called = 0;
      await tester.pumpWidget(buildDashboard(onOpenSettings: () => called++));
      await tester.pumpAndSettle();

      final target = find.descendant(
        of: find.byTooltip('Open settings'),
        matching: find.byType(GestureDetector),
      );
      final topLeft = tester.getTopLeft(target);

      // 2px inset from the top-left corner: inside the 44x44 tap target,
      // outside the centered 36x36 visual circle (4px margin on each side).
      await tester.tapAt(topLeft + const Offset(2, 2));
      await tester.pump();

      expect(called, 1);
    });

    testWidgets('avatar circle keeps its 36x36 visual size', (tester) async {
      await tester.pumpWidget(buildDashboard());
      await tester.pumpAndSettle();

      final size = tester.getSize(
        find.ancestor(
          of: find.text('CS'),
          matching: find.byType(Container),
        ).first,
      );

      expect(size.width, 36);
      expect(size.height, 36);
    });

    testWidgets('hero section uses CalmCard structure', (tester) async {
      await tester.pumpWidget(buildDashboard());
      await tester.pumpAndSettle();

      // Hero card + empty-state candidates: CalmCard used in the screen body
      expect(find.byType(CalmCard), findsWidgets);
    });
  });
}
