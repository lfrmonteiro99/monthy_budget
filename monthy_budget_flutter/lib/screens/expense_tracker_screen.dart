import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/actual_expense.dart';
import '../utils/formatters.dart';
import '../widgets/add_expense_sheet.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  final AppSettings settings;
  final List<ActualExpense> expenses;
  final String householdId;
  final Future<void> Function(ActualExpense) onAdd;
  final Future<void> Function(ActualExpense) onUpdate;
  final Future<void> Function(String) onDelete;
  final Future<List<ActualExpense>> Function(String monthKey) onLoadMonth;

  const ExpenseTrackerScreen({
    super.key,
    required this.settings,
    required this.expenses,
    required this.householdId,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
    required this.onLoadMonth,
  });

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  late DateTime _currentMonth;
  late List<ActualExpense> _expenses;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _expenses = List.of(widget.expenses);
  }

  Future<void> _navigateMonth(int delta) async {
    final next = DateTime(_currentMonth.year, _currentMonth.month + delta);
    setState(() {
      _currentMonth = next;
      _loading = true;
    });
    final newMonthKey =
        '${next.year}-${next.month.toString().padLeft(2, '0')}';
    final loaded = await widget.onLoadMonth(newMonthKey);
    if (mounted) {
      setState(() {
        _expenses = loaded;
        _loading = false;
      });
    }
  }

  Future<void> _addExpense() async {
    final result = await showAddExpenseSheet(
      context: context,
      budgetExpenses: widget.settings.expenses,
      currentExpenses: _expenses,
    );
    if (result != null && mounted) {
      await widget.onAdd(result);
      setState(() => _expenses = [..._expenses, result]
        ..sort((a, b) => b.date.compareTo(a.date)));
    }
  }

  Future<void> _editExpense(ActualExpense expense) async {
    final result = await showAddExpenseSheet(
      context: context,
      budgetExpenses: widget.settings.expenses,
      currentExpenses: _expenses,
      existing: expense,
    );
    if (result != null && mounted) {
      await widget.onUpdate(result);
      setState(() {
        _expenses = _expenses
            .map((e) => e.id == result.id ? result : e)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      });
    }
  }

  Future<void> _deleteExpense(ActualExpense expense) async {
    await widget.onDelete(expense.id);
    if (mounted) {
      setState(() {
        _expenses = _expenses.where((e) => e.id != expense.id).toList();
      });
    }
  }

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

  String _monthLabel(S l10n) {
    final monthNames = [
      l10n.monthFullJan,
      l10n.monthFullFeb,
      l10n.monthFullMar,
      l10n.monthFullApr,
      l10n.monthFullMay,
      l10n.monthFullJun,
      l10n.monthFullJul,
      l10n.monthFullAug,
      l10n.monthFullSep,
      l10n.monthFullOct,
      l10n.monthFullNov,
      l10n.monthFullDec,
    ];
    return '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final summaries = CategoryBudgetSummary.buildSummaries(
      widget.settings.expenses,
      _expenses,
    );
    final totalBudgeted = summaries.fold(0.0, (s, e) => s + e.budgeted);
    final totalActual = summaries.fold(0.0, (s, e) => s + e.actual);
    final diff = totalBudgeted - totalActual;
    final isOver = totalActual > totalBudgeted;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(l10n.expenseTrackerScreenTitle),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          // Month navigator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _loading ? null : () => _navigateMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  _monthLabel(l10n),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  onPressed: _loading ? null : () => _navigateMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // Summary header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryColumn(
                    label: l10n.expenseTrackerBudgeted,
                    value: formatCurrency(totalBudgeted),
                    color: const Color(0xFF64748B),
                  ),
                ),
                Expanded(
                  child: _SummaryColumn(
                    label: l10n.expenseTrackerActual,
                    value: formatCurrency(totalActual),
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Expanded(
                  child: _SummaryColumn(
                    label: isOver
                        ? l10n.expenseTrackerOver
                        : l10n.expenseTrackerRemaining,
                    value: isOver
                        ? '-${formatCurrency(diff.abs())}'
                        : formatCurrency(diff),
                    color: isOver
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF3B82F6)))
                : _expenses.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            l10n.expenseTrackerEmpty,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                              height: 1.5,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: summaries.length,
                        itemBuilder: (_, i) => _CategorySection(
                          summary: summaries[i],
                          expenses: _expenses
                              .where(
                                  (e) => e.category == summaries[i].category)
                              .toList(),
                          icon: _categoryIcon(summaries[i].category),
                          label:
                              _localizedCategory(summaries[i].category, l10n),
                          onEdit: _editExpense,
                          onDelete: _deleteExpense,
                          l10n: l10n,
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        backgroundColor: const Color(0xFF3B82F6),
        tooltip: l10n.addExpenseTooltip,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
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
}

class _CategorySection extends StatelessWidget {
  final CategoryBudgetSummary summary;
  final List<ActualExpense> expenses;
  final IconData icon;
  final String label;
  final Future<void> Function(ActualExpense) onEdit;
  final Future<void> Function(ActualExpense) onDelete;
  final S l10n;

  const _CategorySection({
    required this.summary,
    required this.expenses,
    required this.icon,
    required this.label,
    required this.onEdit,
    required this.onDelete,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = summary.isOver
        ? const Color(0xFFEF4444)
        : summary.progress > 0.8
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ExpansionTile(
        leading: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            Text(
              '${formatCurrency(summary.actual)} / ${formatCurrency(summary.budgeted)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: summary.isOver
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: summary.progress.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE2E8F0),
              color: progressColor,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 4),
            Text(
              summary.isOver
                  ? '${l10n.expenseTrackerOver}: -${formatCurrency(summary.remaining.abs())}'
                  : '${l10n.expenseTrackerRemaining}: ${formatCurrency(summary.remaining)}',
              style: TextStyle(
                fontSize: 11,
                color: summary.isOver
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        children: expenses.map((expense) {
          return Dismissible(
            key: ValueKey(expense.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.delete),
                  content: Text(l10n.expenseTrackerDeleteConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l10n.delete,
                          style: const TextStyle(color: Color(0xFFEF4444))),
                    ),
                  ],
                ),
              );
              return confirmed ?? false;
            },
            onDismissed: (_) => onDelete(expense),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              color: const Color(0xFFFEE2E2),
              child:
                  const Icon(Icons.delete, color: Color(0xFFEF4444), size: 20),
            ),
            child: ListTile(
              onTap: () => onEdit(expense),
              dense: true,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      expense.description ?? label,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formatCurrency(expense.amount),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                '${expense.date.day.toString().padLeft(2, '0')}/${expense.date.month.toString().padLeft(2, '0')}/${expense.date.year}',
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
