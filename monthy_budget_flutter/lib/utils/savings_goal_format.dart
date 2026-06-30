import '../l10n/generated/app_localizations.dart';
import '../models/savings_goal.dart';

/// Localized deadline label for a savings goal, or `null` when the goal has no
/// deadline. Returns the overdue string when the deadline is in the past.
String? savingsDeadlineLabel(SavingsGoal goal, S l10n) {
  if (goal.deadline == null) return null;
  final now = DateTime.now();
  final diff = goal.deadline!.difference(
    DateTime(now.year, now.month, now.day),
  );
  if (diff.isNegative) return l10n.savingsGoalOverdue;
  return l10n.savingsGoalDaysLeft('${diff.inDays}');
}

/// Whether the goal's deadline has already passed.
bool savingsGoalIsOverdue(SavingsGoal goal) {
  if (goal.deadline == null) return false;
  return goal.deadline!.isBefore(DateTime.now());
}
