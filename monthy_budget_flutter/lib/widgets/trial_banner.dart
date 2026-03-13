import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/subscription_state.dart';
import '../theme/app_colors.dart';

/// A banner shown during the trial period with countdown and progress.
///
/// Adapts its message based on trial phase:
/// - Days 1-11: Welcoming, highlights features to try
/// - Days 12-18: Shows exploration progress, nudges premium features
/// - Days 19-21: Urgency — trial ending soon
class TrialBanner extends StatelessWidget {
  final SubscriptionState subscription;
  final VoidCallback onUpgrade;
  final VoidCallback? onDismiss;

  const TrialBanner({
    super.key,
    required this.subscription,
    required this.onUpgrade,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (!subscription.isTrialActive) return const SizedBox.shrink();

    final l10n = S.of(context);
    final daysLeft = subscription.trialDaysRemaining;
    final isUrgent = daysLeft <= 3;
    final isMidTrial = daysLeft <= 10 && daysLeft > 3;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUrgent
              ? [
                  AppColors.error(context).withValues(alpha: 0.15),
                  AppColors.warning(context).withValues(alpha: 0.1),
                ]
              : [
                  AppColors.primary(context).withValues(alpha: 0.12),
                  AppColors.primary(context).withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUrgent
              ? AppColors.error(context).withValues(alpha: 0.3)
              : AppColors.primary(context).withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(
                  isUrgent ? Icons.timer : Icons.star_rounded,
                  color: isUrgent
                      ? AppColors.error(context)
                      : AppColors.primary(context),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _headline(l10n, daysLeft, isUrgent, isMidTrial),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isUrgent
                          ? AppColors.error(context)
                          : AppColors.primary(context),
                    ),
                  ),
                ),
                if (onDismiss != null && !isUrgent)
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
            const SizedBox(height: 8),

            // Subtitle
            Text(
              _subtitle(l10n, daysLeft, isUrgent, isMidTrial, subscription),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Progress bar (features explored)
            if (!isUrgent) ...[
              Row(
                children: [
                  Text(
                    l10n.trialFeaturesExplored(
                      subscription.featuresExploredCount,
                      SubscriptionState.discoverableFeatures.length,
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.trialDaysRemaining(daysLeft),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isMidTrial
                          ? AppColors.warning(context)
                          : AppColors.textMuted(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Semantics(
                label: l10n.trialProgressLabel((subscription.explorationProgress * 100).round()),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: subscription.explorationProgress,
                    backgroundColor: AppColors.border(context),
                    valueColor: AlwaysStoppedAnimation(
                      AppColors.primary(context),
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // CTA button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUrgent
                      ? AppColors.error(context)
                      : AppColors.primary(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isUrgent ? l10n.trialUpgradeNow : l10n.trialSeePlans,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _headline(S l10n, int daysLeft, bool isUrgent, bool isMidTrial) {
    if (isUrgent) {
      return daysLeft <= 1
          ? l10n.trialLastDay
          : l10n.trialDaysLeftInTrial(daysLeft);
    }
    if (isMidTrial) {
      return l10n.trialHalfway;
    }
    return l10n.trialPremiumActive;
  }

  String _subtitle(S l10n, int daysLeft, bool isUrgent, bool isMidTrial,
      SubscriptionState sub) {
    if (isUrgent) {
      return l10n.trialSubtitleUrgent;
    }
    if (isMidTrial) {
      final next = sub.nextFeatureToDiscover;
      if (next != null) {
        return l10n.trialSubtitleMidFeature(_featureName(next, l10n));
      }
      return l10n.trialSubtitleMidProgress;
    }
    return l10n.trialSubtitleEarly;
  }

  String _featureName(String key, S l10n) {
    switch (key) {
      case 'ai_coach':
        return l10n.featureNameAiCoachFull;
      case 'meal_planner':
        return l10n.featureNameMealPlanner;
      case 'expense_tracker':
        return l10n.featureNameExpenseTracker;
      case 'savings_goals':
        return l10n.featureNameSavingsGoals;
      case 'export':
        return l10n.featureNameExportReports;
      case 'tax_simulator':
        return l10n.featureNameTaxSimulator;
      case 'shopping_list':
        return l10n.featureNameShoppingList;
      case 'grocery_browser':
        return l10n.featureNameGroceryBrowser;
      default:
        return key;
    }
  }
}
