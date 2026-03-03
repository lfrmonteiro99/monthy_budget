import 'package:flutter/material.dart';
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
  return showModalBottomSheet<SavingsGoal>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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
            id: 'sg_${DateTime.now().millisecondsSinceEpoch}',
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
              // Drag handle
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

              // Title
              Text(
                isEdit ? l10n.savingsGoalEdit : l10n.savingsGoalAdd,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 20),

              // Name
              _label(context, l10n.savingsGoalName),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: l10n.savingsGoalName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                    initialDate: _deadline ?? DateTime.now().add(const Duration(days: 90)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) {
                    setState(() => _deadline = picked);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderMuted(context)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 18,
                          color: AppColors.textSecondary(context)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _deadline != null
                              ? '${_deadline!.day.toString().padLeft(2, '0')}/${_deadline!.month.toString().padLeft(2, '0')}/${_deadline!.year}'
                              : l10n.savingsGoalNoDeadline,
                          style: TextStyle(
                            fontSize: 14,
                            color: _deadline != null
                                ? AppColors.textPrimary(context)
                                : AppColors.textMuted(context),
                          ),
                        ),
                      ),
                      if (_deadline != null)
                        GestureDetector(
                          onTap: () => setState(() => _deadline = null),
                          child: Icon(Icons.close,
                              size: 18,
                              color: AppColors.textMuted(context)),
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
                                  color: AppColors.textPrimary(context),
                                  width: 3)
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
                  _isActive ? l10n.savingsGoalActive : l10n.savingsGoalInactive,
                  style: TextStyle(color: AppColors.textPrimary(context)),
                ),
                activeThumbColor: AppColors.primary(context),
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

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary(context),
        letterSpacing: 0.8,
      ),
    );
  }
}

Color _hexToColor(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
}
