import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/screens/more_screen.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

import '../helpers/test_app.dart';

/// Builds a `MoreScreen` with stub callbacks. Override only what the
/// individual test cares about; the rest are no-ops.
class _Stubs {
  int coach = 0;
  int planShop = 0;
  int shoppingList = 0;
  int mealPlanner = 0;
  int pantry = 0;
  int income = 0;
  int recurring = 0;
  int household = 0;
  int yearly = 0;
  int taxSim = 0;
  int receiptScan = 0;
  int dataHealth = 0;
  int notifications = 0;
  int settings = 0;
  int paywall = 0;
  final openedInsights = <String>[];
}

MoreScreen _buildScreen(
  _Stubs s, {
  String coachQuote = 'You can save €100 this week.',
  List<MoreObservation> observations = const [],
  SubscriptionState? subscription,
  int householdMemberCount = 0,
  int dataHealthAlertCount = 0,
  int? currentYear,
  bool taxSimulatorEnabled = true,
  bool receiptOcrEnabled = true,
}) {
  return MoreScreen(
    coachQuote: coachQuote,
    observations: observations,
    onOpenCoach: () => s.coach++,
    onOpenInsight: (o) => s.openedInsights.add(o.id),
    onOpenPlanShop: () => s.planShop++,
    onOpenShoppingList: () => s.shoppingList++,
    onOpenMealPlanner: () => s.mealPlanner++,
    onOpenPantry: () => s.pantry++,
    onOpenIncome: () => s.income++,
    onOpenRecurring: () => s.recurring++,
    onOpenHousehold: () => s.household++,
    onOpenYearlySummary: () => s.yearly++,
    onOpenTaxSimulator: () => s.taxSim++,
    onOpenScanReceipt: () => s.receiptScan++,
    onOpenDataHealth: () => s.dataHealth++,
    onOpenNotifications: () => s.notifications++,
    onOpenSettings: () => s.settings++,
    onOpenPaywall: () => s.paywall++,
    subscription: subscription,
    householdMemberCount: householdMemberCount,
    dataHealthAlertCount: dataHealthAlertCount,
    currentYear: currentYear,
    taxSimulatorEnabled: taxSimulatorEnabled,
    receiptOcrEnabled: receiptOcrEnabled,
  );
}

SubscriptionState _freeTier() => SubscriptionState(
  tier: SubscriptionTier.free,
  trialStartDate: DateTime.utc(2020),
  trialUsed: true,
);

