import 'package:flutter/material.dart';
import '../models/subscription_state.dart';
import '../theme/app_colors.dart';

/// A nudge card shown during the first 3 days of trial encouraging users
/// to set up enough categories and savings goals so that downgrade friction
/// is maximised (exceeding free-tier limits).
class TrialOnboardingNudge extends StatelessWidget {
  final SubscriptionState subscription;
  final int activeCategories;
  final int activeSavingsGoals;
  final VoidCallback onAddCategories;
  final VoidCallback onAddSavingsGoals;
  final VoidCallback? onDismiss;

  /// Thresholds that create natural downgrade friction.
  static const targetCategories = 9;
  static const targetSavingsGoals = 2;

  /// Only show nudge during the first 3 days of trial.
  static const nudgeWindowDays = 3;

  const TrialOnboardingNudge({
    super.key,
    required this.subscription,
    required this.activeCategories,
    required this.activeSavingsGoals,
    required this.onAddCategories,
    required this.onAddSavingsGoals,
    this.onDismiss,
  });

  /// Whether this nudge should be shown.
  bool get shouldShow {
    if (!subscription.isTrialActive) return false;
    final daysSinceStart =
        DateTime.now().difference(subscription.trialStartDate).inDays;
    if (daysSinceStart >= nudgeWindowDays) return false;
    // Hide if both targets are met.
    return activeCategories < targetCategories ||
        activeSavingsGoals < targetSavingsGoals;
  }

  @override
  Widget build(BuildContext context) {
    if (!shouldShow) return const SizedBox.shrink();

    final categoriesDone = activeCategories >= targetCategories;
    final goalsDone = activeSavingsGoals >= targetSavingsGoals;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.primary(context).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary(context).withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.rocket_launch_rounded,
                  color: AppColors.primary(context),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Get the most out of your trial',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary(context),
                    ),
                  ),
                ),
                if (onDismiss != null)
                  GestureDetector(
                    onTap: onDismiss,
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.textMuted(context),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Set up your budget now so you can experience the full power of premium features.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            if (!categoriesDone)
              _NudgeAction(
                icon: Icons.category_rounded,
                label:
                    'Add more categories ($activeCategories/$targetCategories)',
                onTap: onAddCategories,
              ),
            if (!goalsDone) ...[
              if (!categoriesDone) const SizedBox(height: 8),
              _NudgeAction(
                icon: Icons.savings_rounded,
                label:
                    'Create savings goals ($activeSavingsGoals/$targetSavingsGoals)',
                onTap: onAddSavingsGoals,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NudgeAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NudgeAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary(context)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }
}
