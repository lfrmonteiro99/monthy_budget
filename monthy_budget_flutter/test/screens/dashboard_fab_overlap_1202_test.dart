import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/constants/app_constants.dart';
import 'package:monthly_management/containers/dashboard_container.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';
import 'package:monthly_management/models/onboarding_state.dart';
import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/providers/app_state_providers.dart';
import 'package:monthly_management/providers/budget_config_providers.dart';
import 'package:monthly_management/providers/expense_providers.dart';
import 'package:monthly_management/providers/settings_providers.dart';
import 'package:monthly_management/providers/subscription_providers.dart';
import 'package:monthly_management/screens/dashboard_screen.dart';
import 'package:monthly_management/services/data_health_service.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import 'package:monthly_management/widgets/quick_add_launcher.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

// ─── Fixed-value notifier overrides ─────────────────────────────────────────
// Each provider [DashboardContainer] watches is overridden with a subclass that
// returns the fixture value from `build()` — the standard Riverpod way to seed
// NotifierProviders deterministically before the tree builds.

class _FixedSettingsNotifier extends SettingsNotifier {
  _FixedSettingsNotifier(this.value);
  final AppSettings value;
  @override
  AppSettings build() => value;
}

class _FixedActualExpensesNotifier extends ActualExpensesNotifier {
  _FixedActualExpensesNotifier(this.value);
  final List<ActualExpense> value;
  @override
  List<ActualExpense> build() => value;
}

class _FixedMonthlyBudgetsNotifier extends MonthlyBudgetsNotifier {
  _FixedMonthlyBudgetsNotifier(this.value);
  final Map<String, double> value;
  @override
  Map<String, double> build() => value;
}

class _FixedDashboardConfigNotifier extends DashboardConfigNotifier {
  _FixedDashboardConfigNotifier(this.value);
  final LocalDashboardConfig value;
  @override
  LocalDashboardConfig build() => value;
}

class _FixedSubscriptionNotifier extends SubscriptionNotifier {
  _FixedSubscriptionNotifier(this.value);
  final SubscriptionState value;
  @override
  SubscriptionState build() => value;
}

class _FixedOnboardingNotifier extends OnboardingNotifier {
  _FixedOnboardingNotifier(this.value);
  final OnboardingState value;
  @override
  OnboardingState build() => value;
}

/// Deterministic, non-empty dashboard data — several summary cards plus a
/// 5-row TOP CATEGORIAS card with an over-budget '+X €' row, mirroring the QA
/// fixture that reproduced #1202.
List<Override> _dashboardOverrides() {
  final settings = makeSettings(
    salaries: [makeSalary(grossAmount: 2200)],
    expenses: [
      makeExpense(id: 'exp_1', label: 'Housing', amount: 800, category: 'habitacao'),
      makeExpense(id: 'exp_2', label: 'Food', amount: 300, category: 'alimentacao'),
      makeExpense(id: 'exp_3', label: 'Transport', amount: 150, category: 'transporte'),
      makeExpense(id: 'exp_4', label: 'Leisure', amount: 100, category: 'lazer'),
      makeExpense(id: 'exp_5', label: 'Health', amount: 80, category: 'saude'),
      makeExpense(id: 'exp_6', label: 'Education', amount: 60, category: 'educacao'),
    ],
  );
  final actualExpenses = [
    makeActualExpense(id: 'ae_1', category: 'alimentacao', amount: 400),
    makeActualExpense(id: 'ae_2', category: 'transporte', amount: 350),
    makeActualExpense(id: 'ae_3', category: 'lazer', amount: 300),
    makeActualExpense(id: 'ae_4', category: 'saude', amount: 250),
    makeActualExpense(id: 'ae_5', category: 'educacao', amount: 200),
  ];
  const monthlyBudgets = <String, double>{
    'habitacao': 800,
    'alimentacao': 300,
    'transporte': 150,
    'lazer': 100,
    'saude': 80,
    'educacao': 240,
  };
  // Note: showBudgetVsActual stays OFF — its category rows have a
  // pre-existing width-sensitive overflow at narrow widths
  // (dashboard_screen.dart:1437, unrelated to #1202).
  final dashboardConfig = LocalDashboardConfig(
    showHeroCard: false, // pre-existing hero Row overflow at narrow widths, unrelated to #1202
    showStressIndex: false,
    showMonthReview: false,
    showSummaryCards: true,
    showUpcomingBills: false,
    showBudgetVsActual: false,
    showCashFlowForecast: true,
    showBurnRate: true,
    showTopCategories: true,
    showSavingsRate: true,
    showCoachInsight: false,
    showQuickActions: false,
    showSpendingAnomalies: false,
    showSavingsGoals: false,
    showPurchaseHistory: false,
    showExpensesBreakdown: false,
    showCharts: false,
    showSalaryBreakdown: false,
    showBudgetStreaks: false,
    showTaxDeductions: false,
    // burnRate + topCategories first so the pace badge and the first
    // category row are inside the pre-scroll fold on BOTH viewports (the
    // QA report's covered elements); the taller cards after them guarantee
    // the fixture reaches the FAB band on phone without the fix, so the
    // test is not vacuous there.
    cardOrder: const [
      'heroCard', 'burnRate', 'topCategories', 'summaryCards',
      'savingsRate', 'cashFlowForecast',
    ],
  );
  final subscription =
      SubscriptionState(trialStartDate: AppConstants.farPastDate);
  const onboarding = OnboardingState(toursCompleted: {'dashboard': true});

  return [
    settingsProvider.overrideWith(() => _FixedSettingsNotifier(settings)),
    actualExpensesProvider
        .overrideWith(() => _FixedActualExpensesNotifier(actualExpenses)),
    monthlyBudgetsProvider
        .overrideWith(() => _FixedMonthlyBudgetsNotifier(monthlyBudgets)),
    dashboardConfigProvider
        .overrideWith(() => _FixedDashboardConfigNotifier(dashboardConfig)),
    subscriptionProvider
        .overrideWith(() => _FixedSubscriptionNotifier(subscription)),
    onboardingProvider
        .overrideWith(() => _FixedOnboardingNotifier(onboarding)),
  ];
}

