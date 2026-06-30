import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../models/actual_expense.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';

/// Row used in the expense search results list.
class SearchResultTile extends StatelessWidget {
  final ActualExpense expense;
  final String categoryLabel;
  final IconData categoryIcon;
  final Color categoryColor;
  final VoidCallback? onTap;

  const SearchResultTile({
    super.key,
    required this.expense,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.categoryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${expense.date.day.toString().padLeft(2, '0')}/${expense.date.month.toString().padLeft(2, '0')}/${expense.date.year}';
    return Column(
      children: [
        CalmListTile(
          leadingIcon: categoryIcon,
          leadingColor: categoryColor,
          title: expense.description ?? categoryLabel,
          subtitle: '$dateStr  •  $categoryLabel',
          trailing: formatCurrency(expense.amount),
          onTap: onTap,
        ),
        Divider(color: AppColors.line(context), height: 1),
      ],
    );
  }
}
