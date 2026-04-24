import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/savings_goal.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

const _goalColors = [
  '#3B82F6', // blue
  '#10B981', // emerald
  '#F59E0B', // amber
  '#EF4444', // red
  '#8B5CF6', // violet
  '#EC4899', // pink
];

Future<SavingsGoal?> showAddSavingsGoalSheet({
  required BuildContext context,
  SavingsGoal? existing,
}) {
  return CalmBottomSheet.show<SavingsGoal>(
    context,
    isScrollControlled: true,
    builder: (_) => _AddSavingsGoalSheet(existing: existing),
  );
}

class _AddSavingsGoalSheet extends StatefulWidget {
  final SavingsGoal? existing;
  const _AddSavingsGoalSheet({this.existing});

  @override
  State<_AddSavingsGoalSheet> createState() => _AddSavingsGoalSheetState();
}

class _AddSavingsGoalSheetState extends State<_AddSavingsGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  DateTime? _deadline;
  String? _selectedColor;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final g = widget.existing!;
      _nameController.text = g.name;
      _targetController.text = g.targetAmount.toStringAsFixed(2);
      _deadline = g.deadline;
      _selectedColor = g.color;
      _isActive = g.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final target =
        double.tryParse(_targetController.text.replaceAll(',', '.'));
    if (target == null || target <= 0) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final result = widget.existing != null
        ? widget.existing!.copyWith(
            name: name,
            targetAmount: target,
            deadline: _deadline,
            clearDeadline: _deadline == null,
            color: _selectedColor,
            clearColor: _selectedColor == null,
            isActive: _isActive,
          )
        : SavingsGoal(
            id: const Uuid().v4(),
            name: name,
            targetAmount: target,
            deadline: _deadline,
            color: _selectedColor,
            isActive: _isActive,
          );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isEdit = widget.existing != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Form(
        key: _formKey,
        child: CalmBottomSheetContent(
          title: isEdit ? l10n.savingsGoalEdit : l10n.savingsGoalAdd,
          primaryAction: FilledButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name
                _label(context, l10n.savingsGoalName),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: l10n.savingsGoalName,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.savingsGoalName : null,
                ),
                const SizedBox(height: 20),

                // Target amount
                _label(context, l10n.savingsGoalTarget),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _targetController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixText: currencySymbol(),
                  ),
                  validator: (v) {
                    final val =
                        double.tryParse((v ?? '').replaceAll(',', '.'));
                    if (val == null || val <= 0) return l10n.savingsGoalTarget;
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Deadline
                _label(context, l10n.savingsGoalDeadline),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _deadline ??
                          DateTime.now().add(const Duration(days: 90)),
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null && mounted) {
                      setState(() => _deadline = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.line(context)),
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.card(context),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 18,
                            color: AppColors.ink70(context)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _deadline != null
                                ? '${_deadline!.day.toString().padLeft(2, '0')}/${_deadline!.month.toString().padLeft(2, '0')}/${_deadline!.year}'
                                : l10n.savingsGoalNoDeadline,
                            style: TextStyle(
                              fontSize: 15,
                              color: _deadline != null
                                  ? AppColors.ink(context)
                                  : AppColors.ink50(context),
                            ),
                          ),
                        ),
                        if (_deadline != null)
                          GestureDetector(
                            onTap: () => setState(() => _deadline = null),
                            child: Icon(Icons.close,
                                size: 18,
                                color: AppColors.ink50(context)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Color picker
                _label(context, l10n.savingsGoalColor),
                const SizedBox(height: 8),
                Row(
                  children: _goalColors.map((hex) {
                    final color = _hexToColor(hex);
                    final selected = _selectedColor == hex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _selectedColor = selected ? null : hex;
                        }),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(
                                    color: AppColors.ink(context),
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: selected
                              ? const Icon(Icons.check,
                                  size: 18, color: Colors.white)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Active toggle
                SwitchListTile(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: Text(
                    _isActive
                        ? l10n.savingsGoalActive
                        : l10n.savingsGoalInactive,
                    style: TextStyle(color: AppColors.ink(context)),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.ink70(context),
        letterSpacing: 0.8,
      ),
    );
  }
}

Color _hexToColor(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
}
