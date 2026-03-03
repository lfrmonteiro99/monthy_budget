import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/actual_expense.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

Future<ActualExpense?> showAddExpenseSheet({
  required BuildContext context,
  required List<ExpenseItem> budgetExpenses,
  required List<ActualExpense> currentExpenses,
  ActualExpense? existing,
  Future<void> Function(ActualExpense)? onDelete,
}) {
  return showModalBottomSheet<ActualExpense>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddExpenseSheet(
      budgetExpenses: budgetExpenses,
      currentExpenses: currentExpenses,
      existing: existing,
      onDelete: onDelete,
    ),
  );
}

class _AddExpenseSheet extends StatefulWidget {
  final List<ExpenseItem> budgetExpenses;
  final List<ActualExpense> currentExpenses;
  final ActualExpense? existing;
  final Future<void> Function(ActualExpense)? onDelete;

  const _AddExpenseSheet({
    required this.budgetExpenses,
    required this.currentExpenses,
    this.existing,
    this.onDelete,
  });

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  // Expense item selection (tier 1)
  ExpenseItem? _selectedExpenseItem;
  bool _isOthers = false;

  // Category selection (tier 2 — only when "Outros" is selected)
  String? _selectedCategory;
  bool _isCustom = false;
  final _customCategoryController = TextEditingController();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  final _formKey = GlobalKey<FormState>();

  List<ExpenseItem> get _enabledItems =>
      widget.budgetExpenses.where((e) => e.enabled).toList();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _selectedDate = e.date;
      _amountController.text = e.amount.toStringAsFixed(2);
      _descriptionController.text = e.description ?? '';

      // Try to match an expense item by label + category
      final match = _enabledItems.where(
        (item) =>
            item.label == e.description && item.category.name == e.category,
      );
      if (match.isNotEmpty) {
        _selectedExpenseItem = match.first;
        _isOthers = false;
      } else {
        // "Outros" mode — restore category selection
        _isOthers = true;
        _selectedExpenseItem = null;
        final isKnown =
            ExpenseCategory.values.any((c) => c.name == e.category);
        if (isKnown) {
          _selectedCategory = e.category;
          _isCustom = false;
        } else {
          _isCustom = true;
          _customCategoryController.text = e.category;
        }
      }
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> get _budgetCategories {
    final cats = <String>{};
    for (final e in widget.budgetExpenses) {
      if (e.enabled) cats.add(e.category.name);
    }
    return cats.toList();
  }

