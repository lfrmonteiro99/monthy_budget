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

    test('uses real month-span for contributions spread over ~1.5 months', () {
      // 3 contributions spanning Jan 15 – Feb 28 (≈1.47 months).
      // Bug: divided by hardcoded 3 → 133.33/month (underestimated).
      // Fix: divide by actual span max(1, 1.47) → ≈272/month.
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
      // 400 / 1.467 months ≈ 272/month (not the buggy 400/3 = 133)
      expect(projection.averageMonthlyContribution, greaterThan(250));
      expect(projection.remaining, 900);
      expect(projection.monthsToGoal, lessThan(4));
      expect(projection.requiredMonthlyContribution, isNotNull);
      // avg >> required → on track
      expect(projection.onTrack, isTrue);
    });

    test('same-month contributions use 1-month floor, not 3-month divisor', () {
      // Bug: 2 contributions in Jan → totalRecent/3 = 200/3 ≈ 66.67 (wrong)
      // Fix: span ≈ 15 days → max(1, 0.5) = 1 → avg = 200/1 = 200
      final projection = calculateProjection(
        goal: SavingsGoal(
          id: 'g4',
          name: 'Car',
          targetAmount: 5000,
          currentAmount: 200,
        ),
        contributions: [
          SavingsContribution(
            id: 'c1',
            goalId: 'g4',
            amount: 100,
            contributionDate: DateTime(2026, 1, 5),
          ),
          SavingsContribution(
            id: 'c2',
            goalId: 'g4',
            amount: 100,
            contributionDate: DateTime(2026, 1, 20),
          ),
        ],
        now: DateTime(2026, 2, 1),
      );

      expect(projection.hasData, isTrue);
      // Should not underestimate: avg must be ≥ 100/month (not ≈66.67)
      expect(projection.averageMonthlyContribution, greaterThanOrEqualTo(150));
    });

    test('contributions spread over 2 months use real span', () {
      // Jan 1 + March 1 → span = 59 days ≈ 1.97 months → avg ≈ 101.5 (not 200/3)
      final projection = calculateProjection(
        goal: SavingsGoal(
          id: 'g5',
          name: 'Bike',
          targetAmount: 2000,
          currentAmount: 200,
        ),
        contributions: [
          SavingsContribution(
            id: 'c1',
            goalId: 'g5',
            amount: 100,
            contributionDate: DateTime(2026, 1, 1),
          ),
          SavingsContribution(
            id: 'c2',
            goalId: 'g5',
            amount: 100,
            contributionDate: DateTime(2026, 3, 1),
          ),
        ],
        now: DateTime(2026, 3, 1),
      );

      expect(projection.hasData, isTrue);
      // span ≈ 1.97 months → avg ≈ 101.5 (close to 100, not 66.67)
      expect(projection.averageMonthlyContribution, greaterThan(90));
      expect(projection.averageMonthlyContribution, lessThan(120));
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
