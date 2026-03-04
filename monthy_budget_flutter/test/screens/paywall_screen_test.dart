import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/subscription_state.dart';
import 'package:orcamento_mensal/screens/paywall_screen.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  group('PaywallScreen', () {
    group('header', () {
      testWidgets('shows "Your trial has ended" when trial expired',
          (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.text('Your trial has ended'), findsOneWidget);
        expect(
          find.text('Choose a plan to keep all your data and features'),
          findsOneWidget,
        );
      });

      testWidgets('shows "Upgrade to Premium" when trial active',
          (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.text('Upgrade to Premium'), findsOneWidget);
        expect(
          find.text('Unlock the full power of your budget'),
          findsOneWidget,
        );
      });

      testWidgets('shows "Your trial has ended" when trialUsed is true',
          (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.text('Your trial has ended'), findsOneWidget);
      });
    });

    group('tier cards', () {
      testWidgets('displays all three tier cards', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.text('Free'), findsOneWidget);
        expect(find.text('Premium'), findsOneWidget);
        expect(find.text('Family'), findsOneWidget);
      });

      testWidgets('shows "Most Popular" badge on Premium', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.text('Most Popular'), findsOneWidget);
      });

      testWidgets('shows CTA labels for each tier', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.text('Continue Free'), findsOneWidget);
        expect(find.text('Start Premium'), findsOneWidget);
        expect(find.text('Start Family'), findsOneWidget);
      });

      testWidgets('shows "Current Plan" for active tier', (tester) async {
        final state = SubscriptionState(
          tier: SubscriptionTier.premium,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
          trialUsed: true,
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.text('Current Plan'), findsOneWidget);
      });

      testWidgets('shows "Current Plan" for free tier (no active trial)',
          (tester) async {
        final state = SubscriptionState(
          tier: SubscriptionTier.free,
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
          trialUsed: true,
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        // The Free card shows "Current Plan" instead of "Continue Free"
        expect(find.text('Current Plan'), findsOneWidget);
      });
    });

    group('pricing', () {
      testWidgets('defaults to yearly pricing', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        // Yearly prices
        expect(find.text('€2.49'), findsOneWidget); // Premium yearly
        expect(find.text('€4.16'), findsOneWidget); // Family yearly
        expect(find.text('€0'), findsOneWidget); // Free
      });

      testWidgets('shows yearly savings notes', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.textContaining('Save 37%'), findsOneWidget);
        expect(find.textContaining('Save 40%'), findsOneWidget);
      });

      testWidgets('switches to monthly pricing when toggled', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        // Tap "Monthly" toggle
        await tester.tap(find.text('Monthly'));
        await tester.pumpAndSettle();

        // Monthly prices
        expect(find.text('€3.99'), findsOneWidget); // Premium monthly
        expect(find.text('€6.99'), findsOneWidget); // Family monthly
      });
    });

    group('features list', () {
      testWidgets('shows free tier features', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.text('Budget calculator (5 categories)'), findsOneWidget);
        expect(find.text('Basic expense tracking'), findsOneWidget);
        expect(find.text('1 savings goal'), findsOneWidget);
      });

      testWidgets('shows premium tier features', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.text('AI Financial Coach'), findsOneWidget);
        expect(find.text('Meal Planner + AI recipes'), findsOneWidget);
        expect(find.text('No ads'), findsOneWidget);
      });

      testWidgets('shows family tier features', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.text('Everything in Premium'), findsOneWidget);
        expect(find.text('Household sharing (up to 6)'), findsOneWidget);
        expect(find.text('Multi-country tax simulator'), findsOneWidget);
      });
    });

    group('blocked feature callout', () {
      testWidgets('shows callout when blockedFeature is provided',
          (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(
            subscription: state,
            onSelectTier: (_) {},
            blockedFeature: PremiumFeature.aiCoach,
          ),
        ));

        expect(
          find.text('AI Financial Coach requires a paid subscription'),
          findsOneWidget,
        );
      });

      testWidgets('shows callout for family feature', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(
            subscription: state,
            onSelectTier: (_) {},
            blockedFeature: PremiumFeature.householdSharing,
          ),
        ));

        expect(
          find.text('Household Sharing requires a paid subscription'),
          findsOneWidget,
        );
      });

      testWidgets('hides callout when no blockedFeature', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(
            subscription: state,
            onSelectTier: (_) {},
          ),
        ));

        expect(find.textContaining('requires a paid subscription'),
            findsNothing);
      });
    });

    group('trust signals', () {
      testWidgets('shows trust and legal text', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(
          find.text('Cancel anytime • No hidden fees'),
          findsOneWidget,
        );
        expect(
          find.text('Terms of Service • Privacy Policy'),
          findsOneWidget,
        );
      });
    });

    group('tier selection callbacks', () {
      testWidgets('calls onSelectTier with premium when tapped',
          (tester) async {
        SubscriptionTier? selectedTier;
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(
            subscription: state,
            onSelectTier: (tier) => selectedTier = tier,
          ),
        ));

        await tester.tap(find.text('Start Premium'));
        expect(selectedTier, SubscriptionTier.premium);
      });

      testWidgets('calls onSelectTier with family when tapped',
          (tester) async {
        SubscriptionTier? selectedTier;
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(
            subscription: state,
            onSelectTier: (tier) => selectedTier = tier,
          ),
        ));

        await tester.tap(find.text('Start Family'));
        expect(selectedTier, SubscriptionTier.family);
      });

      testWidgets('calls onSelectTier with free when "Continue Free" tapped',
          (tester) async {
        SubscriptionTier? selectedTier;
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(
            subscription: state,
            onSelectTier: (tier) => selectedTier = tier,
          ),
        ));

        await tester.tap(find.text('Continue Free'));
        expect(selectedTier, SubscriptionTier.free);
      });
    });

    group('close button', () {
      testWidgets('shows close button in app bar', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.byIcon(Icons.close), findsOneWidget);
      });
    });

    group('billing toggle', () {
      testWidgets('shows both Monthly and Yearly options', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.text('Monthly'), findsOneWidget);
        expect(find.text('Yearly (save 37%)'), findsOneWidget);
      });

      testWidgets('toggling between yearly and monthly updates prices',
          (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        // Initially yearly
        expect(find.text('€2.49'), findsOneWidget);

        // Switch to monthly
        await tester.tap(find.text('Monthly'));
        await tester.pumpAndSettle();
        expect(find.text('€3.99'), findsOneWidget);

        // Switch back to yearly
        await tester.tap(find.text('Yearly (save 37%)'));
        await tester.pumpAndSettle();
        expect(find.text('€2.49'), findsOneWidget);
      });
    });
  });
}
