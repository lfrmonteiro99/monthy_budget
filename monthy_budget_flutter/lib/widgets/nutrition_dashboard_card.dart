import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/meal_planner.dart';
import '../models/meal_settings.dart';
import '../theme/app_colors.dart';

/// Pure computation result for weekly nutrition averages.
/// Extracted from the widget so it can be unit-tested without Flutter.
class WeekNutritionStats {
  final double avgKcal;
  final double avgProteinG;
  final double avgCarbsG;
  final double avgFatG;
  final double avgFiberG;
  final Map<String, int> topProteins;
  final int daysCount;

  const WeekNutritionStats({
    required this.avgKcal,
    required this.avgProteinG,
    required this.avgCarbsG,
    required this.avgFatG,
    required this.avgFiberG,
    required this.topProteins,
    required this.daysCount,
  });

  double get totalMacroG => avgProteinG + avgCarbsG + avgFatG;
  int get proteinPct => totalMacroG > 0 ? (avgProteinG / totalMacroG * 100).round() : 0;
  int get carbsPct => totalMacroG > 0 ? (avgCarbsG / totalMacroG * 100).round() : 0;
  int get fatPct => totalMacroG > 0 ? (avgFatG / totalMacroG * 100).round() : 0;
}

/// Computes weekly nutrition averages from meal days.
///
/// Returns null when no days have nutrition data.
/// [nPessoas] is the household size; nutrition is divided equally among members.
WeekNutritionStats? computeWeekNutritionStats({
  required List<MealDay> weekDays,
  required Map<String, Recipe> recipeMap,
  required int nPessoas,
}) {
  double totalKcal = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0, totalFiber = 0;
  int daysWithNutrition = 0;
  final proteinCounts = <String, int>{};

  // Group meals by day index so we sum per-day totals before averaging.
  final dayGroups = <int, List<MealDay>>{};
  for (final day in weekDays) {
    dayGroups.putIfAbsent(day.dayIndex, () => []).add(day);
  }

  final perPerson = nPessoas > 0 ? nPessoas : 1;

  for (final entry in dayGroups.entries) {
    double dayKcal = 0, dayProtein = 0, dayCarbs = 0, dayFat = 0, dayFiber = 0;
    bool dayHasNutrition = false;

    for (final day in entry.value) {
      if (day.isLeftover || day.isFreeform) continue;
      final recipe = recipeMap[day.recipeId];
      if (recipe == null || recipe.nutrition == null) continue;

      // Nutrition is per-recipe total. Divide by household size for per-person.
      final n = recipe.nutrition!;
      dayKcal += n.kcal / perPerson;
      dayProtein += n.proteinG / perPerson;
      dayCarbs += n.carbsG / perPerson;
      dayFat += n.fatG / perPerson;
      dayFiber += n.fiberG / perPerson;
      dayHasNutrition = true;

      proteinCounts.update(recipe.proteinId, (v) => v + 1, ifAbsent: () => 1);
    }

    if (dayHasNutrition) {
      totalKcal += dayKcal;
      totalProtein += dayProtein;
      totalCarbs += dayCarbs;
      totalFat += dayFat;
      totalFiber += dayFiber;
      daysWithNutrition++;
    }
  }

  if (daysWithNutrition == 0) return null;

  return WeekNutritionStats(
    avgKcal: totalKcal / daysWithNutrition,
    avgProteinG: totalProtein / daysWithNutrition,
    avgCarbsG: totalCarbs / daysWithNutrition,
    avgFatG: totalFat / daysWithNutrition,
    avgFiberG: totalFiber / daysWithNutrition,
    topProteins: Map.fromEntries(
      proteinCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    ),
    daysCount: daysWithNutrition,
  );
}

class NutritionDashboardCard extends StatelessWidget {
  final List<MealDay> weekDays;
  final Map<String, Recipe> recipeMap;
  final Map<String, Ingredient> ingredientMap;
  final int nPessoas;
  final MealSettings settings;

  const NutritionDashboardCard({
    super.key,
    required this.weekDays,
    required this.recipeMap,
    required this.ingredientMap,
    required this.nPessoas,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final stats = computeWeekNutritionStats(
      weekDays: weekDays,
      recipeMap: recipeMap,
      nPessoas: nPessoas,
    );
    if (stats == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Card(
        elevation: 0,
        color: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.border(context)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.textSecondary(context)),
                  const SizedBox(width: 8),
                  Text(
                    l10n.nutritionDashboardTitle,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bars for each nutrient with a target
              if (settings.dailyCalorieTarget != null)
                _NutrientBar(
                  label: l10n.nutritionCalories,
                  current: stats.avgKcal,
                  target: settings.dailyCalorieTarget!.toDouble(),
                  unit: 'kcal',
                  color: AppColors.error(context),
                ),
              if (settings.dailyProteinTargetG != null) ...[
                const SizedBox(height: 8),
                _NutrientBar(
                  label: l10n.nutritionProtein,
                  current: stats.avgProteinG,
                  target: settings.dailyProteinTargetG!.toDouble(),
                  unit: 'g',
                  color: Colors.blue,
                ),
              ],
              if (settings.dailyFiberTargetG != null) ...[
                const SizedBox(height: 8),
                _NutrientBar(
                  label: l10n.nutritionFiber,
                  current: stats.avgFiberG,
                  target: settings.dailyFiberTargetG!.toDouble(),
                  unit: 'g',
                  color: AppColors.success(context),
                ),
              ],
              // Macro breakdown row
              const SizedBox(height: 12),
              _MacroRow(stats: stats, l10n: l10n),
              // Top protein sources
              if (stats.topProteins.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${l10n.nutritionTopProteins}: ${stats.topProteins.entries.take(3).map((e) => '${_resolveProteinName(e.key)} ${e.value}x').join(', ')}',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Resolves a proteinId to a human-readable name via the ingredient map.
  /// Falls back to the raw id with underscores replaced by spaces.
  String _resolveProteinName(String proteinId) {
    final ingredient = ingredientMap[proteinId];
    if (ingredient != null) return ingredient.name;
    return proteinId.replaceAll('_', ' ');
  }
}

class _NutrientBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final String unit;
  final Color color;

  const _NutrientBar({
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = target > 0 ? (current / target).clamp(0.0, 1.5) : 0.0;
    final barRatio = ratio.clamp(0.0, 1.0);
    final progressColor = ratio >= 0.8
        ? AppColors.success(context)
        : ratio >= 0.6
            ? AppColors.warning(context)
            : AppColors.error(context);
    final met = ratio >= 0.8;

    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: barRatio,
              backgroundColor: AppColors.border(context),
              color: progressColor,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            '${current.round()}/${target.round()} $unit',
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.end,
          ),
        ),
        if (met) ...[
          const SizedBox(width: 4),
          Icon(Icons.check, size: 14, color: AppColors.success(context)),
        ],
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  final WeekNutritionStats stats;
  final S l10n;

  const _MacroRow({required this.stats, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _MacroChip(label: '${l10n.nutritionProtein} ${stats.proteinPct}%', color: Colors.blue),
        _MacroChip(label: '${l10n.nutritionCarbs} ${stats.carbsPct}%', color: AppColors.warning(context)),
        _MacroChip(label: '${l10n.nutritionFat} ${stats.fatPct}%', color: Colors.purple),
      ],
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MacroChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
