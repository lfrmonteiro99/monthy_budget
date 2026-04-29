import 'package:flutter/material.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/screens/paywall_screen.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: child,
  );
}

void main() {
  group('PaywallScreen', () {
    group('header', () {
      // Wave M5: the header is now a fixed Calm hero title (not conditional on
      // trial state). Tests rebind to the eyebrow + hero title that are always
      // present, and to the Calm CTA that supersedes the old conditional copy.
      testWidgets('shows hero title when trial expired', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(
          find.text('Tudo o que precisas para um ano de paz financeira'),
          findsOneWidget,
        );
        expect(find.text('MONTHLY PLUS'), findsOneWidget);
      });

      testWidgets('shows hero title when trial active', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(
          find.text('Tudo o que precisas para um ano de paz financeira'),
          findsOneWidget,
        );
        expect(find.text('MONTHLY PLUS'), findsOneWidget);
      });

      testWidgets('shows hero title when trialUsed is true', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(
          find.text('Tudo o que precisas para um ano de paz financeira'),
          findsOneWidget,
        );
      });
    });

    group('tier cards', () {
      testWidgets('displays free and pro tier cards', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.text('Free'), findsOneWidget);
        expect(find.text('Monthly Budget Pro'), findsOneWidget);
      });

      testWidgets('shows "Best Value" badge on Pro', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.text('Best Value'), findsOneWidget);
      });

      testWidgets('shows CTA labels for each tier', (tester) async {
        // Use active trial so Free card is not "Current Plan"
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.text('Continue Free'), findsOneWidget);
        expect(find.text('Start Pro'), findsOneWidget);
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
        // Wave M5: price shown in both price card and tier card — allow multiple
        expect(find.textContaining('2.49'), findsAtLeastNWidgets(1));
      });

      testWidgets('shows yearly savings notes', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));

        expect(find.textContaining('Save 37%'), findsAtLeastNWidgets(1));
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
        expect(find.textContaining('3.99'), findsAtLeastNWidgets(1));
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

        expect(find.text('Budget calculator (8 categories)'), findsOneWidget);
        expect(find.text('Basic expense tracking'), findsOneWidget);
        expect(find.text('1 savings goal'), findsOneWidget);
      });

      testWidgets('shows pro tier features', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));
        expect(find.text('Unlimited categories & history'), findsOneWidget);
        expect(find.text('AI Financial Coach'), findsOneWidget);
        expect(find.text('Meal Planner + AI recipes'), findsOneWidget);
        expect(find.text('No ads'), findsOneWidget);
      });

      testWidgets('shows advanced pro features', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(subscription: state, onSelectTier: (_) {}),
        ));
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
        expect(find.textContaining('Cancel anytime'), findsOneWidget);
        expect(find.textContaining('No hidden fees'), findsOneWidget);
        // ToS + Privacy are in RichText TextSpans — verify via RichText content
        expect(
          find.byWidgetPredicate((w) =>
              w is RichText &&
              w.text.toPlainText().contains('Terms of Service')),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate((w) =>
              w is RichText &&
              w.text.toPlainText().contains('Privacy Policy')),
          findsOneWidget,
        );
      });
    });

    group('tier selection callbacks', () {
      testWidgets('calls onSelectTier with family when "Start Pro" tapped',
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

        await tester.scrollUntilVisible(find.text('Start Pro'), 200);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Start Pro'));
        expect(selectedTier, SubscriptionTier.family);
      });


      testWidgets('calls onSelectTier with free when "Continue Free" tapped',
          (tester) async {
        SubscriptionTier? selectedTier;
        // Use active trial so Free card shows "Continue Free" (not "Current Plan")
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          PaywallScreen(
            subscription: state,
            onSelectTier: (tier) => selectedTier = tier,
          ),
        ));

        await tester.scrollUntilVisible(find.text('Continue Free'), 200);
        await tester.pumpAndSettle();
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

        // Initially yearly — price appears in both price card and tier card
        expect(find.textContaining('2.49'), findsAtLeastNWidgets(1));

        // Switch to monthly
        await tester.tap(find.text('Monthly'));
        await tester.pumpAndSettle();
        expect(find.textContaining('3.99'), findsAtLeastNWidgets(1));

        // Switch back to yearly
        await tester.tap(find.text('Yearly (save 37%)'));
        await tester.pumpAndSettle();
        expect(find.textContaining('2.49'), findsAtLeastNWidgets(1));
      });
    });
  });
}
