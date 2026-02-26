import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../models/purchase_record.dart';
import '../utils/formatters.dart';
import '../utils/stress_index.dart';
import '../widgets/charts/budget_charts.dart';
import '../widgets/trend_sheet.dart';
import '../widgets/projection_sheet.dart';
import '../models/local_dashboard_config.dart';
import '../models/expense_snapshot.dart';

class DashboardScreen extends StatelessWidget {
  final AppSettings settings;
  final BudgetSummary summary;
  final PurchaseHistory purchaseHistory;
  final VoidCallback onOpenSettings;
  final ValueChanged<AppSettings> onSaveSettings;
  final LocalDashboardConfig dashboardConfig;
  final Map<String, List<ExpenseSnapshot>> expenseHistory;
  final VoidCallback onSnapshotExpenses;

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
                              const Text(
                                'Orcamento Mensal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'RESUMO FINANCEIRO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade400,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Material(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: onOpenSettings,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.settings, size: 20, color: Colors.grey.shade500),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (hasData && dashboardConfig.showHeroCard) _buildHeroCard(isPositive)
                    else if (!hasData) _buildEmptyState(),
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
                      if (dashboardConfig.showSummaryCards) _buildSummaryCards(),
                      if (dashboardConfig.showSummaryCards) const SizedBox(height: 16),
                      if (dashboardConfig.showSalaryBreakdown) _buildSalaryBreakdown(),
                      if (dashboardConfig.showFoodSpending) _buildFoodSpendingCard(context),
                      if (dashboardConfig.showPurchaseHistory && purchaseHistory.records.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildPurchaseHistoryCard(context),
                      ],
                      if (dashboardConfig.showExpensesBreakdown && summary.totalExpenses > 0) ...[
                        const SizedBox(height: 16),
                        _buildExpensesBreakdown(),
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

  Widget _buildHeroCard(bool isPositive) {
    return Container(
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
            'LIQUIDEZ MENSAL',
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
                  isPositive ? 'Saldo positivo' : 'Saldo negativo',
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
    );
  }

  Widget _buildEmptyState() {
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
          const Text(
            'Configure os seus dados para ver o resumo.',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
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
            child: const Text('Abrir Definicoes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.account_balance_wallet,
                label: 'Rendimento Bruto',
                value: formatCurrency(summary.totalGross),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.arrow_circle_up,
                label: 'Rendimento Liquido',
                value: formatCurrency(summary.totalNetWithMeal),
                sublabel: summary.totalMealAllowance > 0
                    ? 'Incl. sub. alim.: ${formatCurrency(summary.totalMealAllowance)}'
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
                label: 'Descontos',
                value: formatCurrency(summary.totalDeductions),
                sublabel: 'IRS: ${formatCurrency(summary.totalIRS)} | SS: ${formatCurrency(summary.totalSS)}',
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.savings,
                label: 'Taxa Poupanca',
                value: formatPercentage(summary.savingsRate > 0 ? summary.savingsRate : 0),
                sublabel: 'Despesas: ${formatCurrency(summary.totalExpenses)}',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalaryBreakdown() {
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
            'DETALHE VENCIMENTOS',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade400, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          ...List.generate(summary.salaries.length, (i) {
            final calc = summary.salaries[i];
            if (calc.effectiveGrossAmount <= 0) return const SizedBox.shrink();
            final label = i < settings.salaries.length && settings.salaries[i].label.isNotEmpty
                ? settings.salaries[i].label
                : 'Vencimento ${i + 1}';
            return Padding(
              padding: EdgeInsets.only(top: i > 0 ? 12 : 0),
              child: _SalaryRow(label: label, calc: calc),
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
              const Expanded(
                child: Text(
                  'ALIMENTACAO',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _foodStatColumn(
                  'Orcado', formatCurrency(foodBudget), const Color(0xFF64748B)),
              _foodStatColumn('Gasto', formatCurrency(spent),
                  isOver ? const Color(0xFFEF4444) : const Color(0xFF1E293B)),
              _foodStatColumn(
                  'Restante',
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
            const Text(
              'Finaliza uma compra na Lista para registar gastos.',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ],
      ),
    );
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
              const Expanded(
                child: Text(
                  'HISTORICO DE COMPRAS',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8),
                ),
              ),
              GestureDetector(
                onTap: () => _showAllHistory(context),
                child: const Text(
                  'Ver tudo',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600),
                ),
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
                            '${r.itemCount} produto${r.itemCount != 1 ? 's' : ''}',
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
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Todas as Compras',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
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
                    return GestureDetector(
                      onTap: () =>
                          setLocalState(() => expandedMap[i] = !isExpanded),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
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
                                  '${r.itemCount} produto${r.itemCount != 1 ? 's' : ''}',
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

  Widget _buildExpensesBreakdown() {
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
            'DESPESAS MENSAIS',
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
                const Text('Total', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
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

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
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
                'ÍNDICE DE TRANQUILIDADE',
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
                        result.label,
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
                            '${result.delta! > 0 ? '+' : ''}${result.delta} vs mês passado',
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
                          f.label,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      Text(
                        f.valueLabel,
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
                      hasSubsidy ? 'Bruto c/ duodéc.' : 'Bruto',
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
                    Text('IRS (${formatPercentage(calc.irsRate)})', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade400)),
                    const SizedBox(height: 2),
                    Text('-${formatCurrency(calc.irsRetention)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFF87171))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SS (11%)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade400)),
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
                  Text('Sub. Alimentacao', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade400)),
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
                Text('Rend. Isento', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade400)),
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
