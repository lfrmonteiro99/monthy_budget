import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/subscription_state.dart';
import '../services/downgrade_service.dart';
import '../theme/app_colors.dart';

class MoreScreen extends StatelessWidget {
  final VoidCallback onOpenInsights;
  final VoidCallback onOpenSavingsGoals;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSubscription;
  final VoidCallback? onOpenConfidenceCenter;
  final VoidCallback onOpenProductUpdates;
  final SubscriptionState? subscription;
  final int pausedItemCount;
  final int confidenceAlertCount;

  const MoreScreen({
    super.key,
    required this.onOpenInsights,
    required this.onOpenSavingsGoals,
    required this.onOpenSettings,
    required this.onOpenNotifications,
    required this.onOpenSubscription,
    this.onOpenConfidenceCenter,
    required this.onOpenProductUpdates,
    this.subscription,
    this.pausedItemCount = 0,
    this.confidenceAlertCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return CalmScaffold(
      title: l10n.moreTitle,
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          CalmCard(
            onTap: onOpenInsights,
            child: CalmListTile(
              leadingIcon: Icons.insights_outlined,
              leadingColor: AppColors.accent(context),
              title: l10n.insightsTitle,
              subtitle: l10n.trendTitle,
              trailing: '›',
              onTap: onOpenInsights,
            ),
          ),
          const SizedBox(height: 12),
          CalmCard(
            onTap: onOpenSavingsGoals,
            child: CalmListTile(
              leadingIcon: Icons.savings_outlined,
              leadingColor: AppColors.accent(context),
              title: l10n.savingsGoals,
              subtitle: l10n.moreSavingsSubtitle,
              trailing: '›',
              onTap: onOpenSavingsGoals,
            ),
          ),
          const SizedBox(height: 12),
          CalmCard(
            onTap: onOpenNotifications,
            child: CalmListTile(
              leadingIcon: Icons.notifications_outlined,
              leadingColor: AppColors.accent(context),
              title: l10n.notifications,
              subtitle: l10n.moreNotificationsSubtitle,
              trailing: '›',
              onTap: onOpenNotifications,
            ),
          ),
          const SizedBox(height: 12),
          _SubscriptionCard(
            subscription: subscription,
            pausedItemCount: pausedItemCount,
            onTap: onOpenSubscription,
          ),
          if (onOpenConfidenceCenter != null) ...[
            const SizedBox(height: 12),
            CalmCard(
              onTap: onOpenConfidenceCenter,
              child: CalmListTile(
                leadingIcon: Icons.verified_outlined,
                leadingColor: AppColors.accent(context),
                title: l10n.confidenceCenterTile,
                subtitle: l10n.confidenceCenterSubtitle,
                trailing: confidenceAlertCount > 0
                    ? '$confidenceAlertCount  ›'
                    : '›',
                onTap: onOpenConfidenceCenter,
              ),
            ),
          ],
          const SizedBox(height: 12),
          CalmCard(
            onTap: onOpenProductUpdates,
            child: CalmListTile(
              leadingIcon: Icons.new_releases_outlined,
              leadingColor: AppColors.accent(context),
              title: l10n.productUpdatesTitle,
              subtitle: l10n.productUpdatesSubtitle,
              trailing: '›',
              onTap: onOpenProductUpdates,
            ),
          ),
          const SizedBox(height: 12),
          CalmCard(
            onTap: onOpenSettings,
            child: CalmListTile(
              leadingIcon: Icons.settings_outlined,
              leadingColor: AppColors.accent(context),
              title: l10n.settingsTitle,
              subtitle: l10n.moreSettingsSubtitle,
              trailing: '›',
              onTap: onOpenSettings,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionState? subscription;
  final int pausedItemCount;
  final VoidCallback onTap;

  const _SubscriptionCard({
    required this.subscription,
    required this.pausedItemCount,
    required this.onTap,
  });

  String _planLabel(S l10n) {
    if (subscription == null) return l10n.morePlanFree;
    if (subscription!.isTrialActive) return l10n.morePlanTrial;
    switch (subscription!.tier) {
      case SubscriptionTier.premium:
        return l10n.morePlanPro;
      case SubscriptionTier.family:
        return l10n.morePlanFamily;
      case SubscriptionTier.free:
        return l10n.morePlanFree;
    }
  }

  String _subtitle(S l10n) {
    final base = (subscription == null || subscription!.hasPremiumAccess)
        ? l10n.morePlanManage
        : l10n.morePlanLimits(
            DowngradeService.maxFreeCategories,
            DowngradeService.maxFreeSavingsGoals,
          );
    if (pausedItemCount > 0) {
      return '$base\n${l10n.moreItemsPaused(pausedItemCount)}';
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final showsUpgrade =
        subscription != null && !subscription!.hasPremiumAccess;
    return CalmCard(
      onTap: onTap,
      child: CalmListTile(
        leadingIcon: Icons.workspace_premium_outlined,
        leadingColor: AppColors.accent(context),
        title: _planLabel(l10n),
        subtitle: _subtitle(l10n),
        trailing: showsUpgrade ? '${l10n.moreUpgrade}  ›' : '›',
        onTap: onTap,
      ),
    );
  }
}
