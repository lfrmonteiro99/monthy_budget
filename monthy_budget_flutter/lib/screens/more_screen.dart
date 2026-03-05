import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';

class MoreScreen extends StatelessWidget {
  final VoidCallback onOpenDetailedDashboard;
  final VoidCallback onOpenInsights;
  final VoidCallback onOpenSavingsGoals;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSubscription;

  const MoreScreen({
    super.key,
    required this.onOpenDetailedDashboard,
    required this.onOpenInsights,
    required this.onOpenSavingsGoals,
    required this.onOpenSettings,
    required this.onOpenNotifications,
    required this.onOpenSubscription,
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
          _Tile(
            icon: Icons.workspace_premium_outlined,
            title: 'Subscription',
            subtitle: 'Manage your plan and billing',
            onTap: onOpenSubscription,
          ),
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

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border(context)),
      ),
      leading: Icon(icon, color: AppColors.primary(context)),
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
