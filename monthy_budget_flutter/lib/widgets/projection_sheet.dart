import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../models/purchase_record.dart';
import '../theme/app_colors.dart';
import '../utils/calculations.dart';
import '../utils/formatters.dart';
import '../utils/stress_index.dart';
import '../data/tax/tax_factory.dart';
import '../l10n/generated/app_localizations.dart';

/// Opens the projection simulator bottom sheet.
void showProjectionSheet({
  required BuildContext context,
  required AppSettings settings,
  required BudgetSummary summary,
  required PurchaseHistory purchaseHistory,
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
    _daysRemaining = (_daysInMonth - _dayOfMonth).clamp(0, _daysInMonth);

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
    final taxSystem = getTaxSystem(widget.settings.country);
    final simSummary = calculateBudgetSummary(
      widget.settings.salaries,
      widget.settings.personalInfo,
      simulatedExpenses ?? widget.settings.expenses,
      taxSystem,
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
              color: AppColors.dragHandle(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Text(
          S.of(context).projectionTitle(localizedMonthFull(S.of(context), _now.month), '${_now.year}'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          S.of(context).projectionSubtitle(formatCurrency(_foodSpent), formatCurrency(_foodBudget), '$_dayOfMonth'),
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
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
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).projectionFood, style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600,
            color: AppColors.textMuted(context), letterSpacing: 1.2,
          )),
          const SizedBox(height: 16),

          // Scenario chips
          Wrap(
            spacing: 8,
            children: [
              _scenarioChip(S.of(context).projectionCurrentPace, _dailyAvg),
              _scenarioChip(S.of(context).projectionNoShopping, 0),
              _scenarioChip(S.of(context).projectionReduce20, _dailyAvg * 0.8),
            ],
          ),
          const SizedBox(height: 16),

          // Slider
          Text(
            S.of(context).projectionDailySpend(formatCurrency(_dailySpend)),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textLabel(context)),
          ),
          Slider(
            value: _dailySpend.clamp(0, sliderMax),
            min: 0,
            max: sliderMax > 0 ? sliderMax : 1,
            activeColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _dailySpend = v),
          ),
          const SizedBox(height: 12),

          // Results
          _resultRow(S.of(context).projectionEndOfMonth, formatCurrency(_projectedTotal),
              _projectedTotal > _foodBudget ? AppColors.error(context) : AppColors.textPrimary(context)),
          const SizedBox(height: 8),
          _resultRow(
            S.of(context).projectionRemaining,
            '${_projectedRemaining >= 0 ? '' : '-'}${formatCurrency(_projectedRemaining.abs())}',
            _projectedRemaining >= 0 ? AppColors.success(context) : AppColors.error(context),
          ),
          const SizedBox(height: 8),
          Tooltip(
            message: S.of(context).projectionStressHint,
            child: _resultRow(
              S.of(context).projectionStressImpact,
              '${delta >= 0 ? '+' : ''}$delta pts (${simStress.score}/100)',
              delta >= 0 ? AppColors.success(context) : AppColors.error(context),
            ),
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
        color: isActive ? AppColors.onPrimary(context) : AppColors.textLabel(context),
        fontWeight: FontWeight.w500,
      )),
      backgroundColor: isActive ? AppColors.primary(context) : AppColors.surfaceVariant(context),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => setState(() => _dailySpend = dailyValue),
    );
  }

  // ── Expense what-if panel ───────────────────────────────────────────────

  Widget _buildExpenseSection() {
    final simExpenses = _simulatedExpenses;
    final taxSystem = getTaxSystem(widget.settings.country);
    final simSummary = calculateBudgetSummary(
      widget.settings.salaries,
      widget.settings.personalInfo,
      simExpenses,
      taxSystem,
    );
    final simStress = _simulateStress(simulatedExpenses: simExpenses);
    final currentStress = _simulateStress();
    final liquidityDelta = simSummary.netLiquidity - widget.summary.netLiquidity;
    final stressDelta = simStress.score - currentStress.score;

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
          Row(
            children: [
              Text(S.of(context).projectionExpenses, style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textMuted(context), letterSpacing: 1.2,
              )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  S.of(context).projectionSimulation,
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
              Text(S.of(context).projectionReduceAll, style: TextStyle(fontSize: 13, color: AppColors.textLabel(context))),
              Text('${_globalReduction.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary(context))),
            ],
          ),
          Slider(
            value: _globalReduction,
            min: 0,
            max: 50,
            divisions: 10,
            activeColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _globalReduction = v),
          ),
          const SizedBox(height: 8),

          // Per-expense rows
          ...widget.settings.expenses
              .where((e) => e.amount > 0)
              .map((e) => _expenseRow(e)),
          const SizedBox(height: 16),

          // Results
          Divider(color: AppColors.border(context)),
          const SizedBox(height: 12),
          _resultRow(S.of(context).projectionSimLiquidity, formatCurrency(simSummary.netLiquidity),
              simSummary.netLiquidity >= 0 ? AppColors.success(context) : AppColors.error(context)),
          const SizedBox(height: 8),
          _resultRow(
            S.of(context).projectionDelta,
            '${liquidityDelta >= 0 ? '+' : ''}${formatCurrency(liquidityDelta)}/m\u00eas',
            liquidityDelta >= 0 ? AppColors.success(context) : AppColors.error(context),
          ),
          const SizedBox(height: 8),
          _resultRow(
            S.of(context).projectionSimSavingsRate,
            formatPercentage(simSummary.savingsRate > 0 ? simSummary.savingsRate : 0),
            AppColors.textLabel(context),
          ),
          const SizedBox(height: 8),
          Tooltip(
            message: S.of(context).projectionStressHint,
            child: _resultRow(
              S.of(context).projectionSimIndex,
              '${simStress.score}/100 (${stressDelta >= 0 ? '+' : ''}$stressDelta)',
              stressDelta >= 0 ? AppColors.success(context) : AppColors.error(context),
            ),
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
              activeTrackColor: AppColors.primary(context),
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
                color: enabled ? AppColors.textLabel(context) : AppColors.borderMuted(context),
                decoration: enabled ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
          Text(
            formatCurrency(enabled ? displayAmount : 0),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: enabled ? AppColors.textPrimary(context) : AppColors.borderMuted(context),
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
        Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: valueColor)),
      ],
    );
  }
}
