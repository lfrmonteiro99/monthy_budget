import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/meal_planner.dart';
import '../theme/app_colors.dart';

/// Horizontal chip row summarizing active pantry ingredients.
/// Shown in the meal planner above the plan view.
class PantrySummaryChipRow extends StatelessWidget {
  final Set<String> activePantryIds;
  final Map<String, Ingredient> ingredientMap;
  final VoidCallback onEditPantry;

  const PantrySummaryChipRow({
    super.key,
    required this.activePantryIds,
    required this.ingredientMap,
    required this.onEditPantry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    if (activePantryIds.isEmpty) return const SizedBox.shrink();

    final names = activePantryIds
        .map((id) => ingredientMap[id]?.name)
        .whereType<String>()
        .toList()
      ..sort();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.kitchen_outlined,
                  size: 14, color: AppColors.primary(context)),
              const SizedBox(width: 6),
              Text(
                l10n.pantrySummaryLabel(activePantryIds.length),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary(context),
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEditPantry,
                child: Text(
                  l10n.pantryEdit,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 30,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: names.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, i) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successBackground(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.success(context)),
                ),
                child: Text(
                  names[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.success(context),
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