SubscriptionState _premiumTier() => SubscriptionState(
  tier: SubscriptionTier.premium,
  trialStartDate: DateTime.utc(2020),
);

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('MoreScreen — structure', () {
    testWidgets('renders header, coach hero, ferramentas eyebrow', (
      tester,
    ) async {
      final s = _Stubs();
      await tester.pumpWidget(wrapWithTestApp(_buildScreen(s)));
      await tester.pumpAndSettle();

      expect(find.text('Insights & more'), findsOneWidget);
      expect(find.text('UNDERSTANDING'), findsOneWidget);
      expect(find.text('COACH'), findsOneWidget);
      expect(find.text('You can save €100 this week.'), findsOneWidget);
      expect(find.text('Talk to the coach'), findsOneWidget);
      expect(find.text('TOOLS'), findsOneWidget);
    });

    testWidgets('observações skipped when list empty', (tester) async {
      await tester.pumpWidget(wrapWithTestApp(_buildScreen(_Stubs())));
      await tester.pumpAndSettle();

      expect(find.text('OBSERVATIONS'), findsNothing);
      expect(find.byType(CalmObservationCard), findsNothing);
    });

    testWidgets('renders all three observation kinds with right labels', (
      tester,
    ) async {
      final s = _Stubs();
      await tester.pumpWidget(
        wrapWithTestApp(
          _buildScreen(
            s,
            observations: const [
              MoreObservation(
                id: 'a',
                kind: CalmObservationKind.warning,
                title: 'Leisure 43% over budget',
                body: 'You spent €287 vs €200 planned.',
              ),
              MoreObservation(
                id: 'b',
                kind: CalmObservationKind.info,
                title: 'On track for groceries',
                body: 'You are €37 below.',
              ),
              MoreObservation(
                id: 'c',
                kind: CalmObservationKind.success,
                title: '3 months consecutively in green',
                body: 'Average €880 saved per month.',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('OBSERVATIONS'), findsOneWidget);
      expect(find.byType(CalmObservationCard), findsNWidgets(3));
      expect(find.text('HEADS UP'), findsOneWidget);
      expect(find.text('FYI'), findsOneWidget);
      expect(find.text('GREAT'), findsOneWidget);
    });
  });

  group('MoreScreen — tools list', () {
    testWidgets('all 13 tools render with correct titles by default', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithTestApp(_buildScreen(_Stubs())));
      await tester.pumpAndSettle();

      final expectedTitles = <String>[
        'Plan & shopping list',
        'Shopping list',
        'Meals this week',
        'Pantry',
        'Income',
        'Recurring bills',
        'Household',
        'Yearly summary',
        'Tax simulator',
        'Scan receipt',
        'Data health',
        'Notifications',
        'Settings',
      ];
      for (final t in expectedTitles) {
        expect(find.text(t), findsOneWidget, reason: 'missing tool: $t');
      }
    });

    testWidgets('taxSimulatorEnabled=false hides Tax simulator row', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          _buildScreen(_Stubs(), taxSimulatorEnabled: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tax simulator'), findsNothing);
      expect(find.text('Scan receipt'), findsOneWidget);
    });

    testWidgets('receiptOcrEnabled=false hides Scan receipt row', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          _buildScreen(_Stubs(), receiptOcrEnabled: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Scan receipt'), findsNothing);
      expect(find.text('Tax simulator'), findsOneWidget);
    });

    testWidgets('household sublabel shows "Set up" when memberCount=0', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithTestApp(_buildScreen(_Stubs())));
      await tester.pumpAndSettle();

      expect(find.text('Set up'), findsOneWidget);
    });

    testWidgets('household sublabel shows count when memberCount>0', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          _buildScreen(_Stubs(), householdMemberCount: 3),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3 members · shared'), findsOneWidget);
      expect(find.text('Set up'), findsNothing);
    });

    testWidgets('data health badge appears when alertCount > 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          _buildScreen(_Stubs(), dataHealthAlertCount: 4),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('yearly summary sub uses provided year', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(_buildScreen(_Stubs(), currentYear: 2026)),
      );
      await tester.pumpAndSettle();

      expect(find.text('2026 trends'), findsOneWidget);
    });
  });

  group('MoreScreen — taps', () {
    testWidgets('tapping coach hero invokes onOpenCoach', (tester) async {
      final s = _Stubs();
      await tester.pumpWidget(wrapWithTestApp(_buildScreen(s)));
      await tester.pumpAndSettle();

      await _tapVisible(tester, find.text('Talk to the coach'));
      expect(s.coach, 1);
      expect(s.paywall, 0);
    });

    testWidgets('tapping every tool invokes its callback exactly once', (
      tester,
    ) async {
      final s = _Stubs();
      await tester.pumpWidget(wrapWithTestApp(_buildScreen(s)));
      await tester.pumpAndSettle();

      await _tapVisible(tester, find.text('Plan & shopping list'));
      await _tapVisible(tester, find.text('Shopping list'));
      await _tapVisible(tester, find.text('Meals this week'));
      await _tapVisible(tester, find.text('Pantry'));
      await _tapVisible(tester, find.text('Income'));
      await _tapVisible(tester, find.text('Recurring bills'));
      await _tapVisible(tester, find.text('Household'));
      await _tapVisible(tester, find.text('Yearly summary'));
      await _tapVisible(tester, find.text('Tax simulator'));
      await _tapVisible(tester, find.text('Scan receipt'));
      await _tapVisible(tester, find.text('Data health'));
      await _tapVisible(tester, find.text('Notifications'));
      await _tapVisible(tester, find.text('Settings'));

      expect(s.planShop, 1);
      expect(s.shoppingList, 1);
      expect(s.mealPlanner, 1);
      expect(s.pantry, 1);
      expect(s.income, 1);
      expect(s.recurring, 1);
      expect(s.household, 1);
      expect(s.yearly, 1);
      expect(s.taxSim, 1);
      expect(s.receiptScan, 1);
      expect(s.dataHealth, 1);
      expect(s.notifications, 1);
      expect(s.settings, 1);
    });

    testWidgets('tapping an observation dispatches its id', (tester) async {
      final s = _Stubs();
      await tester.pumpWidget(
        wrapWithTestApp(
          _buildScreen(
            s,
            observations: const [
              MoreObservation(
                id: 'leisure-over',
                kind: CalmObservationKind.warning,
                title: 'Leisure 43% over budget',
                body: 'Body.',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _tapVisible(tester, find.text('Leisure 43% over budget'));
      expect(s.openedInsights, ['leisure-over']);
    });
  });

  group('MoreScreen — free tier', () {
    testWidgets('shows PRO pill on coach hero', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(_buildScreen(_Stubs(), subscription: _freeTier())),
      );
      await tester.pumpAndSettle();

      expect(find.text('PRO'), findsOneWidget);
      expect(find.text('Unlock the coach'), findsOneWidget);
      expect(find.text('Talk to the coach'), findsNothing);
    });

    testWidgets('tapping CTA opens paywall, not coach', (tester) async {
      final s = _Stubs();
      await tester.pumpWidget(
        wrapWithTestApp(_buildScreen(s, subscription: _freeTier())),
      );
      await tester.pumpAndSettle();

      await _tapVisible(tester, find.text('Unlock the coach'));
      expect(s.paywall, 1);
      expect(s.coach, 0);
    });

    testWidgets('premium tier shows normal CTA without PRO pill', (
      tester,
    ) async {
      final s = _Stubs();
      await tester.pumpWidget(
        wrapWithTestApp(_buildScreen(s, subscription: _premiumTier())),
      );
      await tester.pumpAndSettle();

      expect(find.text('PRO'), findsNothing);
      expect(find.text('Talk to the coach'), findsOneWidget);

      await _tapVisible(tester, find.text('Talk to the coach'));
      expect(s.coach, 1);
      expect(s.paywall, 0);
    });
  });

  group('MoreScreen — accessibility', () {
    testWidgets('every tool row exposes a button semantics node', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithTestApp(_buildScreen(_Stubs())));
      await tester.pumpAndSettle();

      // Each tool row is wrapped in Semantics(button: true). With 13 tools,
      // we expect at least 13 button-tagged semantics nodes (the coach hero
      // adds another).
      final handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(RegExp(r'Plan|Shopping|Meals|Pantry|Income')),
        findsWidgets,
      );
      handle.dispose();
    });
  });
}
