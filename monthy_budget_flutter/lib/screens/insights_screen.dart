import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
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

    return CalmScaffold(
      title: l10n.insightsTitle,
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          // Hero: net liquidity KPI (one CalmHero per screen).
          CalmCard(
            child: CalmHero(
              eyebrow: l10n.dashboardMonthlyLiquidity,
              amount: formatCurrency(summary.netLiquidity),
            ),
          ),
          const SizedBox(height: 16),

          // Action tiles — each wrapped in a tappable CalmCard.
          CalmCard(
            onTap: onOpenExpenseTrends,
            child: CalmListTile(
              leadingIcon: Icons.show_chart,
              leadingColor: AppColors.accent(context),
              title: l10n.trendTitle,
              subtitle: l10n.insightsAnalyzeSpending,
              trailing: '›',
              onTap: onOpenExpenseTrends,
            ),
          ),
          const SizedBox(height: 12),
          CalmCard(
            onTap: onOpenSavingsGoals,
            child: CalmListTile(
              leadingIcon: Icons.savings_outlined,
              leadingColor: AppColors.accent(context),
              title: l10n.savingsGoals,
              subtitle: l10n.insightsTrackProgress,
              trailing: '›',
              onTap: onOpenSavingsGoals,
            ),
          ),
          if (settings.country == Country.pt) ...[
            const SizedBox(height: 12),
            CalmCard(
              onTap: onOpenTaxSimulator,
              child: CalmListTile(
                leadingIcon: Icons.calculate_outlined,
                leadingColor: AppColors.accent(context),
                title: l10n.taxSimTitle,
                subtitle: l10n.insightsTaxOutcome,
                trailing: '›',
                onTap: onOpenTaxSimulator,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
