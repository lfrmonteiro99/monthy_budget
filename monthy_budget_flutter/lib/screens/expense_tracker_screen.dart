import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/actual_expense.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/export_bottom_sheet.dart';
import '../widgets/info_icon_button.dart';
import '../services/export_service.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  final AppSettings settings;
  final List<ActualExpense> expenses;
  final String householdId;
  final Future<void> Function(ActualExpense) onAdd;
  final Future<void> Function(ActualExpense) onUpdate;
  final Future<void> Function(String) onDelete;
  final Future<List<ActualExpense>> Function(String monthKey) onLoadMonth;
  final Future<Map<String, List<ActualExpense>>> Function()? onLoadHistory;
  final VoidCallback? onOpenRecurring;

  const ExpenseTrackerScreen({
    super.key,
    required this.settings,
    required this.expenses,
    required this.householdId,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
    required this.onLoadMonth,
    this.onLoadHistory,
    this.onOpenRecurring,
  });

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  late DateTime _currentMonth;
  late List<ActualExpense> _expenses;
  bool _loading = false;

  // Search state
  bool _searchActive = false;
  String _searchQuery = '';
  Set<String> _selectedCategories = {};
  DateTime? _dateFrom;
  DateTime? _dateTo;
  List<ActualExpense> _searchResults = [];
  Map<String, List<ActualExpense>>? _historyCache;
  bool _loadingHistory = false;

  final _searchController = TextEditingController();
  final _exportService = ExportService();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _expenses = List.of(widget.expenses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      onDelete: _deleteExpense,
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

  // --- Export ---

  Future<void> _exportMonth() async {
    final format = await showExportSheet(context);
    if (format == null || !mounted) return;

    final l10n = S.of(context);
    final summaries = CategoryBudgetSummary.buildSummaries(
      widget.settings.expenses,
      _expenses,
    );
    final label = _monthLabel(l10n);
    String catLabel(String name) => _localizedCategory(name, l10n);

    if (format == ExportFormat.pdf) {
      final bytes = await _exportService.generatePdf(
        monthLabel: label,
        summaries: summaries,
        expenses: _expenses,
        categoryLabelMap: catLabel,
        headerLabels: [
          l10n.addExpenseCategory,
          l10n.expenseTrackerBudgeted,
          l10n.expenseTrackerActual,
          l10n.expenseTrackerRemaining,
          l10n.addExpenseDate,
          l10n.addExpenseCategory,
          l10n.addExpenseDescription.replaceAll(RegExp(r'\s*\(.*\)'), ''),
          l10n.addExpenseAmount,
        ],
        formatCurrency: formatCurrency,
        reportTitle: l10n.exportReportTitle,
        budgetVsActualTitle: l10n.exportBudgetVsActual,
        expenseDetailTitle: l10n.exportExpenseDetail,
      );
      final file = await _exportService.writeTempFile(
        'expenses_${_currentMonth.year}_${_currentMonth.month.toString().padLeft(2, '0')}.pdf',
        bytes,
      );
      await Share.shareXFiles([XFile(file.path)]);
    } else {
      final csv = _exportService.generateCsv(
        expenses: _expenses,
        categoryLabelMap: catLabel,
        headerRow: [
          l10n.addExpenseDate,
          l10n.addExpenseCategory,
          l10n.addExpenseDescription.replaceAll(RegExp(r'\s*\(.*\)'), ''),
          l10n.addExpenseAmount,
        ],
      );
      final file = await _exportService.writeTempFile(
        'expenses_${_currentMonth.year}_${_currentMonth.month.toString().padLeft(2, '0')}.csv',
        utf8.encode(csv),
      );
      await Share.shareXFiles([XFile(file.path)]);
    }
  }

  // --- Search ---

  Future<void> _activateSearch() async {
    if (widget.onLoadHistory == null) return;

    setState(() {
      _searchActive = true;
      _loadingHistory = _historyCache == null;
    });

    if (_historyCache == null) {
      final history = await widget.onLoadHistory!();
      if (mounted) {
        setState(() {
          _historyCache = history;
          _loadingHistory = false;
        });
        _applyFilters();
      }
    } else {
      _applyFilters();
    }
  }

  void _deactivateSearch() {
    _searchController.clear();
    setState(() {
      _searchActive = false;
      _searchQuery = '';
      _selectedCategories = {};
      _dateFrom = null;
      _dateTo = null;
      _searchResults = [];
    });
  }

  void _applyFilters() {
    if (_historyCache == null) return;

    final allExpenses = _historyCache!.values.expand((l) => l).toList();
    final query = _searchQuery.toLowerCase();

    final filtered = allExpenses.where((e) {
      if (query.isNotEmpty) {
        final desc = (e.description ?? '').toLowerCase();
        if (!desc.contains(query)) return false;
      }
      if (_selectedCategories.isNotEmpty) {
        if (!_selectedCategories.contains(e.category)) return false;
      }
      if (_dateFrom != null && e.date.isBefore(_dateFrom!)) return false;
      if (_dateTo != null &&
          e.date.isAfter(_dateTo!.add(const Duration(days: 1)))) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    setState(() => _searchResults = filtered);
  }

  void _toggleCategory(String cat) {
    setState(() {
      if (_selectedCategories.contains(cat)) {
        _selectedCategories.remove(cat);
      } else {
        _selectedCategories.add(cat);
      }
    });
    _applyFilters();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _dateFrom != null && _dateTo != null
          ? DateTimeRange(start: _dateFrom!, end: _dateTo!)
          : null,
    );
    if (range != null && mounted) {
      setState(() {
        _dateFrom = range.start;
        _dateTo = range.end;
      });
      _applyFilters();
    }
  }

  Set<String> _allCategories() {
    if (_historyCache == null) return {};
    return _historyCache!.values
        .expand((l) => l)
        .map((e) => e.category)
        .toSet();
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    if (_searchActive) return _buildSearchView(l10n);
    return _buildNormalView(l10n);
  }

  Widget _buildNormalView(S l10n) {
    final summaries = CategoryBudgetSummary.buildSummaries(
      widget.settings.expenses,
      _expenses,
    );
    final totalBudgeted = summaries.fold(0.0, (s, e) => s + e.budgeted);
    final totalActual = summaries.fold(0.0, (s, e) => s + e.actual);
    final diff = totalBudgeted - totalActual;
    final isOver = totalActual > totalBudgeted;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(l10n.expenseTrackerScreenTitle),
        backgroundColor: AppColors.surface(context),
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: l10n.exportTooltip,
            onPressed: _exportMonth,
          ),
          if (widget.onLoadHistory != null)
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: l10n.searchExpenses,
              onPressed: _activateSearch,
            ),
          if (widget.onOpenRecurring != null)
            IconButton(
              icon: const Icon(Icons.repeat),
              tooltip: l10n.recurringExpenseManage,
              onPressed: widget.onOpenRecurring,
            ),
        ],
      ),
      body: Column(
        children: [
          // Month navigator
          Container(
            color: AppColors.surface(context),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
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
            color: AppColors.surface(context),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryColumn(
                    label: l10n.expenseTrackerBudgeted,
                    value: formatCurrency(totalBudgeted),
                    color: AppColors.textSecondary(context),
                  ),
                ),
                Expanded(
                  child: _SummaryColumn(
                    label: l10n.expenseTrackerActual,
                    value: formatCurrency(totalActual),
                    color: AppColors.textPrimary(context),
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
                        ? AppColors.error(context)
                        : AppColors.success(context),
                  ),
                ),
                InfoIconButton(
                  title: l10n.expenseTrackerScreenTitle,
                  body: l10n.infoExpenseTrackerSummary,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Category progress info
          if (_expenses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text(
                    l10n.expenseTrackerBudgeted,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted(context),
                      letterSpacing: 0.5,
                    ),
                  ),
                  InfoIconButton(
                    title: l10n.expenseTrackerBudgeted,
                    body: l10n.infoExpenseTrackerProgress,
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: _loading
                ? Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary(context)))
                : _expenses.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            l10n.expenseTrackerEmpty,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted(context),
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
        backgroundColor: AppColors.primary(context),
        tooltip: l10n.addExpenseTooltip,
        child: Icon(Icons.add, color: AppColors.onPrimary(context)),
      ),
    );
  }

  Widget _buildSearchView(S l10n) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _deactivateSearch,
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchExpensesHint,
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 16,
            ),
          ),
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 16,
          ),
          onChanged: (value) {
            _searchQuery = value;
            _applyFilters();
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _searchQuery = '';
                _applyFilters();
              },
            ),
        ],
      ),
      body: _loadingHistory
          ? Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary(context)))
          : Column(
              children: [
                // Category chips + date range
                Row(
                  children: [
                    Expanded(child: _buildFilterBar(l10n)),
                    InfoIconButton(
                      title: 'Filter',
                      body: l10n.infoExpenseTrackerFilter,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const Divider(height: 1),

                // Result count
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        l10n.searchResultCount(_searchResults.length),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Results
                Expanded(
                  child: _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            l10n.searchNoResults,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted(context),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _searchResults.length,
                          itemBuilder: (_, i) {
                            final expense = _searchResults[i];
                            return _SearchResultTile(
                              expense: expense,
                              categoryLabel: _localizedCategory(
                                  expense.category, l10n),
                              categoryIcon: _categoryIcon(expense.category),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterBar(S l10n) {
    final categories = _allCategories().toList()..sort();

    return Container(
      color: AppColors.surface(context),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...categories.map((cat) {
                  final selected = _selectedCategories.contains(cat);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(
                        _localizedCategory(cat, l10n),
                        style: TextStyle(fontSize: 12),
                      ),
                      selected: selected,
                      onSelected: (_) => _toggleCategory(cat),
                      selectedColor:
                          AppColors.primary(context).withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary(context),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),
                // Date range chip
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    avatar: Icon(
                      Icons.date_range,
                      size: 16,
                      color: _dateFrom != null
                          ? AppColors.primary(context)
                          : AppColors.textSecondary(context),
                    ),
                    label: Text(
                      _dateFrom != null && _dateTo != null
                          ? '${_dateFrom!.day}/${_dateFrom!.month} - ${_dateTo!.day}/${_dateTo!.month}'
                          : l10n.searchDateRange,
                      style: TextStyle(
                        fontSize: 12,
                        color: _dateFrom != null
                            ? AppColors.primary(context)
                            : AppColors.textSecondary(context),
                      ),
                    ),
                    onPressed: _pickDateRange,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                if (_dateFrom != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _dateFrom = null;
                        _dateTo = null;
                      });
                      _applyFilters();
                    },
                    child: Icon(Icons.clear, size: 16,
                        color: AppColors.textMuted(context)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final ActualExpense expense;
  final String categoryLabel;
  final IconData categoryIcon;

  const _SearchResultTile({
    required this.expense,
    required this.categoryLabel,
    required this.categoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${expense.date.day.toString().padLeft(2, '0')}/${expense.date.month.toString().padLeft(2, '0')}/${expense.date.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        leading: Icon(categoryIcon, size: 20,
            color: AppColors.textSecondary(context)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                expense.description ?? categoryLabel,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              formatCurrency(expense.amount),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '$dateStr  •  $categoryLabel',
          style:
              TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
        ),
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
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted(context),
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
        ? AppColors.error(context)
        : summary.progress > 0.8
            ? AppColors.warning(context)
            : AppColors.success(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: ExpansionTile(
        leading: Icon(icon, size: 20, color: AppColors.textSecondary(context)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            Text(
              '${formatCurrency(summary.actual)} / ${formatCurrency(summary.budgeted)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: summary.isOver
                    ? AppColors.error(context)
                    : AppColors.textSecondary(context),
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
              backgroundColor: AppColors.border(context),
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
                    ? AppColors.error(context)
                    : AppColors.textSecondary(context),
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
                          style: TextStyle(color: AppColors.error(context))),
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
              color: AppColors.errorBackground(context),
              child:
                  Icon(Icons.delete, color: AppColors.error(context), size: 20),
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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                '${expense.date.day.toString().padLeft(2, '0')}/${expense.date.month.toString().padLeft(2, '0')}/${expense.date.year}',
                style: TextStyle(
                    fontSize: 11, color: AppColors.textMuted(context)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
