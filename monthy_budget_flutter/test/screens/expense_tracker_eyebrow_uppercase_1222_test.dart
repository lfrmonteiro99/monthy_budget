import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/app_shell.dart';
import 'package:monthly_management/screens/expense_tracker_screen.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

/// Reproduces #1222: every other CalmEyebrow in the app is rendered in
/// UPPERCASE via an explicit `.toUpperCase()` at the call site (see
/// dashboard_screen.dart), but the 5 CalmEyebrow call sites in
/// expense_tracker_screen.dart pass the l10n string as-is, so they render
/// in the title-case the ARB stores them in (e.g. 'Movimento' instead of
/// 'MOVIMENTO'). See lib/screens/expense_tracker_screen.dart:586,689,715,
/// 741,874.
void main() {
  Future<void> pumpScreen(WidgetTester tester, {Locale locale = const Locale('pt')}) async {
    final settings = makeSettings(
      expenses: [
        makeExpense(id: 'exp_1', category: 'habitacao', amount: 2500),
      ],
    );
    final actual = makeActualExpense(
      id: 'ae_1',
      category: 'habitacao',
      amount: 2000.45,
    );

    await tester.pumpWidget(
      wrapWithTestApp(
        ExpenseTrackerScreen(
          settings: settings,
          expenses: [actual],
          householdId: 'house-1',
          onAdd: (_) async {},
          onUpdate: (_) async {},
          onDelete: (_) async {},
          onLoadMonth: (_) async => [actual],
        ),
        controller: AppShellController(locale: locale),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'all 5 CalmEyebrow labels in the Despesas screen render in UPPERCASE (pt) (#1222)',
    (tester) async {
      await pumpScreen(tester);

      expect(
        find.text('MOVIMENTO'),
        findsOneWidget,
        reason: "header eyebrow must read 'MOVIMENTO', matching the "
            "uppercase pattern of every other screen's eyebrow",
      );
      expect(find.text('Movimento'), findsNothing);

      expect(find.text('ESTE MÊS'), findsOneWidget);
      expect(find.text('Este Mês'), findsNothing);

      expect(find.text('MÉDIA/DIA'), findsOneWidget);
      expect(find.text('Média/Dia'), findsNothing);

      expect(find.text('CONTAS'), findsOneWidget);
      expect(find.text('Contas'), findsNothing);

      expect(find.text('POR CATEGORIA'), findsOneWidget);
      expect(find.text('Por Categoria'), findsNothing);

      // The big Fraunces title stays title-case — only the eyebrow changes.
      expect(find.text('Despesas'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'CalmEyebrow labels in the Despesas screen render in UPPERCASE (en) (#1222)',
    (tester) async {
      await pumpScreen(tester, locale: const Locale('en'));

      expect(find.text('ACTIVITY'), findsOneWidget);
      expect(find.text('Activity'), findsNothing);

      expect(find.text('THIS MONTH'), findsOneWidget);
      expect(find.text('AVG/DAY'), findsOneWidget);
      expect(find.text('BILLS'), findsOneWidget);
      expect(find.text('BY CATEGORY'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );
}
