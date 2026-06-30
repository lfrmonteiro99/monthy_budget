import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/savings_goal.dart';
import '../utils/savings_projections.dart';

/// Savings goals list (#632 increment 4). Storage-only; loading/mutation logic
/// (SavingsGoalService, projection computation) stays in AppHome and calls
/// [set] with the result.
class SavingsGoalsNotifier extends Notifier<List<SavingsGoal>> {
  @override
  List<SavingsGoal> build() => const [];

  void set(List<SavingsGoal> goals) => state = goals;
}

final savingsGoalsProvider =
    NotifierProvider<SavingsGoalsNotifier, List<SavingsGoal>>(
  SavingsGoalsNotifier.new,
);

/// Per-goal savings projections used by the dashboard card.
class SavingsProjectionsNotifier
    extends Notifier<Map<String, SavingsProjection>> {
  @override
  Map<String, SavingsProjection> build() => const {};

  void set(Map<String, SavingsProjection> projections) => state = projections;
}

final savingsProjectionsProvider =
    NotifierProvider<SavingsProjectionsNotifier,
        Map<String, SavingsProjection>>(
  SavingsProjectionsNotifier.new,
);
