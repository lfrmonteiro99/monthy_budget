import '../models/app_settings.dart';
import '../models/savings_goal.dart';

/// Handles deactivation of items that exceed free-tier limits when a user
/// transitions from trial/premium to the free plan.
class DowngradeService {
  static const maxFreeCategories = 8;
  static const maxFreeSavingsGoals = 1;

  /// Apply free-tier limits by pausing excess categories and savings goals.
  ///
  /// Returns `true` if any items were paused.
  Future<bool> applyFreeTierLimits({
    required AppSettings settings,
    required List<SavingsGoal> goals,
    required void Function(AppSettings) onSaveSettings,
    required String householdId,
    required Future<void> Function(SavingsGoal goal, String householdId)
    onSaveGoal,
  }) async {
    bool changed = false;

    // Categories: keep first N enabled ones, pause the rest
    final expenses = List<ExpenseItem>.from(settings.expenses);
    int activeCount = 0;
    for (int i = 0; i < expenses.length; i++) {
      if (expenses[i].enabled) {
        activeCount++;
        if (activeCount > maxFreeCategories) {
          expenses[i] = expenses[i].copyWith(enabled: false);
          changed = true;
        }
      }
    }
    if (changed) {
      onSaveSettings(settings.copyWith(expenses: expenses));
    }

    // Savings goals: keep first active one, pause the rest
    final activeGoals = <int>[];
    for (int i = 0; i < goals.length; i++) {
      if (goals[i].isActive) activeGoals.add(i);
    }
    if (activeGoals.length > maxFreeSavingsGoals) {
      for (int i = maxFreeSavingsGoals; i < activeGoals.length; i++) {
        final goal = goals[activeGoals[i]].copyWith(isActive: false);
        await onSaveGoal(goal, householdId);
        changed = true;
      }
    }

    return changed;
  }

  /// Count how many active categories exceed the free limit.
  static int excessCategories(List<ExpenseItem> expenses) {
    final active = expenses.where((e) => e.enabled).length;
    return (active - maxFreeCategories).clamp(0, active);
  }

  /// Count how many active savings goals exceed the free limit.
  static int excessSavingsGoals(List<SavingsGoal> goals) {
    final active = goals.where((g) => g.isActive).length;
    return (active - maxFreeSavingsGoals).clamp(0, active);
  }

  /// Whether the user has items exceeding free-tier limits.
  static bool hasExcessItems(
    List<ExpenseItem> expenses,
    List<SavingsGoal> goals,
  ) {
    return excessCategories(expenses) > 0 || excessSavingsGoals(goals) > 0;
  }

  /// Total number of active categories.
  static int activeCategories(List<ExpenseItem> expenses) {
    return expenses.where((e) => e.enabled).length;
  }

  /// Total number of active savings goals.
  static int activeSavingsGoals(List<SavingsGoal> goals) {
    return goals.where((g) => g.isActive).length;
  }

  /// Number of paused categories.
  static int pausedCategories(List<ExpenseItem> expenses) {
    return expenses.where((e) => !e.enabled).length;
  }

  /// Number of paused savings goals.
  static int pausedSavingsGoals(List<SavingsGoal> goals) {
    return goals.where((g) => !g.isActive).length;
  }
}
