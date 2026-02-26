import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/expense_snapshot.dart';
import '../utils/formatters.dart';

const _monthNames = [
  '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
  'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
];

const _categoryColors = {
  'telecomunicacoes': Color(0xFF818CF8),
  'energia': Color(0xFFFBBF24),
  'agua': Color(0xFF60A5FA),
  'alimentacao': Color(0xFF34D399),
  'educacao': Color(0xFFA78BFA),
  'habitacao': Color(0xFFF87171),
  'transportes': Color(0xFFFB923C),
  'saude': Color(0xFFF472B6),
  'lazer': Color(0xFF2DD4BF),
  'outros': Color(0xFF94A3B8),
};

const _categoryLabels = {
  'telecomunicacoes': 'Telecom',
  'energia': 'Energia',
  'agua': 'Água',
  'alimentacao': 'Alimentação',
  'educacao': 'Educação',
  'habitacao': 'Habitação',
  'transportes': 'Transportes',
  'saude': 'Saúde',
  'lazer': 'Lazer',
  'outros': 'Outros',
};

/// Opens the trend bottom sheet from a parent context.
void showTrendSheet({
  required BuildContext context,
  required Map<String, int> stressHistory,
  required Map<String, List<ExpenseSnapshot>> expenseHistory,
  required double currentTotalExpenses,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
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
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Center(
          child: Container(
            width: 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const Text(
          'Evolução',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        if (stressHistory.length >= 2) ...[
          _buildStressChart(),
          const SizedBox(height: 24),
        ],
        if (expenseHistory.isNotEmpty) ...[
          _buildExpenseTotalChart(),
          const SizedBox(height: 24),
          _buildExpenseCategoryChart(),
        ],
      ],
    );
  }

  Widget _buildStressChart() {
    final sorted = stressHistory.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final entries = sorted.length > 12 ? sorted.sublist(sorted.length - 12) : sorted;

    final spots = <FlSpot>[];
    final labels = <int, String>{};
    for (var i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].value.toDouble()));
      final parts = entries[i].key.split('-');
      final monthNum = int.parse(parts[1]);
      labels[i] = _monthNames[monthNum];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ÍNDICE DE TRANQUILIDADE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: Colors.grey.shade400, letterSpacing: 1.2),
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
                    color: const Color(0xFFF1F5F9),
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
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
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
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
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
                    HorizontalRangeAnnotation(y1: 0, y2: 39, color: const Color(0xFFFEF2F2)),
                    HorizontalRangeAnnotation(y1: 40, y2: 59, color: const Color(0xFFFFFBEB)),
                    HorizontalRangeAnnotation(y1: 60, y2: 79, color: const Color(0xFFEFF6FF)),
                    HorizontalRangeAnnotation(y1: 80, y2: 100, color: const Color(0xFFECFDF5)),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: const Color(0xFF3B82F6),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        final isLast = spot.x == spots.last.x;
                        return FlDotCirclePainter(
                          radius: isLast ? 5 : 3,
                          color: _scoreColor(spot.y.toInt()),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
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
                        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
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
              _zoneDot(const Color(0xFFEF4444), 'Crítico'),
              const SizedBox(width: 12),
              _zoneDot(const Color(0xFFF59E0B), 'Atenção'),
              const SizedBox(width: 12),
              _zoneDot(const Color(0xFF3B82F6), 'Bom'),
              const SizedBox(width: 12),
              _zoneDot(const Color(0xFF10B981), 'Excelente'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Total expenses bar chart ────────────────────────────────────────

  Widget _buildExpenseTotalChart() {
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESPESAS TOTAIS',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: Colors.grey.shade400, letterSpacing: 1.2),
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
                            : const Color(0xFF3B82F6),
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
                          color: const Color(0xFF94A3B8),
                          strokeWidth: 1,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                            labelResolver: (_) => 'Atual: ${formatCurrency(currentTotalExpenses)}',
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
                            child: Text(_monthNames[monthNum],
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
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
                        const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
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

  Widget _buildExpenseCategoryChart() {
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
            _categoryColors[cat] ?? const Color(0xFF94A3B8),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESPESAS POR CATEGORIA',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: Colors.grey.shade400, letterSpacing: 1.2),
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
                            child: Text(_monthNames[monthNum],
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
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
                          final label = _categoryLabels[cat] ?? cat;
                          lines.add('$label: ${formatCurrency(amount)}');
                        }
                      }
                      lines.add('Total: ${formatCurrency(rod.toY)}');
                      return BarTooltipItem(
                        lines.join('\n'),
                        const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
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
              _categoryColors[cat] ?? const Color(0xFF94A3B8),
              _categoryLabels[cat] ?? cat,
            )).toList(),
          ),
        ],
      ),
    );
  }

  static Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFF3B82F6);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Widget _zoneDot(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      );
}
