import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/shopping_grouping.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CalmCard(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: availableModes.map((mode) {
            final isSelected = mode == selected;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.ink(context)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => onChanged(mode),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      child: Text(
                        labels[mode]!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.bg(context)
                              : AppColors.ink70(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
