import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../utils/formatters.dart';
import '../widgets/charts/budget_charts.dart';

class DashboardScreen extends StatelessWidget {
  final AppSettings settings;
  final BudgetSummary summary;
  final VoidCallback onOpenSettings;

  const DashboardScreen({
    super.key,
    required this.settings,
    required this.summary,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = summary.totalGross > 0;
    final isPositive = summary.netLiquidity >= 0;

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
                    if (hasData) _buildHeroCard(isPositive) else _buildEmptyState(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              if (hasData) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      if (settings.dashboardConfig.showSummaryCards) _buildSummaryCards(),
                      const SizedBox(height: 16),
                      _buildSalaryBreakdown(),
                      if (summary.totalExpenses > 0) ...[
                        const SizedBox(height: 16),
                        _buildExpensesBreakdown(),
                      ],
                      const SizedBox(height: 16),
                      BudgetCharts(
                        summary: summary,
                        expenses: settings.expenses,
                        enabledCharts: settings.dashboardConfig.enabledCharts,
                      ),
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
          if (summary.salary1.grossAmount > 0)
            _SalaryRow(
              label: settings.salaries[0].label.isNotEmpty ? settings.salaries[0].label : 'Vencimento 1',
              calc: summary.salary1,
            ),
          if (summary.salary2.grossAmount > 0) ...[
            const SizedBox(height: 12),
            _SalaryRow(
              label: settings.salaries.length > 1 && settings.salaries[1].label.isNotEmpty
                  ? settings.salaries[1].label
                  : 'Vencimento 2',
              calc: summary.salary2,
            ),
          ],
        ],
      ),
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

class _SalaryRow extends StatelessWidget {
  final String label;
  final SalaryCalculation calc;
  const _SalaryRow({required this.label, required this.calc});

  @override
  Widget build(BuildContext context) {
    final hasMeal = calc.mealAllowance.totalMonthly > 0;
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
                    Text('Bruto', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade400)),
                    const SizedBox(height: 2),
                    Text(formatCurrency(calc.grossAmount), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
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
        ],
      ),
    );
  }
}