  List<String> get _customCategoriesUsed {
    final known = ExpenseCategory.values.map((c) => c.name).toSet();
    final custom = <String>{};
    for (final e in widget.currentExpenses) {
      if (!known.contains(e.category)) custom.add(e.category);
    }
    return custom.toList()..sort();
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

  void _selectExpenseItem(ExpenseItem item) {
    setState(() {
      _selectedExpenseItem = item;
      _isOthers = false;
      _selectedCategory = item.category.name;
      _isCustom = false;
      // Pre-fill description with item label if description is empty
      if (_descriptionController.text.trim().isEmpty) {
        _descriptionController.text = item.label;
      }
    });
  }

  void _selectOthers() {
    setState(() {
      _selectedExpenseItem = null;
      _isOthers = true;
      _selectedCategory = null;
      _isCustom = false;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;

    final String? category;
    if (_selectedExpenseItem != null) {
      category = _selectedExpenseItem!.category.name;
    } else if (_isCustom) {
      category = _customCategoryController.text.trim();
    } else {
      category = _selectedCategory;
    }
    if (category == null || category.isEmpty) return;

    final description = _descriptionController.text.trim();

    if (widget.existing != null) {
      Navigator.of(context).pop(widget.existing!.copyWith(
        category: category,
        amount: amount,
        date: _selectedDate,
        description: description.isEmpty ? null : description,
      ));
    } else {
      Navigator.of(context).pop(ActualExpense.create(
        category: category,
        amount: amount,
        date: _selectedDate,
        description: description.isEmpty ? null : description,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isEdit = widget.existing != null;
    final enabledItems = _enabledItems;
    final budgetCats = _budgetCategories;
    final customCats = _customCategoriesUsed;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
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
                isEdit ? l10n.editExpenseTitle : l10n.addExpenseTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 20),

              // --- Tier 1: Expense Item picker ---
              Text(
                l10n.addExpenseItem,
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
                children: [
                  ...enabledItems.map((item) {
                    final selected =
                        !_isOthers && _selectedExpenseItem?.id == item.id;
                    return ChoiceChip(
                      avatar: Icon(_categoryIcon(item.category.name), size: 16),
                      label: Text(item.label),
                      selected: selected,
                      onSelected: (_) => _selectExpenseItem(item),
                      selectedColor: AppColors.primaryLight(context),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected
                            ? AppColors.primary(context)
                            : AppColors.textSecondary(context),
                      ),
                    );
                  }),
                  ChoiceChip(
                    avatar: const Icon(Icons.more_horiz, size: 16),
                    label: Text(l10n.addExpenseOthers),
                    selected: _isOthers,
                    onSelected: (_) => _selectOthers(),
                    selectedColor: AppColors.primaryLight(context),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: _isOthers ? FontWeight.w600 : FontWeight.w400,
                      color: _isOthers
                          ? AppColors.primary(context)
                          : AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Tier 2: Category picker (only when "Outros" selected) ---
              if (_isOthers) ...[
                Text(
                  l10n.addExpenseCategory,
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
                  children: [
                    ...budgetCats.map((cat) => ChoiceChip(
                          avatar: Icon(_categoryIcon(cat), size: 16),
                          label: Text(_localizedCategory(cat, l10n)),
                          selected: !_isCustom && _selectedCategory == cat,
                          onSelected: (_) => setState(() {
                            _selectedCategory = cat;
                            _isCustom = false;
                          }),
                          selectedColor: AppColors.primaryLight(context),
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                !_isCustom && _selectedCategory == cat
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                            color: !_isCustom && _selectedCategory == cat
                                ? AppColors.primary(context)
                                : AppColors.textSecondary(context),
                          ),
                        )),
                    ...customCats.map((cat) => ChoiceChip(
                          avatar: const Icon(Icons.label_outline, size: 16),
                          label: Text(cat),
                          selected: _isCustom &&
                              _customCategoryController.text == cat,
                          onSelected: (_) => setState(() {
                            _isCustom = true;
                            _customCategoryController.text = cat;
                          }),
                          selectedColor: AppColors.primaryLight(context),
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: _isCustom &&
                                    _customCategoryController.text == cat
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: _isCustom &&
                                    _customCategoryController.text == cat
                                ? AppColors.primary(context)
                                : AppColors.textSecondary(context),
                          ),
                        )),
                    ChoiceChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: Text(l10n.addExpenseCustomCategory),
                      selected: _isCustom &&
                          !customCats
                              .contains(_customCategoryController.text),
                      onSelected: (_) => setState(() {
                        _isCustom = true;
                        _customCategoryController.clear();
                        _selectedCategory = null;
                      }),
                      selectedColor: AppColors.primaryLight(context),
                      labelStyle: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                if (_isCustom &&
                    !customCats
                        .contains(_customCategoryController.text)) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _customCategoryController,
                    decoration: InputDecoration(
                      hintText: l10n.addExpenseCustomCategory,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
                const SizedBox(height: 20),
              ],

              // Amount
              Text(
                l10n.addExpenseAmount,
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
                  if (val == null || val <= 0) {
                    return l10n.addExpenseInvalidAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Date
              Text(
                l10n.addExpenseDate,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderMuted(context)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 18, color: AppColors.textSecondary(context)),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textPrimary(context)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                l10n.addExpenseDescription,
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
                  hintText: l10n.addExpenseDescription,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
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

              // Delete button (edit mode only)
              if (isEdit && widget.onDelete != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
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
                                  style: TextStyle(
                                      color: AppColors.error(context))),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        await widget.onDelete!(widget.existing!);
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: AppColors.error(context)),
                    label: Text(l10n.delete),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error(context),
                      side: BorderSide(color: AppColors.error(context)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
