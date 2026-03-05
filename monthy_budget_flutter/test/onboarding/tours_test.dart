import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/onboarding/coach_tour.dart';
import 'package:orcamento_mensal/onboarding/meals_tour.dart';

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
}

