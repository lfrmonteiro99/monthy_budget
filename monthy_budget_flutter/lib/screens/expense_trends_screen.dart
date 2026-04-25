import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/actual_expense.dart';
import '../models/expense_snapshot.dart';
import '../models/app_settings.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'package:monthly_management/widgets/calm/calm.dart';


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

  String _rangeSubtitle(S l10n) {
    switch (_selectedMonths) {
      case 3:
        return l10n.expenseTrends3Months;
      case 12:
        return l10n.expenseTrends12Months;
      default:
        return l10n.expenseTrends6Months;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final months = _filteredMonthKeys();
    final hasData = months.isNotEmpty;
    final totalActual = months.fold(0.0, (sum, mk) => sum + _actualTotal(mk));

    return CalmScaffold(
      title: l10n.expenseTrends,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Hero block — one Fraunces number per screen
          CalmHero(
            eyebrow: 'TENDÊNCIAS', // TODO(l10n): move to ARB (Wave H)
            amount: formatCurrency(totalActual),
            subtitle: _rangeSubtitle(l10n),
          ),

          const SizedBox(height: 24),

          // Time range selector
          CalmCard(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _rangeButton(l10n.expenseTrends3Months, 3),
                const SizedBox(width: 8),
                _rangeButton(l10n.expenseTrends6Months, 6),
                const SizedBox(width: 8),
                _rangeButton(l10n.expenseTrends12Months, 12),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Content
          Expanded(
            child: !hasData
                ? Center(
                    child: CalmEmptyState(
                      icon: Icons.bar_chart_outlined,
                      title: l10n.expenseTrendsNoData,
                      // TODO(l10n): move subtitle to ARB (Wave H)
                      body: 'Adiciona despesas para ver as tendências.',
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOverviewChart(context, l10n, months),
                        const SizedBox(height: 20),
                        _buildCategoryBreakdown(context, l10n, months),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _rangeButton(String label, int months) {
    final isSelected = _selectedMonths == months;
    return OutlinedButton(
      onPressed: () => setState(() => _selectedMonths = months),
      style: OutlinedButton.styleFrom(
        foregroundColor:
            isSelected ? AppColors.bg(context) : AppColors.ink(context),
        backgroundColor: isSelected ? AppColors.ink(context) : null,
        side: BorderSide(
          color: isSelected
              ? AppColors.ink(context)
              : AppColors.ink20(context),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
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

    // Determine actual line color: ok if overall under budget, bad if over
    final totalBudgeted =
        months.fold(0.0, (sum, mk) => sum + _budgetedTotal(mk));
    final totalActual =
        months.fold(0.0, (sum, mk) => sum + _actualTotal(mk));
    final actualColor = totalActual <= totalBudgeted
        ? AppColors.ok(context)
        : AppColors.bad(context);

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalmEyebrow(l10n.expenseTrendsOverview.toUpperCase()),
          const SizedBox(height: 16),
          Semantics(
            label: l10n.expenseTrendsChartLabel,
            child: SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: ceilY,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: ceilY / 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.line(context),
                      strokeWidth: 1,
                      dashArray: [4, 4],
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
                              color: AppColors.ink50(context),
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
                                  color: AppColors.ink70(context),
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
                    // Budgeted line (accent)
                    LineChartBarData(
                      spots: budgetedSpots,
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: AppColors.accent(context),
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: AppColors.accent(context),
                          strokeWidth: 1.5,
                          strokeColor: AppColors.card(context),
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.accent(context)
                            .withValues(alpha: 0.06),
                      ),
                    ),
                    // Actual line (ok/bad)
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
                          final mk =
                              index < months.length ? months[index] : '';
                          final budgeted = _budgetedTotal(mk);
                          final dotColor = spot.y <= budgeted
                              ? AppColors.ok(context)
                              : AppColors.bad(context);
                          return FlDotCirclePainter(
                            radius: 3,
                            color: dotColor,
                            strokeWidth: 1.5,
                            strokeColor: AppColors.card(context),
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
                              color: AppColors.bg(context),
                            ),
                          );
                        }).toList();
                      },
                    ),
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
              _legendLine(context, AppColors.accent(context),
                  l10n.expenseTrendsBudgeted,
                  dashed: false),
              const SizedBox(width: 20),
              _legendLine(context, actualColor, l10n.expenseTrendsActual,
                  dashed: true),
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
                  AppColors.ink(context),
                ),
              ),
              Expanded(
                child: _summaryColumn(
                  context,
                  l10n.expenseTrendsAverage,
                  formatCurrency(months.isNotEmpty
                      ? totalActual / months.length
                      : 0),
                  AppColors.ink70(context),
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

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalmEyebrow(l10n.expenseTrendsByCategory.toUpperCase()),
          const SizedBox(height: 16),
          ...stats.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            return Column(
              children: [
                _CategoryRow(
                  stat: s,
                  maxAvg: maxAvg,
                  months: months,
                  actualExpenseHistory: widget.actualExpenseHistory,
                  l10n: l10n,
                ),
                if (i < stats.length - 1)
                  Divider(color: AppColors.line(context), height: 1),
              ],
            );
          }),
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

  Widget _legendLine(BuildContext context, Color color, String label,
      {required bool dashed}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 3,
          child: dashed
              ? Row(
                  children: [
                    Container(width: 5, height: 3, color: color), // Justified: dashed legend line stroke
                    const SizedBox(width: 3),
                    Container(width: 5, height: 3, color: color), // Justified: dashed legend line stroke
                    const SizedBox(width: 3),
                    Container(width: 4, height: 3, color: color), // Justified: dashed legend line stroke
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: ColoredBox(color: color),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.ink70(context),
          ),
        ),
      ],
    );
  }

  Widget _summaryColumn(
          BuildContext context, String label, String value, Color color) =>
      Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.ink50(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: CalmText.amount(context).copyWith(
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

// ── Category row with tap-to-detail ────────────────────────────────────
//
// Uses a custom row layout: circular avatar (like CalmListTile) + label +
// inline progress bar + trailing average. CalmListTile.trailing is
// String-only so we can't embed the progress bar there.

class _CategoryRow extends StatelessWidget {
  final _CategoryStats stat;
  final double maxAvg;
  final List<String> months;
  final Map<String, List<ActualExpense>> actualExpenseHistory;
  final S l10n;

  const _CategoryRow({
    required this.stat,
    required this.maxAvg,
    required this.months,
    required this.actualExpenseHistory,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final barFraction =
        maxAvg > 0 ? (stat.average / maxAvg).clamp(0.0, 1.0) : 0.0;
    final color = AppColors.categoryColorByName(stat.category);
    final categoryLabels = _localizedCategoryLabels(l10n);
    final label = categoryLabels[stat.category] ??
        _localizedCategory(stat.category, l10n);

    return InkWell(
      onTap: () => _showCategoryDetail(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Leading circular avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(
                _categoryIcon(stat.category),
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            // Label + progress bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (_, constraints) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 4,
                              width: double.infinity,
                              child: ColoredBox(
                                color: AppColors.bgSunk(context),
                              ),
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: barFraction),
                              duration: AppConstants.animProgressBar,
                              curve: Curves.easeOutCubic,
                              builder: (_, fraction, __) => SizedBox(
                                height: 4,
                                width: constraints.maxWidth * fraction,
                                child: ColoredBox(color: color),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Trailing average
            Text(
              formatCurrency(stat.average),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink(context),
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
    final color = AppColors.categoryColorByName(stat.category);

    // Build per-month data for this category
    final monthlyData = <_MonthAmount>[];
    for (final mk in months) {
      final actuals = actualExpenseHistory[mk] ?? [];
      final catTotal = actuals
          .where((e) => e.category == stat.category)
          .fold(0.0, (sum, e) => sum + e.amount);
      monthlyData.add(_MonthAmount(monthKey: mk, amount: catTotal));
    }

    CalmBottomSheet.show(
      context,
      builder: (_) => SingleChildScrollView(
        child: CalmBottomSheetContent(
          title: label,
          child: _CategoryDetailContent(
            label: label,
            color: color,
            monthlyData: monthlyData,
            total: stat.total,
            average: stat.average,
            l10n: l10n,
          ),
        ),
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

// ── Category detail content (used inside CalmBottomSheetContent) ───────

class _CategoryDetailContent extends StatelessWidget {
  final String label;
  final Color color;
  final List<_MonthAmount> monthlyData;
  final double total;
  final double average;
  final S l10n;

  const _CategoryDetailContent({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats pill + average
        Row(
          children: [
            CalmPill(
              label: formatCurrency(total),
              color: color,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                '${l10n.expenseTrendsAverage}: ${formatCurrency(average)}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.ink70(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Mini chart
        if (spots.length >= 2) ...[
          CalmCard(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: ceilY,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: ceilY / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.line(context),
                      strokeWidth: 1,
                      dashArray: [4, 4],
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
                            color: AppColors.ink50(context),
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
                                  color: AppColors.ink70(context),
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
                          strokeColor: AppColors.card(context),
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
                          final parts = mk.split('-');
                          final tooltipLabel = parts.length == 2
                              ? '${localizedMonthAbbr(l10n, int.parse(parts[1]))} ${parts[0]}'
                              : mk;
                          return LineTooltipItem(
                            '$tooltipLabel\n${formatCurrency(s.y)}',
                            TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.bg(context),
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Monthly breakdown list
        CalmEyebrow('HISTÓRICO MENSAL'), // TODO(l10n): move to ARB (Wave H)
        const SizedBox(height: 8),
        ...monthlyData.asMap().entries.map((entry) {
          final i = entry.key;
          final d = entry.value;
          final parts = d.monthKey.split('-');
          final monthNum = int.parse(parts[1]);
          final monthLabel = localizedMonthAbbr(l10n, monthNum);
          final year = parts[0];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$monthLabel $year',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.ink70(context),
                      ),
                    ),
                    Text(
                      formatCurrency(d.amount),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (i < monthlyData.length - 1)
                Divider(color: AppColors.line(context), height: 1),
            ],
          );
        }),
      ],
    );
  }

  String _compactCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }
}
