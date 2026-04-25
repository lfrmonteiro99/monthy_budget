import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/app_settings.dart';
import '../../models/budget_summary.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/category_helpers.dart';
import '../../utils/formatters.dart';
import '../info_icon_button.dart';


class BudgetCharts extends StatelessWidget {
  final BudgetSummary summary;
  final List<ExpenseItem> expenses;
  final List<ChartType> enabledCharts;

  const BudgetCharts({
    super.key,
    required this.summary,
    required this.expenses,
    required this.enabledCharts,
  });

  @override
  Widget build(BuildContext context) {
    final activeExpenses = expenses.where((e) => e.enabled && e.amount > 0).toList();
    return Column(
      children: [
        if (enabledCharts.contains(ChartType.expensesPie) && activeExpenses.isNotEmpty) ...[
          _ExpensesPieChart(expenses: activeExpenses),
          const SizedBox(height: 16),
        ],
        if (enabledCharts.contains(ChartType.incomeVsExpenses)) ...[
          _IncomeVsExpensesChart(summary: summary),
          const SizedBox(height: 16),
        ],
        if (enabledCharts.contains(ChartType.deductionsBreakdown) && summary.totalGross > 0) ...[
          _DeductionsChart(summary: summary),
          const SizedBox(height: 16),
        ],
        if (enabledCharts.contains(ChartType.netIncomeBar)) ...[
          _NetIncomeChart(summary: summary),
          const SizedBox(height: 16),
        ],
        if (enabledCharts.contains(ChartType.savingsRate) && summary.totalNetWithMeal > 0) ...[
          _SavingsRateChart(summary: summary),
        ],
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final String? infoBody;
  const _ChartCard({required this.title, required this.child, this.infoBody});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary(context), letterSpacing: 0.5),
                ),
              ),
              if (infoBody != null) InfoIconButton(title: title, body: infoBody!),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ExpensesPieChart extends StatelessWidget {
  final List<ExpenseItem> expenses;
  const _ExpensesPieChart({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, double>{};
    for (final exp in expenses) {
      grouped[exp.category] = (grouped[exp.category] ?? 0) + exp.amount;
    }
    final total = grouped.values.fold(0.0, (a, b) => a + b);
    final entries = grouped.entries.toList();

    final l10n = S.of(context);
    return _ChartCard(
      title: l10n.chartExpensesByCategory,
      infoBody: l10n.infoCharts,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: entries.map((e) {
                  return PieChartSectionData(
                    value: e.value,
                    color: AppColors.categoryColorByName(e.key),
                    title: '${(e.value / total * 100).toStringAsFixed(1)}%',
                    titleStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.onPrimary(context)),
                    radius: 80,
                    borderSide: BorderSide(color: AppColors.surface(context), width: 2),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.categoryColorByName(e.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${localizedCategoryLabel(e.key, l10n)}: ${formatCurrency(e.value)}',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context)),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _IncomeVsExpensesChart extends StatelessWidget {
  final BudgetSummary summary;
  const _IncomeVsExpensesChart({required this.summary});

  @override
  Widget build(BuildContext context) {
    final maxVal = [summary.totalNetWithMeal, summary.totalExpenses, math.max(0.0, summary.netLiquidity)]
        .reduce(math.max);

    final l10n = S.of(context);
    return _ChartCard(
      title: l10n.chartIncomeVsExpenses,
      infoBody: l10n.infoCharts,
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            maxY: maxVal * 1.15,
            barGroups: [
              _bar(0, summary.totalNetWithMeal, AppColors.chartGreen(context)),
              _bar(1, summary.totalExpenses, AppColors.chartRed(context)),
              _bar(2, math.max(0, summary.netLiquidity), AppColors.chartIndigo(context)),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final labels = [l10n.chartNetIncome, l10n.chartExpensesLabel, l10n.chartLiquidity];
                    if (value.toInt() < labels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(labels[value.toInt()], style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context))),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(formatCurrency(rod.toY), TextStyle(fontSize: 12, color: AppColors.onPrimary(context), fontWeight: FontWeight.w600));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 32,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ],
    );
  }
}

class _DeductionsChart extends StatelessWidget {
  final BudgetSummary summary;
  const _DeductionsChart({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return _ChartCard(
      title: l10n.chartDeductions,
      infoBody: l10n.infoCharts,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: summary.totalNet,
                    color: AppColors.chartGreen(context),
                    title: '',
                    radius: 70,
                    borderSide: BorderSide(color: AppColors.surface(context), width: 3),
                  ),
                  PieChartSectionData(
                    value: summary.totalIRS,
                    color: AppColors.chartRed(context),
                    title: '',
                    radius: 70,
                    borderSide: BorderSide(color: AppColors.surface(context), width: 3),
                  ),
                  PieChartSectionData(
                    value: summary.totalSS,
                    color: AppColors.chartAmber(context),
                    title: '',
                    radius: 70,
                    borderSide: BorderSide(color: AppColors.surface(context), width: 3),
                  ),
                ],
                sectionsSpace: 0,
                centerSpaceRadius: 50,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(context, AppColors.chartGreen(context), l10n.chartNetSalary),
              const SizedBox(width: 16),
              _legendDot(context, AppColors.chartRed(context), l10n.chartIRS),
              const SizedBox(width: 16),
              _legendDot(context, AppColors.chartAmber(context), l10n.chartSocialSecurity),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context))),
        ],
      );
}

class _NetIncomeChart extends StatelessWidget {
  final BudgetSummary summary;
  const _NetIncomeChart({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final labels = <String>[];
    final grossValues = <double>[];
    final netValues = <double>[];

    for (var i = 0; i < summary.salaries.length; i++) {
      final s = summary.salaries[i];
      if (s.effectiveGrossAmount > 0) {
        labels.add(l10n.chartSalaryN(i + 1));
        grossValues.add(s.effectiveGrossAmount);
        netValues.add(s.totalNetWithMeal);
      }
    }

    if (labels.isEmpty) return const SizedBox.shrink();

    final maxVal = [...grossValues, ...netValues].reduce(math.max);

    return _ChartCard(
      title: l10n.chartGrossVsNet,
      infoBody: l10n.infoCharts,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxVal * 1.15,
                barGroups: List.generate(labels.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: grossValues[i],
                        color: AppColors.chartIndigoLight(context),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      BarChartRodData(
                        toY: netValues[i],
                        color: AppColors.chartIndigo(context),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        if (value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[value.toInt()], style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context))),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(context, AppColors.chartIndigoLight(context), l10n.chartGross),
              const SizedBox(width: 16),
              _legendDot(context, AppColors.chartIndigo(context), l10n.chartNet),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context))),
        ],
      );
}

class _SavingsRateChart extends StatelessWidget {
  final BudgetSummary summary;
  const _SavingsRateChart({required this.summary});

  @override
  Widget build(BuildContext context) {
    final savingsRate = math.max(0.0, summary.savingsRate);
    final expenseRate = 1 - savingsRate;

    final l10n = S.of(context);
    return _ChartCard(
      title: l10n.chartSavingsRate,
      infoBody: l10n.infoCharts,
      child: SizedBox(
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: savingsRate * 100,
                    color: AppColors.chartGreen(context),
                    title: '',
                    radius: 24,
                    borderSide: BorderSide.none,
                  ),
                  PieChartSectionData(
                    value: expenseRate * 100,
                    color: AppColors.surfaceVariant(context),
                    title: '',
                    radius: 24,
                    borderSide: BorderSide.none,
                  ),
                ],
                sectionsSpace: 0,
                centerSpaceRadius: 60,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatPercentage(savingsRate),
                  style: CalmText.display(context, size: 28).copyWith(
                    color: AppColors.ok(context),
                  ),
                ),
                Text(l10n.chartSavings, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted(context))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
