import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/savings_goal.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';

/// Bottom-sheet form to add a contribution to a savings goal. Pops with the
/// created [SavingsContribution] on save, or `null` on cancel.
class AddContributionSheet extends StatefulWidget {
  final String goalId;
  const AddContributionSheet({super.key, required this.goalId});

  @override
  State<AddContributionSheet> createState() => _AddContributionSheetState();
}

class _AddContributionSheetState extends State<AddContributionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;

    final note = _noteController.text.trim();
    final result = SavingsContribution(
      id: const Uuid().v4(),
      goalId: widget.goalId,
      amount: amount,
      contributionDate: _selectedDate,
      note: note.isEmpty ? null : note,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) => Form(
        key: _formKey,
        child: CalmBottomSheetContent(
          title: l10n.savingsGoalContribute,
          primaryAction: FilledButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Amount
                _sheetLabel(context, l10n.savingsGoalContributionAmount),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    prefixText: currencySymbol(),
                  ),
                  validator: (v) {
                    final val = double.tryParse((v ?? '').replaceAll(',', '.'));
                    if (val == null || val <= 0) {
                      return l10n.savingsGoalContributionAmount;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Date
                _sheetLabel(context, l10n.savingsGoalContributionDate),
                const SizedBox(height: 8),
                CalmCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null && mounted) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppColors.ink70(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.ink(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Note
                _sheetLabel(context, l10n.savingsGoalContributionNote),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: l10n.savingsGoalContributionNote,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetLabel(BuildContext context, String text) {
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
