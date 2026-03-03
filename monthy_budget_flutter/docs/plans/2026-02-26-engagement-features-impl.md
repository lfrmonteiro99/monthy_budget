# Engagement Features Implementation Plan — Trends & Projections

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add historical trend visualization (stress index + spending) and interactive what-if projections (food + expense simulator) to the Dashboard, triggered by tapping existing cards.

**Architecture:** Two new widget files (`trend_sheet.dart`, `projection_sheet.dart`) opened as DraggableScrollableSheet bottom sheets from existing Dashboard cards. Pure client-side calculations reusing `calculateBudgetSummary()` and `calculateStressIndex()`. No new API calls, Supabase tables, tabs, or navigation destinations.

**Tech Stack:** Flutter, fl_chart (already in pubspec), Dart

---

### Task 1: Add `spentByMonth()` helper to PurchaseHistory

**Files:**
- Modify: `lib/models/purchase_record.dart:38-57`

**Context:** The trend sheet needs monthly spending aggregation. `PurchaseHistory` already has `spentInMonth(year, month)` for a single month. We need a method that returns the last N months as a map for charting.

**Step 1: Add the helper method**

In `lib/models/purchase_record.dart`, add this method to the `PurchaseHistory` class, right after the existing `spentInMonth` method (after line 45):

```dart
  /// Returns a map of 'YYYY-MM' → total spent for each month that has records,
  /// sorted chronologically, limited to the last [months] months.
  Map<String, double> spentByMonth({int months = 6}) {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - months + 1);
    final map = <String, double>{};
    for (final r in records) {
      if (r.date.isBefore(cutoff)) continue;
      final key = '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}';
      map[key] = (map[key] ?? 0) + r.amount;
    }
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted;
  }
```

**Step 2: Verify it compiles**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter analyze lib/models/purchase_record.dart`
Expected: No new errors.

---

### Task 2: Create the Trend Sheet widget

**Files:**
- Create: `lib/widgets/trend_sheet.dart`

**Context:** This is a DraggableScrollableSheet bottom sheet containing two fl_chart charts: a stress index line chart and a monthly spending bar chart. It receives data via constructor params — no services or state management.

**Step 1: Create the file**

Create `lib/widgets/trend_sheet.dart` with the following content:

```dart
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/formatters.dart';

const _monthNames = [
  '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
  'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
];

/// Opens the trend bottom sheet from a parent context.
void showTrendSheet({
  required BuildContext context,
  required Map<String, int> stressHistory,
  required Map<String, double> spendingByMonth,
  required double currentFoodBudget,
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
        spendingByMonth: spendingByMonth,
        currentFoodBudget: currentFoodBudget,
      ),
    ),
  );
}

class _TrendSheetContent extends StatelessWidget {
  final ScrollController scrollController;
  final Map<String, int> stressHistory;
  final Map<String, double> spendingByMonth;
  final double currentFoodBudget;

