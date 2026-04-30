import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/app_settings.dart';
import '../../theme/app_colors.dart';

/// Shows the "Add income source" bottom sheet.
///
/// Returns the new (or edited) `IncomeSource` on save, or `null` on cancel.
Future<IncomeSource?> showAddIncomeSourceSheet({
  required BuildContext context,
  IncomeSource? existing,
}) {
  return CalmBottomSheet.show<IncomeSource>(
    context,
    isScrollControlled: true,
    builder: (_) => _AddIncomeSourceSheet(existing: existing),
  );
}

class _AddIncomeSourceSheet extends StatefulWidget {
  final IncomeSource? existing;
  const _AddIncomeSourceSheet({this.existing});

  @override
  State<_AddIncomeSourceSheet> createState() => _AddIncomeSourceSheetState();
}

class _AddIncomeSourceSheetState extends State<_AddIncomeSourceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtl = TextEditingController();
  final _amountCtl = TextEditingController();
  final _dayCtl = TextEditingController(text: '1');

  IncomePeriod _period = IncomePeriod.monthly;
  String _category = 'wallet';
  bool _recurring = true;
  bool _received = false;

  static const _categories = <String>[
    'wallet',
    'home',
    'sparkle',
    'pie',
    'chart',
    'gift',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    if (s != null) {
      _labelCtl.text = s.label;
      _amountCtl.text = s.amount.toStringAsFixed(2);
      _dayCtl.text = s.dayOfMonth.toString();
      _period = s.period;
      _category = s.category;
      _recurring = s.recurring;
      _received = s.received;
    }
  }

  @override
  void dispose() {
    _labelCtl.dispose();
    _amountCtl.dispose();
    _dayCtl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final amount =
        double.tryParse(_amountCtl.text.trim().replaceAll(',', '.')) ?? 0;
    final day = int.tryParse(_dayCtl.text.trim()) ?? 1;
    final label = _labelCtl.text.trim();
    if (amount <= 0 || label.isEmpty) return;

    final source = (widget.existing ??
            IncomeSource(
              id: const Uuid().v4(),
              label: label,
              amount: amount,
            ))
        .copyWith(
      label: label,
      amount: amount,
      dayOfMonth: day,
      period: _period,
      category: _category,
      recurring: _recurring,
      received: _received,
    );

    Navigator.of(context).pop(source);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isEdit = widget.existing != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtl) => Form(
        key: _formKey,
        child: CalmBottomSheetContent(
          title: isEdit
              ? l10n.incomeSheetEditTitle
              : l10n.incomeSheetAddTitle,
          primaryAction: FilledButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
          child: SingleChildScrollView(
            controller: scrollCtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CalmTextField(
                  controller: _labelCtl,
                  label: l10n.incomeSheetLabelField,
                  hint: l10n.incomeSheetLabelHint,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.incomeSheetLabelRequired
                      : null,
                ),
                const SizedBox(height: 12),
                CalmTextField(
                  controller: _amountCtl,
                  label: l10n.incomeSheetAmountField,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  validator: (v) {
                    final n = double.tryParse(
                      (v ?? '').trim().replaceAll(',', '.'),
                    );
                    if (n == null || n <= 0) {
                      return l10n.incomeSheetAmountInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _SectionLabel(l10n.incomeSheetPeriodSection),
                const SizedBox(height: 8),
                _PeriodSegmented(
                  value: _period,
                  onChanged: (p) => setState(() {
                    _period = p;
                    if (p == IncomePeriod.oneOff) _recurring = false;
                    if (p == IncomePeriod.monthly) _recurring = true;
                  }),
                ),
                const SizedBox(height: 12),
                if (_period != IncomePeriod.oneOff)
                  CalmTextField(
                    controller: _dayCtl,
                    label: l10n.incomeSheetDayField,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      if (n == null || n < 1 || n > 31) {
                        return l10n.incomeSheetDayInvalid;
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                _SectionLabel(l10n.incomeSheetCategorySection),
                const SizedBox(height: 8),
                _CategoryPicker(
                  value: _category,
                  onChanged: (c) => setState(() => _category = c),
                  options: _categories,
                ),
                const SizedBox(height: 16),
                CalmSwitchRow(
                  title: l10n.incomeSheetRecurringToggle,
                  subtitle: l10n.incomeSheetRecurringSub,
                  value: _recurring,
                  onChanged: _period == IncomePeriod.oneOff
                      ? null
                      : (v) => setState(() => _recurring = v),
                ),
                CalmSwitchRow(
                  title: l10n.incomeSheetReceivedToggle,
                  subtitle: l10n.incomeSheetReceivedSub,
                  value: _received,
                  onChanged: (v) => setState(() => _received = v),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AppColors.ink50(context),
      ),
    );
  }
}

class _PeriodSegmented extends StatelessWidget {
  const _PeriodSegmented({required this.value, required this.onChanged});

  final IncomePeriod value;
  final ValueChanged<IncomePeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final entries = <(IncomePeriod, String)>[
      (IncomePeriod.monthly, l10n.incomePeriodMonthly),
      (IncomePeriod.oneOff, l10n.incomePeriodOneOff),
      (IncomePeriod.yearly, l10n.incomePeriodYearly),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgSunk(context),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          for (final entry in entries)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(entry.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: entry.$1 == value
                        ? AppColors.card(context)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    entry.$2,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: entry.$1 == value
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: entry.$1 == value
                          ? AppColors.ink(context)
                          : AppColors.ink50(context),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.value,
    required this.onChanged,
    required this.options,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in options)
          ChoiceChip(
            label: Text(_categoryLabel(l10n, c)),
            selected: c == value,
            onSelected: (_) => onChanged(c),
          ),
      ],
    );
  }

  String _categoryLabel(S l10n, String key) {
    switch (key) {
      case 'home':
        return l10n.incomeCategoryRent;
      case 'sparkle':
        return l10n.incomeCategoryFreelance;
      case 'pie':
        return l10n.incomeCategoryInterest;
      case 'chart':
        return l10n.incomeCategoryInvestment;
      case 'gift':
        return l10n.incomeCategoryGift;
      case 'wallet':
      default:
        return l10n.incomeCategorySalary;
    }
  }
}
