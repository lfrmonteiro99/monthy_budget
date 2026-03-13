import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/expense_snapshot.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../l10n/generated/app_localizations.dart';


Map<String, String> _localizedCategoryLabels(S l10n) => {
  'telecomunicacoes': l10n.trendCatTelecom,
  'energia': l10n.trendCatEnergy,
  'agua': l10n.trendCatWater,
  'alimentacao': l10n.trendCatFood,
  'educacao': l10n.trendCatEducation,
  'habitacao': l10n.trendCatHousing,
  'transportes': l10n.trendCatTransport,
  'saude': l10n.trendCatHealth,
  'lazer': l10n.trendCatLeisure,
  'outros': l10n.trendCatOther,
};

/// Opens the trend bottom sheet from a parent context.
void showTrendSheet({
  required BuildContext context,
  required Map<String, int> stressHistory,
  required Map<String, List<ExpenseSnapshot>> expenseHistory,
  required double currentTotalExpenses,
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
      builder: (_, scrollController) => _TrendSheetContent(
        scrollController: scrollController,
        stressHistory: stressHistory,
        expenseHistory: expenseHistory,
        currentTotalExpenses: currentTotalExpenses,
      ),
    ),
  );
}

class _TrendSheetContent extends StatelessWidget {
  final ScrollController scrollController;
  final Map<String, int> stressHistory;
  final Map<String, List<ExpenseSnapshot>> expenseHistory;
  final double currentTotalExpenses;

