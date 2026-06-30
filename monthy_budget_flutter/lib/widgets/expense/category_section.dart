import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/actual_expense.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

/// Expandable card for one budget category: header with progress + the list of
/// expenses in that category (each swipe-to-delete).
class CategorySection extends StatelessWidget {
  final CategoryBudgetSummary summary;
  final List<ActualExpense> expenses;
  final IconData icon;
  final Color categoryColor;
  final String label;
  final Future<void> Function(ActualExpense) onOpenDetails;
  final Future<void> Function(ActualExpense) onDelete;
  final S l10n;

  const CategorySection({
    super.key,
    required this.summary,
    required this.expenses,
    required this.icon,
    required this.categoryColor,
    required this.label,
    required this.onOpenDetails,
    required this.onDelete,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = summary.isOver
        ? AppColors.bad(context)
        : summary.progress > 0.8
        ? AppColors.warn(context)
        : AppColors.ok(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CalmCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: categoryColor.withValues(alpha: 0.15),
                  child: Icon(icon, size: 18, color: categoryColor),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: CalmEyebrow(label.toUpperCase()),
                    ),
                    Text(
                      formatCurrency(summary.actual),
                      style: CalmText.amount(context),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: summary.progress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.line(context),
                        color: progressColor,
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          CalmPill(
                            label: summary.isOver
                                ? '-${formatCurrency(summary.remaining.abs())}'
                                : formatCurrency(summary.remaining),
                            color: progressColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            summary.isOver
                                ? l10n.expenseTrackerOver
                                : l10n.expenseTrackerRemaining,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.ink70(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                shape: const Border(),
                collapsedShape: const Border(),
                tilePadding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                childrenPadding: EdgeInsets.zero,
                children: [
                  if (expenses.isNotEmpty) ...[
                    Divider(
                      color: AppColors.line(context),
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    ...expenses.asMap().entries.map((entry) {
                      final i = entry.key;
                      final expense = entry.value;
                      final dateStr =
                          '${expense.date.day.toString().padLeft(2, '0')}/${expense.date.month.toString().padLeft(2, '0')}/${expense.date.year}';
                      return Column(
                        children: [
                          Dismissible(
                            key: ValueKey(expense.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) async {
                              final confirmed = await CalmDialog.confirm(
                                context,
                                title: l10n.delete,
                                body: l10n.expenseTrackerDeleteConfirm,
                                confirmLabel: l10n.delete,
                                cancelLabel: l10n.cancel,
                                destructive: true,
                              );
                              return confirmed ?? false;
                            },
                            onDismissed: (_) => onDelete(expense),
                            background: ColoredBox(
                              color: AppColors.bad(context)
                                  .withValues(alpha: 0.12),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: AppColors.bad(context),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: CalmListTile(
                                leadingIcon: icon,
                                leadingColor: categoryColor,
                                title: expense.description ?? label,
                                subtitle: dateStr,
                                trailing: formatCurrency(expense.amount),
                                onTap: () => onOpenDetails(expense),
                              ),
                            ),
                          ),
                          if (i < expenses.length - 1)
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
