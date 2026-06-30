import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/actual_expense.dart';
import '../../models/custom_category.dart';
import '../../theme/app_colors.dart';
import '../../utils/category_helpers.dart';
import '../../utils/expense_category_format.dart';
import '../../utils/formatters.dart';

/// "ALERTAS" card listing the over-budget categories as rows.
class ExpenseAlertsCard extends StatelessWidget {
  final List<CategoryBudgetSummary> summaries;
  final List<CustomCategory> customCategories;
  final S l10n;

  const ExpenseAlertsCard({
    super.key,
    required this.summaries,
    required this.customCategories,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final overItems = summaries.where((s) => s.isOver).toList();
    return CalmCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                // TODO(l10n): move to ARB (Wave H)
                const CalmEyebrow('ALERTAS'),
                const SizedBox(width: 6),
                CalmPill(
                  label: '${overItems.length}',
                  color: AppColors.bad(context),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.line(context), height: 1),
          ...overItems.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            final catIcon = categoryIconByName(
              s.category,
              customCategories: customCategories,
            );
            final over = s.actual - s.budgeted;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CalmListTile(
                    leadingIcon: catIcon,
                    leadingColor: AppColors.bad(context),
                    title: localizedExpenseCategory(s.category, l10n),
                    subtitle:
                        // TODO(l10n): move to ARB (Wave H)
                        'orç. ${formatCurrency(s.budgeted)} · gasto ${formatCurrency(s.actual)}',
                    trailing: '+${formatCurrency(over)}',
                  ),
                ),
                if (i < overItems.length - 1)
                  Divider(
                    color: AppColors.line(context),
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
