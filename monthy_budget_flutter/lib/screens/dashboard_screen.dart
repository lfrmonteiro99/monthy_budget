import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/actual_expense.dart';
import '../models/budget_summary.dart';
import '../models/purchase_record.dart';
import '../utils/formatters.dart';
import '../utils/stress_index.dart';
import '../widgets/charts/budget_charts.dart';
import '../widgets/trend_sheet.dart';
import '../widgets/projection_sheet.dart';
import '../models/local_dashboard_config.dart';
import '../models/expense_snapshot.dart';
import '../utils/month_review.dart';
import '../widgets/month_review_sheet.dart';

class DashboardScreen extends StatelessWidget {
  final AppSettings settings;
  final BudgetSummary summary;
  final PurchaseHistory purchaseHistory;
  final VoidCallback onOpenSettings;
  final ValueChanged<AppSettings> onSaveSettings;
  final LocalDashboardConfig dashboardConfig;
  final Map<String, List<ExpenseSnapshot>> expenseHistory;
  final VoidCallback onSnapshotExpenses;
  final List<ActualExpense> actualExpenses;
  final VoidCallback onAddExpense;
  final VoidCallback onOpenExpenseTracker;

  const DashboardScreen({
    super.key,
    required this.settings,
    required this.summary,
    required this.purchaseHistory,
    required this.onOpenSettings,
    required this.onSaveSettings,
    required this.dashboardConfig,
    required this.expenseHistory,
    required this.onSnapshotExpenses,
    required this.actualExpenses,
    required this.onAddExpense,
    required this.onOpenExpenseTracker,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = summary.totalGross > 0;
    final isPositive = summary.netLiquidity >= 0;

    // Stress Index — calculate and persist if changed
    final stressResult = calculateStressIndex(
      summary: summary,
      purchaseHistory: purchaseHistory,
      settings: settings,
    );
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final l10n = S.of(context);
    final monthReview = buildMonthReview(
      expenseHistory: expenseHistory,
      currentExpenses: settings.expenses,
      purchaseHistory: purchaseHistory,
      now: now,
      monthLabelBuilder: (m, y) => '${localizedMonthFull(l10n, m)} $y',
    );
    final foodBudgetTotal = settings.expenses
        .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
        .fold(0.0, (s, e) => s + e.amount);
    final foodSpentTotal = purchaseHistory.spentInMonth(now.year, now.month);
    final paceResult = foodBudgetTotal > 0 && foodSpentTotal > 0
        ? checkBudgetPace(foodBudget: foodBudgetTotal, foodSpent: foodSpentTotal, now: now)
        : null;
    if (hasData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (settings.stressHistory[monthKey] != stressResult.score) {
          final updated = Map<String, int>.from(settings.stressHistory)
            ..[monthKey] = stressResult.score;
          onSaveSettings(settings.copyWith(stressHistory: updated));
        }
        onSnapshotExpenses();
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.dashboardTitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.dashboardFinancialSummary,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade400,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Semantics(
                            button: true,
                            label: l10n.dashboardOpenSettings,
                            child: Material(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: onOpenSettings,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.settings, size: 20, color: Colors.grey.shade500),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (hasData && dashboardConfig.showHeroCard) _buildHeroCard(isPositive, l10n)
                    else if (!hasData) _buildEmptyState(l10n),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              if (hasData) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      if (dashboardConfig.showStressIndex)
                        _StressIndexCard(
                          result: stressResult,
                          onShowTrend: stressResult.score > 0 ? () {
                            showTrendSheet(
                              context: context,
                              stressHistory: settings.stressHistory,
                              expenseHistory: expenseHistory,
                              currentTotalExpenses: summary.totalExpenses,
                            );
                          } : null,
                        ),
                      if (dashboardConfig.showStressIndex) const SizedBox(height: 16),
                      if (monthReview != null)
                        _MonthReviewCard(
                          review: monthReview,
                          onTap: () => showMonthReviewSheet(
                            context: context,
                            review: monthReview,
                          ),
                        ),
                      if (monthReview != null) const SizedBox(height: 16),
                      if (dashboardConfig.showSummaryCards) _buildSummaryCards(l10n),
                      if (dashboardConfig.showSummaryCards) const SizedBox(height: 16),
                      if (dashboardConfig.showSalaryBreakdown) _buildSalaryBreakdown(l10n),
                      if (dashboardConfig.showFoodSpending) _buildFoodSpendingCard(context),
                      if (paceResult != null && paceResult.isOverPace)
                        _BudgetPaceAlert(pace: paceResult),
                      if (dashboardConfig.showBudgetVsActual) ...[
                        const SizedBox(height: 16),
                        _buildBudgetVsActualCard(context),
                      ],
                      if (dashboardConfig.showPurchaseHistory && purchaseHistory.records.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildPurchaseHistoryCard(context),
                      ],
                      if (dashboardConfig.showExpensesBreakdown && summary.totalExpenses > 0) ...[
                        const SizedBox(height: 16),
                        _buildExpensesBreakdown(l10n),
                      ],
                      if (dashboardConfig.showCharts) ...[
                        const SizedBox(height: 16),
                        BudgetCharts(
                          summary: summary,
                          expenses: settings.expenses,
                          enabledCharts: dashboardConfig.enabledCharts,
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(bool isPositive, S l10n) {
    return Semantics(
      label: l10n.dashboardHeroLabel(formatCurrency(summary.netLiquidity), isPositive ? l10n.dashboardPositiveBalance : l10n.dashboardNegativeBalance),
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Text(
            l10n.dashboardMonthlyLiquidity,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(summary.netLiquidity),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPositive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 13,
                  color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                ),
                const SizedBox(width: 4),
                Text(
                  isPositive ? l10n.dashboardPositiveBalance : l10n.dashboardNegativeBalance,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildEmptyState(S l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        children: [
          Icon(Icons.monetization_on_outlined, size: 40, color: Colors.blue.shade200),
          const SizedBox(height: 12),
          Text(
            l10n.dashboardConfigureData,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onOpenSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: Text(l10n.dashboardOpenSettingsButton, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(S l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.account_balance_wallet,
                label: l10n.dashboardGrossIncome,
                value: formatCurrency(summary.totalGross),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.arrow_circle_up,
                label: l10n.dashboardNetIncome,
                value: formatCurrency(summary.totalNetWithMeal),
                sublabel: summary.totalMealAllowance > 0
                    ? l10n.dashboardInclMealAllowance(formatCurrency(summary.totalMealAllowance))
                    : null,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.arrow_circle_down,
                label: l10n.dashboardDeductions,
                value: formatCurrency(summary.totalDeductions),
                sublabel: l10n.dashboardIrsSs(formatCurrency(summary.totalIRS), formatCurrency(summary.totalSS)),
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.savings,
                label: l10n.dashboardSavingsRate,
                value: formatPercentage(summary.savingsRate > 0 ? summary.savingsRate : 0),
                sublabel: l10n.dashboardExpensesAmount(formatCurrency(summary.totalExpenses)),
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalaryBreakdown(S l10n) {
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
            l10n.dashboardSalaryDetail,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade400, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          ...List.generate(summary.salaries.length, (i) {
            final calc = summary.salaries[i];
            final hasGross = calc.effectiveGrossAmount > 0;
            final hasAnyIncome = hasGross || calc.otherExemptIncome > 0;
            if (!hasAnyIncome) return const SizedBox.shrink();
            final label = i < settings.salaries.length && settings.salaries[i].label.isNotEmpty
                ? settings.salaries[i].label
                : l10n.dashboardSalaryN(i + 1);
            return Padding(
              padding: EdgeInsets.only(top: i > 0 ? 12 : 0),
              child: hasGross
                  ? _SalaryRow(label: label, calc: calc)
                  : _ExemptIncomeRow(label: label, amount: calc.otherExemptIncome),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFoodSpendingCard(BuildContext context) {
    final now = DateTime.now();
    final foodBudget = settings.expenses
        .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
        .fold(0.0, (s, e) => s + e.amount);

    if (foodBudget <= 0) return const SizedBox();

    final spent = purchaseHistory.spentInMonth(now.year, now.month);
    final remaining = foodBudget - spent;
    final progress = (spent / foodBudget).clamp(0.0, 1.0);
    final isOver = spent > foodBudget;

    return Container(
      margin: const EdgeInsets.only(top: 16),
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
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF34D399),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  S.of(context).dashboardFood,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8),
                ),
              ),
              TextButton.icon(
                onPressed: () => showProjectionSheet(
                  context: context,
                  settings: settings,
                  summary: summary,
                  purchaseHistory: purchaseHistory,
                ),
                icon: const Icon(Icons.auto_graph, size: 14),
                label: Text(
                  S.of(context).dashboardSimulate,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(48, 40),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _foodStatColumn(
                  S.of(context).dashboardBudgeted, formatCurrency(foodBudget), const Color(0xFF64748B)),
              _foodStatColumn(S.of(context).dashboardSpent, formatCurrency(spent),
                  isOver ? const Color(0xFFEF4444) : const Color(0xFF1E293B)),
              _foodStatColumn(
                  S.of(context).dashboardRemaining,
                  isOver
                      ? '-${formatCurrency(spent - foodBudget)}'
                      : formatCurrency(remaining),
                  isOver ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE2E8F0),
            color: isOver ? const Color(0xFFEF4444) : const Color(0xFF34D399),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          if (spent == 0) ...[
            const SizedBox(height: 8),
            Text(
              S.of(context).dashboardFinalizePurchaseHint,
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBudgetVsActualCard(BuildContext context) {
    final l10n = S.of(context);
    final summaries = CategoryBudgetSummary.buildSummaries(
      settings.expenses,
      actualExpenses,
    );
    final totalBudgeted = summaries.fold(0.0, (s, e) => s + e.budgeted);
    final totalActual = summaries.fold(0.0, (s, e) => s + e.actual);

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
              const Icon(Icons.compare_arrows,
                  size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.expenseTrackerTitle,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8),
                ),
              ),
              TextButton(
                onPressed: onOpenExpenseTracker,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(48, 40),
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                child: Text(l10n.expenseTrackerViewAll),
              ),
            ],
          ),
          if (actualExpenses.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.expenseTrackerNoExpenses,
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ] else ...[
            const SizedBox(height: 12),
            ...summaries.where((s) => s.actual > 0 || s.budgeted > 0).take(6).map((s) {
              final progressColor = s.isOver
                  ? const Color(0xFFEF4444)
                  : s.progress > 0.8
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF10B981);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_budgetCategoryIcon(s.category),
                            size: 14, color: const Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _budgetCategoryLabel(s.category, l10n),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B)),
                          ),
                        ),
                        Text(
                          s.isOver
                              ? '-${formatCurrency(s.remaining.abs())}'
                              : formatCurrency(s.remaining),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: s.isOver
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: s.progress.clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: progressColor,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${formatCurrency(s.actual)} / ${formatCurrency(s.budgeted)}',
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.expenseTrackerBudgeted}: ${formatCurrency(totalBudgeted)}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B)),
                ),
                Text(
                  '${l10n.expenseTrackerActual}: ${formatCurrency(totalActual)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: totalActual > totalBudgeted
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static IconData _budgetCategoryIcon(String catName) {
    try {
      final cat = ExpenseCategory.values.firstWhere((c) => c.name == catName);
      switch (cat) {
        case ExpenseCategory.telecomunicacoes: return Icons.phone;
        case ExpenseCategory.energia: return Icons.bolt;
        case ExpenseCategory.agua: return Icons.water_drop;
        case ExpenseCategory.alimentacao: return Icons.restaurant;
        case ExpenseCategory.educacao: return Icons.school;
        case ExpenseCategory.habitacao: return Icons.home;
        case ExpenseCategory.transportes: return Icons.directions_car;
        case ExpenseCategory.saude: return Icons.local_hospital;
        case ExpenseCategory.lazer: return Icons.sports_esports;
        case ExpenseCategory.outros: return Icons.more_horiz;
      }
    } catch (_) {
      return Icons.label_outline;
    }
  }

  static String _budgetCategoryLabel(String catName, S l10n) {
    try {
      final cat = ExpenseCategory.values.firstWhere((c) => c.name == catName);
      return cat.localizedLabel(l10n);
    } catch (_) {
      return catName;
    }
  }

  Widget _buildPurchaseHistoryCard(BuildContext context) {
    final recent = purchaseHistory.records.take(5).toList();
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
              const Icon(Icons.receipt_long_outlined,
                  size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  S.of(context).dashboardPurchaseHistory,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8),
                ),
              ),
              TextButton(
                onPressed: () => _showAllHistory(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(48, 40),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                child: Text(S.of(context).dashboardViewAll),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recent.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${r.date.day}/${r.date.month}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).dashboardProductCount(r.itemCount),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B)),
                          ),
                          if (r.items.isNotEmpty)
                            Text(
                              r.items.take(3).join(', ') +
                                  (r.items.length > 3 ? '...' : ''),
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF94A3B8)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Text(
                      formatCurrency(r.amount),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showAllHistory(BuildContext context) {
    final expandedMap = <int, bool>{};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => StatefulBuilder(
          builder: (ctx, setLocalState) => Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    S.of(context).dashboardAllPurchases,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: purchaseHistory.records.length,
                  itemBuilder: (_, i) {
                    final r = purchaseHistory.records[i];
                    final isExpanded = expandedMap[i] ?? false;
                    return Semantics(
                      button: true,
                      label: S.of(context).dashboardPurchaseLabel('${r.date.day}/${r.date.month}/${r.date.year}', formatCurrency(r.amount)),
                      child: Material(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                      onTap: () =>
                          setLocalState(() => expandedMap[i] = !isExpanded),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${r.date.day}/${r.date.month}/${r.date.year}',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569)),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      formatCurrency(r.amount),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E293B)),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      size: 18,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!isExpanded)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  S.of(context).dashboardProductCount(r.itemCount),
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF94A3B8)),
                                ),
                              ),
                            if (isExpanded && r.items.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...r.items.map((name) => Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.circle,
                                            size: 4, color: Color(0xFF94A3B8)),
                                        const SizedBox(width: 8),
                                        Text(name,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF475569))),
                                      ],
                                    ),
                                  )),
                            ],
                          ],
                        ),
                      ),
                    ),
                    ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _foodStatColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: valueColor)),
      ],
    );
  }

  Widget _buildExpensesBreakdown(S l10n) {
    final activeExpenses = settings.expenses.where((e) => e.enabled && e.amount > 0).toList();
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
            l10n.dashboardMonthlyExpenses,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade400, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          ...activeExpenses.map((expense) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF8FAFC)))),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _categoryColor(expense.category),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Text(expense.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                            const SizedBox(width: 8),
                            Text(expense.category.label, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                          ],
                        ),
                      ),
                      Text(formatCurrency(expense.amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.dashboardTotal, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                Text(formatCurrency(summary.totalExpenses), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _categoryColor(ExpenseCategory category) {
    const colors = {
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
    return colors[category] ?? const Color(0xFF94A3B8);
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? sublabel;
  final MaterialColor color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: color.shade400, width: 3),
          top: const BorderSide(color: Color(0xFFF1F5F9)),
          right: const BorderSide(color: Color(0xFFF1F5F9)),
          bottom: const BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color.shade500),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade400)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B), letterSpacing: -0.3)),
          if (sublabel != null) ...[
            const SizedBox(height: 4),
            Text(sublabel!, style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
          ],
        ],
      ),
    );
  }
}

