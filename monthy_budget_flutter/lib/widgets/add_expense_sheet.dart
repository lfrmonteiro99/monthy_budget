import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/actual_expense.dart';
import '../utils/formatters.dart';

Future<ActualExpense?> showAddExpenseSheet({
  required BuildContext context,
  required List<ExpenseItem> budgetExpenses,
  required List<ActualExpense> currentExpenses,
  ActualExpense? existing,
}) {
  return showModalBottomSheet<ActualExpense>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddExpenseSheet(
      budgetExpenses: budgetExpenses,
      currentExpenses: currentExpenses,
      existing: existing,
    ),
  );
}

class _AddExpenseSheet extends StatefulWidget {
  final List<ExpenseItem> budgetExpenses;
  final List<ActualExpense> currentExpenses;
  final ActualExpense? existing;

  const _AddExpenseSheet({
    required this.budgetExpenses,
    required this.currentExpenses,
    this.existing,
  });

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  String? _selectedCategory;
  bool _isCustom = false;
  final _customCategoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _selectedDate = e.date;
      _amountController.text = e.amount.toStringAsFixed(2);
      _descriptionController.text = e.description ?? '';
      // Check if category is a known enum
      final isKnown = ExpenseCategory.values.any((c) => c.name == e.category);
      if (isKnown) {
        _selectedCategory = e.category;
        _isCustom = false;
      } else {
        _isCustom = true;
        _customCategoryController.text = e.category;
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(
        _amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;

    final category = _isCustom
        ? _customCategoryController.text.trim()
        : _selectedCategory;
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
    final budgetCats = _budgetCategories;
    final customCats = _customCategoriesUsed;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEdit ? l10n.editExpenseTitle : l10n.addExpenseTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 20),

              // Category picker
              Text(
                l10n.addExpenseCategory,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
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
                        selectedColor: const Color(0xFFDBEAFE),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: !_isCustom && _selectedCategory == cat
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: !_isCustom && _selectedCategory == cat
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF64748B),
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
                        selectedColor: const Color(0xFFDBEAFE),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: _isCustom &&
                                  _customCategoryController.text == cat
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _isCustom &&
                                  _customCategoryController.text == cat
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF64748B),
                        ),
                      )),
                  ChoiceChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: Text(l10n.addExpenseCustomCategory),
                    selected: _isCustom &&
                        !customCats.contains(
                            _customCategoryController.text),
                    onSelected: (_) => setState(() {
                      _isCustom = true;
                      _customCategoryController.clear();
                      _selectedCategory = null;
                    }),
                    selectedColor: const Color(0xFFDBEAFE),
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

              // Amount
              Text(
                l10n.addExpenseAmount,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
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
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
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
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 18, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                l10n.addExpenseDescription,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
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
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
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
