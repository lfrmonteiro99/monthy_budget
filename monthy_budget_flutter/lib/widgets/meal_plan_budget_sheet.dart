import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/meal_budget_insight.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'meal_budget_status_chip.dart';

/// Opens the meal plan budget detail bottom sheet.
void showMealPlanBudgetSheet({
  required BuildContext context,
  required MealPlanBudgetInsight insight,
  void Function(MealCostSwap swap)? onApplySwap,
}) {
  showModalBottomSheet(
    showDragHandle: true,
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollController) => _MealPlanBudgetSheetContent(
        scrollController: scrollController,
        insight: insight,
        onApplySwap: onApplySwap,
      ),
    ),
  );
}

class _MealPlanBudgetSheetContent extends StatelessWidget {
  final ScrollController scrollController;
  final MealPlanBudgetInsight insight;
  final void Function(MealCostSwap swap)? onApplySwap;

  const _MealPlanBudgetSheetContent({
    required this.scrollController,
    required this.insight,
    this.onApplySwap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        // Title + status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.mealBudgetInsightTitle,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            MealBudgetStatusChip(status: insight.status),
          ],
        ),
        const SizedBox(height: 16),

        // Summary section
        _buildSummarySection(context, l10n),
        const SizedBox(height: 20),

        // Shopping impact
        _buildShoppingImpact(context, l10n),
        const SizedBox(height: 20),

        // Per-day cost breakdown
        if (insight.dailyBreakdown.isNotEmpty) ...[
          Text(
            l10n.mealBudgetDailyBreakdown,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          ...insight.dailyBreakdown.map(
            (day) => _buildDayRow(context, l10n, day),
          ),
          const SizedBox(height: 20),
        ],

        // Top expensive meals
        if (insight.topExpensiveMeals.isNotEmpty) ...[
          Text(
            l10n.mealBudgetTopExpensive,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          ...insight.topExpensiveMeals.map(
            (entry) => _buildExpensiveMealRow(context, entry),
          ),
          const SizedBox(height: 20),
        ],

        // Suggested swaps
        if (insight.suggestedSwaps.isNotEmpty) ...[
          Text(
            l10n.mealBudgetSuggestedSwaps,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          ...insight.suggestedSwaps.map(
            (swap) => _buildSwapRow(context, l10n, swap),
          ),
        ],
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context, S l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          _summaryLine(
            context,
            l10n.mealBudgetWeeklyCost,
            formatCurrency(insight.weeklyEstimatedCost),
          ),
          const SizedBox(height: 8),
          _summaryLine(
            context,
            l10n.mealBudgetProjectedMonthly,
            formatCurrency(insight.projectedMonthlySpend),
          ),
          const SizedBox(height: 8),
          _summaryLine(
            context,
            l10n.mealBudgetMonthlyBudget,
            formatCurrency(insight.monthlyBudget),
          ),
          const SizedBox(height: 8),
          _summaryLine(
            context,
            l10n.mealBudgetRemaining,
            formatCurrency(insight.remainingBudget),
            valueColor: insight.remainingBudget >= 0
                ? AppColors.success(context)
                : AppColors.error(context),
          ),
        ],
      ),
    );
  }

  Widget _summaryLine(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
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

  Widget _buildShoppingImpact(BuildContext context, S l10n) {
    final impact = insight.shoppingImpact;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.infoBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.mealBudgetShoppingImpact,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          _summaryLine(
            context,
            l10n.mealBudgetUniqueIngredients,
            '${impact.uniqueIngredients}',
          ),
          const SizedBox(height: 4),
          _summaryLine(
            context,
            l10n.mealBudgetEstShoppingCost,
            formatCurrency(impact.estimatedShoppingCost),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(
    BuildContext context,
    S l10n,
    DayCostBreakdown day,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              l10n.mealDayLabel(day.dayIndex),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: insight.weeklyEstimatedCost > 0
                      ? (day.totalCost / insight.weeklyEstimatedCost)
                          .clamp(0.0, 1.0)
                      : 0.0,
                  backgroundColor: AppColors.border(context),
                  color: AppColors.primary(context),
                  minHeight: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCurrency(day.totalCost),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensiveMealRow(BuildContext context, MealCostEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.warningBackground(context),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${entry.dayIndex}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.warning(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapRow(
    BuildContext context,
    S l10n,
    MealCostSwap swap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.successBackground(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.success(context).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary(context),
                    ),
                    children: [
                      TextSpan(
                        text: swap.original.recipeName,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const TextSpan(text: '  '),
                      TextSpan(
                        text: swap.alternativeRecipeName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.mealBudgetSwapSavings(
                  formatCurrency(swap.savings),
                ),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success(context),
                ),
              ),
              if (onApplySwap != null)
                TextButton(
                  onPressed: () => onApplySwap!(swap),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.mealBudgetApplySwap,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
