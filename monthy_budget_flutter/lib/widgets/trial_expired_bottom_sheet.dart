import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/savings_goal.dart';
import '../services/downgrade_service.dart';
import '../theme/app_colors.dart';

/// Result of the trial-expired bottom sheet interaction.
enum TrialExpiredAction { upgrade, manageCategories, extendTrial, dismiss }

/// Bottom sheet shown once when trial expires and user is downgraded to free.
///
/// Shows what changed (paused categories/goals) and offers options to upgrade,
/// manage categories, or continue on free plan.
class TrialExpiredBottomSheet extends StatelessWidget {
  final List<ExpenseItem> expenses;
  final List<SavingsGoal> savingsGoals;
  final bool isSubscriptionEnd;
  final bool canExtendTrial;

  const TrialExpiredBottomSheet({
    super.key,
    required this.expenses,
    required this.savingsGoals,
    this.isSubscriptionEnd = false,
    this.canExtendTrial = false,
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
                  ? S.of(context).subscriptionEndedTitle
                  : S.of(context).trialExpiredTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              hasExcess ? S.of(context).trialExpiredSubtitleLimits : S.of(context).trialExpiredSubtitleSafe,
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
                        text: S.of(context).trialExpiredCategoriesActive(activeCategories, totalCategories),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          S.of(context).trialExpiredCategoriesPaused(pausedCategories),
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
                        text: S.of(context).trialExpiredGoalsActive(activeGoals, totalGoals),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          S.of(context).trialExpiredGoalsPaused(pausedGoals),
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
                S.of(context).trialExpiredPremiumNote,
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
                child: Text(
                  S.of(context).upgradeToPro,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                  child: Text(
                    S.of(context).trialExpiredManageCategories,
                    style:
                        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],

            // Extend trial button (only if eligible)
            if (canExtendTrial && !isSubscriptionEnd) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context)
                      .pop(TrialExpiredAction.extendTrial),
                  icon: const Icon(Icons.access_time_rounded, size: 18),
                  label: Text(
                    S.of(context).trialExpiredExtend,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary(context),
                    side: BorderSide(
                        color: AppColors.primary(context).withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
                  S.of(context).trialExpiredContinueFree,
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
  bool canExtendTrial = false,
}) {
  return showModalBottomSheet<TrialExpiredAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TrialExpiredBottomSheet(
      expenses: expenses,
      savingsGoals: savingsGoals,
      isSubscriptionEnd: isSubscriptionEnd,
      canExtendTrial: canExtendTrial,
    ),
  );
}
