import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/subscription_state.dart';
import '../theme/app_colors.dart';

/// A card that nudges users to explore premium features during their trial.
///
/// Shows the next unexplored feature with a compelling description and CTA.
/// Designed to appear on the dashboard to drive engagement.
class FeatureDiscoveryCard extends StatelessWidget {
  final SubscriptionState subscription;
  final ValueChanged<String> onExploreFeature;
  final VoidCallback onDismiss;

  const FeatureDiscoveryCard({
    super.key,
    required this.subscription,
    required this.onExploreFeature,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final next = subscription.nextFeatureToDiscover;
    if (next == null || !subscription.isTrialActive) {
      return const SizedBox.shrink();
    }

    final info = _featureInfo(context, next);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    info.icon,
                    size: 20,
                    color: AppColors.primary(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Try ${info.name}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        info.tagline,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(Icons.close,
                      size: 18, color: AppColors.textMuted(context)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              info.description,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => onExploreFeature(next),
                icon: Icon(info.icon, size: 16),
                label: Text(S.of(context).featureDiscoveryExplore(info.name)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary(context),
                  side: BorderSide(
                      color: AppColors.primary(context).withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _FeatureInfo _featureInfo(BuildContext context, String key) {
    final l10n = S.of(context);
    switch (key) {
      case 'ai_coach':
        return _FeatureInfo(
          name: l10n.featureAiCoach,
          icon: Icons.psychology_rounded,
          tagline: l10n.featureAiCoachTagline,
          description: l10n.featureAiCoachDesc,
        );
      case 'meal_planner':
        return _FeatureInfo(
          name: l10n.featureMealPlanner,
          icon: Icons.restaurant_rounded,
          tagline: l10n.featureMealPlannerTagline,
          description: l10n.featureMealPlannerDesc,
        );
      case 'expense_tracker':
        return _FeatureInfo(
          name: l10n.featureExpenseTracker,
          icon: Icons.receipt_long_rounded,
          tagline: l10n.featureExpenseTrackerTagline,
          description: l10n.featureExpenseTrackerDesc,
        );
      case 'savings_goals':
        return _FeatureInfo(
          name: l10n.featureSavingsGoals,
          icon: Icons.savings_rounded,
          tagline: l10n.featureSavingsGoalsTagline,
          description: l10n.featureSavingsGoalsDesc,
        );
      case 'shopping_list':
        return _FeatureInfo(
          name: l10n.featureShoppingList,
          icon: Icons.shopping_basket_rounded,
          tagline: l10n.featureShoppingListTagline,
          description: l10n.featureShoppingListDesc,
        );
      case 'grocery_browser':
        return _FeatureInfo(
          name: l10n.featureGroceryBrowser,
          icon: Icons.shopping_cart_rounded,
          tagline: l10n.featureGroceryBrowserTagline,
          description: l10n.featureGroceryBrowserDesc,
        );
      case 'export':
        return _FeatureInfo(
          name: l10n.featureExportReports,
          icon: Icons.download_rounded,
          tagline: l10n.featureExportReportsTagline,
          description: l10n.featureExportReportsDesc,
        );
      case 'tax_simulator':
        return _FeatureInfo(
          name: l10n.featureTaxSimulator,
          icon: Icons.calculate_rounded,
          tagline: l10n.featureTaxSimulatorTagline,
          description: l10n.featureTaxSimulatorDesc,
        );
      default:
        return _FeatureInfo(
          name: l10n.featureDashboard,
          icon: Icons.dashboard_rounded,
          tagline: l10n.featureDashboardTagline,
          description: l10n.featureDashboardDesc,
        );
    }
  }
}

class _FeatureInfo {
  final String name;
  final IconData icon;
  final String tagline;
  final String description;

  const _FeatureInfo({
    required this.name,
    required this.icon,
    required this.tagline,
    required this.description,
  });
}

/// A small lock overlay to show on feature cards that are locked.
class PremiumLockOverlay extends StatelessWidget {
  final Widget child;
  final bool isLocked;
  final VoidCallback onTapLocked;
  final String featureName;

  const PremiumLockOverlay({
    super.key,
    required this.child,
    required this.isLocked,
    required this.onTapLocked,
    this.featureName = 'This feature',
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) return child;

    return GestureDetector(
      onTap: onTapLocked,
      child: Stack(
        children: [
          // Blurred/dimmed content
          Opacity(opacity: 0.4, child: AbsorbPointer(child: child)),
          // Lock overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background(context).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 28,
                      color: AppColors.primary(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$featureName requires Premium',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to upgrade',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
