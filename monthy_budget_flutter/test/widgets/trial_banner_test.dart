import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/subscription_state.dart';
import 'package:orcamento_mensal/widgets/trial_banner.dart';

/// Wrap widget under test in a MaterialApp for theme context.
Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));
}

void main() {
  group('TrialBanner', () {
    group('visibility', () {
      testWidgets('renders nothing when trial is expired', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(find.byType(TrialBanner), findsOneWidget);
        // The widget should return SizedBox.shrink
        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.text('Premium Trial Active'), findsNothing);
      });

      testWidgets('renders nothing when trialUsed is true', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(find.text('Premium Trial Active'), findsNothing);
      });
    });

    group('early phase (>10 days left)', () {
      testWidgets('shows "Premium Trial Active" headline', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 2)),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(find.text('Premium Trial Active'), findsOneWidget);
      });

      testWidgets('shows "See Plans" CTA', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 1)),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(find.text('See Plans'), findsOneWidget);
      });

      testWidgets('shows features explored progress', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          featuresExplored: {'dashboard', 'ai_coach'},
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(
          find.textContaining('2/${SubscriptionState.discoverableFeatures.length} features explored'),
          findsOneWidget,
        );
      });

      testWidgets('shows days remaining', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 4)),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(find.text('17 days left'), findsOneWidget);
      });

      testWidgets('shows progress bar', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('shows star icon in early phase', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      });
    });

    group('mid phase (4-10 days left)', () {
      testWidgets('shows "halfway through" headline', (tester) async {
        // Day 14 of 21 = 7 days left → mid phase
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 14)),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(find.text('Your trial is halfway through'), findsOneWidget);
      });

      testWidgets('suggests next feature to discover', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 14)),
          featuresExplored: {'dashboard'},
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        // Next feature after 'dashboard' is 'ai_coach' → "AI Financial Coach"
        expect(
          find.textContaining('AI Financial Coach'),
          findsOneWidget,
        );
      });

      testWidgets('shows progress message when all features explored',
          (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 15)),
          featuresExplored: SubscriptionState.discoverableFeatures.toSet(),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(
          find.textContaining('great progress'),
          findsOneWidget,
        );
      });

      testWidgets('still shows progress bar in mid phase', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 14)),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });
    });

    group('urgent phase (<=3 days left)', () {
      testWidgets('shows "X days left in your trial!" headline',
          (tester) async {
        // Day 18 of 21 = 3 days left → urgent
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 18)),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(find.text('3 days left in your trial!'), findsOneWidget);
      });

      testWidgets('shows "Last day" when 1 day left', (tester) async {
        // Day 20 of 21 = 1 day left
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 20)),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(find.text('Last day of your free trial!'), findsOneWidget);
      });

      testWidgets('shows urgent CTA text', (tester) async {
        // Day 19 of 21 = 2 days left → urgent
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 19)),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(
            find.text('Upgrade Now — Keep Your Data'), findsOneWidget);
      });

      testWidgets('shows timer icon in urgent phase', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 19)),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(find.byIcon(Icons.timer), findsOneWidget);
      });

      testWidgets('does NOT show progress bar in urgent phase',
          (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 19)),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(find.byType(LinearProgressIndicator), findsNothing);
      });

      testWidgets('shows urgency subtitle about premium access ending',
          (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 19)),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(
          find.textContaining('premium access ends soon'),
          findsOneWidget,
        );
      });
    });

    group('dismiss button', () {
      testWidgets('shows dismiss button when onDismiss provided and not urgent',
          (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(
            subscription: state,
            onUpgrade: () {},
            onDismiss: () {},
          ),
        ));

        expect(find.byIcon(Icons.close), findsOneWidget);
      });

      testWidgets('hides dismiss button in urgent phase', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 19)),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(
            subscription: state,
            onUpgrade: () {},
            onDismiss: () {},
          ),
        ));

        // dismiss close icon should not be present (only timer icon)
        expect(find.byIcon(Icons.close), findsNothing);
      });

      testWidgets('hides dismiss button when onDismiss is null',
          (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(subscription: state, onUpgrade: () {}),
        ));

        expect(find.byIcon(Icons.close), findsNothing);
      });

      testWidgets('calls onDismiss when close icon tapped', (tester) async {
        var dismissed = false;
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(
            subscription: state,
            onUpgrade: () {},
            onDismiss: () => dismissed = true,
          ),
        ));

        await tester.tap(find.byIcon(Icons.close));
        expect(dismissed, true);
      });
    });

    group('callbacks', () {
      testWidgets('calls onUpgrade when CTA button tapped', (tester) async {
        var upgraded = false;
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(
            subscription: state,
            onUpgrade: () => upgraded = true,
          ),
        ));

        await tester.tap(find.text('See Plans'));
        expect(upgraded, true);
      });

      testWidgets('calls onUpgrade when urgent CTA tapped', (tester) async {
        var upgraded = false;
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 19)),
        );

        await tester.pumpWidget(_wrap(
          TrialBanner(
            subscription: state,
            onUpgrade: () => upgraded = true,
          ),
        ));

        await tester.tap(find.text('Upgrade Now — Keep Your Data'));
        expect(upgraded, true);
      });
    });
  });
}
