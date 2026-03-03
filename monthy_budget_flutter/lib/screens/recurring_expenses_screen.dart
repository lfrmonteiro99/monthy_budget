import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/recurring_expense.dart';
import '../models/app_settings.dart';
import '../services/recurring_expense_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class RecurringExpensesScreen extends StatefulWidget {
  final String householdId;
  final List<RecurringExpense> expenses;
  final ValueChanged<List<RecurringExpense>> onChanged;

  const RecurringExpensesScreen({
    super.key,
    required this.householdId,
    required this.expenses,
    required this.onChanged,
  });

  @override
  State<RecurringExpensesScreen> createState() =>
      _RecurringExpensesScreenState();
}

class _RecurringExpensesScreenState extends State<RecurringExpensesScreen> {
  final _service = RecurringExpenseService();
  late List<RecurringExpense> _expenses;

  @override
  void initState() {
    super.initState();
    _expenses = List.from(widget.expenses);
  }

  void _notify() => widget.onChanged(_expenses);

  Future<void> _addOrEdit([RecurringExpense? existing]) async {
    final result = await _showEditSheet(existing);
    if (result == null) return;

    await _service.save(result, widget.householdId);
    setState(() {
      if (existing != null) {
        _expenses = _expenses.map((e) => e.id == result.id ? result : e).toList();
      } else {
        _expenses = [result, ..._expenses];
      }
    });
    _notify();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).recurringExpenseSaved)),
      );
    }
  }

  Future<void> _delete(RecurringExpense expense) async {
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.recurringExpenseDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete,
                style: TextStyle(color: AppColors.error(context))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _service.delete(expense.id);
    setState(() {
      _expenses = _expenses.where((e) => e.id != expense.id).toList();
    });
    _notify();
  }

  Future<void> _toggleActive(RecurringExpense expense) async {
    final updated = expense.copyWith(isActive: !expense.isActive);
    await _service.save(updated, widget.householdId);
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
    return showModalBottomSheet<RecurringExpense>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditRecurringSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(l10n.recurringExpenses),
        backgroundColor: AppColors.surface(context),
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        backgroundColor: AppColors.primary(context),
        child: Icon(Icons.add, color: AppColors.onPrimary(context)),
      ),
      body: _expenses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.recurringExpenseEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _expenses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final e = _expenses[i];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: e.isActive
                          ? AppColors.primaryLight(context)
                          : AppColors.surfaceVariant(context),
                      child: Icon(
                        Icons.repeat,
                        color: e.isActive
                            ? AppColors.primary(context)
                            : AppColors.textMuted(context),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      _localizedCategory(e.category, l10n),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    subtitle: Text(
                      [
                        formatCurrency(e.amount),
                        if (e.dayOfMonth != null) 'Dia ${e.dayOfMonth}',
                        if (e.description != null && e.description!.isNotEmpty)
                          e.description!,
                        if (!e.isActive) l10n.recurringExpenseInactive,
                      ].join(' · '),
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        switch (action) {
                          case 'edit':
                            _addOrEdit(e);
                          case 'toggle':
                            _toggleActive(e);
                          case 'delete':
                            _delete(e);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(l10n.recurringExpenseEdit),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(e.isActive
                              ? l10n.recurringExpenseInactive
                              : l10n.recurringExpenseActive),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(l10n.delete,
                              style: TextStyle(color: AppColors.error(context))),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _EditRecurringSheet extends StatefulWidget {
  final RecurringExpense? existing;
  const _EditRecurringSheet({this.existing});

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
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dragHandle(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEdit
                    ? l10n.recurringExpenseEdit
                    : l10n.recurringExpenseAdd,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 20),

              // Category
              Text(
                l10n.recurringExpenseCategory,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
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
                    selectedColor: AppColors.primaryLight(context),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? AppColors.primary(context)
                          : AppColors.textSecondary(context),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Amount
              Text(
                l10n.recurringExpenseAmount,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: currencySymbol(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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

              // Day of month
              Text(
                l10n.recurringExpenseDayOfMonth,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dayController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: l10n.recurringExpenseDayHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
              Text(
                l10n.recurringExpenseDescription,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: l10n.recurringExpenseDescription,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Active toggle
              SwitchListTile(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: Text(
                  _isActive
                      ? l10n.recurringExpenseActive
                      : l10n.recurringExpenseInactive,
                  style: TextStyle(color: AppColors.textPrimary(context)),
                ),
                activeColor: AppColors.primary(context),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: AppColors.onPrimary(context),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
