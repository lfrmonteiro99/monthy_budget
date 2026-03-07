import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/savings_goal.dart';
import '../services/downgrade_service.dart';
import '../theme/app_colors.dart';

/// Result of the trial-expired bottom sheet interaction.
enum TrialExpiredAction { upgrade, manageCategories, dismiss }

/// Bottom sheet shown once when trial expires and user is downgraded to free.
///
/// Shows what changed (paused categories/goals) and offers options to upgrade,
/// manage categories, or continue on free plan.
class TrialExpiredBottomSheet extends StatelessWidget {
  final List<ExpenseItem> expenses;
  final List<SavingsGoal> savingsGoals;
  final bool isSubscriptionEnd;

  const TrialExpiredBottomSheet({
    super.key,
    required this.expenses,
    required this.savingsGoals,
    this.isSubscriptionEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalCategories = expenses.length;
    final activeCategories = DowngradeService.activeCategories(expenses);
    final pausedCategories = DowngradeService.pausedCategories(expenses);

    final totalGoals = savingsGoals.length;
    final activeGoals = DowngradeService.activeSavingsGoals(savingsGoals);
    final pausedGoals = DowngradeService.pausedSavingsGoals(savingsGoals);

    final hasExcess = pausedCategories > 0 || pausedGoals > 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dragHandle(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Icon
            Icon(
              Icons.info_outline,
              size: 32,
              color: AppColors.primary(context),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              isSubscriptionEnd
                  ? 'Your subscription has ended'
                  : 'Your free trial has ended',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Your data is safe. ${hasExcess ? "We've adjusted some limits for the free plan:" : "Premium features like AI Coach, Meal Planner, and Export are now available with a subscription."}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),

            // Affected items box (only if there are excess items)
            if (hasExcess) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warningBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pausedCategories > 0) ...[
                      _AffectedItemRow(
                        text:
                            '$activeCategories of $totalCategories categories active',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          '$pausedCategories categories paused',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                      ),
                    ],
                    if (pausedGoals > 0) ...[
                      if (pausedCategories > 0) const SizedBox(height: 8),
                      _AffectedItemRow(
                        text:
                            '$activeGoals of $totalGoals savings goals active',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          '$pausedGoals savings goals paused',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Premium features like AI Coach, Meal Planner, and Export are now available with a subscription.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Upgrade button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pop(TrialExpiredAction.upgrade),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  foregroundColor: AppColors.onPrimary(context),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Upgrade to Pro',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            // Manage categories button (only if excess)
            if (hasExcess) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context)
                      .pop(TrialExpiredAction.manageCategories),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary(context),
                    side: BorderSide(color: AppColors.border(context)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Manage My Categories',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Continue with free plan
            Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(TrialExpiredAction.dismiss),
                child: Text(
                  'Continue with Free Plan',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AffectedItemRow extends StatelessWidget {
  final String text;
  const _AffectedItemRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textSecondary(context),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}

/// Show the trial-expired bottom sheet and return the user's action.
Future<TrialExpiredAction?> showTrialExpiredBottomSheet({
  required BuildContext context,
  required List<ExpenseItem> expenses,
  required List<SavingsGoal> savingsGoals,
  bool isSubscriptionEnd = false,
}) {
  return showModalBottomSheet<TrialExpiredAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TrialExpiredBottomSheet(
      expenses: expenses,
      savingsGoals: savingsGoals,
      isSubscriptionEnd: isSubscriptionEnd,
    ),
  );
}
