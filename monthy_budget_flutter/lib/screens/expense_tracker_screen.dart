import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/actual_expense.dart';
import '../models/budget_summary.dart';
import '../models/custom_category.dart';
import '../theme/app_colors.dart';
import '../utils/category_helpers.dart';
import '../utils/expense_filter.dart';
import '../utils/formatters.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/export_bottom_sheet.dart';
import '../services/receipt_scan_service.dart';
import '../widgets/receipt_scan_sheet.dart';
import '../widgets/receipt_review_sheet.dart';
import '../widgets/info_icon_button.dart';
import '../widgets/expense_detail_sheet.dart';
import '../services/export_service.dart';
import '../services/actual_expense_service.dart';
import '../onboarding/expense_tracker_tour.dart';
import '../data/tax/tax_deductions.dart';
import '../widgets/irs_deduction_banner.dart';
import 'tax_deduction_detail_screen.dart';

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
  final bool showTour;
  final VoidCallback? onTourComplete;
  final List<CustomCategory> customCategories;
  final YearlyDeductionSummary? irsDeductionSummary;
  final BudgetSummary? budgetSummary;

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
    this.showTour = false,
    this.onTourComplete,
    this.customCategories = const [],
    this.irsDeductionSummary,
    this.budgetSummary,
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
  final _expenseService = ActualExpenseService();
  bool _tourShown = false;
  TutorialCoachMark? _activeTour;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _expenses = List.of(widget.expenses);
    if (widget.showTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryShowTour());
    }
  }

  void _tryShowTour() {
    if (_tourShown || !mounted) return;
    _tourShown = true;
    _activeTour = buildExpenseTrackerTour(
      context: context,
      onFinish: () {
        _activeTour = null;
        widget.onTourComplete?.call();
      },
      onSkip: () {
        _activeTour = null;
        widget.onTourComplete?.call();
      },
    );
    _activeTour!.show(context: context);
  }

  @override
  void didUpdateWidget(covariant ExpenseTrackerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync with parent when viewing the current month and parent data changes
    final now = DateTime.now();
    final isCurrentMonth =
        _currentMonth.year == now.year && _currentMonth.month == now.month;
    if (isCurrentMonth && widget.expenses != oldWidget.expenses) {
      setState(() => _expenses = List.of(widget.expenses));
    }
  }

  @override
  void dispose() {
    _activeTour?.finish();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _navigateMonth(int delta) async {
    final next = DateTime(_currentMonth.year, _currentMonth.month + delta);
    setState(() {
      _currentMonth = next;
      _loading = true;
    });
    final newMonthKey = '${next.year}-${next.month.toString().padLeft(2, '0')}';
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
      customCategories: widget.customCategories,
    );
    if (result != null && mounted) {
      var expense = result.expense;
      if (result.newAttachmentFiles.isNotEmpty) {
        final urls = await _expenseService.uploadAttachments(
          result.newAttachmentFiles,
          widget.householdId,
          expense.id,
        );
        if (urls.isNotEmpty) {
          final allUrls = [...?expense.attachmentUrls, ...urls];
          expense = expense.copyWith(attachmentUrls: allUrls);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).expenseAttachUploadFailed),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
      await widget.onAdd(expense);
      if (!mounted) return;
      setState(
        () =>
            _expenses = [..._expenses, expense]
              ..sort((a, b) => b.date.compareTo(a.date)),
      );
    }
  }

  Future<void> _scanReceipt() async {
    final receipt = await ReceiptScanSheet.show(context);
    if (receipt == null || !mounted) return;

    final categories = {
      ...widget.settings.expenses.map((e) => e.category),
      ...widget.customCategories.map((c) => c.name),
    }.toList()..sort();

    final chosenCategory = await ReceiptReviewSheet.show(
      context,
      receipt: receipt,
      categories: categories,
    );
    if (chosenCategory == null || !mounted) return;

    final expense = ReceiptScanService.buildExpense(
      receipt: receipt,
      category: chosenCategory,
    );
    await widget.onAdd(expense);
    if (!mounted) return;
    setState(
      () =>
          _expenses = [..._expenses, expense]
            ..sort((a, b) => b.date.compareTo(a.date)),
    );
  }

  Future<void> _editExpense(ActualExpense expense) async {
    final result = await showAddExpenseSheet(
      context: context,
      budgetExpenses: widget.settings.expenses,
      currentExpenses: _expenses,
      customCategories: widget.customCategories,
      existing: expense,
      onDelete: _deleteExpense,
    );
    if (result != null && mounted) {
      var updated = result.expense;
      if (result.newAttachmentFiles.isNotEmpty) {
        final urls = await _expenseService.uploadAttachments(
          result.newAttachmentFiles,
          widget.householdId,
          updated.id,
        );
        if (urls.isNotEmpty) {
          final allUrls = [...?updated.attachmentUrls, ...urls];
          updated = updated.copyWith(attachmentUrls: allUrls);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).expenseAttachUploadFailed),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
      await widget.onUpdate(updated);
      if (!mounted) return;
      setState(() {
        _expenses =
            _expenses.map((e) => e.id == updated.id ? updated : e).toList()
              ..sort((a, b) => b.date.compareTo(a.date));
      });
    }
  }

  Future<void> _showExpenseDetail(ActualExpense expense) async {
    final l10n = S.of(context);
    final action = await showExpenseDetailSheet(
      context: context,
      expense: expense,
      categoryLabel: _localizedCategory(expense.category, l10n),
      categoryIcon: categoryIconByName(
        expense.category,
        customCategories: widget.customCategories,
      ),
      categoryColor: categoryColorByNameFull(
        expense.category,
        customCategories: widget.customCategories,
      ),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case ExpenseDetailAction.edit:
        await _editExpense(expense);
        break;
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

    final monthSuffix =
        '${_currentMonth.year}_${_currentMonth.month.toString().padLeft(2, '0')}';

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
        'expenses_$monthSuffix.pdf',
        bytes,
      );
      await Share.shareXFiles([XFile(file.path)]);
    } else if (format == ExportFormat.monthlySummary) {
      final budgetSummary =
          widget.budgetSummary ?? const BudgetSummary();
      final csv = _exportService.generateMonthlySummaryCsv(
        monthLabel: label,
        budgetSummary: budgetSummary,
        categorySummaries: summaries,
        expenses: _expenses,
        categoryLabelMap: catLabel,
        formatCurrency: formatCurrency,
        sectionIncome: l10n.exportSectionIncome,
        sectionBudgetVsActual: l10n.exportBudgetVsActual,
        sectionExpenses: l10n.exportExpenseDetail,
        sectionSummary: l10n.exportSectionSummary,
        headerCategory: l10n.addExpenseCategory,
        headerBudgeted: l10n.expenseTrackerBudgeted,
        headerActual: l10n.expenseTrackerActual,
        headerRemaining: l10n.expenseTrackerRemaining,
        headerDate: l10n.addExpenseDate,
        headerDescription: l10n.addExpenseDescription
            .replaceAll(RegExp(r'\s*\(.*\)'), ''),
        headerAmount: l10n.addExpenseAmount,
        labelTotalIncome: l10n.exportLabelTotalIncome,
        labelGrossIncome: l10n.exportLabelGrossIncome,
        labelDeductions: l10n.exportLabelDeductions,
        labelTotalExpenses: l10n.exportLabelTotalExpenses,
        labelNetLiquidity: l10n.exportLabelNetLiquidity,
        labelSavingsRate: l10n.exportLabelSavingsRate,
        labelTotal: l10n.exportLabelTotal,
      );
      final file = await _exportService.writeTempFile(
        'monthly_summary_$monthSuffix.csv',
        utf8.encode(csv),
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
        'expenses_$monthSuffix.csv',
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
    final filtered = filterExpenses(
      allExpenses,
      query: _searchQuery,
      selectedCategories: _selectedCategories,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
    );

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
    return extractCategories(_historyCache!);
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
            icon: Icon(
              Icons.document_scanner,
              color: AppColors.textMuted(context),
            ),
            tooltip: l10n.quickScanReceipt,
            onPressed: _scanReceipt,
          ),
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
            key: ExpenseTrackerTourKeys.monthNav,
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
            key: ExpenseTrackerTourKeys.summary,
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

          // IRS deduction banner (Portugal only)
          if (widget.irsDeductionSummary != null)
            IrsDeductionBanner(
              summary: widget.irsDeductionSummary,
              onSeeDetail: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TaxDeductionDetailScreen(
                    summary: widget.irsDeductionSummary!,
                  ),
                ),
              ),
            ),

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
                    child: CircularProgressIndicator(
                      color: AppColors.primary(context),
                    ),
                  )
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
                    key: ExpenseTrackerTourKeys.categoryList,
                    padding: const EdgeInsets.all(16),
                    itemCount: summaries.length,
                    itemBuilder: (_, i) => _CategorySection(
                      summary: summaries[i],
                      expenses: _expenses
                          .where((e) => e.category == summaries[i].category)
                          .toList(),
                      icon: categoryIconByName(
                        summaries[i].category,
                        customCategories: widget.customCategories,
                      ),
                      categoryColor: categoryColorByNameFull(
                        summaries[i].category,
                        customCategories: widget.customCategories,
                      ),
                      label: _localizedCategory(summaries[i].category, l10n),
                      onOpenDetails: _showExpenseDetail,
                      onDelete: _deleteExpense,
                      l10n: l10n,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: ExpenseTrackerTourKeys.addFab,
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
          style: TextStyle(color: AppColors.textPrimary(context), fontSize: 16),
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
                color: AppColors.primary(context),
              ),
            )
          : Column(
              children: [
                // Category chips + date range
                Row(
                  children: [
                    Expanded(child: _buildFilterBar(l10n)),
                    InfoIconButton(
                      title: l10n.filter,
                      body: l10n.infoExpenseTrackerFilter,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const Divider(height: 1),

                // Result count
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                                expense.category,
                                l10n,
                              ),
                              categoryIcon: categoryIconByName(
                                expense.category,
                                customCategories: widget.customCategories,
                              ),
                              categoryColor: categoryColorByNameFull(
                                expense.category,
                                customCategories: widget.customCategories,
                              ),
                              onTap: () => _showExpenseDetail(expense),
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
                      selectedColor: AppColors.chipSelected(context),
                      checkmarkColor: AppColors.primary(context),
                      side: selected
                          ? BorderSide(color: const Color(0xFF93C5FD))
                          : null,
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
                  Tooltip(
                    message: l10n.shoppingClear,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _dateFrom = null;
                          _dateTo = null;
                        });
                        _applyFilters();
                      },
                      child: Icon(
                        Icons.clear,
                        size: 16,
                        color: AppColors.textMuted(context),
                      ),
                    ),
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
  final Color categoryColor;
  final VoidCallback? onTap;

  const _SearchResultTile({
    required this.expense,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.categoryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${expense.date.day.toString().padLeft(2, '0')}/${expense.date.month.toString().padLeft(2, '0')}/${expense.date.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: categoryColor.withValues(alpha: 0.15),
          child: Icon(categoryIcon, size: 16, color: categoryColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                expense.description ?? categoryLabel,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              formatCurrency(expense.amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.error(context),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '$dateStr  •  $categoryLabel',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
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
  final Color categoryColor;
  final String label;
  final Future<void> Function(ActualExpense) onOpenDetails;
  final Future<void> Function(ActualExpense) onDelete;
  final S l10n;

  const _CategorySection({
    required this.summary,
    required this.expenses,
    required this.icon,
    required this.categoryColor,
    required this.label,
    required this.onOpenDetails,
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
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: categoryColor.withValues(alpha: 0.15),
          child: Icon(icon, size: 18, color: categoryColor),
        ),
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
                      child: Text(
                        l10n.delete,
                        style: TextStyle(color: AppColors.error(context)),
                      ),
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
              child: Icon(
                Icons.delete,
                color: AppColors.error(context),
                size: 20,
              ),
            ),
            child: ListTile(
              onTap: () => onOpenDetails(expense),
              dense: true,
              trailing: Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textMuted(context),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      expense.description ?? label,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formatCurrency(expense.amount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error(context),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                '${expense.date.day.toString().padLeft(2, '0')}/${expense.date.month.toString().padLeft(2, '0')}/${expense.date.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
