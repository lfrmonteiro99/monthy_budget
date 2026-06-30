import 'package:flutter/material.dart';
import '../../models/shopping_item.dart';
import '../../services/meal_planner_service.dart';
import '../../utils/pantry_matching.dart';
import '../pantry_coverage_badge.dart';
import '../star_rating_row.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/meal_planner.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import 'meal_badges.dart';

class DayCard extends StatelessWidget {
  final MealDay mealDay;

  /// All courses for this day+mealType group (soup, main, dessert).
  final List<MealDay> allCourses;
  final MealPlan plan;
  final MealPlannerService service;
  final RecipeAiContent? aiContent;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onSwap;
  final void Function(MealDay day) onSwapCourse;
  final VoidCallback onReplaceFreeform;
  final void Function(ShoppingItem) onAddIngredientToList;
  final ValueChanged<int> onRating;
  final VoidCallback onViewPrepGuide;
  final Set<String> activePantryIds;
  final void Function(String ingredientId) onSubstituteIngredient;
  final void Function(MealDay day, String ingredientId)
  onSubstituteCourseIngredient;

  const DayCard({
    super.key,
    required this.mealDay,
    this.allCourses = const [],
    required this.plan,
    required this.service,
    required this.aiContent,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onSwap,
    required this.onSwapCourse,
    required this.onReplaceFreeform,
    required this.onAddIngredientToList,
    required this.onRating,
    required this.onViewPrepGuide,
    required this.onSubstituteIngredient,
    required this.onSubstituteCourseIngredient,
    this.activePantryIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final recipe = service.recipeMap[mealDay.recipeId];
    if (recipe == null) return const SizedBox();
    final iMap = service.ingredientMap;
    // Total cost for all courses in this meal slot
    final totalMealCost = allCourses.fold(
      0.0,
      (sum, c) => sum + c.costEstimate,
    );
    final displayCost = allCourses.length > 1
        ? totalMealCost
        : mealDay.costEstimate;
    final costPerPerson = plan.nPessoas > 0
        ? displayCost / plan.nPessoas
        : displayCost;

    return CalmCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header: eyebrow + meal-type pill + leftover pill + cost + menu
          CalmEyebrow(l10n.mealDayLabel(mealDay.dayIndex)),
          const SizedBox(height: 6),
          Row(
            children: [
              CalmPill(
                label: mealDay.mealType.localizedLabel(l10n),
                color: AppColors.ok(context),
              ),
              if (mealDay.isLeftover) ...[
                const SizedBox(width: 4),
                CalmPill(
                  label: l10n.mealLeftover,
                  color: AppColors.warn(context),
                ),
              ],
              if (activePantryIds.isNotEmpty) ...[
                const SizedBox(width: 4),
                PantryCoverageBadge(
                  coverageRatio: computePantryCoverage(
                    recipe,
                    activePantryIds,
                  ).coverageRatio,
                ),
              ],
              const Spacer(),
              Text(
                '${displayCost.toStringAsFixed(2)}${currencySymbol()}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: AppColors.textMuted(context),
                ),
                padding: EdgeInsets.zero,
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'freeform',
                    child: Text(l10n.freeformReplace),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'freeform') onReplaceFreeform();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Course rows as CalmListTile
          ..._buildCourseListTiles(context, l10n, recipe, iMap),
          const SizedBox(height: 4),
          // Compact info row: stars + time + cost/person
          Row(
            children: [
              Stars(recipe.complexity),
              const SizedBox(width: 8),
              Icon(
                Icons.timer_outlined,
                size: 13,
                color: AppColors.textMuted(context),
              ),
              const SizedBox(width: 2),
              Text(
                recipe.activeMinutes != null && recipe.passiveMinutes != null
                    ? '${recipe.activeMinutes}+${recipe.passiveMinutes}min'
                    : '${recipe.prepMinutes}min',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted(context),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.person_outline,
                size: 13,
                color: AppColors.textMuted(context),
              ),
              const SizedBox(width: 2),
              Text(
                l10n.mealCostPerPerson(costPerPerson.toStringAsFixed(2)),
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
          // Compact nutrition badges
          if (recipe.nutrition != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                NutriBadge(
                  '${recipe.nutrition!.kcal}',
                  'kcal',
                  AppColors.error(context),
                ),
                const SizedBox(width: 4),
                NutriBadge(
                  '${recipe.nutrition!.proteinG.round()}g',
                  l10n.mealNutriProt,
                  AppColors.primary(context),
                ),
                const SizedBox(width: 4),
                NutriBadge(
                  '${recipe.nutrition!.carbsG.round()}g',
                  l10n.mealNutriCarbs,
                  AppColors.warning(context),
                ),
                const SizedBox(width: 4),
                NutriBadge(
                  '${recipe.nutrition!.fatG.round()}g',
                  l10n.mealNutriFat,
                  AppColors.accent(context),
                ),
                if (recipe.nutrition!.fiberG >= 5) ...[
                  const SizedBox(width: 4),
                  NutriBadge(
                    '${recipe.nutrition!.fiberG.round()}g',
                    l10n.mealNutriFiber,
                    AppColors.success(context),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 6),
          // Action row: star rating + icon-only buttons
          Row(
            children: [
              StarRatingRow(
                currentRating: mealDay.effectiveRating,
                onRate: onRating,
              ),
              const Spacer(),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: onToggleExpand,
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.restaurant_menu,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  color: isExpanded
                      ? AppColors.textSecondary(context)
                      : AppColors.primary(context),
                  tooltip: isExpanded ? l10n.close : l10n.mealIngredients,
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: onViewPrepGuide,
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  padding: EdgeInsets.zero,
                  color: AppColors.primary(context),
                  tooltip: l10n.mealViewPrepGuide,
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: onSwap,
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  padding: EdgeInsets.zero,
                  color: AppColors.textSecondary(context),
                  tooltip: l10n.mealSwap,
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: AppColors.line(context)),
            const SizedBox(height: 8),
            // Show ingredients for ALL courses in this meal slot
            ...allCourses.expand((course) {
              final courseRecipe = service.recipeMap[course.recipeId];
              if (courseRecipe == null) return <Widget>[];
              final courseLabel = allCourses.length > 1
                  ? _courseLabel(course.courseType, l10n)
                  : null;
              return [
                if (courseLabel != null) ...[
                  const SizedBox(height: 2),
                  CalmEyebrow(courseLabel),
                ] else ...[
                  CalmEyebrow(l10n.mealIngredients.toUpperCase()),
                ],
                ...courseRecipe.ingredients.map((ri) {
                  final effectiveId =
                      course.substitutions[ri.ingredientId] ?? ri.ingredientId;
                  final ing = iMap[effectiveId] ?? iMap[ri.ingredientId];
                  if (ing == null) return const SizedBox();
                  final isSubstituted = course.substitutions.containsKey(
                    ri.ingredientId,
                  );
                  final dayGuests = plan.extraGuests[course.dayIndex] ?? 0;
                  final scale =
                      (plan.nPessoas + dayGuests) / courseRecipe.servings;
                  final qty = ri.quantity * scale;
                  final cost = qty * ing.avgPricePerUnit;
                  // Tap → add to shopping list; tap icon → substitute ingredient.
                  return CalmListTile(
                    leadingIcon: isSubstituted ? Icons.swap_horiz : Icons.grain,
                    leadingColor: isSubstituted
                        ? AppColors.primary(context)
                        : AppColors.textMuted(context),
                    title: ing.name,
                    subtitle:
                        '${_fmt(qty)} ${ing.unit}${isSubstituted ? ' · substituted' : ''}',
                    trailing: '${cost.toStringAsFixed(2)}${currencySymbol()}',
                    onTap: () =>
                        onSubstituteCourseIngredient(course, ri.ingredientId),
                  );
                }),
              ];
            }),
            if (aiContent != null) ...[
              const SizedBox(height: 8),
              CalmEyebrow(l10n.mealPreparation.toUpperCase()),
              const SizedBox(height: 4),
              CalmCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...aiContent!.steps.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${e.key + 1}. ${e.value}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    if (aiContent!.tip.isNotEmpty) ...[
                      Divider(height: 1, color: AppColors.line(context)),
                      CalmListTile(
                        leadingIcon: Icons.lightbulb_outline,
                        leadingColor: AppColors.warning(context),
                        title: aiContent!.tip,
                      ),
                    ],
                    if (aiContent!.variation.isNotEmpty) ...[
                      Divider(height: 1, color: AppColors.line(context)),
                      CalmListTile(
                        leadingIcon: Icons.shuffle,
                        leadingColor: AppColors.primary(context),
                        title: l10n.mealVariation,
                        subtitle: aiContent!.variation,
                      ),
                    ],
                    if (aiContent!.pairingSuggestion.isNotEmpty) ...[
                      Divider(height: 1, color: AppColors.line(context)),
                      CalmListTile(
                        leadingIcon: Icons.restaurant,
                        leadingColor: AppColors.success(context),
                        title: l10n.mealPairing,
                        subtitle: aiContent!.pairingSuggestion,
                      ),
                    ],
                    if (aiContent!.storageInfo.isNotEmpty) ...[
                      Divider(height: 1, color: AppColors.line(context)),
                      CalmListTile(
                        leadingIcon: Icons.kitchen,
                        leadingColor: AppColors.textSecondary(context),
                        title: l10n.mealStorage,
                        subtitle: aiContent!.storageInfo,
                      ),
                    ],
                    if (mealDay.isLeftover &&
                        aiContent!.leftoverIdea.isNotEmpty) ...[
                      Divider(height: 1, color: AppColors.line(context)),
                      CalmListTile(
                        leadingIcon: Icons.auto_fix_high,
                        leadingColor: AppColors.warn(context),
                        title: l10n.mealLeftoverIdea,
                        subtitle: aiContent!.leftoverIdea,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _courseLabel(CourseType ct, S l10n) {
    switch (ct) {
      case CourseType.soupOrStarter:
        return l10n.mealCourseSoupStarter.toUpperCase();
      case CourseType.mainCourse:
        return l10n.mealCourseMain.toUpperCase();
      case CourseType.dessert:
        return l10n.mealCourseDessert.toUpperCase();
    }
  }

  /// Builds course rows as CalmListTile for the compact header display.
  List<Widget> _buildCourseListTiles(
    BuildContext context,
    S l10n,
    Recipe mainRecipe,
    Map<String, Ingredient> iMap,
  ) {
    final widgets = <Widget>[];
    final hasCourses = allCourses.length > 1;

    if (!hasCourses) {
      // Single course: show as CalmListTile
      widgets.add(
        CalmListTile(
          leadingIcon: Icons.restaurant,
          leadingColor: AppColors.primary(context),
          title: mainRecipe.name,
          onTap: onSwap,
        ),
      );
      return widgets;
    }

    // Multi-course: soup/starter, main, dessert each as CalmListTile
    for (final course in allCourses) {
      if (course.courseType == CourseType.soupOrStarter) {
        final soupRecipe = service.recipeMap[course.recipeId];
        if (soupRecipe != null) {
          widgets.add(
            CalmListTile(
              leadingIcon: Icons.soup_kitchen,
              leadingColor: AppColors.warn(context),
              title: soupRecipe.name,
              onTap: () => onSwapCourse(course),
            ),
          );
        }
      }
    }

    // Main course
    widgets.add(
      CalmListTile(
        leadingIcon: Icons.restaurant,
        leadingColor: AppColors.primary(context),
        title: mainRecipe.name,
        onTap: onSwap,
      ),
    );

    for (final course in allCourses) {
      if (course.courseType == CourseType.dessert) {
        final dessertRecipe = service.recipeMap[course.recipeId];
        if (dessertRecipe != null) {
          widgets.add(
            CalmListTile(
              leadingIcon: Icons.icecream,
              leadingColor: AppColors.accent(context),
              title: dessertRecipe.name,
              onTap: () => onSwapCourse(course),
            ),
          );
        }
      }
    }

    return widgets;
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(1);
  }
}

// -- Swap Bottom Sheet --------------------------------------------------------

