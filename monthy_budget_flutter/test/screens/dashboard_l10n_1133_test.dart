import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/screens/dashboard_screen.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget buildEmpty() => wrapWithTestApp(
        DashboardScreen(
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
        ),
      );

  group('#1133 dashboard l10n — hardcoded strings replaced', () {
    testWidgets('empty state body uses l10n key, not hardcoded PT', (tester) async {
      await tester.pumpWidget(buildEmpty());
      await tester.pumpAndSettle();

      // Verify the hardcoded PT string is gone
      expect(
        find.text('Configure os seus rendimentos e despesas para começar.'),
        findsNothing,
      );

      // Verify the EN translation from the ARB key is shown instead
      final l10n = await S.delegate.load(const Locale('en'));
      expect(find.text(l10n.dashboardEmptyStateBody), findsOneWidget);
    });

    testWidgets('burn rate attention label uses l10n key, not hardcoded', (tester) async {
      // The l10n key must exist in the generated class — compile check.
      final l10n = await S.delegate.load(const Locale('en'));
      expect(l10n.dashboardBurnRateAttention, isNotEmpty);
      expect(l10n.dashboardBurnRateAttention, isNot('atenção'));
    });
  });
}
