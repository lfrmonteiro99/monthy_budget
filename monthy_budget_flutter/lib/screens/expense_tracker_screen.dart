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
import '../theme/app_theme.dart';
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
import '../utils/expense_category_format.dart';
import '../widgets/expense/category_section.dart';
import '../widgets/expense/expense_alerts_card.dart';
import '../widgets/expense/expense_recent_card.dart';
import '../widgets/expense/expense_search_view.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

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
          CalmSnack.error(
              context, S.of(context).expenseAttachUploadFailed);
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
          CalmSnack.error(
              context, S.of(context).expenseAttachUploadFailed);
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
      categoryLabel: localizedExpenseCategory(expense.category, l10n),
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

  /// Average spend per elapsed day in [_currentMonth] (or whole month total ÷
  /// days-in-month when viewing a past month). Returned as a formatted currency string.
  String _avgPerDay(double totalActual) {
    final now = DateTime.now();
    final isCurrentMonth =
        _currentMonth.year == now.year && _currentMonth.month == now.month;
    final elapsedDays =
        isCurrentMonth ? now.day.clamp(1, 31) : _daysInMonth(_currentMonth);
    final avg = totalActual / elapsedDays;
    return formatCurrency(avg);
  }

  int _daysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
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
    String catLabel(String name) => localizedExpenseCategory(name, l10n);

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

    if (_searchActive) {
      return ExpenseSearchView(
        searchController: _searchController,
        searchQuery: _searchQuery,
        loadingHistory: _loadingHistory,
        searchResults: _searchResults,
        selectedCategories: _selectedCategories,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        allCategories: _allCategories().toList(),
        customCategories: widget.customCategories,
        l10n: l10n,
        onBack: _deactivateSearch,
        onQueryChanged: (value) {
          _searchQuery = value;
          _applyFilters();
        },
        onClearQuery: () {
          _searchController.clear();
          _searchQuery = '';
          _applyFilters();
        },
        onToggleCategory: _toggleCategory,
        onPickDateRange: _pickDateRange,
        onClearDates: () {
          setState(() {
            _dateFrom = null;
            _dateTo = null;
          });
          _applyFilters();
        },
        onShowDetail: _showExpenseDetail,
      );
    }
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

    return CalmScaffold(
      floatingActionButton: FloatingActionButton(
        key: ExpenseTrackerTourKeys.addFab,
        onPressed: _addExpense,
        backgroundColor: AppColors.ink(context),
        foregroundColor: AppColors.bg(context),
        tooltip: l10n.addExpenseTooltip,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Header — eyebrow + Fraunces hero + action icons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TODO(l10n): move to ARB (Wave H)
                      const CalmEyebrow('MOVIMENTO'),
                      const SizedBox(height: 4),
                      Text(
                        // TODO(l10n): move to ARB (Wave H)
                        'Despesas',
                        style: CalmText.display(context, size: 36),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.document_scanner_outlined,
                    color: AppColors.ink50(context),
                  ),
                  tooltip: l10n.quickScanReceipt,
                  onPressed: _scanReceipt,
                ),
                IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    color: AppColors.ink50(context),
                  ),
                  tooltip: l10n.exportTooltip,
                  onPressed: _exportMonth,
                ),
                if (widget.onLoadHistory != null)
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: AppColors.ink50(context),
                    ),
                    tooltip: l10n.searchExpenses,
                    onPressed: _activateSearch,
                  ),
                if (widget.onOpenRecurring != null)
                  IconButton(
                    icon: Icon(
                      Icons.repeat,
                      color: AppColors.ink50(context),
                    ),
                    tooltip: l10n.recurringExpenseManage,
                    onPressed: widget.onOpenRecurring,
                  ),
              ],
            ),
          ),

          // Month navigator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              key: ExpenseTrackerTourKeys.monthNav,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _loading ? null : () => _navigateMonth(-1),
                  icon: Icon(
                    Icons.chevron_left,
                    color: _loading
                        ? AppColors.ink20(context)
                        : AppColors.ink(context),
                  ),
                ),
                Text(
                  _monthLabel(l10n),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink(context),
                  ),
                ),
                IconButton(
                  onPressed: _loading ? null : () => _navigateMonth(1),
                  icon: Icon(
                    Icons.chevron_right,
                    color: _loading
                        ? AppColors.ink20(context)
                        : AppColors.ink(context),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Stats row — 3 cards: Este mês / Média/dia / Contas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              key: ExpenseTrackerTourKeys.summary,
              children: [
                Expanded(
                  child: CalmCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TODO(l10n): move to ARB (Wave H)
                        const CalmEyebrow('ESTE MÊS'),
                        const SizedBox(height: 4),
                        Text(
                          formatCurrency(totalActual),
                          style: CalmText.amount(context,
                              size: 22, weight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CalmCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TODO(l10n): move to ARB (Wave H)
                        const CalmEyebrow('MÉDIA/DIA'),
                        const SizedBox(height: 4),
                        Text(
                          _avgPerDay(totalActual),
                          style: CalmText.amount(context,
                              size: 22, weight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CalmCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TODO(l10n): move to ARB (Wave H)
                        const CalmEyebrow('CONTAS'),
                        const SizedBox(height: 4),
                        Text(
                          '${_expenses.length}',
                          style: CalmText.amount(context,
                              size: 22, weight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Budget status pill
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CalmPill(
                  label: isOver
                      ? '-${formatCurrency(diff.abs())}'
                      : formatCurrency(diff),
                  color: isOver
                      ? AppColors.bad(context)
                      : AppColors.ok(context),
                ),
                const SizedBox(width: 8),
                Text(
                  isOver
                      ? l10n.expenseTrackerOver
                      : l10n.expenseTrackerRemaining,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.ink70(context),
                  ),
                ),
                const Spacer(),
                Text(
                  // TODO(l10n): move to ARB (Wave H)
                  'orç. ${formatCurrency(totalBudgeted)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.ink50(context),
                  ),
                ),
                InfoIconButton(
                  title: l10n.expenseTrackerScreenTitle,
                  body: l10n.infoExpenseTrackerSummary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Divider(color: AppColors.line(context), height: 1),

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

          // Content
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accent(context),
                    ),
                  )
                : _expenses.isEmpty
                ? _buildEmptyState(l10n)
                : CustomScrollView(
                    key: ExpenseTrackerTourKeys.categoryList,
                    slivers: [
                      // "ALERTAS" card — over-budget categories
                      if (summaries.any((s) => s.isOver))
                        SliverPadding(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          sliver: SliverToBoxAdapter(
                            child: ExpenseAlertsCard(
                            summaries: summaries,
                            customCategories: widget.customCategories,
                            l10n: l10n,
                          ),
                          ),
                        ),

                      // "RECENTES" card — last 3 expenses quick-view
                      if (_expenses.isNotEmpty)
                        SliverPadding(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          sliver: SliverToBoxAdapter(
                            child: ExpenseRecentCard(
                            expenses: _expenses,
                            customCategories: widget.customCategories,
                            l10n: l10n,
                            onShowDetail: _showExpenseDetail,
                          ),
                          ),
                        ),

                      // "POR CATEGORIA" sticky section label
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              // TODO(l10n): move to ARB (Wave H)
                              const CalmEyebrow('POR CATEGORIA'),
                              const Spacer(),
                              Text(
                                '${summaries.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.ink50(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                        sliver: SliverList.builder(
                          itemCount: summaries.length,
                          itemBuilder: (_, i) => CategorySection(
                            summary: summaries[i],
                            expenses: _expenses
                                .where(
                                  (e) =>
                                      e.category == summaries[i].category,
                                )
                                .toList(),
                            icon: categoryIconByName(
                              summaries[i].category,
                              customCategories: widget.customCategories,
                            ),
                            categoryColor: categoryColorByNameFull(
                              summaries[i].category,
                              customCategories: widget.customCategories,
                            ),
                            label: localizedExpenseCategory(
                                summaries[i].category, l10n),
                            onOpenDetails: _showExpenseDetail,
                            onDelete: _deleteExpense,
                            l10n: l10n,
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

  Widget _buildEmptyState(S l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: CalmEmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.expenseTrackerEmpty,
        // TODO(l10n): move to ARB (Wave H)
        body: 'Adicione a sua primeira despesa para começar a acompanhar o orçamento.',
        action: CalmEmptyStateAction(
          label: l10n.addExpenseTooltip,
          onPressed: _addExpense,
        ),
      ),
    );
  }

}
