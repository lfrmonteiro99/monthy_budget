import 'package:flutter/material.dart';
import '../../services/meal_planner_service.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/meal_planner.dart';
import '../../models/meal_settings.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';

class SwapSheet extends StatefulWidget {
  final String currentRecipeId;
  final int nPessoas;
  final Map<String, Ingredient> ingredientMap;
  final MealPlannerService service;
  final MealSettings mealSettings;
  final MealType currentMealType;
  final CourseType? courseType;
  final void Function(String) onSelect;

  const SwapSheet({
    super.key,
    required this.currentRecipeId,
    required this.nPessoas,
    required this.ingredientMap,
    required this.service,
    required this.mealSettings,
    required this.currentMealType,
    this.courseType,
    required this.onSelect,
  });

  @override
  State<SwapSheet> createState() => _SwapSheetState();
}

class _SwapSheetState extends State<SwapSheet> {
  bool _showAllMealTypes = false;
  late List<Recipe> _alternatives;

  @override
  void initState() {
    super.initState();
    _alternatives = widget.service.alternativesFor(
      widget.currentRecipeId,
      widget.nPessoas,
      ms: widget.mealSettings,
      courseType: widget.courseType,
    );
  }

  void _refreshAlternatives() {
    setState(() {
      _alternatives = widget.service.alternativesFor(
        widget.currentRecipeId,
        widget.nPessoas,
        ms: widget.mealSettings,
        crossType: _showAllMealTypes,
        courseType: widget.courseType,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final currentRecipe = widget.service.recipeMap[widget.currentRecipeId];
    final currentCost = currentRecipe != null
        ? widget.service.recipeCost(
            currentRecipe,
            widget.nPessoas,
            widget.ingredientMap,
          )
        : 0.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.mealAlternatives,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilterChip(
                  label: Text(l10n.mealSwapSameType),
                  selected: !_showAllMealTypes,
                  onSelected: (_) {
                    _showAllMealTypes = false;
                    _refreshAlternatives();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(l10n.mealSwapAllTypes),
                  selected: _showAllMealTypes,
                  onSelected: (_) {
                    _showAllMealTypes = true;
                    _refreshAlternatives();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            CalmCard(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  ..._alternatives.take(6).map((r) {
                    final cost = widget.service.recipeCost(
                      r,
                      widget.nPessoas,
                      widget.ingredientMap,
                    );
                    final delta = cost - currentCost;
                    final deltaStr = delta >= 0
                        ? '+${delta.toStringAsFixed(2)}${currencySymbol()}'
                        : '${delta.toStringAsFixed(2)}${currencySymbol()}';
                    final deltaColor = delta > 0
                        ? AppColors.bad(context)
                        : AppColors.ok(context);
                    // Show meal type badge for cross-type results via subtitle
                    final isCrossType = !r.suitableMealTypes.contains(
                      widget.currentMealType.name,
                    );
                    final subtitleParts = [
                      l10n.mealTotalCost(cost.toStringAsFixed(2)),
                      if (_showAllMealTypes && isCrossType)
                        r.suitableMealTypes.first,
                    ];
                    return CalmListTile(
                      leadingIcon: Icons.restaurant_menu,
                      leadingColor: deltaColor,
                      title: r.name,
                      subtitle: subtitleParts.join(' · '),
                      trailing: deltaStr,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onSelect(r.id);
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Consolidated List Sheet --------------------------------------------------

