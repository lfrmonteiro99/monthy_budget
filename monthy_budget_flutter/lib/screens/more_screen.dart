import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/subscription_state.dart';
import '../services/downgrade_service.dart';
import '../theme/app_colors.dart';

class MoreScreen extends StatelessWidget {
  final VoidCallback onOpenDetailedDashboard;
  final VoidCallback onOpenInsights;
  final VoidCallback onOpenSavingsGoals;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSubscription;
  final VoidCallback? onOpenConfidenceCenter;
  final SubscriptionState? subscription;
  final int pausedItemCount;
  final int confidenceAlertCount;

  const MoreScreen({
    super.key,
    required this.onOpenDetailedDashboard,
    required this.onOpenInsights,
    required this.onOpenSavingsGoals,
    required this.onOpenSettings,
    required this.onOpenNotifications,
    required this.onOpenSubscription,
    this.onOpenConfidenceCenter,
    this.subscription,
    this.pausedItemCount = 0,
    this.confidenceAlertCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        surfaceTintColor: AppColors.surface(context),
        title: Text(
          'More',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _Tile(
            icon: Icons.dashboard_customize_outlined,
            title: 'Detailed Dashboard',
            subtitle: 'Open full financial dashboard with all cards',
            onTap: onOpenDetailedDashboard,
          ),
          const SizedBox(height: 8),
          _Tile(
            icon: Icons.insights_outlined,
            title: 'Insights',
            subtitle: l10n.trendTitle,
            onTap: onOpenInsights,
          ),
          const SizedBox(height: 8),
          _Tile(
            icon: Icons.savings_outlined,
            title: l10n.savingsGoals,
            subtitle: 'Track and update your goal progress',
            onTap: onOpenSavingsGoals,
          ),
          const SizedBox(height: 8),
          _Tile(
            icon: Icons.notifications_outlined,
            title: l10n.notifications,
            subtitle: 'Budgets, bills and reminders',
            onTap: onOpenNotifications,
          ),
          const SizedBox(height: 8),
          _SubscriptionTile(
            subscription: subscription,
            pausedItemCount: pausedItemCount,
            onTap: onOpenSubscription,
          ),
          if (onOpenConfidenceCenter != null) ...[
            const SizedBox(height: 8),
            _Tile(
              icon: Icons.verified_outlined,
              title: l10n.confidenceCenterTile,
              subtitle: l10n.confidenceCenterSubtitle,
              onTap: onOpenConfidenceCenter!,
              badgeCount: confidenceAlertCount,
            ),
          ],
          const SizedBox(height: 8),
          _Tile(
            icon: Icons.settings_outlined,
            title: l10n.settingsTitle,
            subtitle: 'Preferences, profile and dashboard',
            onTap: onOpenSettings,
          ),
        ],
      ),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  final SubscriptionState? subscription;
  final int pausedItemCount;
  final VoidCallback onTap;

  const _SubscriptionTile({
    required this.subscription,
    required this.pausedItemCount,
    required this.onTap,
  });

  String _planLabel() {
    if (subscription == null) return 'Free Plan';
    if (subscription!.isTrialActive) return 'Trial Active';
    switch (subscription!.tier) {
      case SubscriptionTier.premium:
        return 'Pro Plan';
      case SubscriptionTier.family:
        return 'Family Plan';
      case SubscriptionTier.free:
        return 'Free Plan';
    }
  }

  String _planDetails() {
    if (subscription == null || subscription!.hasPremiumAccess) {
      return 'Manage your plan and billing';
    }
    final details = <String>[
      '${DowngradeService.maxFreeCategories} categories',
      '${DowngradeService.maxFreeSavingsGoals} savings goal',
    ];
    return details.join(' \u2022 ');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border(context)),
      ),
      leading:
          Icon(Icons.workspace_premium_outlined, color: AppColors.primary(context)),
      title: Text(
        _planLabel(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(context),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _planDetails(),
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          if (pausedItemCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '$pausedItemCount items paused',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                ),
              ),
            ),
        ],
      ),
      trailing: subscription != null && !subscription!.hasPremiumAccess
          ? Text(
              'Upgrade \u2192',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary(context),
              ),
            )
          : Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
      onTap: onTap,
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int badgeCount;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border(context)),
      ),
      leading: Badge(
        isLabelVisible: badgeCount > 0,
        label: Text('$badgeCount', style: const TextStyle(fontSize: 10)),
        child: Icon(icon, color: AppColors.primary(context)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondary(context)),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
      onTap: onTap,
    );
  }
}
