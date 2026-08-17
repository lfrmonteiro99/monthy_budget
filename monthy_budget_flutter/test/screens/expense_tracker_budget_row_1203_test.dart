import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/screens/expense_tracker_screen.dart';
import 'package:monthly_management/widgets/info_icon_button.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

void main() {
  // Reproduces the QA finding: at 360px viewport width, the budget summary
  // row's InfoIconButton was pushed off-screen by the fixed-width children
  // (pill + status text + budgeted-amount text) with no Flexible/Expanded to
  // absorb the compression. See lib/screens/expense_tracker_screen.dart:745.
  testWidgets(
    'InfoIconButton stays fully within screen bounds at 360px width (#1203)',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      // Mirrors the exact repro numbers from the issue: "-128,95 € Acima do
      // orçamento orç. 1 871,50 €".
      final settings = makeSettings(
        expenses: [
          makeExpense(id: 'exp_1', category: 'habitacao', amount: 1871.50),
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
        ),
      );
      await tester.pumpAndSettle();

      final infoIconFinder = find.byType(InfoIconButton);
      expect(infoIconFinder, findsOneWidget);

      final topLeft = tester.getTopLeft(infoIconFinder);
      final bottomRight = tester.getBottomRight(infoIconFinder);

      expect(topLeft.dx, greaterThanOrEqualTo(0));
      expect(bottomRight.dx, lessThanOrEqualTo(360));

      // The a11y tap target must stay at least 44x44.
      expect(bottomRight.dx - topLeft.dx, greaterThanOrEqualTo(44));
      expect(bottomRight.dy - topLeft.dy, greaterThanOrEqualTo(44));

      // The pill ("-128,95 €") must still be fully rendered (not the
      // budgeted-amount text, which is allowed to ellipsize).
      expect(find.textContaining('-128,95'), findsOneWidget);
    },
  );

  testWidgets(
    'InfoIconButton stays visible at 360px even with a longer budgeted amount (#1203)',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      // Keep the per-category remaining small (actual close to budgeted) so
      // only the summary row's totals are long — this isolates the case
      // under test from the unrelated category-row layout.
      final settings = makeSettings(
        expenses: [
          makeExpense(id: 'exp_1', category: 'habitacao', amount: 12871.50),
        ],
      );
      final actual = makeActualExpense(
        id: 'ae_1',
        category: 'habitacao',
        amount: 12871,
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
        ),
      );
      await tester.pumpAndSettle();

      final infoIconFinder = find.byType(InfoIconButton);
      expect(infoIconFinder, findsOneWidget);

      final topLeft = tester.getTopLeft(infoIconFinder);
      final bottomRight = tester.getBottomRight(infoIconFinder);

      expect(topLeft.dx, greaterThanOrEqualTo(0));
      expect(bottomRight.dx, lessThanOrEqualTo(360));
    },
  );

  testWidgets(
    'InfoIconButton stays fully visible at 430px width and budgeted text is unchanged (#1203)',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1.0;

      // Same fixture as the "longer budgeted amount" case above: keeps the
      // per-category remaining small so only this test's assertions (on the
      // summary row) are exercised, independent of the unrelated
      // category-row layout.
      final settings = makeSettings(
        expenses: [
          makeExpense(id: 'exp_1', category: 'habitacao', amount: 12871.50),
        ],
      );
      final actual = makeActualExpense(
        id: 'ae_1',
        category: 'habitacao',
        amount: 12871,
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
        ),
      );
      await tester.pumpAndSettle();

      final infoIconFinder = find.byType(InfoIconButton);
      expect(infoIconFinder, findsOneWidget);

      final topLeft = tester.getTopLeft(infoIconFinder);
      final bottomRight = tester.getBottomRight(infoIconFinder);

      expect(topLeft.dx, greaterThanOrEqualTo(0));
      expect(bottomRight.dx, lessThanOrEqualTo(430));

      // On the wider viewport there's enough room, so the budgeted-amount
      // text renders in full (no ellipsis needed). Match on the l10n
      // prefix + amount fragment rather than the exact separator glyph
      // (NumberFormat may use a non-breaking thousands separator).
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.data ?? '').startsWith('budget') &&
              (widget.data ?? '').contains('871,50'),
        ),
        findsOneWidget,
      );
    },
  );
}
