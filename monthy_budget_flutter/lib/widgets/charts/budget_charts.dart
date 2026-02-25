import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/app_settings.dart';
import '../../models/budget_summary.dart';
import '../../utils/formatters.dart';

const _categoryColors = {
  ExpenseCategory.telecomunicacoes: Color(0xFF818CF8),
  ExpenseCategory.energia: Color(0xFFFBBF24),
  ExpenseCategory.agua: Color(0xFF60A5FA),
  ExpenseCategory.alimentacao: Color(0xFF34D399),
  ExpenseCategory.educacao: Color(0xFFA78BFA),
  ExpenseCategory.habitacao: Color(0xFFF87171),
  ExpenseCategory.transportes: Color(0xFFFB923C),
  ExpenseCategory.saude: Color(0xFFF472B6),
  ExpenseCategory.lazer: Color(0xFF2DD4BF),
  ExpenseCategory.outros: Color(0xFF94A3B8),
};

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
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade400, letterSpacing: 1.2),
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
    final grouped = <ExpenseCategory, double>{};
    for (final exp in expenses) {
      grouped[exp.category] = (grouped[exp.category] ?? 0) + exp.amount;
    }
    final total = grouped.values.fold(0.0, (a, b) => a + b);
    final entries = grouped.entries.toList();

    return _ChartCard(
      title: 'Despesas por Categoria',
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: entries.map((e) {
                  return PieChartSectionData(
                    value: e.value,
                    color: _categoryColors[e.key] ?? const Color(0xFF94A3B8),
                    title: '${(e.value / total * 100).toStringAsFixed(1)}%',
                    titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                    radius: 80,
                    borderSide: const BorderSide(color: Colors.white, width: 2),
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
                      color: _categoryColors[e.key] ?? const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${e.key.label}: ${formatCurrency(e.value)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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

    return _ChartCard(
      title: 'Rendimento vs Despesas',
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            maxY: maxVal * 1.15,
            barGroups: [
              _bar(0, summary.totalNetWithMeal, const Color(0xFF34D399)),
              _bar(1, summary.totalExpenses, const Color(0xFFF87171)),
              _bar(2, math.max(0, summary.netLiquidity), const Color(0xFF818CF8)),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    const labels = ['Rend. Liq.', 'Despesas', 'Liquidez'];
                    if (value.toInt() < labels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(labels[value.toInt()], style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
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
                  return BarTooltipItem(formatCurrency(rod.toY), const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600));
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
    return _ChartCard(
      title: 'Descontos (IRS + Seguranca Social)',
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: summary.totalNet,
                    color: const Color(0xFF34D399),
                    title: '',
                    radius: 70,
                    borderSide: const BorderSide(color: Colors.white, width: 3),
                  ),
                  PieChartSectionData(
                    value: summary.totalIRS,
                    color: const Color(0xFFF87171),
                    title: '',
                    radius: 70,
                    borderSide: const BorderSide(color: Colors.white, width: 3),
                  ),
                  PieChartSectionData(
                    value: summary.totalSS,
                    color: const Color(0xFFFBBF24),
                    title: '',
                    radius: 70,
                    borderSide: const BorderSide(color: Colors.white, width: 3),
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
              _legendDot(const Color(0xFF34D399), 'Sal. Líquido'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFFF87171), 'IRS'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFFFBBF24), 'Seg. Social'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      );
}

class _NetIncomeChart extends StatelessWidget {
  final BudgetSummary summary;
  const _NetIncomeChart({required this.summary});

  @override
  Widget build(BuildContext context) {
    final labels = <String>[];
    final grossValues = <double>[];
    final netValues = <double>[];

    for (var i = 0; i < summary.salaries.length; i++) {
      final s = summary.salaries[i];
      if (s.effectiveGrossAmount > 0) {
        labels.add('Venc. ${i + 1}');
        grossValues.add(s.effectiveGrossAmount);
        netValues.add(s.totalNetWithMeal);
      }
    }

    if (labels.isEmpty) return const SizedBox.shrink();

    final maxVal = [...grossValues, ...netValues].reduce(math.max);

    return _ChartCard(
      title: 'Rendimento Bruto vs Liquido',
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
                        color: const Color(0xFFC7D2FE),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      BarChartRodData(
                        toY: netValues[i],
                        color: const Color(0xFF818CF8),
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
                            child: Text(labels[value.toInt()], style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
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
              _legendDot(const Color(0xFFC7D2FE), 'Bruto'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFF818CF8), 'Líquido'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
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

    return _ChartCard(
      title: 'Taxa de Poupanca',
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
                    color: const Color(0xFF34D399),
                    title: '',
                    radius: 24,
                    borderSide: BorderSide.none,
                  ),
                  PieChartSectionData(
                    value: expenseRate * 100,
                    color: const Color(0xFFF1F5F9),
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
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF10B981), letterSpacing: -0.5),
                ),
                Text('poupanca', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade400)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
