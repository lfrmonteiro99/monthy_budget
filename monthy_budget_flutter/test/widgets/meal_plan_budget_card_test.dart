import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_budget_insight.dart';
import 'package:monthly_management/widgets/meal_plan_budget_card.dart';
import 'package:monthly_management/widgets/meal_budget_status_chip.dart';

import '../helpers/test_app.dart';

MealPlanBudgetInsight _buildInsight({
  required MealBudgetStatus status,
  double weeklyEstimatedCost = 50.0,
  double projectedMonthlySpend = 200.0,
  double monthlyBudget = 300.0,
  double remainingBudget = 100.0,
  List<MealCostEntry> topExpensiveMeals = const [],
  List<MealCostSwap> suggestedSwaps = const [],
}) {
  return MealPlanBudgetInsight(
    weeklyEstimatedCost: weeklyEstimatedCost,
    projectedMonthlySpend: projectedMonthlySpend,
    monthlyBudget: monthlyBudget,
    remainingBudget: remainingBudget,
    status: status,
    topExpensiveMeals: topExpensiveMeals,
    suggestedSwaps: suggestedSwaps,
    shoppingImpact: const ShoppingImpactSummary(
      uniqueIngredients: 5,
      estimatedShoppingCost: 40.0,
    ),
  );
}

void main() {
  group('MealPlanBudgetCard', () {
    testWidgets('renders safe status chip', (tester) async {
      final insight = _buildInsight(status: MealBudgetStatus.safe);
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(body: SingleChildScrollView(
            child: MealPlanBudgetCard(insight: insight),
          )),
        ),
      );
      expect(find.byType(MealBudgetStatusChip), findsOneWidget);
      expect(find.text('On Track'), findsOneWidget);
    });

    testWidgets('renders watch status chip', (tester) async {
      final insight = _buildInsight(status: MealBudgetStatus.watch);
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(body: SingleChildScrollView(
            child: MealPlanBudgetCard(insight: insight),
          )),
        ),
      );
      expect(find.text('Watch'), findsOneWidget);
    });

    testWidgets('renders over budget status chip', (tester) async {
      final insight = _buildInsight(status: MealBudgetStatus.over);
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(body: SingleChildScrollView(
            child: MealPlanBudgetCard(insight: insight),
          )),
        ),
      );
      expect(find.text('Over Budget'), findsOneWidget);
    });

    testWidgets('shows view details button when callback provided', (tester) async {
      bool detailsTapped = false;
      final insight = _buildInsight(status: MealBudgetStatus.safe);
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(body: SingleChildScrollView(
            child: MealPlanBudgetCard(
              insight: insight,
              onViewDetails: () => detailsTapped = true,
            ),
          )),
        ),
      );
      expect(find.text('View details'), findsOneWidget);
      await tester.tap(find.text('View details'));
      expect(detailsTapped, isTrue);
    });

    testWidgets('shows top expensive meals when present', (tester) async {
      final insight = _buildInsight(
        status: MealBudgetStatus.safe,
        topExpensiveMeals: [
          MealCostEntry(
            recipeId: 'a',
            recipeName: 'Expensive Salmon',
            cost: 15.0,
            dayIndex: 1,
            mealType: 'dinner',
          ),
        ],
      );
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(body: SingleChildScrollView(
            child: MealPlanBudgetCard(insight: insight),
          )),
        ),
      );
      expect(find.text('Expensive Salmon'), findsOneWidget);
    });

    testWidgets('displays budget insight title', (tester) async {
      final insight = _buildInsight(status: MealBudgetStatus.safe);
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(body: SingleChildScrollView(
            child: MealPlanBudgetCard(insight: insight),
          )),
        ),
      );
      expect(find.text('Budget Insight'), findsOneWidget);
    });
  });
}
