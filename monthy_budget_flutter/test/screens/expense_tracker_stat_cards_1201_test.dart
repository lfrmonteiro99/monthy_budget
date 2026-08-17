import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/onboarding/expense_tracker_tour.dart';
import 'package:monthly_management/screens/expense_tracker_screen.dart';
import 'package:monthly_management/utils/formatters.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

void main() {
  // Reproduces the QA finding: the 'Este Mês' and 'Média/Dia' stat cards
  // truncated the amount with an ellipsis on narrow viewports because the
  // value Text used a fixed 22px style with maxLines: 1 +
  // TextOverflow.ellipsis inside an Expanded slice of a 3-card Row that
  // doesn't have room for long currency strings. See
  // lib/screens/expense_tracker_screen.dart:665-738.
  Future<void> pumpStatsRow(WidgetTester tester, Size size) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;

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
      ),
    );
    await tester.pumpAndSettle();
  }

  // Scoped to the summary Row (key: ExpenseTrackerTourKeys.summary) because
  // the same formatted amount can also appear in the category list below
  // (e.g. a single-category fixture shows the same total there at a smaller
  // font size) — without scoping, `find.text` matches more than one widget.
  Text findAmountText(WidgetTester tester, String expectedData) {
    final finder = find.descendant(
      of: find.byKey(ExpenseTrackerTourKeys.summary),
      matching: find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == expectedData,
      ),
    );
    expect(
      finder,
      findsOneWidget,
      reason:
          "expected the full value '$expectedData' to be rendered in the "
          'summary row (Text.data is never truncated by FittedBox/ellipsis, '
          "so this only fails if the wrong amount was formatted)",
    );
    return tester.widget<Text>(finder);
  }

  for (final size in [const Size(360, 640), const Size(430, 932)]) {
    testWidgets(
      "'Este Mês' and 'Média/Dia' stat cards render the full amount via "
      'FittedBox instead of ellipsis at ${size.width.toInt()}px (#1201)',
      (tester) async {
        await pumpStatsRow(tester, size);

        final expectedThisMonth = formatCurrency(2000.45);
        final now = DateTime.now();
        final elapsedDays = now.day.clamp(1, 31);
        final expectedAvg = formatCurrency(2000.45 / elapsedDays);

        final summaryText = find.descendant(
          of: find.byKey(ExpenseTrackerTourKeys.summary),
          matching: find.text(expectedThisMonth),
        );
        final thisMonthText = findAmountText(tester, expectedThisMonth);
        expect(thisMonthText.overflow, isNot(TextOverflow.ellipsis));
        expect(
          find.ancestor(of: summaryText, matching: find.byType(FittedBox)),
          findsOneWidget,
          reason: "'Este Mês' value must be wrapped in a FittedBox so it "
              'scales down instead of truncating',
        );

        final summaryAvgText = find.descendant(
          of: find.byKey(ExpenseTrackerTourKeys.summary),
          matching: find.text(expectedAvg),
        );
        final avgText = findAmountText(tester, expectedAvg);
        expect(avgText.overflow, isNot(TextOverflow.ellipsis));
        expect(
          find.ancestor(of: summaryAvgText, matching: find.byType(FittedBox)),
          findsOneWidget,
          reason: "'Média/Dia' value must be wrapped in a FittedBox so it "
              'scales down instead of truncating',
        );

        // 'Contas' (the 3rd card) is untouched: its count text stays a
        // plain Text, not wrapped in FittedBox.
        final billsCountFinder = find.descendant(
          of: find.byKey(ExpenseTrackerTourKeys.summary),
          matching: find.text('1'),
        );
        expect(billsCountFinder, findsOneWidget);
        expect(
          find.ancestor(
            of: billsCountFinder,
            matching: find.byType(FittedBox),
          ),
          findsNothing,
          reason: "the 'Contas' card must keep its current behavior — no "
              'FittedBox wrap',
        );

        // No RenderFlex overflow or other rendering exception.
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    "'Este Mês' value keeps the original 22px/w600 style on the tablet "
    'viewport, i.e. FittedBox does not shrink text that already fits (#1201)',
    (tester) async {
      await pumpStatsRow(tester, const Size(768, 1024));

      final expectedThisMonth = formatCurrency(2000.45);
      final thisMonthText = findAmountText(tester, expectedThisMonth);
      expect(thisMonthText.style?.fontSize, 22);
      expect(thisMonthText.style?.fontWeight, FontWeight.w600);
      expect(thisMonthText.overflow, isNot(TextOverflow.ellipsis));

      expect(tester.takeException(), isNull);
    },
  );
}
