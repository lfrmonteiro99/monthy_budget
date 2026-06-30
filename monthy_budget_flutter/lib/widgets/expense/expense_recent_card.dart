import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/actual_expense.dart';
import '../../models/custom_category.dart';
import '../../theme/app_colors.dart';
import '../../utils/category_helpers.dart';
import '../../utils/expense_category_format.dart';
import '../../utils/formatters.dart';

/// "RECENTES" card with the last 3 expenses, plus a "ver todas" footer when
/// there are more than 3.
class ExpenseRecentCard extends StatelessWidget {
  final List<ActualExpense> expenses;
  final List<CustomCategory> customCategories;
  final S l10n;
  final Future<void> Function(ActualExpense) onShowDetail;

  const ExpenseRecentCard({
    super.key,
    required this.expenses,
    required this.customCategories,
    required this.l10n,
    required this.onShowDetail,
  });

  @override
  Widget build(BuildContext context) {
    final recent = expenses.take(3).toList();
    return CalmCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            // TODO(l10n): move to ARB (Wave H)
            child: const CalmEyebrow('RECENTES'),
          ),
          Divider(color: AppColors.line(context), height: 1),
          ...recent.map((expense) {
            final catColor = categoryColorByNameFull(
              expense.category,
              customCategories: customCategories,
            );
            final catIcon = categoryIconByName(
              expense.category,
              customCategories: customCategories,
            );
            final dateStr =
                '${expense.date.day.toString().padLeft(2, '0')}/${expense.date.month.toString().padLeft(2, '0')}';
            final catLabel = localizedExpenseCategory(expense.category, l10n);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CalmListTile(
                    leadingIcon: catIcon,
                    leadingColor: catColor,
                    title: expense.description ?? catLabel,
                    subtitle: '$dateStr · $catLabel',
                    trailing: formatCurrency(expense.amount),
                    onTap: () => onShowDetail(expense),
                  ),
                ),
                Divider(
                  color: AppColors.line(context),
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
              ],
            );
          }),
          // "Ver todas" footer row
          if (expenses.length > 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CalmListTile(
                leadingIcon: Icons.receipt_long_outlined,
                leadingColor: AppColors.ink50(context),
                // TODO(l10n): move to ARB (Wave H)
                title: 'Ver todas as despesas',
                subtitle: '${expenses.length} transações este mês',
              ),
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}
