import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/app_shell.dart';
import 'package:monthly_management/onboarding/expense_tracker_tour.dart';
import 'package:monthly_management/screens/expense_tracker_screen.dart';
import 'package:monthly_management/widgets/expense/category_section.dart';
import 'package:monthly_management/widgets/expense/expense_alerts_card.dart';
import 'package:monthly_management/widgets/expense/expense_recent_card.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

// Re #1307 follow-up: the sliver Keys above make Flutter's OWN semantics
// tree correct (verified — `tester.getSemantics(find.byType(ExpenseAlertsCard))`
// already returns a fully-merged label starting with "Alerts\n...").  The
// gate that blocked this PR twice was reproducing against the real browser's
// accessibility DOM, not flutter_test's semantics tree, and there the
// difference between ExpenseAlertsCard and ExpenseRecentCard is real: Alertas
// has no interactive descendant, so Flutter's web renderer merges its whole
// subtree into plain nested DOM text with no `aria-label` on the group
// boundary, while Recentes (whose rows are wrapped in InkWell/onTap) gets an
// explicit `aria-label` on its group boundary. Both are technically
// ARIA-valid (accname falls back to subtree text), but relying on the
// implicit fallback for a non-interactive group is exactly the fragile case
// WAI-ARIA authoring practice warns against, and it is what the tester
// tooling failed to discover this card by. Giving the container an EXPLICIT
// label removes that reliance.

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

  testWidgets(
    'ExpenseAlertsCard exposes an explicit group label instead of relying on '
    'merged children (#1307)',
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

      final handle = tester.ensureSemantics();
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

      final alertsSemantics =
          tester.getSemantics(find.byType(ExpenseAlertsCard));

      // Before the fix this is the full merged blob ("Alerts\n1\nHousing\n
      // Budget 400,00 € · Spent 450,00 €\n+50,00 €") because nothing in the
      // subtree declares its own explicit label — the group's accessible
      // name is whatever falls out of merging every descendant Text. After
      // the fix the container declares its own short label directly, so it
      // no longer starts with the eyebrow followed immediately by merged row
      // detail.
      expect(
        alertsSemantics.label,
        'Alerts, 1',
        reason: 'ExpenseAlertsCard should expose an explicit, short group '
            'label (eyebrow + count) instead of an implicitly-merged blob of '
            'every row\'s text — the merged blob is what a real browser '
            'renders as bare nested text with no aria-label on the group, '
            'which is exactly the shape the QA tooling failed to discover.',
      );

      // Explicit label must not swallow the row into one opaque node: the
      // category row itself should still be individually reachable, the way
      // Recentes' individual transaction rows already are.
      final rowFinder = find.descendant(
        of: find.byType(ExpenseAlertsCard),
        matching: find.text('Housing'),
      );
      expect(rowFinder, findsOneWidget);
      final rowSemantics = tester.getSemantics(rowFinder);
      expect(rowSemantics.label, contains('Housing'));

      handle.dispose();
    },
  );

  testWidgets(
    'Recentes does not enter the semantics tree ahead of scroll when it '
    'sits just past the fold, so it never leaks onto the FAB/nav-bar band '
    '(#1307)',
    (tester) async {
      // Reproduces the QA critic's "phantom Recentes" finding empirically:
      // built the real branch as a QA web bundle, dumped the live
      // <flt-semantics> tree, and found a "Recentes" group node reported at
      // y=773..1021 — geometry that overlaps the FAB ("Registar despesa",
      // y=787..843), the chat launcher (y=796..844) and the bottom nav bar
      // (y=860..932) — while the screenshot at that same state shows nothing
      // painted there (blank, then FAB/chat/nav-bar). Root cause: Despesas'
      // CustomScrollView (lib/screens/expense_tracker_screen.dart) used
      // Flutter's default cacheExtent (250 logical px). ExpenseRecentCard is
      // wrapped in a (non-lazy) SliverToBoxAdapter, so its Element/RenderObject
      // is ALWAYS built regardless of scroll offset or cacheExtent — that part
      // was never the bug, and `find.byType`/`find.bySemanticsLabel` (which
      // both special-case "clipped past the viewport" as not-found, the same
      // way the #1202 test suite already documented) cannot see it either
      // way. What cacheExtent DOES control is whether the *sliver protocol*
      // includes that child's geometry in the semantics tree it hands to the
      // engine: with the default 250px cache window, a child starting just
      // past the fold — exactly where Recentes sits once five over-budget
      // categories stretch Alertas almost to the viewport's bottom edge — is
      // treated as "nearby enough to pre-announce", producing a real
      // SemanticsNode at its literal, unclipped page position. That is inert
      // on native platforms (TalkBack/VoiceOver scroll the list before
      // focusing an off-screen node), but Flutter web's DOM semantics mirror
      // places the node at those literal coordinates with no clip, so it
      // reads to an AT user — and to a plain mouse click at those
      // coordinates — as content sitting on top of the nav bar: a dead,
      // mis-described hit target. Proven directly against the raw
      // SemanticsNode tree below (`toStringDeep()`), the same data a11y
      // tooling (native or the QA critic's browser dump) actually reads —
      // `find.byType`/`find.bySemanticsLabel` were tried first and could not
      // tell the buggy and fixed states apart, since both filter out
      // scrolled-off content by construction.
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;

      final overBudgetCategories = [
        'alimentacao',
        'lazer',
        'energia',
        'saude',
        'outros',
      ];
      final settings = makeSettings(
        expenses: overBudgetCategories
            .map((c) => makeExpense(id: 'budget_$c', category: c, amount: 10))
            .toList(),
      );
      final actuals = overBudgetCategories
          .map((c) => makeActualExpense(
                id: 'ae_$c',
                category: c,
                amount: 200,
                description: 'Correios',
              ))
          .toList();

      final handle = tester.ensureSemantics();
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
            monthlyBudgets: {for (final c in overBudgetCategories) c: 10},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExpenseAlertsCard), findsOneWidget);
      final viewportRect =
          tester.getRect(find.byKey(ExpenseTrackerTourKeys.categoryList));
      final alertsBottom = tester.getBottomLeft(
        find.byType(ExpenseAlertsCard),
      ).dy;
      expect(
        alertsBottom,
        greaterThan(viewportRect.bottom - 250),
        reason: 'the fixture must put Alertas within one cache-extent '
            '(250px) of the viewport bottom, or this test would not '
            'exercise the reported off-by-cache-window geometry',
      );

      String semanticsDump() => tester.binding.renderViews.first.owner!
          .semanticsOwner!.rootSemanticsNode!
          .toStringDeep();

      // Not part of the pre-scroll fold: its row content must not appear in
      // the semantics tree at all yet. This is the exact signal a browser's
      // <flt-semantics> DOM mirror exports, and it is what a mouse click (or
      // a screen reader) would find sitting at those coordinates today.
      expect(
        semanticsDump(),
        isNot(contains('Correios')),
        reason: 'Recentes sits past the FAB-clearance-shrunk viewport and '
            "must not enter the semantics tree just because it's within a "
            "look-ahead cache window — Flutter web's DOM semantics mirror "
            'exposes any such node, unclipped, at coordinates overlapping '
            'the FAB/nav bar (#1307).',
      );

      // Scrolling it into view must still work — this is not about
      // disabling Recentes, only about not pre-announcing it before the
      // user scrolls there.
      await tester.drag(
        find.byKey(ExpenseTrackerTourKeys.categoryList),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(
        semanticsDump(),
        contains('Correios'),
        reason: 'Recentes must become reachable in the semantics tree once '
            'actually scrolled into view',
      );

      // Five over-budget categories at 430px width also hit the
      // pre-existing, unrelated RenderFlex overflow in
      // lib/widgets/expense/category_section.dart:81 (a CalmPill + Text Row
      // without Flexible/Expanded, already called out and deliberately not
      // asserted on by test/screens/expense_tracker_fab_overlap_1202_test.dart).
      // Only drained here so it doesn't leak into the next test.
      tester.takeException();

      handle.dispose();
    },
  );
}
