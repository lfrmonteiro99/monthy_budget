import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';
import 'package:monthly_management/screens/dashboard_screen.dart';
import 'package:monthly_management/widgets/calm/calm_list_tile.dart';
import 'package:monthly_management/widgets/calm/calm_pill.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

void main() {
  // Reproduces the QA finding (#1202): on the 'Início' tab, the FAB '+'
  // floated over TOP CATEGORIAS rows and the VELOCIDADE DE GASTO pace
  // badge with NO scroll, on small/phone viewports. Root cause: the FAB
  // is injected by the parent Scaffold in lib/app_home.dart, outside
  // DashboardScreen's own reach — its SingleChildScrollView never
  // reserved that footprint. This harness mirrors app_home.dart's actual
  // structure (Scaffold + floatingActionButton wrapping the screen's
  // Expanded content) so the test exercises the real integration, not
  // just DashboardScreen in isolation.
  //
  // Fix: lib/screens/dashboard_screen.dart wraps the SingleChildScrollView
  // (inside RefreshIndicator) in a Padding(bottom:
  // CalmScaffold.fabBottomClearance).
  //
  // The regression check compares the scrollable viewport's OWN box
  // against the FAB's box rather than individual card/row rects: a row
  // that straddles the viewport's bottom edge is still laid out (and
  // therefore still has a geometric Rect) below that edge even though the
  // viewport clips it from view — asserting on the viewport's box is what
  // the fix actually guarantees and avoids false positives from that
  // clipped, invisible tail.
  Future<void> pumpDashboardWithFab(WidgetTester tester, Size size) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;

    final settings = makeSettings();
    final summary = makeBudgetSummary(
      totalGross: 2200,
      totalNet: 1900,
      totalNetWithMeal: 2000,
      totalExpenses: 1500,
      netLiquidity: 500,
    );
    final actualExpenses = [
      makeActualExpense(id: 'ae_1', category: 'alimentacao', amount: 400),
      makeActualExpense(id: 'ae_2', category: 'transporte', amount: 350),
      makeActualExpense(id: 'ae_3', category: 'lazer', amount: 300),
      makeActualExpense(id: 'ae_4', category: 'saude', amount: 250),
      makeActualExpense(id: 'ae_5', category: 'educacao', amount: 200),
    ];

    const dashboardConfig = LocalDashboardConfig(
      showHeroCard: false,
      showStressIndex: false,
      showMonthReview: false,
      showSummaryCards: false,
      showUpcomingBills: false,
      showBudgetVsActual: false,
      showCashFlowForecast: false,
      showBurnRate: true,
      showTopCategories: true,
      showSavingsRate: false,
      showCoachInsight: false,
      showQuickActions: false,
      showSpendingAnomalies: false,
      cardOrder: ['heroCard', 'burnRate', 'topCategories'],
    );

    // Mirrors lib/app_home.dart:2337-2354 — the FAB is a sibling of the
    // screen's Expanded content inside a plain Scaffold, not something
    // DashboardScreen controls itself.
    await tester.pumpWidget(
      wrapWithTestApp(
        Scaffold(
          body: Column(
            children: [
              Expanded(
                child: DashboardScreen(
                  settings: settings,
                  summary: summary,
                  purchaseHistory: makePurchaseHistory(),
                  onOpenSettings: () {},
                  onSaveSettings: (_) {},
                  dashboardConfig: dashboardConfig,
                  expenseHistory: const {},
                  onSnapshotExpenses: () {},
                  actualExpenses: actualExpenses,
                  onAddExpense: () {},
                  onOpenExpenseTracker: () {},
                ),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FloatingActionButton(
              key: const Key('test_fab'),
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final size in [const Size(360, 640), const Size(430, 932)]) {
    testWidgets(
      'FAB does not overlap the dashboard scroll viewport, and TOP '
      'CATEGORIAS + the burn-rate pace badge are visible without scroll, '
      'at ${size.width.toInt()}px (#1202)',
      (tester) async {
        await pumpDashboardWithFab(tester, size);

        final fabRect = tester.getRect(find.byKey(const Key('test_fab')));
        final viewportFinder = find.byType(SingleChildScrollView);
        expect(viewportFinder, findsOneWidget);
        final viewportRect = tester.getRect(viewportFinder);

        expect(
          viewportRect.overlaps(fabRect),
          isFalse,
          reason: 'the dashboard scroll viewport must stop above the FAB '
              'so nothing painted inside it can render underneath the '
              'button (#1202); viewport=$viewportRect fab=$fabRect',
        );

        // burnRate is the first card, topCategories the second — both
        // must start within the visible (pre-scroll) viewport, matching
        // the bug report (both the pace badge and the category rows were
        // covered before any scroll).
        final pillFinder = find.byType(CalmPill);
        expect(pillFinder, findsOneWidget);
        expect(
          tester.getTopLeft(pillFinder).dy,
          lessThan(viewportRect.bottom),
          reason: "the burn-rate 'Acima do ritmo'/'A bom ritmo' badge must "
              'be part of the pre-scroll fold, or this test would not '
              'exercise the reported bug',
        );

        // Only the FIRST row is required to be part of the pre-scroll fold
        // — with 5 categories the list legitimately extends below it, and
        // rows below the fold simply require scrolling (not a bug; the
        // bug was specifically about the fold itself, e.g. 'Educação').
        final rowFinder = find.byType(CalmListTile);
        expect(
          rowFinder.evaluate().length,
          greaterThan(0),
          reason: 'fixture must produce TOP CATEGORIAS rows',
        );
        expect(
          tester.getTopLeft(rowFinder.first).dy,
          lessThan(viewportRect.bottom),
          reason: 'the first TOP CATEGORIAS row must start within the '
              'pre-scroll fold, or this test would not exercise the '
              'reported bug',
        );

        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'pull-to-refresh still works on the Início tab after the FAB clearance '
    'fix (#1202)',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      var refreshed = false;
      final settings = makeSettings();
      // hasData == false (totalGross <= 0) renders the empty state instead
      // showHeroCard: false avoids a pre-existing overflow in the hero
      // Row at narrow widths (unrelated to #1202, out of scope for this
      // fix); burnRate + topCategories give enough content to actually
      // overflow the viewport so the drag gesture has something to
      // scroll against.
      final summary = makeBudgetSummary(totalGross: 2200);
      final actualExpenses = [
        makeActualExpense(id: 'ae_1', category: 'alimentacao', amount: 400),
        makeActualExpense(id: 'ae_2', category: 'transporte', amount: 350),
        makeActualExpense(id: 'ae_3', category: 'lazer', amount: 300),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          DashboardScreen(
            settings: settings,
            summary: summary,
            purchaseHistory: makePurchaseHistory(),
            onOpenSettings: () {},
            onSaveSettings: (_) {},
            dashboardConfig: const LocalDashboardConfig(
              showHeroCard: false,
              cardOrder: ['heroCard', 'burnRate', 'topCategories'],
            ),
            expenseHistory: const {},
            onSnapshotExpenses: () => refreshed = true,
            actualExpenses: actualExpenses,
            onAddExpense: () {},
            onOpenExpenseTracker: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(refreshed, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
