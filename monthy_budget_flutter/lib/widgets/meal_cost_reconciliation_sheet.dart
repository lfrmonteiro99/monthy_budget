import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/meal_planner.dart';
import '../models/purchase_record.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../l10n/generated/app_localizations.dart';

/// Opens the meal cost reconciliation bottom sheet.
void showMealCostReconciliationSheet({
  required BuildContext context,
  required List<MealDay> mealDays,
  required PurchaseHistory purchaseHistory,
  required int year,
  required int month,
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
      initialChildSize: 0.65,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => MealCostReconciliationSheet(
        scrollController: scrollController,
        mealDays: mealDays,
        purchaseHistory: purchaseHistory,
        year: year,
        month: month,
      ),
    ),
  );
}

class MealCostReconciliationSheet extends StatelessWidget {
  final ScrollController scrollController;
  final List<MealDay> mealDays;
  final PurchaseHistory purchaseHistory;
  final int year;
  final int month;

  const MealCostReconciliationSheet({
    super.key,
    required this.scrollController,
    required this.mealDays,
    required this.purchaseHistory,
    required this.year,
    required this.month,
  });

  static int weekOfMonth(DateTime date) => (date.day - 1) ~/ 7;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final weekCount = weekOfMonth(DateTime(year, month, daysInMonth)) + 1;

    // Estimated per week from meal plan
    final estimatedPerWeek = List<double>.filled(weekCount, 0.0);
    for (final day in mealDays) {
      final weekIdx = day.dayIndex ~/ 7;
      if (weekIdx < weekCount) {
        estimatedPerWeek[weekIdx] += day.costEstimate;
      }
    }

    // Actual per week from purchase records flagged as meal purchases
    final actualPerWeek = List<double>.filled(weekCount, 0.0);
    for (final record in purchaseHistory.records) {
      if (!record.isMealPurchase) continue;
      if (record.date.year != year || record.date.month != month) continue;
      final weekIdx = weekOfMonth(record.date);
      if (weekIdx < weekCount) {
        actualPerWeek[weekIdx] += record.amount;
      }
    }

    final totalEstimated = estimatedPerWeek.fold(0.0, (s, v) => s + v);
    final totalActual = actualPerWeek.fold(0.0, (s, v) => s + v);
    final hasData = totalEstimated > 0 || totalActual > 0;
    final maxValue = _maxAcrossWeeks(estimatedPerWeek, actualPerWeek);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.dragHandle(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Text(
          l10n.mealCostReconciliation,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        _buildLegend(context, l10n),
        const SizedBox(height: 20),
        if (!hasData)
          _buildNoData(context, l10n)
        else ...[
          for (var w = 0; w < weekCount; w++)
            _buildWeekRow(
              context,
              l10n,
              weekIndex: w,
              estimated: estimatedPerWeek[w],
              actual: actualPerWeek[w],
              maxValue: maxValue,
            ),
          const SizedBox(height: 8),
          _buildTotalRow(context, l10n, totalEstimated, totalActual, maxValue),
          const SizedBox(height: 16),
          _buildSummaryBadge(context, l10n, totalEstimated, totalActual),
        ],
      ],
    );
  }

  Widget _buildLegend(BuildContext context, S l10n) {
    return Row(
      children: [
        _legendDot(context, AppColors.primary(context), l10n.mealCostEstimated),
        const SizedBox(width: 16),
        _legendDot(context, AppColors.success(context), l10n.mealCostActual),
      ],
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildNoData(BuildContext context, S l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Text(
        l10n.mealCostNoData,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textMuted(context),
        ),
      ),
    );
  }

  Widget _buildWeekRow(
    BuildContext context,
    S l10n, {
    required int weekIndex,
    required double estimated,
    required double actual,
    required double maxValue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.mealCostWeek('${weekIndex + 1}'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              _weekStatusLabel(context, l10n, estimated, actual),
            ],
          ),
          const SizedBox(height: 6),
          _comparisonBar(
            context,
            estimated: estimated,
            actual: actual,
            maxValue: maxValue,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatCurrency(estimated),
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                formatCurrency(actual),
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.success(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    S l10n,
    double totalEstimated,
    double totalActual,
    double maxValue,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.mealCostTotal,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          _comparisonBar(
            context,
            estimated: totalEstimated,
            actual: totalActual,
            maxValue: maxValue,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatCurrency(totalEstimated),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                formatCurrency(totalActual),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.success(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _comparisonBar(
    BuildContext context, {
    required double estimated,
    required double actual,
    required double maxValue,
  }) {
    final barMax = maxValue > 0 ? maxValue : 1.0;
    final estFraction = (estimated / barMax).clamp(0.0, 1.0);
    final actFraction = (actual / barMax).clamp(0.0, 1.0);

    return Column(
      children: [
        _singleBar(context, fraction: estFraction, color: AppColors.primary(context)),
        const SizedBox(height: 3),
        _singleBar(context, fraction: actFraction, color: AppColors.success(context)),
      ],
    );
  }

  Widget _singleBar(
    BuildContext context, {
    required double fraction,
    required Color color,
  }) {
    return SizedBox(
      height: 8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth * fraction;
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: math.max(barWidth, fraction > 0 ? 4 : 0),
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _weekStatusLabel(
    BuildContext context,
    S l10n,
    double estimated,
    double actual,
  ) {
    if (estimated == 0 && actual == 0) {
      return const SizedBox.shrink();
    }

    final diff = actual - estimated;
    final String label;
    final Color color;

    if (diff.abs() < 0.01 * estimated || (estimated == 0 && actual == 0)) {
      label = l10n.mealCostOnTrack;
      color = AppColors.success(context);
    } else if (diff < 0) {
      label = l10n.mealCostUnder;
      color = AppColors.success(context);
    } else {
      label = l10n.mealCostOver;
      color = AppColors.error(context);
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _buildSummaryBadge(
    BuildContext context,
    S l10n,
    double totalEstimated,
    double totalActual,
  ) {
    final diff = totalActual - totalEstimated;
    final bool isSaving = diff <= 0;
    final absDiff = diff.abs();

    final String label;
    final Color bgColor;
    final Color textColor;
    final Color borderColor;

    if (isSaving) {
      label = '${l10n.mealCostSavings}: ${formatCurrency(absDiff)}';
      bgColor = AppColors.successBackground(context);
      textColor = AppColors.success(context);
      borderColor = AppColors.success(context).withValues(alpha: 0.3);
    } else {
      label = '${l10n.mealCostOverrun}: ${formatCurrency(absDiff)}';
      bgColor = AppColors.errorBackground(context);
      textColor = AppColors.error(context);
      borderColor = AppColors.error(context).withValues(alpha: 0.3);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  double _maxAcrossWeeks(List<double> estimated, List<double> actual) {
    double maxVal = 0;
    for (var i = 0; i < estimated.length; i++) {
      maxVal = math.max(maxVal, estimated[i]);
      maxVal = math.max(maxVal, actual[i]);
    }
    return maxVal;
  }
}
