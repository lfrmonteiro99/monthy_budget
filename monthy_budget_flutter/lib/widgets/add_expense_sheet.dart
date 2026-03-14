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
    showDragHandle: true,
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
  bool _showDescription = false;

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
      _showDescription = _descriptionController.text.isNotEmpty;
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

  bool _isChoiceSelected(_CategoryChoice choice) {
    if (choice.expenseItem != null) {
      return !_isOthers && _selectedExpenseItem?.id == choice.expenseItem!.id;
    }
    if (choice.customCategory != null) {
      return _isCustom && _customCategoryController.text == choice.customCategory;
    }
    return false;
  }

  void _selectChoice(_CategoryChoice choice) {
    if (choice.expenseItem != null) {
      _selectExpenseItem(choice.expenseItem!);
    } else if (choice.customCategory != null) {
      setState(() {
        _isCustom = true;
        _isOthers = true;
        _selectedExpenseItem = null;
        _customCategoryController.text = choice.customCategory!;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).addExpenseInvalidAmount),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
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
    if (category == null || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).addExpenseCategory),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

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
    final customCats = _customCategoriesUsed;

    // Build flat category list: expense items + custom categories + "Others"
    final allChoices = <_CategoryChoice>[
      ...enabledItems.map((item) => _CategoryChoice(
            label: item.label,
            icon: _categoryIcon(item.category.name),
            expenseItem: item,
          )),
      ...customCats.map((cat) => _CategoryChoice(
            label: cat,
            icon: Icons.label_outline,
            customCategory: cat,
          )),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
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

              // --- Amount (first — auto-focused with numpad) ---
              Text(
                l10n.addExpenseAmount.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                autofocus: !isEdit,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: currencySymbol(),
                  hintText: '0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
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

              // --- Flat category picker (merged tier 1 + tier 2) ---
              Text(
                l10n.addExpenseCategory.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...allChoices.map((choice) {
                    final selected = _isChoiceSelected(choice);
                    return ChoiceChip(
                      avatar: Icon(choice.icon, size: 16),
                      label: Text(choice.label),
                      selected: selected,
                      onSelected: (_) => _selectChoice(choice),
                      selectedColor: AppColors.primaryLight(context),
                      side: BorderSide(
                        color: selected
                            ? const Color(0xFF93C5FD)
                            : const Color(0xFFE2E8F0),
                      ),
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
                    avatar: const Icon(Icons.add, size: 16),
                    label: Text(l10n.addExpenseCustomCategory),
                    selected: _isCustom && !customCats.contains(_customCategoryController.text),
                    onSelected: (_) => setState(() {
                      _isCustom = true;
                      _isOthers = true;
                      _selectedExpenseItem = null;
                      _customCategoryController.clear();
                      _selectedCategory = null;
                    }),
                    selectedColor: AppColors.primaryLight(context),
                    side: BorderSide(
                      color: (_isCustom && !customCats.contains(_customCategoryController.text))
                          ? const Color(0xFF93C5FD)
                          : const Color(0xFFE2E8F0),
                    ),
                    labelStyle: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              if (_isCustom && !customCats.contains(_customCategoryController.text)) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customCategoryController,
                  decoration: InputDecoration(
                    hintText: l10n.addExpenseCustomCategory,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
              const SizedBox(height: 20),

              // --- Date (compact inline) ---
              // Date range limited to 1 year back: expenses older than 12 months
              // fall outside the budgeting cycle and should not be retroactively added.
              Tooltip(
                message: l10n.addExpenseDate,
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      // 1-year limit: keeps entries within the current budgeting cycle
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
                        const Spacer(),
                        // M8: Toggle note with clear visual state
                        TextButton.icon(
                          onPressed: () => setState(() => _showDescription = !_showDescription),
                          icon: Icon(
                            _showDescription ? Icons.expand_less : Icons.note_add,
                            size: 18,
                            color: _showDescription
                                ? AppColors.primary(context)
                                : AppColors.textSecondary(context),
                          ),
                          label: Text(
                            l10n.addExpenseDescription,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _showDescription
                                  ? AppColors.primary(context)
                                  : AppColors.textSecondary(context),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            backgroundColor: _showDescription
                                ? AppColors.primaryLight(context)
                                : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Description (collapsed by default) ---
              if (_showDescription) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: l10n.addExpenseDescription,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
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

class _CategoryChoice {
  final String label;
  final IconData icon;
  final ExpenseItem? expenseItem;
  final String? customCategory;

  const _CategoryChoice({
    required this.label,
    required this.icon,
    this.expenseItem,
    this.customCategory,
  });
}