class _StressIndexCard extends StatefulWidget {
  final StressIndexResult result;
  final VoidCallback? onShowTrend;
  const _StressIndexCard({required this.result, this.onShowTrend});

  @override
  State<_StressIndexCard> createState() => _StressIndexCardState();
}

class _StressIndexCardState extends State<_StressIndexCard> {
  bool _expanded = false;

  String _localizedValueLabel(StressFactorResult f, S l10n) {
    switch (f.type) {
      case StressFactorType.food:
        return f.valueLabel.isEmpty ? l10n.stressNA : l10n.stressUsed(f.valueLabel);
      case StressFactorType.stability:
        return f.valueLabel == 'stable' ? l10n.stressStable : l10n.stressHigh;
      default:
        return f.valueLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final l10n = S.of(context);
    final color = _scoreColor(result.score);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.dashboardStressIndex.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade400,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${result.score}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        result.level.localizedLabel(l10n),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    if (result.delta != null)
                      Row(
                        children: [
                          Icon(
                            result.delta! > 0
                                ? Icons.arrow_upward
                                : result.delta! < 0
                                    ? Icons.arrow_downward
                                    : Icons.remove,
                            size: 12,
                            color: result.delta! > 0
                                ? const Color(0xFF10B981)
                                : result.delta! < 0
                                    ? const Color(0xFFEF4444)
                                    : Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            l10n.dashboardVsLastMonth('${result.delta! > 0 ? '+' : ''}${result.delta}'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: result.delta! > 0
                                  ? const Color(0xFF10B981)
                                  : result.delta! < 0
                                      ? const Color(0xFFEF4444)
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: result.score / 100.0,
            backgroundColor: const Color(0xFFE2E8F0),
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 10),
            ...result.factors.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        f.ok
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_outlined,
                        size: 16,
                        color: f.ok
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f.type.localizedLabel(l10n),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      Text(
                        _localizedValueLabel(f, l10n),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                ),
                label: Text(_expanded ? l10n.close : l10n.dashboardDetails),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  minimumSize: const Size(48, 40),
                ),
              ),
              if (widget.onShowTrend != null) ...[
                Container(
                  width: 1, height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: const Color(0xFFE2E8F0),
                ),
                TextButton.icon(
                  onPressed: widget.onShowTrend,
                  icon: const Icon(Icons.show_chart, size: 14),
                  label: Text(l10n.trendTitle),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    minimumSize: const Size(48, 40),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFF3B82F6);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

class _SalaryRow extends StatelessWidget {
  final String label;
  final SalaryCalculation calc;
  const _SalaryRow({required this.label, required this.calc});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final hasMeal = calc.mealAllowance.totalMonthly > 0;
    final hasSubsidy = calc.subsidyMonthlyBonus > 0;
    final hasExempt = calc.otherExemptIncome > 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
              Text(
                formatCurrency(calc.totalNetWithMeal),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasSubsidy ? l10n.dashboardGrossWithSubsidy : l10n.dashboardGross,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatCurrency(calc.effectiveGrossAmount),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dashboardIrsRate(formatPercentage(calc.irsRate)), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade400)),
                    const SizedBox(height: 2),
                    Text('-${formatCurrency(calc.irsRetention)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFF87171))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dashboardSsRate, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade400)),
                    const SizedBox(height: 2),
                    Text('-${formatCurrency(calc.socialSecurity)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFF59E0B))),
                  ],
                ),
              ),
            ],
          ),
          if (hasMeal) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.dashboardMealAllowance, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade400)),
                  Text(
                    '+${formatCurrency(calc.mealAllowance.netMealAllowance)}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                  ),
                ],
              ),
            ),
          ],
          if (hasExempt) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.dashboardExemptIncome, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade400)),
                Text(
                  '+${formatCurrency(calc.otherExemptIncome)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ExemptIncomeRow extends StatelessWidget {
  final String label;
  final double amount;
  const _ExemptIncomeRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8))),
              const SizedBox(height: 2),
              Text(l10n.dashboardExemptIncome, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            ],
          ),
          Text(
            '+${formatCurrency(amount)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }
}