/// Runs [body] with the global [ErrorWidget.builder] restored afterwards.
///
/// [DashboardContainer] wraps its screen in an [ErrorBoundary], which
/// reassigns `ErrorWidget.builder` on mount and never restores it; flutter_test
/// asserts that builder is unchanged at the end of each test body, so restore
/// it before the body returns (same pattern as
/// `test/containers/dashboard_container_test.dart`).
Future<void> _withErrorBoundaryGuard(Future<void> Function() body) async {
  final original = ErrorWidget.builder;
  try {
    await body();
  } finally {
    ErrorWidget.builder = original;
  }
}

/// Reproduces the QA finding (#1202): on the 'Início' tab the FAB '+' floated
/// over TOP CATEGORIAS rows / the VELOCIDADE DE GASTO pace badge with NO scroll,
/// on small/phone viewports.
///
/// The regression check compares the real scrollable's box against the real
/// FAB's box (not individual row rects): a row that straddles the viewport's
/// bottom edge is still laid out below that edge even though the viewport clips
/// it from view — asserting on the viewport's box is what the fix actually
/// guarantees and avoids false positives from that clipped, invisible tail.
///
/// Structure under test is the real production wiring for the dashboard tab:
/// - `content` is the real [DashboardContainer] (the exact widget app_home.dart
///   renders as `content`), with its provider graph seeded deterministically;
/// - the FAB is the real [QuickAddLauncher] the dashboard tab uses;
/// - the FAB-footprint reservation is [FabClearance] — the shared production
///   widget app_home.dart's `Expanded(child: content)` now uses. Because the
///   reservation is production code (not a copy in this harness), reverting it
///   (e.g. deleting the `Padding` inside `FabClearance.build`) makes this test
///   fail: the scroll viewport then extends to the Scaffold's body bottom,
///   which overlaps the FAB on both viewports.
///
/// (A full `AppHome` pump is not viable in this repo — `_AppHomeState.initState`
/// touches `AppDatabase.instance` and `RepositoryFactory`'s Supabase defaults,
/// which throw in a bare widget test; the dashboard tab's own widget tree and
/// layout decisions are exactly what this harness exercises.)
Future<void> pumpDashboardWithFab(WidgetTester tester, Size size) async {
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(
    ProviderScope(
      overrides: _dashboardOverrides(),
      child: wrapWithTestApp(
        Scaffold(
          body: Column(
            children: [
              Expanded(
                // Mirrors lib/app_home.dart: the FAB floats over `content`
                // in THIS same Scaffold, so the footprint is reserved here —
                // with the shared production FabClearance widget, wrapping
                // the whole DashboardContainer (siblings + screen), exactly
                // like app_home.dart does.
                child: FabClearance(
                  reserve: true,
                  child: DashboardContainer(
                    dataHealthService: DataHealthService(),
                    onSaveSettings: (_) {},
                    onSnapshotExpenses: () {},
                    onAddExpense: () {},
                    onOpenExpenseTracker: () {},
                    onViewTrends: () {},
                    onOpenSavingsGoals: () {},
                    onOpenRecurringExpenses: () {},
                    onOpenSettings: () {},
                    onTourComplete: () {},
                    onOpenInsights: () {},
                    onOpenCoach: () {},
                    onOpenIncome: () {},
                    onOpenTaxSimulator: () {},
                    onOpenConfidenceCenter: () {},
                    onUpgrade: () {},
                    onExploreFeature: (_) {},
                    onTrackFeature: (_) {},
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: QuickAddLauncher(onAction: (_) {}),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 1, color: Colors.black12),
              NavigationBar(
                height: 72,
                selectedIndex: 0,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    label: 'Track',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [const Size(360, 640), const Size(430, 932)]) {
    testWidgets(
      'FAB does not overlap the dashboard scroll viewport, and TOP '
      'CATEGORIAS + the burn-rate pace badge are visible without scroll, '
      'at ${size.width.toInt()}px (#1202)',
      (tester) async {
        await _withErrorBoundaryGuard(() async {
          await pumpDashboardWithFab(tester, size);

          final fabRect = tester.getRect(find.byType(FloatingActionButton));
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
          // the bug report (the pace badge and the category rows were
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
        });
      },
    );
  }

  testWidgets(
    'pull-to-refresh still works on the Início tab after the FAB clearance '
    'fix (#1202)',
    (tester) async {
      var refreshed = false;
      final settings = makeSettings();
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
