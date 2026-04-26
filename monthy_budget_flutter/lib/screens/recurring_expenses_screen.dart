import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/recurring_expense.dart';
import '../models/custom_category.dart';
import '../models/app_settings.dart';
import '../services/recurring_expense_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/category_icons.dart';
import '../onboarding/recurring_expenses_tour.dart';

class RecurringExpensesScreen extends StatefulWidget {
  final String householdId;
  final List<RecurringExpense> expenses;
  final ValueChanged<List<RecurringExpense>> onChanged;
  final List<CustomCategory> customCategories;
  final bool showTour;
  final VoidCallback? onTourComplete;

  const RecurringExpensesScreen({
    super.key,
    required this.householdId,
    required this.expenses,
    required this.onChanged,
    this.customCategories = const [],
    this.showTour = false,
    this.onTourComplete,
  });

  @override
  State<RecurringExpensesScreen> createState() =>
      _RecurringExpensesScreenState();
}

class _RecurringExpensesScreenState extends State<RecurringExpensesScreen> {
  final _service = RecurringExpenseService();
  late List<RecurringExpense> _expenses;

  bool _tourShown = false;

  @override
  void initState() {
    super.initState();
    _expenses = List.from(widget.expenses);
    if (widget.showTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryShowTour());
    }
  }

  void _tryShowTour() {
    if (_tourShown || !mounted || _expenses.isEmpty) return;
    _tourShown = true;
    buildRecurringExpensesTour(
      context: context,
      onFinish: () => widget.onTourComplete?.call(),
      onSkip: () => widget.onTourComplete?.call(),
    ).show(context: context);
  }

  void _notify() => widget.onChanged(_expenses);

  Future<void> _addOrEdit([RecurringExpense? existing]) async {
    final result = await _showEditSheet(existing);
    if (result == null) return;

    await _service.save(result, widget.householdId);
    if (!mounted) return;
    setState(() {
      if (existing != null) {
        _expenses = _expenses.map((e) => e.id == result.id ? result : e).toList();
      } else {
        _expenses = [result, ..._expenses];
      }
    });
    _notify();
    if (mounted) {
      CalmSnack.success(context, S.of(context).recurringExpenseSaved);
    }
  }

  Future<void> _delete(RecurringExpense expense) async {
    final l10n = S.of(context);
    final confirmed = await CalmDialog.confirm(
      context,
      title: l10n.delete,
      body: l10n.recurringExpenseDeleteConfirm,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed != true) return;
    await _service.delete(expense.id);
    if (!mounted) return;
    setState(() {
      _expenses = _expenses.where((e) => e.id != expense.id).toList();
    });
    _notify();
  }

  Future<void> _toggleActive(RecurringExpense expense) async {
    final updated = expense.copyWith(isActive: !expense.isActive);
    await _service.save(updated, widget.householdId);
    if (!mounted) return;
    setState(() {
      _expenses =
          _expenses.map((e) => e.id == expense.id ? updated : e).toList();
    });
    _notify();
  }

  String _localizedCategory(String catName, S l10n) {
    try {
      final cat = ExpenseCategory.values.firstWhere((c) => c.name == catName);
      return cat.localizedLabel(l10n);
    } catch (_) {
      return catName;
    }
  }

  Future<RecurringExpense?> _showEditSheet(
      [RecurringExpense? existing]) async {
    return CalmBottomSheet.show<RecurringExpense>(
      context,
      isScrollControlled: true,
      builder: (_) => _EditRecurringSheet(
        existing: existing,
        customCategories: widget.customCategories,
      ),
    );
  }

  double get _totalMonthly =>
      _expenses.where((e) => e.isActive).fold(0.0, (sum, e) => sum + e.amount);

  Widget _buildSummaryCard(BuildContext context, S l10n) {
    final activeCount = _expenses.where((e) => e.isActive).length;
    final pausedCount = _expenses.length - activeCount;
    final activeMonthly = _totalMonthly;
    final pausedMonthly = _expenses
        .where((e) => !e.isActive)
        .fold(0.0, (s, e) => s + e.amount);
    final pillColor =
        activeCount > 0 ? AppColors.ok(context) : AppColors.ink50(context);
    final pillLabel = activeCount == 1
        ? '1 ativa' // TODO(l10n): move to ARB (Wave H)
        : '$activeCount ativas'; // TODO(l10n): move to ARB (Wave H)

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CalmEyebrow('TOTAL MENSAL'), // TODO(l10n): move to ARB (Wave H)
              const Spacer(),
              CalmPill(label: pillLabel, color: pillColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(activeMonthly),
            style: CalmText.display(context, size: 32),
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.line(context), height: 1),
          const SizedBox(height: 4),
          // Active summary row
          CalmListTile(
            leadingIcon: Icons.check_circle_outline,
            leadingColor: AppColors.ok(context),
            title: 'Ativas', // TODO(l10n): move to ARB (Wave H)
            subtitle: '$activeCount subscrição${activeCount == 1 ? '' : 'ões'}', // TODO(l10n): move to ARB (Wave H)
            trailing: formatCurrency(activeMonthly),
          ),
          if (pausedCount > 0) ...[
            Divider(
              color: AppColors.line(context),
              height: 1,
              indent: 44,
            ),
            // Paused summary row
            CalmListTile(
              leadingIcon: Icons.pause_circle_outline,
              leadingColor: AppColors.ink50(context),
              title: 'Pausadas', // TODO(l10n): move to ARB (Wave H)
              subtitle: '$pausedCount subscrição${pausedCount == 1 ? '' : 'ões'}', // TODO(l10n): move to ARB (Wave H)
              trailing: formatCurrency(pausedMonthly),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpenseGroup(
    BuildContext context,
    S l10n,
    String groupLabel,
    List<RecurringExpense> items,
    bool isFirst,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : 16, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CalmEyebrow(groupLabel),
          ),
          const SizedBox(height: 8),
          CalmCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    Divider(
                      color: AppColors.line(context),
                      height: 1,
                      indent: 64,
                    ),
                  _buildExpenseRow(
                    context,
                    l10n,
                    items[i],
                    isFirst: i == 0,
                    isFirstInAllGroups: isFirst && i == 0,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseRow(
    BuildContext context,
    S l10n,
    RecurringExpense expense, {
    bool isFirst = false,
    bool isFirstInAllGroups = false,
  }) {
    final catColor = AppColors.categoryColorByName(expense.category);
    final localizedCat = _localizedCategory(expense.category, l10n);

    final subtitleParts = <String>[
      formatCurrency(expense.amount),
      if (expense.dayOfMonth != null)
        'dia ${expense.dayOfMonth}', // TODO(l10n): move to ARB (Wave H)
      if (expense.description != null && expense.description!.isNotEmpty)
        expense.description!,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        key: isFirstInAllGroups ? RecurringExpensesTourKeys.expenseItem : null,
        children: [
          Expanded(
            child: CalmListTile(
              leadingIcon: getCategoryIcon(expense.category),
              leadingColor: catColor,
              title: localizedCat,
              subtitle: subtitleParts.join(' · '),
              trailing: expense.isActive ? null : l10n.recurringExpenseInactive,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (action) {
              switch (action) {
                case 'edit':
                  _addOrEdit(expense);
                case 'toggle':
                  _toggleActive(expense);
                case 'delete':
                  _delete(expense);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(l10n.recurringExpenseEdit),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Text(expense.isActive
                    ? l10n.recurringExpenseInactive
                    : l10n.recurringExpenseActive),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(l10n.delete,
                    style: TextStyle(color: AppColors.bad(context))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    final active = _expenses.where((e) => e.isActive).toList();
    final paused = _expenses.where((e) => !e.isActive).toList();

    return CalmScaffold(
      title: l10n.recurringExpenses,
      floatingActionButton: FloatingActionButton(
        key: RecurringExpensesTourKeys.addFab,
        onPressed: () => _addOrEdit(),
        backgroundColor: AppColors.ink(context),
        foregroundColor: AppColors.bg(context),
        elevation: 0,
        child: const Icon(Icons.add),
      ),
      body: _expenses.isEmpty
          ? Center(
              child: CalmEmptyState(
                icon: Icons.event_repeat_outlined,
                title: 'Sem pagamentos recorrentes', // TODO(l10n): move to ARB (Wave H)
                body: 'Adicione para gerar automaticamente todos os meses.', // TODO(l10n): move to ARB (Wave H)
                action: CalmEmptyStateAction(
                  label: l10n.recurringExpenseAdd,
                  onPressed: () => _addOrEdit(),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              children: [
                // Hero — total monthly recurring
                CalmHero(
                  eyebrow: 'RECORRENTES', // TODO(l10n): move to ARB (Wave H)
                  amount: formatCurrency(_totalMonthly),
                  subtitle: '${_expenses.where((e) => e.isActive).length} ${_expenses.where((e) => e.isActive).length == 1 ? 'subscrição ativa' : 'subscrições ativas'}', // TODO(l10n): move to ARB (Wave H)
                ),
                const SizedBox(height: 24),

                // Summary card with total + pill
                _buildSummaryCard(context, l10n),
                const SizedBox(height: 24),

                // Active group
                if (active.isNotEmpty)
                  _buildExpenseGroup(
                    context,
                    l10n,
                    'ATIVAS', // TODO(l10n): move to ARB (Wave H)
                    active,
                    true,
                  ),

                // Paused group
                if (paused.isNotEmpty)
                  _buildExpenseGroup(
                    context,
                    l10n,
                    'PAUSADAS', // TODO(l10n): move to ARB (Wave H)
                    paused,
                    active.isEmpty,
                  ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Public helper — show the recurring expense edit sheet from other screens.
// ---------------------------------------------------------------------------

/// Public helper to show the recurring expense edit sheet from other screens.
/// Pass [preselectedCategory] to pre-select the category chip.
Future<RecurringExpense?> showEditRecurringSheet(
  BuildContext context, {
  RecurringExpense? existing,
  String? preselectedCategory,
}) {
  return CalmBottomSheet.show<RecurringExpense>(
    context,
    isScrollControlled: true,
    builder: (_) => _EditRecurringSheet(
      existing: existing,
      preselectedCategory: preselectedCategory,
    ),
  );
}

// ---------------------------------------------------------------------------
// Edit / Add sheet
// ---------------------------------------------------------------------------

class _EditRecurringSheet extends StatefulWidget {
  final RecurringExpense? existing;
  final List<CustomCategory> customCategories;
  final String? preselectedCategory;
  const _EditRecurringSheet({
    this.existing,
    this.customCategories = const [],
    this.preselectedCategory,
  });

  @override
  State<_EditRecurringSheet> createState() => _EditRecurringSheetState();
}

class _EditRecurringSheetState extends State<_EditRecurringSheet> {
  String? _selectedCategory;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dayController = TextEditingController();
  bool _isActive = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _selectedCategory = e.category;
      _amountController.text = e.amount.toStringAsFixed(2);
      _descriptionController.text = e.description ?? '';
      if (e.dayOfMonth != null) _dayController.text = e.dayOfMonth.toString();
      _isActive = e.isActive;
    } else if (widget.preselectedCategory != null) {
      _selectedCategory = widget.preselectedCategory;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;

    final dayText = _dayController.text.trim();
    final day = dayText.isNotEmpty ? int.tryParse(dayText) : null;

    final result = RecurringExpense(
      id: widget.existing?.id ??
          'rec_${DateTime.now().millisecondsSinceEpoch}',
      category: _selectedCategory!,
      amount: amount,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dayOfMonth: day?.clamp(1, 31),
      isActive: _isActive,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isEdit = widget.existing != null;
    final categories = ExpenseCategory.values.map((c) => c.name).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              // Drag handle
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    width: 40,
                    height: 4,
                    child: ColoredBox(color: AppColors.ink20(context)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEdit
                    ? l10n.recurringExpenseEdit
                    : l10n.recurringExpenseAdd,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink(context),
                ),
              ),
              const SizedBox(height: 24),

              // Category
              CalmEyebrow(l10n.recurringExpenseCategory.toUpperCase()),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...categories.map((cat) {
                    final selected = _selectedCategory == cat;
                    String label;
                    try {
                      final ec = ExpenseCategory.values
                          .firstWhere((c) => c.name == cat);
                      label = ec.localizedLabel(l10n);
                    } catch (_) {
                      label = cat;
                    }
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                      selectedColor: AppColors.accentSoft(context),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected
                            ? AppColors.accent(context)
                            : AppColors.ink70(context),
                      ),
                    );
                  }),
                  ...widget.customCategories.map((cc) {
                    final selected = _selectedCategory == cc.name;
                    return ChoiceChip(
                      avatar: Icon(getCategoryIcon(cc.iconName), size: 16),
                      label: Text(cc.name),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cc.name),
                      selectedColor: AppColors.accentSoft(context),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected
                            ? AppColors.accent(context)
                            : AppColors.ink70(context),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),

              // Amount
              CalmEyebrow(l10n.recurringExpenseAmount.toUpperCase()),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: currencySymbol(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.ink20(context)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                validator: (v) {
                  final val =
                      double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (val == null || val <= 0) return l10n.addExpenseInvalidAmount;
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Day of month (due day for bill reminders)
              Row(
                children: [
                  Icon(Icons.notifications_outlined,
                      size: 14, color: AppColors.accent(context)),
                  const SizedBox(width: 6),
                  CalmEyebrow(l10n.recurringExpenseDayOfMonth.toUpperCase()),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dayController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: l10n.recurringExpenseDayHint,
                  prefixIcon: Icon(Icons.calendar_today,
                      size: 18, color: AppColors.ink50(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.ink20(context)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final val = int.tryParse(v.trim());
                  if (val == null || val < 1 || val > 31) {
                    return '1-31';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description
              CalmEyebrow(l10n.recurringExpenseDescription.toUpperCase()),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: l10n.recurringExpenseDescription,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.ink20(context)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Active toggle
              CalmSwitchRow(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: _isActive
                    ? l10n.recurringExpenseActive
                    : l10n.recurringExpenseInactive,
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ink(context),
                    foregroundColor: AppColors.bg(context),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.save,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