  const _TrendSheetContent({
    required this.scrollController,
    required this.stressHistory,
    required this.spendingByMonth,
    required this.currentFoodBudget,
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
        if (spendingByMonth.isNotEmpty) _buildSpendingChart(),
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
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      getDotPainter: (spot, _, __, ___) {
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

  Widget _buildSpendingChart() {
    final entries = spendingByMonth.entries.toList();
    final maxSpend = entries.map((e) => e.value).fold(0.0, math.max);
    final maxY = math.max(maxSpend, currentFoodBudget) * 1.2;

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
            'GASTOS MENSAIS',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: Colors.grey.shade400, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: List.generate(entries.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: entries[i].value,
                        color: entries[i].value > currentFoodBudget
                            ? const Color(0xFFF87171)
                            : const Color(0xFF34D399),
                        width: entries.length <= 6 ? 28 : 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
                extraLinesData: currentFoodBudget > 0
                    ? ExtraLinesData(horizontalLines: [
                        HorizontalLine(
                          y: currentFoodBudget,
                          color: const Color(0xFF94A3B8),
                          strokeWidth: 1,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                            labelResolver: (_) => 'Orçamento: ${formatCurrency(currentFoodBudget)}',
                          ),
                        ),
                      ])
                    : ExtraLinesData(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < entries.length) {
                          final parts = entries[idx].key.split('-');
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
                gridData: FlGridData(show: false),
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
          if (currentFoodBudget > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _zoneDot(const Color(0xFF34D399), 'Dentro orçamento'),
                const SizedBox(width: 16),
                _zoneDot(const Color(0xFFF87171), 'Acima orçamento'),
              ],
            ),
          ],
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
```

**Step 2: Verify it compiles**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter analyze lib/widgets/trend_sheet.dart`
Expected: No errors.

---

### Task 3: Create the Projection Sheet widget

**Files:**
- Create: `lib/widgets/projection_sheet.dart`

**Context:** This is a DraggableScrollableSheet containing two panels: (1) food spending projection with slider + scenario chips, and (2) expense what-if simulator. It uses `calculateBudgetSummary()` and `calculateStressIndex()` to compute simulated values. The widget is stateful because it needs to react to slider/toggle changes.

**Step 1: Create the file**

Create `lib/widgets/projection_sheet.dart` with the following content:

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../models/purchase_record.dart';
import '../utils/calculations.dart';
import '../utils/formatters.dart';
import '../utils/stress_index.dart';

const _monthNames = [
  '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
];

/// Opens the projection simulator bottom sheet.
void showProjectionSheet({
  required BuildContext context,
  required AppSettings settings,
  required BudgetSummary summary,
  required PurchaseHistory purchaseHistory,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => _ProjectionSheetContent(
        scrollController: scrollController,
        settings: settings,
        summary: summary,
        purchaseHistory: purchaseHistory,
      ),
    ),
  );
}

class _ProjectionSheetContent extends StatefulWidget {
  final ScrollController scrollController;
  final AppSettings settings;
  final BudgetSummary summary;
  final PurchaseHistory purchaseHistory;

  const _ProjectionSheetContent({
    required this.scrollController,
    required this.settings,
    required this.summary,
    required this.purchaseHistory,
  });

  @override
  State<_ProjectionSheetContent> createState() => _ProjectionSheetContentState();
}

class _ProjectionSheetContentState extends State<_ProjectionSheetContent> {
  late double _dailySpend;
  late double _globalReduction;
  late Map<String, bool> _expenseEnabled;
  late Map<String, double> _expenseAmounts;

  // Precomputed constants
  late final DateTime _now;
  late final int _dayOfMonth;
  late final int _daysInMonth;
  late final int _daysRemaining;
  late final double _foodBudget;
  late final double _foodSpent;
  late final double _dailyAvg;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _dayOfMonth = _now.day;
    _daysInMonth = DateTime(_now.year, _now.month + 1, 0).day;
    _daysRemaining = _daysInMonth - _dayOfMonth;

    _foodBudget = widget.settings.expenses
        .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
        .fold(0.0, (s, e) => s + e.amount);
    _foodSpent = widget.purchaseHistory.spentInMonth(_now.year, _now.month);
    _dailyAvg = _dayOfMonth > 0 ? _foodSpent / _dayOfMonth : 0;
    _dailySpend = _dailyAvg;

    _globalReduction = 0;
    _expenseEnabled = {
      for (final e in widget.settings.expenses) e.id: e.enabled,
    };
    _expenseAmounts = {
      for (final e in widget.settings.expenses) e.id: e.amount,
    };
  }

  double get _projectedTotal => _foodSpent + (_dailySpend * _daysRemaining);
  double get _projectedRemaining => _foodBudget - _projectedTotal;

  StressIndexResult _simulateStress({double? simulatedFoodSpent, List<ExpenseItem>? simulatedExpenses}) {
    final simSummary = calculateBudgetSummary(
      widget.settings.salaries,
      widget.settings.personalInfo,
      simulatedExpenses ?? widget.settings.expenses,
    );
    final simHistory = simulatedFoodSpent != null
        ? _buildSimulatedHistory(simulatedFoodSpent)
        : widget.purchaseHistory;
    return calculateStressIndex(
      summary: simSummary,
      purchaseHistory: simHistory,
      settings: widget.settings,
    );
  }

  PurchaseHistory _buildSimulatedHistory(double simulatedTotal) {
    // Replace current month's records with a single simulated record
    final otherRecords = widget.purchaseHistory.records
        .where((r) => !(r.date.year == _now.year && r.date.month == _now.month))
        .toList();
    return PurchaseHistory(records: [
      PurchaseRecord(
        id: 'simulated',
        date: _now,
        amount: simulatedTotal,
        itemCount: 0,
      ),
      ...otherRecords,
    ]);
  }

  List<ExpenseItem> get _simulatedExpenses {
    return widget.settings.expenses.map((e) {
      final enabled = _expenseEnabled[e.id] ?? e.enabled;
      final baseAmount = _expenseAmounts[e.id] ?? e.amount;
      final amount = baseAmount * (1 - _globalReduction / 100);
      return e.copyWith(enabled: enabled, amount: amount);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
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
        Text(
          'Projeção — ${_monthNames[_now.month]} ${_now.year}',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Gastou ${formatCurrency(_foodSpent)} de ${formatCurrency(_foodBudget)} em $_dayOfMonth dias',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 20),
        _buildFoodSection(),
        const SizedBox(height: 24),
        _buildExpenseSection(),
      ],
    );
  }

  // ── Food projection panel ───────────────────────────────────────────────

  Widget _buildFoodSection() {
    final currentStress = _simulateStress();
    final simStress = _simulateStress(simulatedFoodSpent: _projectedTotal);
    final delta = simStress.score - currentStress.score;
    final sliderMax = _foodBudget > 0 ? _foodBudget * 1.5 / math.max(_daysRemaining, 1) : _dailyAvg * 3;

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
          Text('ALIMENTAÇÃO', style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600,
            color: Colors.grey.shade400, letterSpacing: 1.2,
          )),
          const SizedBox(height: 16),

          // Scenario chips
          Wrap(
            spacing: 8,
            children: [
              _scenarioChip('Ritmo atual', _dailyAvg),
              _scenarioChip('Sem compras', 0),
              _scenarioChip('-20%', _dailyAvg * 0.8),
            ],
          ),
          const SizedBox(height: 16),

          // Slider
          Text(
            'Gasto diário estimado: ${formatCurrency(_dailySpend)}/dia',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
          ),
          Slider(
            value: _dailySpend.clamp(0, sliderMax),
            min: 0,
            max: sliderMax > 0 ? sliderMax : 1,
            activeColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _dailySpend = v),
          ),
          const SizedBox(height: 12),

          // Results
          _resultRow('Projeção fim de mês', formatCurrency(_projectedTotal),
              _projectedTotal > _foodBudget ? const Color(0xFFEF4444) : const Color(0xFF1E293B)),
          const SizedBox(height: 8),
          _resultRow(
            'Restante projetado',
            '${_projectedRemaining >= 0 ? '' : '-'}${formatCurrency(_projectedRemaining.abs())}',
            _projectedRemaining >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
          const SizedBox(height: 8),
          _resultRow(
            'Impacto no Índice',
            '${delta >= 0 ? '+' : ''}$delta pts (${simStress.score}/100)',
            delta >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _scenarioChip(String label, double dailyValue) {
    final isActive = (_dailySpend - dailyValue).abs() < 0.01;
    return ActionChip(
      label: Text(label, style: TextStyle(
        fontSize: 12,
        color: isActive ? Colors.white : const Color(0xFF475569),
        fontWeight: FontWeight.w500,
      )),
      backgroundColor: isActive ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => setState(() => _dailySpend = dailyValue),
    );
  }

  // ── Expense what-if panel ───────────────────────────────────────────────

  Widget _buildExpenseSection() {
    final simExpenses = _simulatedExpenses;
    final simSummary = calculateBudgetSummary(
      widget.settings.salaries,
      widget.settings.personalInfo,
      simExpenses,
    );
    final simStress = _simulateStress(simulatedExpenses: simExpenses);
    final currentStress = _simulateStress();
    final liquidityDelta = simSummary.netLiquidity - widget.summary.netLiquidity;
    final stressDelta = simStress.score - currentStress.score;

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
          Row(
            children: [
              Text('DESPESAS', style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: Colors.grey.shade400, letterSpacing: 1.2,
              )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Simulação — não guardado',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                      color: Colors.orange.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Global reduction slider
          Row(
            children: [
              const Text('Reduzir todas em ', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
              Text('${_globalReduction.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
            ],
          ),
          Slider(
            value: _globalReduction,
            min: 0,
            max: 50,
            divisions: 10,
            activeColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _globalReduction = v),
          ),
          const SizedBox(height: 8),

          // Per-expense rows
          ...widget.settings.expenses
              .where((e) => e.amount > 0)
              .map((e) => _expenseRow(e)),
          const SizedBox(height: 16),

          // Results
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          _resultRow('Liquidez simulada', formatCurrency(simSummary.netLiquidity),
              simSummary.netLiquidity >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
          const SizedBox(height: 8),
          _resultRow(
            'Delta',
            '${liquidityDelta >= 0 ? '+' : ''}${formatCurrency(liquidityDelta)}/mês',
            liquidityDelta >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
          const SizedBox(height: 8),
          _resultRow(
            'Taxa poupança simulada',
            formatPercentage(simSummary.savingsRate > 0 ? simSummary.savingsRate : 0),
            const Color(0xFF475569),
          ),
          const SizedBox(height: 8),
          _resultRow(
            'Índice simulado',
            '${simStress.score}/100 (${stressDelta >= 0 ? '+' : ''}$stressDelta)',
            stressDelta >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _expenseRow(ExpenseItem expense) {
    final enabled = _expenseEnabled[expense.id] ?? expense.enabled;
    final baseAmount = _expenseAmounts[expense.id] ?? expense.amount;
    final displayAmount = baseAmount * (1 - _globalReduction / 100);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Switch(
              value: enabled,
              activeColor: const Color(0xFF3B82F6),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (v) => setState(() => _expenseEnabled[expense.id] = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              expense.label,
              style: TextStyle(
                fontSize: 13,
                color: enabled ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                decoration: enabled ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
          Text(
            formatCurrency(enabled ? displayAmount : 0),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: enabled ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: valueColor)),
      ],
    );
  }
}
```

**Step 2: Verify it compiles**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter analyze lib/widgets/projection_sheet.dart`
Expected: No errors.

---

### Task 4: Wire up Dashboard — add tap affordances and open sheets

**Files:**
- Modify: `lib/screens/dashboard_screen.dart`

**Context:** The Dashboard already has `_StressIndexCard` and `_buildFoodSpendingCard()`. We need to:
1. Add "Evolução" tap target to the stress index card
2. Add "Simular" tap target to the food spending card
3. Pass required data to each sheet

**Step 1: Add imports**

At the top of `lib/screens/dashboard_screen.dart`, add after the existing imports (after line 7):

```dart
import '../widgets/trend_sheet.dart';
import '../widgets/projection_sheet.dart';
```

**Step 2: Update `_StressIndexCard` to accept and invoke the trend sheet callback**

The `_StressIndexCard` widget (around line 797) needs a callback. Change its definition:

Replace the class declaration and constructor of `_StressIndexCard` (lines 797-799):

```dart
class _StressIndexCard extends StatefulWidget {
  final StressIndexResult result;
  final VoidCallback? onShowTrend;
  const _StressIndexCard({required this.result, this.onShowTrend});
```

Then in `_StressIndexCardState.build()`, after the existing "Ver detalhes" `GestureDetector` (around line 963-984), replace that entire `GestureDetector` block with a Row containing both "Detalhes" and "Evolução":

Replace the `GestureDetector` at the bottom of the card (the one with "Ver detalhes" / "Fechar") with:

```dart
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'Fechar' : 'Detalhes',
                      style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 16, color: const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
              if (widget.onShowTrend != null) ...[
                Container(
                  width: 1, height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: const Color(0xFFE2E8F0),
                ),
                GestureDetector(
                  onTap: widget.onShowTrend,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.show_chart, size: 14, color: Color(0xFF3B82F6)),
                      SizedBox(width: 4),
                      Text(
                        'Evolução',
                        style: TextStyle(
                          fontSize: 12, color: Color(0xFF3B82F6), fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
```

**Step 3: Update the `_StressIndexCard` instantiation in `build()`**

In the `build()` method (around line 117), change:

```dart
_StressIndexCard(result: stressResult),
```

to:

```dart
_StressIndexCard(
  result: stressResult,
  onShowTrend: stressResult.score > 0 ? () {
    final foodBudget = settings.expenses
        .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
        .fold(0.0, (s, e) => s + e.amount);
    showTrendSheet(
      context: context,
      stressHistory: settings.stressHistory,
      spendingByMonth: purchaseHistory.spentByMonth(),
      currentFoodBudget: foodBudget,
    );
  } : null,
),
```

**Step 4: Add "Simular" affordance to the food spending card**

In `_buildFoodSpendingCard()` (around line 336), find the header Row that has the green dot and 'ALIMENTACAO' text (lines 360-378). After that Row (after the closing `]` of the Row's children), add the "Simular" tap target. Replace just the Row widget containing the dot and "ALIMENTACAO" text:

```dart
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF34D399), shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'ALIMENTACAO',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B), letterSpacing: 0.8,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => showProjectionSheet(
                  context: context,
                  settings: settings,
                  summary: summary,
                  purchaseHistory: purchaseHistory,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_graph, size: 14, color: Color(0xFF3B82F6)),
                    SizedBox(width: 4),
                    Text(
                      'Simular',
                      style: TextStyle(
                        fontSize: 12, color: Color(0xFF3B82F6), fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
```

**Step 5: Verify everything compiles**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter analyze lib/`
Expected: No new errors (same pre-existing warnings as before).

---

### Task 5: Build APK and commit

**Step 1: Run full analysis**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter analyze lib/`
Expected: Only pre-existing warnings (unused_import for household_service, unused_field for _groceryData, etc.). Zero new errors.

**Step 2: Build the APK**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter build apk --release`
Expected: BUILD SUCCESSFUL.

**Step 3: Commit all changes**

Files to stage:
- `lib/models/purchase_record.dart` (modified — spentByMonth helper)
- `lib/widgets/trend_sheet.dart` (new — trend bottom sheet)
- `lib/widgets/projection_sheet.dart` (new — projection simulator)
- `lib/screens/dashboard_screen.dart` (modified — tap affordances + sheet wiring)

Commit message: `claude/budget-calculator-app-TFWgZ: add trend charts and projection simulator`

---

## File Dependency Graph

```
purchase_record.dart (Task 1 — add spentByMonth)
       ↓
trend_sheet.dart (Task 2 — uses spentByMonth output)
       ↓
projection_sheet.dart (Task 3 — uses calculations + stress_index)
       ↓
dashboard_screen.dart (Task 4 — imports both sheets, wires up)
       ↓
Build + Commit (Task 5)
```

Tasks must be done in order. Each builds on the previous.
