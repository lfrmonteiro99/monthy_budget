import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/savings_goal.dart';
import 'package:monthly_management/utils/savings_projections.dart';

void main() {
  group('calculateProjection', () {
    test('returns immediate completion projection when goal is completed', () {
      final projection = calculateProjection(
        goal: SavingsGoal(
          id: 'g1',
          name: 'Emergency',
          targetAmount: 1000,
          currentAmount: 1000,
        ),
        contributions: const [],
        now: DateTime(2026, 3, 1),
      );

      expect(projection.remaining, 0);
      expect(projection.hasData, isTrue);
      expect(projection.projectedDate, DateTime(2026, 3, 1));
    });

    test('uses contribution average and computes deadline status', () {
      final projection = calculateProjection(
        goal: SavingsGoal(
          id: 'g2',
          name: 'Trip',
          targetAmount: 1200,
          currentAmount: 300,
          deadline: DateTime(2026, 9, 1),
        ),
        contributions: [
          SavingsContribution(
            id: 'c1',
            goalId: 'g2',
            amount: 100,
            contributionDate: DateTime(2026, 1, 15),
          ),
          SavingsContribution(
            id: 'c2',
            goalId: 'g2',
            amount: 150,
            contributionDate: DateTime(2026, 2, 15),
          ),
          SavingsContribution(
            id: 'c3',
            goalId: 'g2',
            amount: 150,
            contributionDate: DateTime(2026, 2, 28),
          ),
        ],
        now: DateTime(2026, 3, 1),
      );

      expect(projection.hasData, isTrue);
      expect(projection.averageMonthlyContribution, closeTo(133.33, 0.2));
      expect(projection.remaining, 900);
      expect(projection.monthsToGoal, greaterThan(6.5));
      expect(projection.requiredMonthlyContribution, isNotNull);
      expect(projection.onTrack, isFalse);
    });

    test('returns required monthly amount when no contribution history exists', () {
      final projection = calculateProjection(
        goal: SavingsGoal(
          id: 'g3',
          name: 'Laptop',
          targetAmount: 1800,
          currentAmount: 300,
          deadline: DateTime(2026, 12, 1),
        ),
        contributions: const [],
        now: DateTime(2026, 3, 1),
      );

      expect(projection.hasData, isFalse);
      expect(projection.averageMonthlyContribution, 0);
      expect(projection.remaining, 1500);
      expect(projection.requiredMonthlyContribution, greaterThan(0));
    });
  });
}
