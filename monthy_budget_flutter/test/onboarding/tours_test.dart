import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:monthly_management/onboarding/coach_tour.dart';
import 'package:monthly_management/onboarding/command_assistant_tour.dart';
import 'package:monthly_management/onboarding/dashboard_tour.dart';
import 'package:monthly_management/onboarding/expense_tracker_tour.dart';
import 'package:monthly_management/onboarding/grocery_tour.dart';
import 'package:monthly_management/onboarding/meals_tour.dart';
import 'package:monthly_management/onboarding/recurring_expenses_tour.dart';
import 'package:monthly_management/onboarding/savings_goals_tour.dart';
import 'package:monthly_management/onboarding/shopping_tour.dart';

import '../helpers/test_app.dart';

void main() {
  group('buildCoachTour', () {
    testWidgets('returns no targets when keyed widgets are absent', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(const Scaffold(body: SizedBox.shrink())),
      );
      final context = tester.element(find.byType(Scaffold));
      final tour = buildCoachTour(
        context: context,
        onFinish: () {},
        onSkip: () {},
      );
      expect(tour.targets, isEmpty);
    });

    testWidgets('includes analyze/history targets when keys are mounted', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: Column(
              children: [
                Container(key: CoachTourKeys.analyzeButton),
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),
                      Container(key: CoachTourKeys.historyList),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      final context = tester.element(find.byType(Scaffold));
      final tour = buildCoachTour(
        context: context,
        onFinish: () {},
        onSkip: () {},
      );
      expect(tour.targets.length, 2);
      expect(tour.targets.map((t) => t.identify), containsAll(['analyze', 'history']));
    });
  });

  group('buildMealsTour', () {
    testWidgets('returns no targets when keyed widgets are absent', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(const Scaffold(body: SizedBox.shrink())),
      );
      final context = tester.element(find.byType(Scaffold));
      final tour = buildMealsTour(
        context: context,
        onFinish: () {},
        onSkip: () {},
      );
      expect(tour.targets, isEmpty);
    });

    testWidgets('includes all targets when keys are mounted', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: Column(
              children: [
                Container(key: MealsTourKeys.generateButton),
                Container(key: MealsTourKeys.weekTabs),
                Container(key: MealsTourKeys.addToListButton),
              ],
            ),
          ),
        ),
      );
      final context = tester.element(find.byType(Scaffold));
      final tour = buildMealsTour(
        context: context,
        onFinish: () {},
        onSkip: () {},
      );
      expect(tour.targets.length, 3);
      expect(
        tour.targets.map((t) => t.identify),
        containsAll(['generate', 'weeks', 'addToList']),
      );
    });
  });

  group('onboarding tour backdrop accessibility', () {
    testWidgets('every tour builder sets a non-empty backgroundSemanticLabel', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(const Scaffold(body: SizedBox.shrink())),
      );
      final context = tester.element(find.byType(Scaffold));
      final fabKey = GlobalKey();
      final navBarKey = GlobalKey();

      final tours = <String, TutorialCoachMark>{
        'coach': buildCoachTour(context: context, onFinish: () {}, onSkip: () {}),
        'commandAssistant': buildCommandAssistantTour(
          context: context,
          onFinish: () {},
          onSkip: () {},
        ),
        'dashboard': buildDashboardTour(
          context: context,
          fabKey: fabKey,
          navBarKey: navBarKey,
          onFinish: () {},
          onSkip: () {},
        ),
        'expenseTracker': buildExpenseTrackerTour(
          context: context,
          onFinish: () {},
          onSkip: () {},
        ),
        'grocery': buildGroceryTour(context: context, onFinish: () {}, onSkip: () {}),
        'meals': buildMealsTour(context: context, onFinish: () {}, onSkip: () {}),
        'recurringExpenses': buildRecurringExpensesTour(
          context: context,
          onFinish: () {},
          onSkip: () {},
        ),
        'savingsGoals': buildSavingsGoalsTour(
          context: context,
          onFinish: () {},
          onSkip: () {},
        ),
        'shopping': buildShoppingTour(context: context, onFinish: () {}, onSkip: () {}),
      };

      for (final entry in tours.entries) {
        expect(
          entry.value.backgroundSemanticLabel,
          isNotNull,
          reason: '${entry.key} tour has no backgroundSemanticLabel',
        );
        expect(
          entry.value.backgroundSemanticLabel,
          isNotEmpty,
          reason: '${entry.key} tour has an empty backgroundSemanticLabel',
        );
      }
    });
  });
}

