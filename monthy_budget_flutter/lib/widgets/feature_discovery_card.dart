import 'package:flutter/material.dart';
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

    final info = _featureInfo(next);

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
                label: Text('Explore ${info.name}'),
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

  _FeatureInfo _featureInfo(String key) {
    switch (key) {
      case 'ai_coach':
        return _FeatureInfo(
          name: 'AI Coach',
          icon: Icons.psychology_rounded,
          tagline: 'Your personal financial advisor',
          description:
              'Get personalized insights about your spending habits, savings tips, and budget optimization powered by AI.',
        );
      case 'meal_planner':
        return _FeatureInfo(
          name: 'Meal Planner',
          icon: Icons.restaurant_rounded,
          tagline: 'Save money on food',
          description:
              'Plan weekly meals within your budget. AI generates recipes based on your preferences and dietary needs.',
        );
      case 'expense_tracker':
        return _FeatureInfo(
          name: 'Expense Tracker',
          icon: Icons.receipt_long_rounded,
          tagline: 'Know where every euro goes',
          description:
              'Track actual expenses vs. your budget in real-time. See where you\'re overspending and where you can save.',
        );
      case 'savings_goals':
        return _FeatureInfo(
          name: 'Savings Goals',
          icon: Icons.savings_rounded,
          tagline: 'Make your dreams happen',
          description:
              'Set savings goals with deadlines, track contributions, and see projections for when you\'ll reach your targets.',
        );
      case 'shopping_list':
        return _FeatureInfo(
          name: 'Shopping List',
          icon: Icons.shopping_basket_rounded,
          tagline: 'Shop smarter together',
          description:
              'Create shared shopping lists that sync in real-time. Check items off as you shop, finalize and track spending.',
        );
      case 'grocery_browser':
        return _FeatureInfo(
          name: 'Grocery Browser',
          icon: Icons.shopping_cart_rounded,
          tagline: 'Compare prices instantly',
          description:
              'Browse products from multiple stores, compare prices, and add the best deals directly to your shopping list.',
        );
      case 'export':
        return _FeatureInfo(
          name: 'Export Reports',
          icon: Icons.download_rounded,
          tagline: 'Professional budget reports',
          description:
              'Export your budget, expenses, and financial summaries as PDF or CSV for your records or accountant.',
        );
      case 'tax_simulator':
        return _FeatureInfo(
          name: 'Tax Simulator',
          icon: Icons.calculate_rounded,
          tagline: 'Multi-country tax planning',
          description:
              'Compare tax obligations across countries. Perfect for expats and anyone considering relocation.',
        );
      default:
        return _FeatureInfo(
          name: 'Dashboard',
          icon: Icons.dashboard_rounded,
          tagline: 'Your financial overview',
          description:
              'See your complete budget breakdown, charts, and financial health at a glance.',
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
