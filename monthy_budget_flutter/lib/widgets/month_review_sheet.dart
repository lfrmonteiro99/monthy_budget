import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/month_review.dart';
import '../utils/formatters.dart';

void showMonthReviewSheet({
  required BuildContext context,
  required MonthReviewResult review,
  VoidCallback? onAskAI,
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
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => _MonthReviewContent(
        scrollController: scrollController,
        review: review,
        onAskAI: onAskAI,
      ),
    ),
  );
}

class _MonthReviewContent extends StatelessWidget {
  final ScrollController scrollController;
  final MonthReviewResult review;
  final VoidCallback? onAskAI;

  const _MonthReviewContent({
    required this.scrollController,
    required this.review,
    this.onAskAI,
  });

  @override
  Widget build(BuildContext context) {
    final isOver = review.totalDifference > 0;
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Center(
          child: Container(
            width: 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.dragHandle(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Text(
          S.of(context).monthReviewTitle(review.monthLabel),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),

        // Totals
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _stat(context, S.of(context).monthReviewPlanned, formatCurrency(review.totalPlanned), AppColors.textSecondary(context))),
                  Expanded(child: _stat(context, S.of(context).monthReviewActual, formatCurrency(review.totalActual), AppColors.textPrimary(context))),
                  Expanded(
                    child: _stat(
                      context,
                      S.of(context).monthReviewDifference,
                      '${isOver ? '+' : ''}${formatCurrency(review.totalDifference)}',
                      isOver ? AppColors.error(context) : AppColors.success(context),
                    ),
                  ),
                ],
              ),
              if (review.foodBudget > 0) ...[
                Divider(height: 24, color: AppColors.border(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.of(context).monthReviewFood, style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context))),
                    Text(
                      S.of(context).monthReviewFoodValue(formatCurrency(review.foodActual), formatCurrency(review.foodBudget)),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: review.foodActual > review.foodBudget
                            ? AppColors.error(context)
                            : AppColors.success(context),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Top deviations
        if (review.deviations.isNotEmpty) ...[
          Text(
            S.of(context).monthReviewTopDeviations,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted(context), letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          ...review.deviations.take(3).map((d) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          Text(
                            '${formatCurrency(d.planned)} \u2192 ${formatCurrency(d.actual)}',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${d.difference > 0 ? '+' : ''}${formatCurrency(d.difference)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: d.difference > 0 ? AppColors.error(context) : AppColors.success(context),
                          ),
                        ),
                        Text(
                          '${d.difference > 0 ? '+' : ''}${(d.percentChange * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
        ],

        // Suggestions
        Text(
          S.of(context).monthReviewSuggestions,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted(context), letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        ...review.suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\u2022 ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context))),
                  Expanded(
                    child: Text(s, style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context))),
                  ),
                ],
              ),
            )),

        // AI button
        if (onAskAI != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAskAI,
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: Text(S.of(context).monthReviewAiAnalysis),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary(context),
                side: BorderSide(color: AppColors.infoBorder(context)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _stat(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context))),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
