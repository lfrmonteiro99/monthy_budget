import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/meal_planner.dart';
import '../../theme/app_colors.dart';

class WeeklySummaryCard extends StatelessWidget {
  final WeeklyNutritionSummary summary;
  const WeeklySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final scoreColor = summary.overallScore >= 7
        ? AppColors.success(context)
        : summary.overallScore >= 4
        ? AppColors.warning(context)
        : AppColors.error(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: CalmCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 18,
                  color: AppColors.ink70(context),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.mealWeeklySummary,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                CalmPill(
                  label: '${summary.overallScore}/10',
                  color: scoreColor,
                ),
              ],
            ),
            if (summary.highlights.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...summary.highlights.map(
                (h) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: AppColors.ok(context),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(h, style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (summary.concerns.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...summary.concerns.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        size: 14,
                        color: AppColors.warn(context),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(c, style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
