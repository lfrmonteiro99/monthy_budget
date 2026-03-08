import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/meal_budget_insight.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'meal_budget_status_chip.dart';

class MealPlanBudgetCard extends StatelessWidget {
  final MealPlanBudgetInsight insight;
  final VoidCallback? onViewDetails;
  final void Function(MealCostSwap swap)? onApplySwap;

  const MealPlanBudgetCard({
    super.key,
    required this.insight,
    this.onViewDetails,
    this.onApplySwap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row: title + status chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.mealBudgetInsightTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              MealBudgetStatusChip(status: insight.status),
            ],
          ),
          const SizedBox(height: 12),

          // Budget summary row
          _SummaryRow(
            label: l10n.mealBudgetWeeklyCost,
            value: formatCurrency(insight.weeklyEstimatedCost),
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: l10n.mealBudgetProjectedMonthly,
            value: formatCurrency(insight.projectedMonthlySpend),
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: l10n.mealBudgetRemaining,
            value: formatCurrency(insight.remainingBudget),
            valueColor: insight.remainingBudget >= 0
                ? AppColors.success(context)
                : AppColors.error(context),
          ),
          const SizedBox(height: 12),

          // Budget progress bar
          _buildProgressBar(context),
          const SizedBox(height: 12),

          // Top expensive meals (compact)
          if (insight.topExpensiveMeals.isNotEmpty) ...[
            Text(
              l10n.mealBudgetTopExpensive,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 6),
            ...insight.topExpensiveMeals.take(3).map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.recipeName,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          formatCurrency(entry.cost),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 8),
          ],

          // Action buttons
          Row(
            children: [
              if (onViewDetails != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary(context),
                      side: BorderSide(color: AppColors.primary(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      l10n.mealBudgetViewDetails,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final usage = insight.budgetUsagePercent.clamp(0.0, 1.5);
    final displayFraction = (usage / 1.5).clamp(0.0, 1.0);
    final Color barColor;
    switch (insight.status) {
      case MealBudgetStatus.safe:
        barColor = AppColors.success(context);
      case MealBudgetStatus.watch:
        barColor = AppColors.warning(context);
      case MealBudgetStatus.over:
        barColor = AppColors.error(context);
    }

    return Column(
      children: [
        SizedBox(
          height: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: displayFraction,
              backgroundColor: AppColors.border(context),
              color: barColor,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(usage * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: barColor,
              ),
            ),
            Text(
              formatCurrency(insight.monthlyBudget),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary(context),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}
