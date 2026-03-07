import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/savings_goal.dart';
import 'package:orcamento_mensal/utils/savings_projections.dart';
import 'package:orcamento_mensal/widgets/savings_goal_card.dart';

import '../helpers/test_app.dart';

void main() {
  group('SavingsGoalCard', () {
    testWidgets('shows at most two active goals', (tester) async {
      final goals = [
        SavingsGoal(id: 'g1', name: 'Trip', targetAmount: 1000, currentAmount: 100),
        SavingsGoal(id: 'g2', name: 'Laptop', targetAmount: 1500, currentAmount: 300),
        SavingsGoal(id: 'g3', name: 'Bike', targetAmount: 800, currentAmount: 200),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: SavingsGoalCard(
              goals: goals,
              onSeeAll: () {},
            ),
          ),
        ),
      );

      expect(find.text('Trip'), findsOneWidget);
      expect(find.text('Laptop'), findsOneWidget);
      expect(find.text('Bike'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });

    testWidgets('shows completed fallback when no active goals', (tester) async {
      final goals = [
        SavingsGoal(
          id: 'g1',
          name: 'Emergency Fund',
          targetAmount: 500,
          currentAmount: 500,
          isActive: false,
        ),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: SavingsGoalCard(
              goals: goals,
              onSeeAll: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('Emergency Fund'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows projection warning icon when off-track', (tester) async {
      final goal = SavingsGoal(
        id: 'g1',
        name: 'Vacation',
        targetAmount: 2000,
        currentAmount: 200,
      );

      final projections = {
        'g1': SavingsProjection(
          hasData: true,
          projectedDate: DateTime(2027, 6, 1),
          onTrack: false,
        ),
      };

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: SavingsGoalCard(
              goals: [goal],
              projections: projections,
              onSeeAll: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('see all action is tappable', (tester) async {
      var tapped = false;
      final goals = [
        SavingsGoal(id: 'g1', name: 'Trip', targetAmount: 1000, currentAmount: 100),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: SavingsGoalCard(
              goals: goals,
              onSeeAll: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('See all'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}

