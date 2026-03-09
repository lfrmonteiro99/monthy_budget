import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/shopping_grouping.dart';

/// A segmented toggle for switching between shopping list group modes.
class ShoppingGroupToggle extends StatelessWidget {
  final List<ShoppingGroupMode> availableModes;
  final ShoppingGroupMode selected;
  final ValueChanged<ShoppingGroupMode> onChanged;

  const ShoppingGroupToggle({
    super.key,
    required this.availableModes,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final labels = {
      ShoppingGroupMode.items: l10n.shoppingViewItems,
      ShoppingGroupMode.meals: l10n.shoppingViewMeals,
      ShoppingGroupMode.stores: l10n.shoppingViewStores,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface(context),
      child: Row(
        children: availableModes.map((mode) {
          final isSelected = mode == selected;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: isSelected
                    ? AppColors.primary(context)
                    : AppColors.background(context),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => onChanged(mode),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary(context)
                            : AppColors.border(context),
                      ),
                    ),
                    child: Text(
                      labels[mode]!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.onPrimary(context)
                            : AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
