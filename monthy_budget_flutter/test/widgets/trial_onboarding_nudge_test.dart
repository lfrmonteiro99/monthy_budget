import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/widgets/trial_onboarding_nudge.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));
}

void main() {
  group('TrialOnboardingNudge', () {
    group('visibility (shouldShow)', () {
      test('shouldShow true during first 3 days with low counts', () {
        final nudge = TrialOnboardingNudge(
          subscription: SubscriptionState(
            trialStartDate: DateTime.now(),
          ),
          activeCategories: 3,
          activeSavingsGoals: 0,
          onAddCategories: () {},
          onAddSavingsGoals: () {},
        );
        expect(nudge.shouldShow, true);
      });

      test('shouldShow false after 3 days', () {
        final nudge = TrialOnboardingNudge(
          subscription: SubscriptionState(
            trialStartDate: DateTime.now().subtract(const Duration(days: 4)),
          ),
          activeCategories: 3,
          activeSavingsGoals: 0,
          onAddCategories: () {},
          onAddSavingsGoals: () {},
        );
        expect(nudge.shouldShow, false);
      });

      test('shouldShow false when both targets met', () {
        final nudge = TrialOnboardingNudge(
          subscription: SubscriptionState(
            trialStartDate: DateTime.now(),
          ),
          activeCategories: 9,
          activeSavingsGoals: 2,
          onAddCategories: () {},
          onAddSavingsGoals: () {},
        );
        expect(nudge.shouldShow, false);
      });

      test('shouldShow false when trial inactive', () {
        final nudge = TrialOnboardingNudge(
          subscription: SubscriptionState(
            trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
          ),
          activeCategories: 3,
          activeSavingsGoals: 0,
          onAddCategories: () {},
          onAddSavingsGoals: () {},
        );
        expect(nudge.shouldShow, false);
      });

      test('shouldShow true when only categories target not met', () {
        final nudge = TrialOnboardingNudge(
          subscription: SubscriptionState(
            trialStartDate: DateTime.now(),
          ),
          activeCategories: 5,
          activeSavingsGoals: 2,
          onAddCategories: () {},
          onAddSavingsGoals: () {},
        );
        expect(nudge.shouldShow, true);
      });

      test('shouldShow true when only goals target not met', () {
        final nudge = TrialOnboardingNudge(
          subscription: SubscriptionState(
            trialStartDate: DateTime.now(),
          ),
          activeCategories: 10,
          activeSavingsGoals: 1,
          onAddCategories: () {},
          onAddSavingsGoals: () {},
        );
        expect(nudge.shouldShow, true);
      });
    });

    group('rendering', () {
      testWidgets('renders nothing when shouldShow is false', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 10)),
        );

        await tester.pumpWidget(_wrap(
          TrialOnboardingNudge(
            subscription: state,
            activeCategories: 3,
            activeSavingsGoals: 0,
            onAddCategories: () {},
            onAddSavingsGoals: () {},
          ),
        ));

        expect(find.text('Get the most out of your trial'), findsNothing);
      });

      testWidgets('shows headline when visible', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          TrialOnboardingNudge(
            subscription: state,
            activeCategories: 3,
            activeSavingsGoals: 0,
            onAddCategories: () {},
            onAddSavingsGoals: () {},
          ),
        ));

        expect(find.text('Get the most out of your trial'), findsOneWidget);
      });

      testWidgets('shows category action when below target', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          TrialOnboardingNudge(
            subscription: state,
            activeCategories: 5,
            activeSavingsGoals: 0,
            onAddCategories: () {},
            onAddSavingsGoals: () {},
          ),
        ));

        expect(find.textContaining('Add more categories (5/9)'), findsOneWidget);
      });

      testWidgets('shows savings goal action when below target', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          TrialOnboardingNudge(
            subscription: state,
            activeCategories: 10,
            activeSavingsGoals: 1,
            onAddCategories: () {},
            onAddSavingsGoals: () {},
          ),
        ));

        expect(find.textContaining('Create savings goals (1/2)'), findsOneWidget);
        // Categories action should NOT show since target met
        expect(find.textContaining('Add more categories'), findsNothing);
      });

      testWidgets('calls onAddCategories when tapped', (tester) async {
        var tapped = false;
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          TrialOnboardingNudge(
            subscription: state,
            activeCategories: 3,
            activeSavingsGoals: 2,
            onAddCategories: () => tapped = true,
            onAddSavingsGoals: () {},
          ),
        ));

        await tester.tap(find.textContaining('Add more categories'));
        expect(tapped, true);
      });

      testWidgets('calls onAddSavingsGoals when tapped', (tester) async {
        var tapped = false;
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          TrialOnboardingNudge(
            subscription: state,
            activeCategories: 10,
            activeSavingsGoals: 0,
            onAddCategories: () {},
            onAddSavingsGoals: () => tapped = true,
          ),
        ));

        await tester.tap(find.textContaining('Create savings goals'));
        expect(tapped, true);
      });

      testWidgets('shows dismiss button when onDismiss provided', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          TrialOnboardingNudge(
            subscription: state,
            activeCategories: 3,
            activeSavingsGoals: 0,
            onAddCategories: () {},
            onAddSavingsGoals: () {},
            onDismiss: () {},
          ),
        ));

        expect(find.byIcon(Icons.close), findsOneWidget);
      });

      testWidgets('hides dismiss button when onDismiss is null', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          TrialOnboardingNudge(
            subscription: state,
            activeCategories: 3,
            activeSavingsGoals: 0,
            onAddCategories: () {},
            onAddSavingsGoals: () {},
          ),
        ));

        expect(find.byIcon(Icons.close), findsNothing);
      });
    });

    group('constants', () {
      test('targetCategories is 9', () {
        expect(TrialOnboardingNudge.targetCategories, 9);
      });

      test('targetSavingsGoals is 2', () {
        expect(TrialOnboardingNudge.targetSavingsGoals, 2);
      });

      test('nudgeWindowDays is 3', () {
        expect(TrialOnboardingNudge.nudgeWindowDays, 3);
      });
    });
  });
}
