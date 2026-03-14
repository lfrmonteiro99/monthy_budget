import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';
import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/widgets/feature_discovery_card.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('FeatureDiscoveryCard', () {
    group('visibility', () {
      testWidgets('renders nothing when trial expired', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        await tester.pumpWidget(_wrap(
          FeatureDiscoveryCard(
            subscription: state,
            onExploreFeature: (_) {},
            onDismiss: () {},
          ),
        ));

        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.textContaining('Try'), findsNothing);
      });

      testWidgets('renders nothing when all features explored',
          (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          featuresExplored: SubscriptionState.discoverableFeatures.toSet(),
        );

        await tester.pumpWidget(_wrap(
          FeatureDiscoveryCard(
            subscription: state,
            onExploreFeature: (_) {},
            onDismiss: () {},
          ),
        ));

        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.textContaining('Try'), findsNothing);
      });

      testWidgets('renders nothing when trialUsed is true', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          trialUsed: true,
        );

        await tester.pumpWidget(_wrap(
          FeatureDiscoveryCard(
            subscription: state,
            onExploreFeature: (_) {},
            onDismiss: () {},
          ),
        ));

        expect(find.textContaining('Try'), findsNothing);
      });
    });

    group('content for next feature', () {
      testWidgets('shows first feature (dashboard) when none explored',
          (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          FeatureDiscoveryCard(
            subscription: state,
            onExploreFeature: (_) {},
            onDismiss: () {},
          ),
        ));

        expect(find.text('Try Dashboard'), findsOneWidget);
        expect(find.text('Explore Dashboard'), findsOneWidget);
        expect(find.textContaining('financial overview'), findsOneWidget);
      });

      testWidgets('shows ai_coach when dashboard is explored',
          (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          featuresExplored: {'dashboard'},
        );

        await tester.pumpWidget(_wrap(
          FeatureDiscoveryCard(
            subscription: state,
            onExploreFeature: (_) {},
            onDismiss: () {},
          ),
        ));

        expect(find.text('Try AI Coach'), findsOneWidget);
        expect(find.text('Explore AI Coach'), findsOneWidget);
      });

      testWidgets('shows meal_planner when dashboard+ai_coach explored',
          (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          featuresExplored: {'dashboard', 'ai_coach'},
        );

        await tester.pumpWidget(_wrap(
          FeatureDiscoveryCard(
            subscription: state,
            onExploreFeature: (_) {},
            onDismiss: () {},
          ),
        ));

        expect(find.text('Try Meal Planner'), findsOneWidget);
      });

      testWidgets('shows tagline and description', (tester) async {
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          featuresExplored: {'dashboard'},
        );

        await tester.pumpWidget(_wrap(
          FeatureDiscoveryCard(
            subscription: state,
            onExploreFeature: (_) {},
            onDismiss: () {},
          ),
        ));

        // AI Coach tagline
        expect(find.text('Your personal financial advisor'), findsOneWidget);
        // AI Coach description
        expect(find.textContaining('personalized insights'), findsOneWidget);
      });
    });

    group('callbacks', () {
      testWidgets('calls onExploreFeature with feature key when CTA tapped',
          (tester) async {
        String? exploredKey;
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
          featuresExplored: {'dashboard'},
        );

        await tester.pumpWidget(_wrap(
          FeatureDiscoveryCard(
            subscription: state,
            onExploreFeature: (key) => exploredKey = key,
            onDismiss: () {},
          ),
        ));

        await tester.tap(find.text('Explore AI Coach'));
        expect(exploredKey, 'ai_coach');
      });

      testWidgets('calls onDismiss when close icon tapped', (tester) async {
        var dismissed = false;
        final state = SubscriptionState(
          trialStartDate: DateTime.now(),
        );

        await tester.pumpWidget(_wrap(
          FeatureDiscoveryCard(
            subscription: state,
            onExploreFeature: (_) {},
            onDismiss: () => dismissed = true,
          ),
        ));

        await tester.tap(find.byIcon(Icons.close));
        expect(dismissed, true);
      });
    });

    group('all feature info variants', () {
      final featureExpectations = <String, String>{
        'dashboard': 'Dashboard',
        'ai_coach': 'AI Coach',
        'meal_planner': 'Meal Planner',
        'expense_tracker': 'Expense Tracker',
        'savings_goals': 'Savings Goals',
        'shopping_list': 'Shopping List',
        'grocery_browser': 'Grocery Browser',
        'export': 'Export Reports',
        'tax_simulator': 'Tax Simulator',
      };

      // Build explored set incrementally to test each feature as "next"
      final allFeatures = SubscriptionState.discoverableFeatures;
      for (var i = 0; i < allFeatures.length; i++) {
        final featureKey = allFeatures[i];
        final explored = allFeatures.sublist(0, i).toSet();
        final expectedName = featureExpectations[featureKey]!;

        testWidgets('shows correct info for $featureKey', (tester) async {
          final state = SubscriptionState(
            trialStartDate: DateTime.now(),
            featuresExplored: explored,
          );

          await tester.pumpWidget(_wrap(
            FeatureDiscoveryCard(
              subscription: state,
              onExploreFeature: (_) {},
              onDismiss: () {},
            ),
          ));

          expect(find.text('Try $expectedName'), findsOneWidget);
          expect(find.text('Explore $expectedName'), findsOneWidget);
        });
      }
    });
  });

  group('PremiumLockOverlay', () {
    testWidgets('shows child directly when not locked', (tester) async {
      await tester.pumpWidget(_wrap(
        PremiumLockOverlay(
          isLocked: false,
          onTapLocked: () {},
          child: const Text('Unlocked Content'),
        ),
      ));

      expect(find.text('Unlocked Content'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
    });

    testWidgets('shows lock overlay when locked', (tester) async {
      await tester.pumpWidget(_wrap(
        PremiumLockOverlay(
          isLocked: true,
          onTapLocked: () {},
          child: const SizedBox(width: 200, height: 200, child: Text('Locked Content')),
        ),
      ));

      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.text('Tap to upgrade'), findsOneWidget);
    });

    testWidgets('shows default feature name in lock message', (tester) async {
      await tester.pumpWidget(_wrap(
        PremiumLockOverlay(
          isLocked: true,
          onTapLocked: () {},
          child: const SizedBox(width: 200, height: 200, child: Text('Content')),
        ),
      ));

      expect(find.text('This feature requires Premium'), findsOneWidget);
    });

    testWidgets('shows custom feature name in lock message', (tester) async {
      await tester.pumpWidget(_wrap(
        PremiumLockOverlay(
          isLocked: true,
          onTapLocked: () {},
          featureName: 'AI Coach',
          child: const SizedBox(width: 200, height: 200, child: Text('Content')),
        ),
      ));

      expect(find.text('AI Coach requires Premium'), findsOneWidget);
    });

    testWidgets('calls onTapLocked when overlay tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        PremiumLockOverlay(
          isLocked: true,
          onTapLocked: () => tapped = true,
          child: const SizedBox(width: 200, height: 200),
        ),
      ));

      await tester.tap(find.text('Tap to upgrade'));
      expect(tapped, true);
    });

    testWidgets('dims child content when locked', (tester) async {
      await tester.pumpWidget(_wrap(
        PremiumLockOverlay(
          isLocked: true,
          onTapLocked: () {},
          child: const SizedBox(width: 200, height: 200, child: Text('Dimmed')),
        ),
      ));

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.4);
    });

    testWidgets('absorbs child pointer events when locked', (tester) async {
      await tester.pumpWidget(_wrap(
        PremiumLockOverlay(
          isLocked: true,
          onTapLocked: () {},
          child: const SizedBox(width: 200, height: 200, child: Text('Locked')),
        ),
      ));

      final absorber = tester.widget<AbsorbPointer>(find.descendant(
        of: find.byType(PremiumLockOverlay),
        matching: find.byType(AbsorbPointer),
      ));
      expect(absorber.absorbing, true);
    });
  });
}
