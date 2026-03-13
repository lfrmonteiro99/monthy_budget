import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/meal_planner.dart';
import '../models/shopping_item.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Card that renders a freeform (non-recipe) meal in the plan list.
class FreeformMealCard extends StatelessWidget {
  final MealDay mealDay;
  final VoidCallback onEdit;
  final void Function(ShoppingItem) onAddToShoppingList;
  final ValueChanged<MealFeedback> onFeedback;

  const FreeformMealCard({
    super.key,
    required this.mealDay,
    required this.onEdit,
    required this.onAddToShoppingList,
    required this.onFeedback,
  });

  String _tagLabel(String tag, S l10n) {
    switch (tag) {
      case 'leftovers':
        return l10n.freeformTagLeftovers;
      case 'pantry_meal':
        return l10n.freeformTagPantryMeal;
      case 'takeout':
        return l10n.freeformTagTakeout;
      case 'quick_meal':
        return l10n.freeformTagQuickMeal;
      default:
        return tag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    assert(mealDay.isFreeform);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.surface(context),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border(context)),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: day badge, meal type, freeform badge, cost
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.infoBackground(context),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      l10n.mealDayLabel(mealDay.dayIndex),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successBackground(context),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      mealDay.mealType.localizedLabel(l10n),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight(context),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_note, size: 12, color: AppColors.primary(context)),
                        const SizedBox(width: 4),
                        Text(
                          l10n.freeformBadge,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${mealDay.costEstimate.toStringAsFixed(2)}${currencySymbol()}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                mealDay.freeformTitle ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              // Note preview
              if (mealDay.freeformNote != null && mealDay.freeformNote!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  mealDay.freeformNote!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
                ),
              ],
              // Tags
              if (mealDay.freeformTags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: mealDay.freeformTags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant(context),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _tagLabel(tag, l10n),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  )).toList(),
                ),
              ],
              // Shopping items count
              if (mealDay.freeformShoppingItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 14, color: AppColors.textMuted(context)),
                    const SizedBox(width: 4),
                    Text(
                      l10n.freeformShoppingItemCount(mealDay.freeformShoppingItems.length),
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
