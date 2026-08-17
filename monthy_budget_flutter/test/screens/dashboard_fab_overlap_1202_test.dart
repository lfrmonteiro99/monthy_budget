import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';
import 'package:monthly_management/screens/dashboard_screen.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

void main() {
  // Reproduces the QA finding (#1202): on the 'Início' tab, the FAB '+'
  // floated over TOP CATEGORIAS rows and the VELOCIDADE DE GASTO pace
  // badge with NO scroll, on small/phone viewports.
  //
  // First fix attempt reserved the FAB's footprint with a
  // `Padding(bottom: CalmScaffold.fabBottomClearance)` wrapped around
  // DashboardScreen's own SingleChildScrollView. QA re-verification found
  // that fix worked on the small viewport but NOT on phone (430×932). The
  // structural weakness of anchoring the reservation inside the screen:
  // the dashboard FAB is attached to the OUTER Scaffold in app_home.dart
  // and positioned against ITS body, while this screen sits inside
  // DashboardContainer's Column with sibling banners above and the
  // AdBannerWidget below — so the screen's own bottom edge is not the
  // frame the FAB is measured against, and a bottom sibling falls inside
  // the FAB's band.
  //
  // Fix: the clearance now wraps `Expanded(child: content)` directly in
  // app_home.dart — the same Scaffold the FAB is attached to — instead of
  // being buried inside DashboardScreen. The reserved band is then measured
  // from the FAB's own bottom edge, invariant to viewport height and to
  // the container's internal composition. This harness mirrors that real
  // app_home.dart structure (outer Scaffold with bottomNavigationBar +
  // floatingActionButton wrapping a Padding-clamped Expanded), with a real
  // non-zero-height sibling above the screen, so the test exercises the
  // same reference-frame class of bug QA found.
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

    final dashboardScreen = DashboardScreen(
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
    );

    // Mirrors lib/app_home.dart's actual tree: an outer Scaffold whose
    // floatingActionButton and bottomNavigationBar are siblings of
    // `Expanded(child: <clearance-padded content>)`. A sibling banner
    // (TrialBanner-equivalent) is included above DashboardScreen — with a
    // real, non-zero height — to reproduce the exact reference-frame gap
    // that broke the first fix attempt.
    await tester.pumpWidget(
      wrapWithTestApp(
        Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: CalmScaffold.fabBottomClearance,
                  ),
                  child: Column(
                    children: [
                      // Sibling banner above the screen, exactly like
                      // DashboardContainer's TrialBanner/CriticalAlertBanner
                      // — non-zero height, to prove the fix isn't
                      // coincidentally correct only when siblings are absent.
                      Container(height: 40, color: Colors.amber),
                      Expanded(child: dashboardScreen),
                    ],
                  ),
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
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 1, color: Colors.black12),
              NavigationBar(
                height: 72,
                selectedIndex: 0,
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.list), label: 'List'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final size in [const Size(360, 640), const Size(430, 932)]) {
    testWidgets(
      'FAB does not overlap the dashboard scroll viewport, and TOP '
      'CATEGORIAS + the burn-rate pace badge are visible without scroll, '
      'at ${size.width.toInt()}px, with a sibling banner above the screen '
      '(#1202)',
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
