import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/actual_expense.dart';
import '../models/expense_snapshot.dart';
import '../models/app_settings.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';


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

String _localizedCategory(String catName, S l10n) {
  try {
    final cat = ExpenseCategory.values.firstWhere((c) => c.name == catName);
    return cat.localizedLabel(l10n);
  } catch (_) {
    return catName;
  }
}

IconData _categoryIcon(String catName) {
  try {
    final cat = ExpenseCategory.values.firstWhere((c) => c.name == catName);
    switch (cat) {
      case ExpenseCategory.telecomunicacoes:
        return Icons.phone;
      case ExpenseCategory.energia:
        return Icons.bolt;
      case ExpenseCategory.agua:
        return Icons.water_drop;
      case ExpenseCategory.alimentacao:
        return Icons.restaurant;
      case ExpenseCategory.educacao:
        return Icons.school;
      case ExpenseCategory.habitacao:
        return Icons.home;
      case ExpenseCategory.transportes:
        return Icons.directions_car;
      case ExpenseCategory.saude:
        return Icons.local_hospital;
      case ExpenseCategory.lazer:
        return Icons.sports_esports;
      case ExpenseCategory.outros:
        return Icons.more_horiz;
    }
  } catch (_) {
    return Icons.label_outline;
  }
}

class ExpenseTrendsScreen extends StatefulWidget {
  final Map<String, List<ActualExpense>> actualExpenseHistory;
  final Map<String, List<ExpenseSnapshot>> expenseHistory;

  const ExpenseTrendsScreen({
    super.key,
    required this.actualExpenseHistory,
    required this.expenseHistory,
  });

  @override
  State<ExpenseTrendsScreen> createState() => _ExpenseTrendsScreenState();
}

class _ExpenseTrendsScreenState extends State<ExpenseTrendsScreen> {
  int _selectedMonths = 6;

  /// Returns sorted month keys filtered to the selected time range.
  List<String> _filteredMonthKeys() {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - _selectedMonths + 1);
    final cutoffKey =
        '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}';

    final allKeys = <String>{
      ...widget.actualExpenseHistory.keys,
      ...widget.expenseHistory.keys,
    }.where((k) => k.compareTo(cutoffKey) >= 0).toList()
      ..sort();

