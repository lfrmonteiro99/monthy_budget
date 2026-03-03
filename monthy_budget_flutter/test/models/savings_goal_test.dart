import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/savings_goal.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('SavingsGoal', () {
    test('progress as fraction clamped 0-1', () {
      final goal = makeSavingsGoal(targetAmount: 1000, currentAmount: 500);
      expect(goal.progress, 0.5);
    });

    test('progress clamped to 1.0 when current exceeds target', () {
      final goal = makeSavingsGoal(targetAmount: 1000, currentAmount: 1500);
      expect(goal.progress, 1.0);
    });

    test('progress is 0 when target is 0', () {
      final goal = makeSavingsGoal(targetAmount: 0, currentAmount: 100);
      expect(goal.progress, 0);
    });

    test('progress is 0 when current is 0', () {
      final goal = makeSavingsGoal(targetAmount: 1000, currentAmount: 0);
      expect(goal.progress, 0.0);
    });

    test('remaining clamped to [0, target]', () {
      // Normal case
      final normal = makeSavingsGoal(targetAmount: 1000, currentAmount: 300);
      expect(normal.remaining, 700.0);

      // When current exceeds target, remaining should be 0
      final exceeded = makeSavingsGoal(targetAmount: 1000, currentAmount: 1500);
      expect(exceeded.remaining, 0.0);

      // When current is 0, remaining should be target
      final zero = makeSavingsGoal(targetAmount: 500, currentAmount: 0);
      expect(zero.remaining, 500.0);
    });

    test('isCompleted when current >= target', () {
      final completed = makeSavingsGoal(targetAmount: 1000, currentAmount: 1000);
      expect(completed.isCompleted, true);

      final exceeded = makeSavingsGoal(targetAmount: 1000, currentAmount: 1500);
      expect(exceeded.isCompleted, true);

      final notDone = makeSavingsGoal(targetAmount: 1000, currentAmount: 999);
      expect(notDone.isCompleted, false);
    });

    group('copyWith', () {
      test('preserves all fields when no args', () {
        final original = makeSavingsGoal(
          deadline: DateTime(2027, 6, 30),
          color: '#FF0000',
        );
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.name, original.name);
        expect(copy.targetAmount, original.targetAmount);
        expect(copy.currentAmount, original.currentAmount);
        expect(copy.deadline, original.deadline);
        expect(copy.color, original.color);
        expect(copy.isActive, original.isActive);
      });

      test('clearDeadline sets deadline to null', () {
        final original = makeSavingsGoal(deadline: DateTime(2027, 12, 31));
        final copy = original.copyWith(clearDeadline: true);
        expect(copy.deadline, isNull);
      });

      test('clearDeadline false does not clear deadline', () {
        final original = makeSavingsGoal(deadline: DateTime(2027, 12, 31));
        final copy = original.copyWith(clearDeadline: false);
        expect(copy.deadline, original.deadline);
      });

      test('updates fields selectively', () {
        final original = makeSavingsGoal();
        final copy = original.copyWith(
          name: 'Vacation',
          targetAmount: 3000,
        );
        expect(copy.name, 'Vacation');
        expect(copy.targetAmount, 3000);
        expect(copy.id, original.id);
      });
    });

    group('fromSupabase', () {
      test('with all fields', () {
        final map = {
          'id': 'sg_100',
          'name': 'Car Fund',
          'target_amount': 15000,
          'current_amount': 5000,
          'deadline': '2027-12-31',
          'color': '#00FF00',
          'is_active': true,
        };

        final goal = SavingsGoal.fromSupabase(map);

        expect(goal.id, 'sg_100');
        expect(goal.name, 'Car Fund');
        expect(goal.targetAmount, 15000.0);
        expect(goal.currentAmount, 5000.0);
        expect(goal.deadline, DateTime(2027, 12, 31));
        expect(goal.color, '#00FF00');
        expect(goal.isActive, true);
      });

      test('with null deadline and color', () {
        final map = {
          'id': 'sg_200',
          'name': 'Savings',
          'target_amount': 1000.0,
          'current_amount': null,
          'deadline': null,
          'color': null,
          'is_active': null,
        };

        final goal = SavingsGoal.fromSupabase(map);

        expect(goal.currentAmount, 0.0);
        expect(goal.deadline, isNull);
        expect(goal.color, isNull);
        expect(goal.isActive, true);
      });

      test('parses amount from int to double', () {
        final map = {
          'id': 'sg_300',
          'name': 'Fund',
          'target_amount': 5000,
          'current_amount': 2000,
        };

        final goal = SavingsGoal.fromSupabase(map);
        expect(goal.targetAmount, isA<double>());
        expect(goal.currentAmount, isA<double>());
      });
    });

    group('toSupabase', () {
      test('date formatting', () {
        final goal = SavingsGoal(
          id: 'sg_fmt',
          name: 'Test',
          targetAmount: 1000,
          currentAmount: 100,
          deadline: DateTime(2027, 1, 5),
          color: '#AABBCC',
          isActive: true,
        );

        final map = goal.toSupabase('hh_1');

        expect(map['id'], 'sg_fmt');
        expect(map['household_id'], 'hh_1');
        expect(map['name'], 'Test');
        expect(map['target_amount'], 1000.0);
        expect(map['current_amount'], 100.0);
        expect(map['deadline'], '2027-01-05');
        expect(map['color'], '#AABBCC');
        expect(map['is_active'], true);
      });

      test('null deadline outputs null', () {
        final goal = makeSavingsGoal();
        final map = goal.toSupabase('hh_2');
        expect(map['deadline'], isNull);
      });
    });
  });

  group('SavingsContribution', () {
    test('fromSupabase parses all fields', () {
      final map = {
        'id': 'sc_1',
        'goal_id': 'sg_1',
        'amount': 250.0,
        'contribution_date': '2026-03-15',
        'note': 'Monthly deposit',
      };

      final contrib = SavingsContribution.fromSupabase(map);

      expect(contrib.id, 'sc_1');
      expect(contrib.goalId, 'sg_1');
      expect(contrib.amount, 250.0);
      expect(contrib.contributionDate, DateTime(2026, 3, 15));
      expect(contrib.note, 'Monthly deposit');
    });

    test('fromSupabase with null note', () {
      final map = {
        'id': 'sc_2',
        'goal_id': 'sg_2',
        'amount': 100,
        'contribution_date': '2026-01-01',
        'note': null,
      };

      final contrib = SavingsContribution.fromSupabase(map);
      expect(contrib.note, isNull);
      expect(contrib.amount, 100.0);
    });

    test('toSupabase includes household_id and formats date', () {
      final contrib = makeContribution(
        contributionDate: DateTime(2026, 2, 14),
        note: 'Valentine deposit',
      );

      final map = contrib.toSupabase('hh_abc');

      expect(map['household_id'], 'hh_abc');
      expect(map['goal_id'], 'sg_1');
      expect(map['contribution_date'], '2026-02-14');
      expect(map['note'], 'Valentine deposit');
    });

    test('toSupabase with null note', () {
      final contrib = makeContribution(note: null);
      final map = contrib.toSupabase('hh_1');
      expect(map['note'], isNull);
    });
  });
}
