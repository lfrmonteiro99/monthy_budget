import 'package:flutter/material.dart';
import '../../models/shopping_item.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/meal_planner.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';

class ConsolidatedSheet extends StatelessWidget {
  final Map<String, double> totals;
  final Map<String, Ingredient> ingredientMap;
  final void Function(ShoppingItem) onAddToShoppingList;

  const ConsolidatedSheet({
    super.key,
    required this.totals,
    required this.ingredientMap,
    required this.onAddToShoppingList,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final grouped = <IngredientCategory, List<MapEntry<String, double>>>{};
    for (final entry in totals.entries) {
      final ing = ingredientMap[entry.key];
      if (ing == null) continue;
      grouped.putIfAbsent(ing.category, () => []).add(entry);
    }

    final categories = [
      IngredientCategory.proteina,
      IngredientCategory.vegetal,
      IngredientCategory.carbo,
      IngredientCategory.gordura,
      IngredientCategory.condimento,
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ClipRRect(
              // Justified: drag-handle indicator, no Calm equivalent
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                width: 40,
                height: 4,
                child: ColoredBox(color: AppColors.borderMuted(context)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.mealConsolidatedTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: categories.expand((cat) {
                final items = grouped[cat];
                if (items == null || items.isEmpty) return <Widget>[];
                return [
                  const SizedBox(height: 16),
                  CalmEyebrow(_categoryLabel(cat, l10n).toUpperCase()),
                  const SizedBox(height: 4),
                  CalmCard(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        ...items.map((entry) {
                          final ing = ingredientMap[entry.key]!;
                          final cost = entry.value * ing.avgPricePerUnit;
                          return CalmListTile(
                            leadingIcon: _ingredientCategoryIcon(cat),
                            leadingColor: _ingredientCategoryColor(
                              cat,
                              context,
                            ),
                            title: ing.name,
                            subtitle: '${_fmt(entry.value)} ${ing.unit}',
                            trailing:
                                '${cost.toStringAsFixed(2)}${currencySymbol()}',
                            onTap: () => onAddToShoppingList(
                              ShoppingItem(
                                productName: ing.name,
                                store: '',
                                price: cost,
                                unitPrice:
                                    '${ing.avgPricePerUnit.toStringAsFixed(2)}${currencySymbol()}/${ing.unit}',
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ];
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(IngredientCategory cat, S l10n) {
    switch (cat) {
      case IngredientCategory.proteina:
        return l10n.mealCatProteins;
      case IngredientCategory.vegetal:
        return l10n.mealCatVegetables;
      case IngredientCategory.carbo:
        return l10n.mealCatCarbs;
      case IngredientCategory.gordura:
        return l10n.mealCatFats;
      case IngredientCategory.condimento:
        return l10n.mealCatCondiments;
    }
  }

  IconData _ingredientCategoryIcon(IngredientCategory cat) {
    switch (cat) {
      case IngredientCategory.proteina:
        return Icons.egg_outlined;
      case IngredientCategory.vegetal:
        return Icons.eco_outlined;
      case IngredientCategory.carbo:
        return Icons.grain;
      case IngredientCategory.gordura:
        return Icons.water_drop_outlined;
      case IngredientCategory.condimento:
        return Icons.spa_outlined;
    }
  }

  Color _ingredientCategoryColor(IngredientCategory cat, BuildContext context) {
    switch (cat) {
      case IngredientCategory.proteina:
        return AppColors.error(context);
      case IngredientCategory.vegetal:
        return AppColors.ok(context);
      case IngredientCategory.carbo:
        return AppColors.warning(context);
      case IngredientCategory.gordura:
        return AppColors.accent(context);
      case IngredientCategory.condimento:
        return AppColors.primary(context);
    }
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(1);
  }
}

// -- Helpers ------------------------------------------------------------------