    return allKeys;
  }

  /// Compute budgeted total for a given month key from the expense snapshots.
  double _budgetedTotal(String monthKey) {
    final snapshots = widget.expenseHistory[monthKey];
    if (snapshots == null) return 0;
    return snapshots
        .where((s) => s.enabled)
        .fold(0.0, (sum, s) => sum + s.amount);
  }

  /// Compute actual total for a given month key from actual expenses.
  double _actualTotal(String monthKey) {
    final actuals = widget.actualExpenseHistory[monthKey];
    if (actuals == null) return 0;
    return actuals.fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Build per-category stats across the filtered months.
  List<_CategoryStats> _buildCategoryStats(List<String> months) {
    final totals = <String, double>{};
    for (final mk in months) {
      final actuals = widget.actualExpenseHistory[mk] ?? [];
      for (final e in actuals) {
        totals[e.category] = (totals[e.category] ?? 0) + e.amount;
      }
    }

    final monthCount = months.length.clamp(1, 999);
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries
        .map((e) => _CategoryStats(
              category: e.key,
              total: e.value,
              average: e.value / monthCount,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final months = _filteredMonthKeys();
    final hasData = months.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(l10n.expenseTrends),
        backgroundColor: AppColors.surface(context),
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          // Time range selector
          Container(
            color: AppColors.surface(context),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _rangeChip(l10n.expenseTrends3Months, 3),
                const SizedBox(width: 8),
                _rangeChip(l10n.expenseTrends6Months, 6),
                const SizedBox(width: 8),
                _rangeChip(l10n.expenseTrends12Months, 12),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: !hasData
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        l10n.expenseTrendsNoData,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted(context),
                          height: 1.5,
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildOverviewChart(context, l10n, months),
                      const SizedBox(height: 20),
                      _buildCategoryBreakdown(context, l10n, months),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _rangeChip(String label, int months) {
    final isSelected = _selectedMonths == months;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryLight(context),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isSelected
            ? AppColors.primary(context)
            : AppColors.textSecondary(context),
      ),
      backgroundColor: AppColors.surfaceVariant(context),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary(context)
            : AppColors.border(context),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => setState(() => _selectedMonths = months),
    );
  }

  // ── Overview dual-line chart ─────────────────────────────────────────

  Widget _buildOverviewChart(
      BuildContext context, S l10n, List<String> months) {
    final budgetedSpots = <FlSpot>[];
    final actualSpots = <FlSpot>[];
    final labels = <int, String>{};
    double maxY = 0;

    for (var i = 0; i < months.length; i++) {
      final mk = months[i];
      final b = _budgetedTotal(mk);
      final a = _actualTotal(mk);
      budgetedSpots.add(FlSpot(i.toDouble(), b));
      actualSpots.add(FlSpot(i.toDouble(), a));
      maxY = math.max(maxY, math.max(b, a));

      final parts = mk.split('-');
      final monthNum = int.parse(parts[1]);
      labels[i] = localizedMonthAbbr(l10n, monthNum);
    }

    final ceilY = maxY > 0 ? maxY * 1.15 : 1.0;

    // Determine actual line color: green if overall under budget, red if over
    final totalBudgeted =
        months.fold(0.0, (sum, mk) => sum + _budgetedTotal(mk));
    final totalActual = months.fold(0.0, (sum, mk) => sum + _actualTotal(mk));
    final actualColor = totalActual <= totalBudgeted
        ? AppColors.success(context)
        : AppColors.error(context);

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
            l10n.expenseTrendsOverview.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted(context),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: ceilY,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: ceilY / 5,
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
                      reservedSize: 52,
                      interval: ceilY / 5,
                      getTitlesWidget: (value, _) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          _compactCurrency(value),
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        // Show every label for small ranges, every 2nd for larger
                        if (months.length > 8 && idx % 2 != 0) {
                          return const SizedBox();
                        }
                        if (labels.containsKey(idx)) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[idx]!,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  // Budgeted line (blue)
                  LineChartBarData(
                    spots: budgetedSpots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: AppColors.primary(context),
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.primary(context),
                        strokeWidth: 1.5,
                        strokeColor: AppColors.surface(context),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color:
                          AppColors.primary(context).withValues(alpha: 0.06),
                    ),
                  ),
                  // Actual line (green/red)
                  LineChartBarData(
                    spots: actualSpots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: actualColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dashArray: [6, 3],
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        final mk = index < months.length ? months[index] : '';
                        final budgeted = _budgetedTotal(mk);
                        final dotColor = spot.y <= budgeted
                            ? AppColors.success(context)
                            : AppColors.error(context);
                        return FlDotCirclePainter(
                          radius: 3,
                          color: dotColor,
                          strokeWidth: 1.5,
                          strokeColor: AppColors.surface(context),
                        );
                      },
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((s) {
                        final isBudgeted = s.barIndex == 0;
                        return LineTooltipItem(
                          '${isBudgeted ? l10n.expenseTrendsBudgeted : l10n.expenseTrendsActual}\n${formatCurrency(s.y)}',
                          TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimary(context),
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(
                  context, AppColors.primary(context), l10n.expenseTrendsBudgeted),
              const SizedBox(width: 20),
              _legendDot(context, actualColor, l10n.expenseTrendsActual),
            ],
          ),
          const SizedBox(height: 12),
          // Summary row
          Row(
            children: [
              Expanded(
                child: _summaryColumn(
                  context,
                  l10n.expenseTrendsTotal,
                  formatCurrency(totalActual),
                  AppColors.textPrimary(context),
                ),
              ),
              Expanded(
                child: _summaryColumn(
                  context,
                  l10n.expenseTrendsAverage,
                  formatCurrency(
                      months.isNotEmpty ? totalActual / months.length : 0),
                  AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Per-category breakdown ───────────────────────────────────────────

  Widget _buildCategoryBreakdown(
      BuildContext context, S l10n, List<String> months) {
    final stats = _buildCategoryStats(months);
    if (stats.isEmpty) return const SizedBox();

    final maxAvg = stats.fold(0.0, (m, s) => math.max(m, s.average));

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
            l10n.expenseTrendsByCategory.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted(context),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ...stats.map((s) => _CategoryBar(
                stat: s,
                maxAvg: maxAvg,
                months: months,
                actualExpenseHistory: widget.actualExpenseHistory,
                l10n: l10n,
              )),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  String _compactCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  Widget _legendDot(BuildContext context, Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      );

  Widget _summaryColumn(
          BuildContext context, String label, String value, Color color) =>
      Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      );
}

// ── Data class for per-category stats ──────────────────────────────────

class _CategoryStats {
  final String category;
  final double total;
  final double average;

  const _CategoryStats({
    required this.category,
    required this.total,
    required this.average,
  });
}

// ── Category bar row with tap-to-detail ────────────────────────────────

class _CategoryBar extends StatelessWidget {
  final _CategoryStats stat;
  final double maxAvg;
  final List<String> months;
  final Map<String, List<ActualExpense>> actualExpenseHistory;
  final S l10n;

  const _CategoryBar({
    required this.stat,
    required this.maxAvg,
    required this.months,
    required this.actualExpenseHistory,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final barFraction = maxAvg > 0 ? (stat.average / maxAvg).clamp(0.0, 1.0) : 0.0;
    final color =
        AppColors.categoryColorByName(stat.category);
    final categoryLabels = _localizedCategoryLabels(l10n);
    final label = categoryLabels[stat.category] ??
        _localizedCategory(stat.category, l10n);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showCategoryDetail(context),
        child: Row(
          children: [
            Icon(
              _categoryIcon(stat.category),
              size: 18,
              color: color,
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  return Stack(
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant(context),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        height: 14,
                        width: constraints.maxWidth * barFraction,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 72,
              child: Text(
                formatCurrency(stat.average),
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDetail(BuildContext context) {
    final categoryLabels = _localizedCategoryLabels(l10n);
    final label = categoryLabels[stat.category] ??
        _localizedCategory(stat.category, l10n);
    final color =
        AppColors.categoryColorByName(stat.category);

    // Build per-month data for this category
    final monthlyData = <_MonthAmount>[];
    for (final mk in months) {
      final actuals = actualExpenseHistory[mk] ?? [];
      final catTotal = actuals
          .where((e) => e.category == stat.category)
          .fold(0.0, (sum, e) => sum + e.amount);
      monthlyData.add(_MonthAmount(monthKey: mk, amount: catTotal));
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CategoryDetailSheet(
        label: label,
        color: color,
        monthlyData: monthlyData,
        total: stat.total,
        average: stat.average,
        l10n: l10n,
      ),
    );
  }
}

// ── Month-amount pair ──────────────────────────────────────────────────

class _MonthAmount {
  final String monthKey;
  final double amount;
  const _MonthAmount({required this.monthKey, required this.amount});
}

// ── Category detail bottom sheet ───────────────────────────────────────

class _CategoryDetailSheet extends StatelessWidget {
  final String label;
  final Color color;
  final List<_MonthAmount> monthlyData;
  final double total;
  final double average;
  final S l10n;

  const _CategoryDetailSheet({
    required this.label,
    required this.color,
    required this.monthlyData,
    required this.total,
    required this.average,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final maxAmount =
        monthlyData.fold(0.0, (m, d) => math.max(m, d.amount));
    final spots = <FlSpot>[];
    final labels = <int, String>{};

    for (var i = 0; i < monthlyData.length; i++) {
      spots.add(FlSpot(i.toDouble(), monthlyData[i].amount));
      final parts = monthlyData[i].monthKey.split('-');
      final monthNum = int.parse(parts[1]);
      labels[i] = localizedMonthAbbr(l10n, monthNum);
    }

    final ceilY = maxAmount > 0 ? maxAmount * 1.2 : 1.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${l10n.expenseTrendsTotal}: ${formatCurrency(total)}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                '${l10n.expenseTrendsAverage}: ${formatCurrency(average)}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (spots.length >= 2) ...[
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: ceilY,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: ceilY / 4,
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
                        reservedSize: 48,
                        interval: ceilY / 4,
                        getTitlesWidget: (value, _) => Text(
                          _compactCurrency(value),
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textMuted(context),
                          ),
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
                              child: Text(
                                labels[idx]!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: color,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                          radius: 3.5,
                          color: color,
                          strokeWidth: 1.5,
                          strokeColor: AppColors.surface(context),
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((s) {
                          final idx = s.spotIndex;
                          final mk = idx < monthlyData.length
                              ? monthlyData[idx].monthKey
                              : '';
                          return LineTooltipItem(
                            '$mk\n${formatCurrency(s.y)}',
                            TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onPrimary(context),
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Monthly breakdown list
          ...monthlyData.map((d) {
            final parts = d.monthKey.split('-');
            final monthNum = int.parse(parts[1]);
            final monthLabel = localizedMonthAbbr(l10n, monthNum);
            final year = parts[0];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$monthLabel $year',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  Text(
                    formatCurrency(d.amount),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _compactCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }
}
