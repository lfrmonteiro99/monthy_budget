import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../data/tax/tax_system.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class InsightsScreen extends StatelessWidget {
  final AppSettings settings;
  final BudgetSummary summary;
  final VoidCallback onOpenExpenseTrends;
  final VoidCallback onOpenSavingsGoals;
  final VoidCallback onOpenTaxSimulator;

  const InsightsScreen({
    super.key,
    required this.settings,
    required this.summary,
    required this.onOpenExpenseTrends,
    required this.onOpenSavingsGoals,
    required this.onOpenTaxSimulator,
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
          l10n.insightsTitle,
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
          _KpiCard(
            title: l10n.dashboardMonthlyLiquidity,
            value: summary.netLiquidity,
            positive: summary.netLiquidity >= 0,
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.show_chart,
            title: l10n.trendTitle,
            subtitle: l10n.insightsAnalyzeSpending,
            onTap: onOpenExpenseTrends,
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.savings_outlined,
            title: l10n.savingsGoals,
            subtitle: l10n.insightsTrackProgress,
            onTap: onOpenSavingsGoals,
          ),
          if (settings.country == Country.pt) ...[
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.calculate_outlined,
              title: l10n.taxSimTitle,
              subtitle: l10n.insightsTaxOutcome,
              onTap: onOpenTaxSimulator,
            ),
          ],
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final double value;
  final bool positive;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(value),
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: positive ? AppColors.success(context) : AppColors.error(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
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
