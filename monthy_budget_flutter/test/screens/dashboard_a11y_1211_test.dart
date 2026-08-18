// Regression test for issue #1211: icon-only buttons without an accessible
// name. The notification bell IconButton on the Dashboard header wrapped a
// Tooltip *around* itself instead of passing `tooltip:` to the IconButton,
// so the accessible label lived on a non-focusable ancestor node instead of
// the actual `Semantics(button: true)` node that screen readers/keyboard
// navigation land on.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/screens/dashboard_screen.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget buildDashboard() {
    return wrapWithTestApp(
      DashboardScreen(
        settings: const AppSettings(),
        summary: const BudgetSummary(
          totalGross: 2000,
          totalNetWithMeal: 1800,
          totalExpenses: 900,
          netLiquidity: 900,
        ),
        purchaseHistory: const PurchaseHistory(),
        dashboardConfig: const LocalDashboardConfig(
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
        householdName: 'Casa Silva',
      ),
    );
  }

  group('#1211 dashboard notification bell accessible name', () {
    testWidgets(
      'the focusable Semantics(button:true) node of the bell IconButton '
      'carries the notificationSettings label (not a Tooltip ancestor)',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(buildDashboard());
        await tester.pumpAndSettle();

        final bellIconButtonFinder = find.ancestor(
          of: find.byIcon(Icons.notifications_outlined),
          matching: find.byType(IconButton),
        );
        expect(bellIconButtonFinder, findsOneWidget);

        // The IconButton's own SemanticsNode (the one screen readers/keyboard
        // navigation focus, flags: isButton/isFocusable) must carry the name
        // directly. Flutter exposes an IconButton's `tooltip:` via the
        // SemanticsData.tooltip field, which the web engine concatenates
        // into the DOM node's aria-label — but only when it lives on the
        // *same* SemanticsNode as the button flags. Wrapping a `Tooltip`
        // *around* the IconButton instead puts it on a separate, ancestor,
        // non-focusable SemanticsNode.
        final semantics = tester.getSemantics(bellIconButtonFinder);
        expect(
          semantics.flagsCollection.isButton,
          isTrue,
          reason: 'sanity check: the located node must be the focusable button',
        );
        expect(
          semantics.tooltip,
          'Notification Settings',
          reason:
              'The bell IconButton itself must expose the accessible name; '
              'a Tooltip wrapped around the IconButton puts the label on a '
              'non-focusable ancestor instead.',
        );

        handle.dispose();
      },
    );
  });
}
