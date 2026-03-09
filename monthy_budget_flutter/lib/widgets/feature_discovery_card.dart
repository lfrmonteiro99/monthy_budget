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

    final l10n = S.of(context);
    final info = _featureInfo(next, l10n);

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
                        l10n.featureTryName(info.name),
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
                label: Text(l10n.featureExploreName(info.name)),
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

  _FeatureInfo _featureInfo(String key, S l10n) {
    switch (key) {
      case 'ai_coach':
        return _FeatureInfo(
          name: l10n.featureNameAiCoach,
          icon: Icons.psychology_rounded,
          tagline: l10n.featureTagAiCoach,
          description: l10n.featureDescAiCoach,
        );
      case 'meal_planner':
        return _FeatureInfo(
          name: l10n.featureNameMealPlanner,
          icon: Icons.restaurant_rounded,
          tagline: l10n.featureTagMealPlanner,
          description: l10n.featureDescMealPlanner,
        );
      case 'expense_tracker':
        return _FeatureInfo(
          name: l10n.featureNameExpenseTracker,
          icon: Icons.receipt_long_rounded,
          tagline: l10n.featureTagExpenseTracker,
          description: l10n.featureDescExpenseTracker,
        );
      case 'savings_goals':
        return _FeatureInfo(
          name: l10n.featureNameSavingsGoals,
          icon: Icons.savings_rounded,
          tagline: l10n.featureTagSavingsGoals,
          description: l10n.featureDescSavingsGoals,
        );
      case 'shopping_list':
        return _FeatureInfo(
          name: l10n.featureNameShoppingList,
          icon: Icons.shopping_basket_rounded,
          tagline: l10n.featureTagShoppingList,
          description: l10n.featureDescShoppingList,
        );
      case 'grocery_browser':
        return _FeatureInfo(
          name: l10n.featureNameGroceryBrowser,
          icon: Icons.shopping_cart_rounded,
          tagline: l10n.featureTagGroceryBrowser,
          description: l10n.featureDescGroceryBrowser,
        );
      case 'export':
        return _FeatureInfo(
          name: l10n.featureNameExportReports,
          icon: Icons.download_rounded,
          tagline: l10n.featureTagExportReports,
          description: l10n.featureDescExportReports,
        );
      case 'tax_simulator':
        return _FeatureInfo(
          name: l10n.featureNameTaxSimulator,
          icon: Icons.calculate_rounded,
          tagline: l10n.featureTagTaxSimulator,
          description: l10n.featureDescTaxSimulator,
        );
      default:
        return _FeatureInfo(
          name: l10n.featureNameDashboard,
          icon: Icons.dashboard_rounded,
          tagline: l10n.featureTagDashboard,
          description: l10n.featureDescDashboard,
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

    final l10n = S.of(context);
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
                    l10n.featureRequiresPremium(featureName),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.featureTapToUpgrade,
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
