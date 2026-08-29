import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/app_shell.dart';
import 'package:monthly_management/screens/expense_tracker_screen.dart';
import 'package:monthly_management/widgets/expense/category_section.dart';
import 'package:monthly_management/widgets/expense/expense_alerts_card.dart';
import 'package:monthly_management/widgets/expense/expense_recent_card.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

// Reproduces the QA finding (#1307): in the CustomScrollView built by
// ExpenseTrackerScreen, the conditional "Alertas" / "Recentes" / "Por
// categoria" slivers carry no Key. When `monthlyBudgets` arrives later than
// `expenses` (a separate async source, see #1220) and pushes a category over
// budget, the Alertas card is inserted at slot 0 in the very next frame,
// shifting every sibling down by one slot. Without a Key, Flutter's
// positional reconciliation cannot tell "Recentes"/"Por categoria" are the
// same logical items that merely moved down a slot: it tears down their
// Elements/RenderObjects/SemanticsNodes and rebuilds them from scratch
// instead of reusing them (verified empirically below via Element identity —
// `find.byType(..., skipOffstage: false)` is used throughout because with
// only one budget category the "Por categoria" section sits just below the
// visible viewport in the default 800x600 test surface, so the default
// `skipOffstage: true` would hide it from the finder even though it's very
// much alive). That teardown/rebuild churn on every unrelated frame is
// exactly the instability that lets the real browser's accessibility tree
// drift out of sync with what's painted (the QA critic's phantom "Recentes"
// node overlapping the nav bar).
void main() {
  testWidgets(
    'Recentes and Por categoria keep their Element identity when Alertas is inserted above them (#1307)',
    (tester) async {
      final settings = makeSettings(
        expenses: [
          makeExpense(id: 'exp_1', category: 'habitacao', amount: 500),
        ],
      );
      final actual = makeActualExpense(
        id: 'ae_1',
        category: 'habitacao',
        amount: 450,
      );
      final controller = AppShellController(locale: const Locale('en'));

      Widget buildScreen(Map<String, double> monthlyBudgets) {
        return wrapWithTestApp(
          ExpenseTrackerScreen(
            settings: settings,
            expenses: [actual],
            householdId: 'house-1',
            onAdd: (_) async {},
            onUpdate: (_) async {},
            onDelete: (_) async {},
            onLoadMonth: (_) async => [actual],
            monthlyBudgets: monthlyBudgets,
          ),
          controller: controller,
        );
      }

      // Frame N: monthlyBudgets hasn't arrived with an over-budget category
      // yet -> no Alertas card, Recentes is painted first.
      await tester.pumpWidget(buildScreen(const {}));
      await tester.pumpAndSettle();
      expect(find.byType(ExpenseAlertsCard), findsNothing);
      expect(find.byType(ExpenseRecentCard, skipOffstage: false), findsOneWidget);
      expect(find.byType(CategorySection, skipOffstage: false), findsOneWidget);

      final recentElementBefore = tester.element(
        find.byType(ExpenseRecentCard, skipOffstage: false),
      );
      final categoryElementBefore = tester.element(
        find.byType(CategorySection, skipOffstage: false).first,
      );

      // Frame N+1: monthlyBudgets arrives and habitacao is now over budget ->
      // Alertas is inserted at the top, Recentes and Por categoria shift down.
      await tester.pumpWidget(buildScreen(const {'habitacao': 400}));
      await tester.pumpAndSettle();
      expect(find.byType(ExpenseAlertsCard), findsOneWidget);
      expect(find.byType(ExpenseRecentCard, skipOffstage: false), findsOneWidget);
      expect(find.byType(CategorySection, skipOffstage: false), findsOneWidget);

      final recentElementAfter = tester.element(
        find.byType(ExpenseRecentCard, skipOffstage: false),
      );
      final categoryElementAfter = tester.element(
        find.byType(CategorySection, skipOffstage: false).first,
      );

      // Neither card logically changed — only their slot in the list shifted
      // because Alertas was inserted above them. A correctly keyed list
      // preserves their Element (and therefore RenderObject/SemanticsNode)
      // across the shift instead of tearing them down and rebuilding.
      expect(
        identical(recentElementBefore, recentElementAfter),
        isTrue,
        reason: 'ExpenseRecentCard should keep the same Element across the '
            'Alertas insertion; without a stable Key, Flutter rebuilds it '
            'from scratch because it now sits at a different slot index.',
      );
      expect(
        identical(categoryElementBefore, categoryElementAfter),
        isTrue,
        reason: 'The "Por categoria" section should keep the same Element '
            'across the Alertas insertion; without a stable Key, its sliver '
            'moved to a new slot index and got rebuilt from scratch.',
      );
    },
  );

  testWidgets(
    'visual order stays Alertas -> Recentes -> Por categoria (#1307)',
    (tester) async {
      final settings = makeSettings(
        expenses: [
          makeExpense(id: 'exp_1', category: 'habitacao', amount: 500),
        ],
      );
      final actual = makeActualExpense(
        id: 'ae_1',
        category: 'habitacao',
        amount: 450,
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
            monthlyBudgets: const {'habitacao': 400},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final alertsY = tester.getTopLeft(find.byType(ExpenseAlertsCard)).dy;
      final recentY = tester
          .getTopLeft(find.byType(ExpenseRecentCard, skipOffstage: false))
          .dy;
      final categoryY = tester
          .getTopLeft(find.byType(CategorySection, skipOffstage: false).first)
          .dy;

      expect(alertsY, lessThan(recentY));
      expect(recentY, lessThan(categoryY));
    },
  );

  testWidgets(
    'Recentes still exposes working transaction taps when Alertas is present (#1307)',
    (tester) async {
      final settings = makeSettings(
        expenses: [
          makeExpense(id: 'exp_1', category: 'habitacao', amount: 500),
        ],
      );
      final actual = makeActualExpense(
        id: 'ae_1',
        category: 'habitacao',
        amount: 450,
        description: 'Correios',
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
            monthlyBudgets: const {'habitacao': 400},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExpenseAlertsCard), findsOneWidget);
      await tester.tap(find.text('Correios').first);
      await tester.pumpAndSettle();

      // Detail sheet opens for the tapped expense — 'Correios' now shows in
      // the modal too, proving the tap reached the real onTap handler and
      // not a dead spot left over from a stale accessibility/hit-test node.
      expect(find.text('Correios'), findsWidgets);
    },
  );

  testWidgets(
    'Alertas absent: Recentes keeps exposing its 3 transaction rows (#1307)',
    (tester) async {
      final settings = makeSettings(
        expenses: [
          makeExpense(id: 'exp_1', category: 'habitacao', amount: 5000),
        ],
      );
      final actuals = [
        makeActualExpense(
            id: 'ae_1', category: 'habitacao', amount: 50, description: 'A'),
        makeActualExpense(
            id: 'ae_2', category: 'habitacao', amount: 60, description: 'B'),
        makeActualExpense(
            id: 'ae_3', category: 'habitacao', amount: 70, description: 'C'),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          ExpenseTrackerScreen(
            settings: settings,
            expenses: actuals,
            householdId: 'house-1',
            onAdd: (_) async {},
            onUpdate: (_) async {},
            onDelete: (_) async {},
            onLoadMonth: (_) async => actuals,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExpenseAlertsCard), findsNothing);
      expect(find.byType(ExpenseRecentCard), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ExpenseRecentCard),
          matching: find.text('A'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ExpenseRecentCard),
          matching: find.text('B'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ExpenseRecentCard),
          matching: find.text('C'),
        ),
        findsOneWidget,
      );
    },
  );
}