  const _TrendSheetContent({
    required this.scrollController,
    required this.stressHistory,
    required this.expenseHistory,
    required this.currentTotalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
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
          l10n.trendTitle,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        if (stressHistory.length >= 2) ...[
          _buildStressChart(context, l10n),
          const SizedBox(height: 24),
        ],
        if (expenseHistory.isNotEmpty) ...[
          _buildExpenseTotalChart(context, l10n),
          const SizedBox(height: 24),
          _buildExpenseCategoryChart(context, l10n),
        ],
      ],
    );
  }

  Widget _buildStressChart(BuildContext context, S l10n) {
    final sorted = stressHistory.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final entries = sorted.length > 12 ? sorted.sublist(sorted.length - 12) : sorted;

    final spots = <FlSpot>[];
    final labels = <int, String>{};
    for (var i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].value.toDouble()));
      final parts = entries[i].key.split('-');
      final monthNum = int.parse(parts[1]);
      labels[i] = localizedMonthAbbr(l10n, monthNum);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.trendStressIndex,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textMuted(context), letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0, maxY: 100,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.surfaceVariant(context),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 20,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toInt()}',
                        style: TextStyle(fontSize: 10, color: AppColors.textMuted(context)),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (labels.containsKey(idx)) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[idx]!,
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context))),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                rangeAnnotations: RangeAnnotations(
                  horizontalRangeAnnotations: [
                    HorizontalRangeAnnotation(y1: 0, y2: 39, color: AppColors.errorBackground(context)),
                    HorizontalRangeAnnotation(y1: 40, y2: 59, color: AppColors.warningBackground(context)),
                    HorizontalRangeAnnotation(y1: 60, y2: 79, color: AppColors.infoBackground(context)),
                    HorizontalRangeAnnotation(y1: 80, y2: 100, color: AppColors.successBackground(context)),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: AppColors.primary(context),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        final isLast = spot.x == spots.last.x;
                        return FlDotCirclePainter(
                          radius: isLast ? 5 : 3,
                          color: _scoreColor(context, spot.y.toInt()),
                          strokeWidth: 2,
                          strokeColor: AppColors.surface(context),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary(context).withValues(alpha: 0.08),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      final idx = s.spotIndex;
                      final label = idx < entries.length ? entries[idx].key : '';
                      return LineTooltipItem(
                        '${s.y.toInt()}/100\n$label',
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onPrimary(context)),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _zoneDot(context, AppColors.error(context), l10n.stressCritical),
              const SizedBox(width: 12),
              _zoneDot(context, AppColors.warning(context), l10n.stressWarning),
              const SizedBox(width: 12),
              _zoneDot(context, AppColors.primary(context), l10n.stressGood),
              const SizedBox(width: 12),
              _zoneDot(context, AppColors.success(context), l10n.stressExcellent),
            ],
          ),
          const SizedBox(height: 10),
          // Zone explanations
          ...[
            (AppColors.error(context), l10n.stressZoneCritical),
            (AppColors.warning(context), l10n.stressZoneWarning),
            (AppColors.primary(context), l10n.stressZoneGood),
            (AppColors.success(context), l10n.stressZoneExcellent),
          ].map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6, height: 6,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: entry.$1,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    entry.$2,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ── Total expenses bar chart ────────────────────────────────────────

  Widget _buildExpenseTotalChart(BuildContext context, S l10n) {
    final months = expenseHistory.keys.toList()..sort();
    final totals = months.map((m) {
      return expenseHistory[m]!
          .where((s) => s.enabled)
          .fold(0.0, (sum, s) => sum + s.amount);
    }).toList();
    final maxSpend = totals.fold(0.0, math.max);
    final maxY = math.max(maxSpend, currentTotalExpenses) * 1.2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.trendTotalExpenses,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textMuted(context), letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY > 0 ? maxY : 1,
                barGroups: List.generate(months.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: totals[i],
                        color: totals[i] > currentTotalExpenses
                            ? const Color(0xFFF87171)
                            : AppColors.primary(context),
                        width: months.length <= 6 ? 28 : 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
                extraLinesData: currentTotalExpenses > 0
                    ? ExtraLinesData(horizontalLines: [
                        HorizontalLine(
                          y: currentTotalExpenses,
                          color: AppColors.textMuted(context),
                          strokeWidth: 1,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context)),
                            labelResolver: (_) => l10n.trendCurrent(formatCurrency(currentTotalExpenses)),
                          ),
                        ),
                      ])
                    : ExtraLinesData(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < months.length) {
                          final parts = months[idx].split('-');
                          final monthNum = int.parse(parts[1]);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(localizedMonthAbbr(l10n, monthNum),
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context))),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        formatCurrency(rod.toY),
                        TextStyle(fontSize: 12, color: AppColors.onPrimary(context), fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stacked category bar chart ──────────────────────────────────────

  Widget _buildExpenseCategoryChart(BuildContext context, S l10n) {
    final categoryLabels = _localizedCategoryLabels(l10n);
    final months = expenseHistory.keys.toList()..sort();

    // Collect all categories that appear across all months
    final allCategories = <String>{};
    for (final snapshots in expenseHistory.values) {
      for (final s in snapshots) {
        if (s.enabled && s.amount > 0) allCategories.add(s.category);
      }
    }
    final categories = allCategories.toList()..sort();

    if (categories.isEmpty) return const SizedBox();

    // Build stacked bars
    double maxY = 0;
    final groups = List.generate(months.length, (i) {
      final snapshots = expenseHistory[months[i]]!;
      final stackItems = <BarChartRodStackItem>[];
      double runningY = 0;
      for (final cat in categories) {
        final amount = snapshots
            .where((s) => s.category == cat && s.enabled)
            .fold(0.0, (sum, s) => sum + s.amount);
        if (amount > 0) {
          stackItems.add(BarChartRodStackItem(
            runningY,
            runningY + amount,
            AppColors.categoryColorByName(cat),
          ));
          runningY += amount;
        }
      }
      if (runningY > maxY) maxY = runningY;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: runningY,
            rodStackItems: stackItems,
            width: months.length <= 6 ? 28 : 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            color: Colors.transparent,
          ),
        ],
      );
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.trendExpensesByCategory,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textMuted(context), letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY > 0 ? maxY * 1.1 : 1,
                barGroups: groups,
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < months.length) {
                          final parts = months[idx].split('-');
                          final monthNum = int.parse(parts[1]);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(localizedMonthAbbr(l10n, monthNum),
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context))),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final month = months[groupIndex];
                      final snapshots = expenseHistory[month]!;
                      final lines = <String>[];
                      for (final cat in categories) {
                        final amount = snapshots
                            .where((s) => s.category == cat && s.enabled)
                            .fold(0.0, (sum, s) => sum + s.amount);
                        if (amount > 0) {
                          final label = categoryLabels[cat] ?? cat;
                          lines.add('$label: ${formatCurrency(amount)}');
                        }
                      }
                      lines.add('Total: ${formatCurrency(rod.toY)}');
                      return BarTooltipItem(
                        lines.join('\n'),
                        TextStyle(fontSize: 11, color: AppColors.onPrimary(context), fontWeight: FontWeight.w500),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: categories.map((cat) => _zoneDot(
              context,
              AppColors.categoryColorByName(cat),
              categoryLabels[cat] ?? cat,
            )).toList(),
          ),
        ],
      ),
    );
  }

  static Color _scoreColor(BuildContext context, int score) {
    if (score >= 80) return AppColors.success(context);
    if (score >= 60) return AppColors.primary(context);
    if (score >= 40) return AppColors.warning(context);
    return AppColors.error(context);
  }

  Widget _zoneDot(BuildContext context, Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context))),
        ],
      );
}
