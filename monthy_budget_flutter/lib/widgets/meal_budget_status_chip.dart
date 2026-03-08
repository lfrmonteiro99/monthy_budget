import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/meal_budget_insight.dart';
import '../theme/app_colors.dart';

class MealBudgetStatusChip extends StatelessWidget {
  final MealBudgetStatus status;

  const MealBudgetStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final String label;
    final Color bgColor;
    final Color textColor;

    switch (status) {
      case MealBudgetStatus.safe:
        label = l10n.mealBudgetStatusSafe;
        bgColor = AppColors.successBackground(context);
        textColor = AppColors.success(context);
      case MealBudgetStatus.watch:
        label = l10n.mealBudgetStatusWatch;
        bgColor = AppColors.warningBackground(context);
        textColor = AppColors.warning(context);
      case MealBudgetStatus.over:
        label = l10n.mealBudgetStatusOver;
        bgColor = AppColors.errorBackground(context);
        textColor = AppColors.error(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