class _BudgetPaceAlert extends StatelessWidget {
  final BudgetPaceResult pace;

  const _BudgetPaceAlert({required this.pace});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isWarning = pace.severity == 'warning';
    final borderColor = isWarning ? const Color(0xFFFBBF24) : const Color(0xFFEF4444);
    final bgColor = isWarning ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2);
    final iconColor = isWarning ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
    final title = isWarning
        ? l10n.dashboardPaceWarning
        : l10n.dashboardPaceCritical;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: iconColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dashboardPace, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                    const SizedBox(height: 2),
                    Text(
                      l10n.dashboardPaceValue(pace.dailyPace.toStringAsFixed(1), pace.expectedPace.toStringAsFixed(1)),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(l10n.dashboardProjection, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                    const SizedBox(height: 2),
                    Text(
                      '+${pace.projectedOverspend.toStringAsFixed(0)}\u20ac',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: iconColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthReviewCard extends StatelessWidget {
  final MonthReviewResult review;
  final VoidCallback onTap;

  const _MonthReviewCard({required this.review, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isOver = review.totalDifference > 0;
    return Semantics(
      button: true,
      label: l10n.dashboardViewMonthSummary,
      child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment_outlined, size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${review.monthLabel.toUpperCase()} ${l10n.dashboardSummaryLabel}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.monthReviewPlanned, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      Text(formatCurrency(review.totalPlanned),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.monthReviewActual, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      Text(formatCurrency(review.totalActual),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(l10n.monthReviewDifference, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      Text(
                        '${isOver ? '+' : ''}${formatCurrency(review.totalDifference)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isOver ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }
}
