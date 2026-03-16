import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/meal_planner.dart';
import '../models/meal_settings.dart';
import '../models/purchase_record.dart';
import '../models/shopping_item.dart';
import '../services/meal_planner_service.dart';
import '../services/meal_planner_ai_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/freeform_meal_card.dart';
import '../widgets/freeform_meal_sheet.dart';
import '../models/meal_budget_insight.dart';
import '../utils/meal_budget_insights.dart';
import '../widgets/meal_cost_reconciliation_sheet.dart';
import '../widgets/meal_feedback_button.dart';
import '../widgets/meal_plan_budget_card.dart';
import '../widgets/meal_plan_budget_sheet.dart';
import '../onboarding/meals_tour.dart';
import '../utils/pantry_matching.dart';
import '../utils/rate_limiter.dart';
import '../widgets/pantry_coverage_badge.dart';
import '../widgets/pantry_quick_picker_sheet.dart';
import '../widgets/pantry_summary_chip_row.dart';
import 'meal_wizard_screen.dart';

class MealPlannerScreen extends StatefulWidget {
  final AppSettings settings;
  final String apiKey;
  final List<String> favorites;
  final void Function(ShoppingItem) onAddToShoppingList;
  final String householdId;
  final ValueChanged<AppSettings> onSaveSettings;
  final VoidCallback onOpenMealSettings;
  final PurchaseHistory purchaseHistory;
  final bool showTour;
  final VoidCallback? onTourComplete;
  final bool embedded;

  const MealPlannerScreen({
    super.key,
    required this.settings,
    required this.apiKey,
    required this.favorites,
    required this.onAddToShoppingList,
    required this.householdId,
    required this.onSaveSettings,
    required this.onOpenMealSettings,
    required this.purchaseHistory,
    this.showTour = false,
    this.onTourComplete,
    this.embedded = false,
  });

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final _service = MealPlannerService();
  final _aiService = MealPlannerAiService();

  MealPlan? _plan;
  bool _loading = false;
  bool _catalogReady = false;
  int _selectedWeek = 0;

  final Map<String, RecipeAiContent> _aiContent = {};
  final Set<String> _aiPending = {};
  final Set<String> _expanded = {};
  bool _tourShown = false;

  final Map<int, WeeklyNutritionSummary> _weeklySummaries = {};
  final Set<int> _weeklySummaryPending = {};
  bool _batchPlanLoading = false;
  final _rateLimiter = RateLimiter(minInterval: const Duration(seconds: 3));
  MealPlanBudgetInsight? _budgetInsight;
  bool _showDetails = false; // Progressive disclosure toggle

  late AppSettings _localSettings;

  @override
  void initState() {
    super.initState();
    _localSettings = widget.settings;
    _init();
  }

  @override
  void didUpdateWidget(covariant MealPlannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.settings != oldWidget.settings) {
      _localSettings = widget.settings;
    }
  }

  Future<void> _init() async {
    await _service.loadCatalog();
    await _aiService.loadCache();
    final now = DateTime.now();
    final saved = await _service.load(widget.householdId, now.month, now.year);
    if (!mounted) return;
    if (saved != null) {
      // Pre-populate AI content from persisted cache for immediate render
      final locale = Localizations.localeOf(context).languageCode;
      for (final recipeId in saved.days
          .where((d) => !d.isFreeform && d.recipeId.isNotEmpty)
          .map((d) => d.recipeId)
          .toSet()) {
        final cached = _aiService.getCached(recipeId, locale: locale);
        if (cached != null) _aiContent[recipeId] = cached;
      }
    }
    setState(() {
      _plan = saved;
      _catalogReady = true;
    });
    if (saved != null) {
      _enrichPlan(saved);
      _loadWeeklySummary(0, saved);
      _recomputeBudgetInsight();
    }
    _tryShowTour();
  }

  void _tryShowTour() {
    if (_tourShown || !widget.showTour || !mounted || !_catalogReady) return;
    if (!widget.settings.mealSettings.wizardCompleted) return;
    _tourShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        buildMealsTour(
          context: context,
          onFinish: () => widget.onTourComplete?.call(),
          onSkip: () => widget.onTourComplete?.call(),
        ).show(context: context);
      });
    });
  }

  void _recomputeBudgetInsight() {
    final plan = _plan;
    if (plan == null) {
      setState(() => _budgetInsight = null);
      return;
    }
    final calculator = MealBudgetInsightsCalculator(_service);
    final insight = calculator.compute(
      plan: plan,
      selectedWeek: _selectedWeek,
      purchaseHistory: widget.purchaseHistory,
    );
    setState(() => _budgetInsight = insight);
  }

  Future<void> _generatePlan() async {
    if (!_rateLimiter.tryCall()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).rateLimitMessage),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    final now = DateTime.now();

    // Collect feedback from previous plan
    final previousFeedback = <String, MealFeedback>{};
    if (_plan != null) {
      for (final day in _plan!.days) {
        if (day.feedback != MealFeedback.none) {
          previousFeedback[day.recipeId] = day.feedback;
        }
      }
    }

    // Save current plan for undo before regenerating
    final hadPreviousPlan = _plan != null;
    if (_plan != null) {
      await _service.savePreviousPlan(_plan!);
    }

    final plan = _service.generate(widget.settings, now,
      favorites: widget.favorites,
      previousFeedback: previousFeedback,
    );
    await _service.save(plan, widget.householdId);
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _loading = false;
      _selectedWeek = 0;
      _expanded.clear();
      _weeklySummaries.clear();
      _weeklySummaryPending.clear();
    });
    _enrichPlan(plan);
    _loadWeeklySummary(0, plan);
    _recomputeBudgetInsight();

    if (hadPreviousPlan && mounted) {
      final l10n = S.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.mealPlanUndoMessage),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: l10n.mealPlanUndoAction,
            onPressed: () => _undoRegeneration(),
          ),
        ),
      );
    }
  }

  Future<void> _undoRegeneration() async {
    final plan = _plan;
    if (plan == null) return;
    final previous = await _service.loadPreviousPlan(plan.month, plan.year);
    if (previous == null) return;

    await _service.save(previous, widget.householdId);
    await _service.clearPreviousPlan(previous.month, previous.year);

    if (!mounted) return;
    setState(() {
      _plan = previous;
      _selectedWeek = 0;
      _expanded.clear();
      _weeklySummaries.clear();
    });

    _enrichPlan(previous);
    _recomputeBudgetInsight();
  }

  void _enrichPlan(MealPlan plan) {
    final iMap = _service.ingredientMap;
    final locale = Localizations.localeOf(context).languageCode;
    final uniqueRecipeIds = plan.days
        .where((d) => !d.isFreeform && d.recipeId.isNotEmpty)
        .map((d) => d.recipeId)
        .toSet();
    for (final recipeId in uniqueRecipeIds) {
      if (_aiContent.containsKey(recipeId) || _aiPending.contains(recipeId)) continue;
      _aiPending.add(recipeId);
      final recipe = _service.recipeMap[recipeId];
      if (recipe == null) continue;
      _aiService.enrichRecipe(
        apiKey: widget.apiKey,
        recipe: recipe,
        ingredientMap: iMap,
        nPessoas: plan.nPessoas,
        locale: locale,
      ).then((content) {
        if (content != null && mounted) {
          setState(() => _aiContent[recipeId] = content);
        }
        _aiPending.remove(recipeId);
      });
    }
  }

  void _loadWeeklySummary(int weekIndex, MealPlan plan) {
    if (_weeklySummaries.containsKey(weekIndex) || _weeklySummaryPending.contains(weekIndex)) return;
    _weeklySummaryPending.add(weekIndex);
    final weekDays = _getWeekDays(plan, weekIndex);
    final recipes = weekDays
        .where((d) => !d.isFreeform && d.recipeId.isNotEmpty)
        .map((d) => _service.recipeMap[d.recipeId])
        .whereType<Recipe>()
        .toList();
    final locale = Localizations.localeOf(context).languageCode;
    _aiService.analyzeWeeklyNutrition(
      apiKey: widget.apiKey,
      weekRecipes: recipes,
      nPessoas: plan.nPessoas,
      locale: locale,
    ).then((summary) {
      _weeklySummaryPending.remove(weekIndex);
      if (summary != null && mounted) {
        setState(() => _weeklySummaries[weekIndex] = summary);
      }
    });
  }

  bool _weekHasBatchCooking(MealPlan plan, int weekIndex) {
    final weekDays = _getWeekDays(plan, weekIndex);
    return weekDays.any((d) {
      if (d.isFreeform) return false;
      final recipe = _service.recipeMap[d.recipeId];
      return recipe != null && recipe.batchCookable;
    });
  }

  void _showBatchPrepGuide(MealPlan plan, int weekIndex) {
    if (!_rateLimiter.tryCall()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).rateLimitMessage),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    final weekDays = _getWeekDays(plan, weekIndex);
    final batchRecipes = weekDays
        .where((d) => !d.isFreeform && d.recipeId.isNotEmpty)
        .map((d) => _service.recipeMap[d.recipeId])
        .whereType<Recipe>()
        .where((r) => r.batchCookable)
        .toSet()
        .toList();
    if (batchRecipes.isEmpty) return;

    setState(() => _batchPlanLoading = true);
    final locale = Localizations.localeOf(context).languageCode;
    _aiService.generateBatchPlan(
      apiKey: widget.apiKey,
      batchRecipes: batchRecipes,
      nPessoas: plan.nPessoas,
      locale: locale,
    ).then((result) {
      if (!mounted) return;
      setState(() => _batchPlanLoading = false);
      if (result != null) _showBatchPlanSheet(result);
    });
  }

  void _showBatchPlanSheet(BatchCookingPlan plan) {
    final l10n = S.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.borderMuted(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.mealBatchPrepGuide,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  if (plan.totalTimeEstimate.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(l10n.mealBatchTotalTime(plan.totalTimeEstimate),
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context))),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  ...plan.prepOrder.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24, height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${e.key + 1}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onPrimary(context))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13))),
                      ],
                    ),
                  )),
                  if (plan.parallelTips.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(l10n.mealBatchParallelTips,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary(context))),
                    const SizedBox(height: 8),
                    ...plan.parallelTips.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.tips_and_updates_outlined, size: 16, color: AppColors.warning(context)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(tip, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMealPrepGuide(MealDay mealDay) {
    final recipe = _service.recipeMap[mealDay.recipeId];
    if (recipe == null) return;
    final l10n = S.of(context);
    final aiContent = _aiContent[mealDay.recipeId];
    // Use local prepSteps as primary source, fall back to AI steps
    final steps = recipe.prepSteps.isNotEmpty
        ? recipe.prepSteps
        : (aiContent?.steps ?? []);
    if (steps.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, controller) => Column(
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.borderMuted(ctx),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.mealPrepGuideTitle,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(recipe.name,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary(ctx))),
                  const SizedBox(height: 2),
                  Text(l10n.mealPrepTime(recipe.prepMinutes.toString()),
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted(ctx))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  ...steps.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26, height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary(ctx),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Text('${e.key + 1}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onPrimary(ctx))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(e.value, style: const TextStyle(fontSize: 14)),
                        )),
                      ],
                    ),
                  )),
                  // Show AI-enriched extras if available
                  if (aiContent != null) ...[
                    if (aiContent.tip.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warningBackground(ctx),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lightbulb_outline, size: 18, color: AppColors.warning(ctx)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(aiContent.tip,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF92400E)))),
                          ],
                        ),
                      ),
                    ],
                    if (aiContent.variation.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.infoBackground(ctx),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.shuffle, size: 18, color: AppColors.primary(ctx)),
                            const SizedBox(width: 10),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.mealVariation,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary(ctx))),
                                const SizedBox(height: 2),
                                Text(aiContent.variation, style: const TextStyle(fontSize: 13)),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ],
                    if (aiContent.storageInfo.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant(ctx),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.kitchen, size: 18, color: AppColors.textSecondary(ctx)),
                            const SizedBox(width: 10),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.mealStorage,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary(ctx))),
                                const SizedBox(height: 2),
                                Text(aiContent.storageInfo, style: const TextStyle(fontSize: 13)),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setFeedback(int dayIndex, MealType mealType, MealFeedback feedback) {
    final plan = _plan!;
    final updatedDays = plan.days.map((d) {
      if (d.dayIndex == dayIndex && d.mealType == mealType) {
        return d.copyWith(feedback: d.feedback == feedback ? MealFeedback.none : feedback);
      }
      return d;
    }).toList();
    final updated = plan.copyWithDays(updatedDays);
    _service.save(updated, widget.householdId);
    setState(() => _plan = updated);
    _recomputeBudgetInsight();
  }

  void _showPantryPicker() {
    final ms = widget.settings.mealSettings;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PantryQuickPickerSheet(
        availableIngredients: _service.ingredients,
        stapleIds: ms.stapleIngredients.toSet(),
        weeklyIds: ms.weeklyPantryIngredients.toSet(),
        onStaplesChanged: (ids) {
          final updated = ms.copyWith(stapleIngredients: ids.toList());
          widget.onSaveSettings(
              widget.settings.copyWith(mealSettings: updated));
        },
        onWeeklyChanged: (ids) {
          final updated = ms.copyWith(
            weeklyPantryIngredients: ids.toList(),
            weeklyPantryUpdatedAt: DateTime.now(),
          );
          widget.onSaveSettings(
              widget.settings.copyWith(mealSettings: updated));
        },
      ),
    );
  }

  void _showPlanWithPantrySheet() {
    final ms = widget.settings.mealSettings;
    final selected = Set<String>.from(ms.pantryIngredients);
    final allIngredients = _service.ingredients.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final l10n = S.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) => Column(
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.borderMuted(ctx),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.mealPantrySelectTitle,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(l10n.mealPantrySelectHint,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary(ctx))),
                    const SizedBox(height: 4),
                    Text(l10n.mealPantrySelected(selected.length),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary(ctx))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: allIngredients.length,
                  itemBuilder: (_, i) {
                    final ing = allIngredients[i];
                    final isSelected = selected.contains(ing.id);
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(ing.name, style: const TextStyle(fontSize: 14)),
                      subtitle: Text(ing.category.name,
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted(ctx))),
                      value: isSelected,
                      activeColor: AppColors.primary(ctx),
                      onChanged: (v) {
                        setSheetState(() {
                          if (v == true) {
                            selected.add(ing.id);
                          } else {
                            selected.remove(ing.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      // Save pantry selection
                      final updated = ms.copyWith(pantryIngredients: selected.toList());
                      widget.onSaveSettings(
                          widget.settings.copyWith(mealSettings: updated));
                      // Generate plan with pantry boost
                      _generatePlan();
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(l10n.mealPantryApply),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary(ctx),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIngredientSubstitutionSheet(MealDay day, String ingredientId) {
    final recipe = _service.recipeMap[day.recipeId];
    if (recipe == null) return;
    final iMap = _service.ingredientMap;
    final ingredient = iMap[ingredientId];
    if (ingredient == null) return;
    final l10n = S.of(context);

    // Find same-category alternatives
    final alternatives = _service.ingredients
        .where((i) => i.category == ingredient.category && i.id != ingredientId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        expand: false,
        builder: (ctx, controller) => Column(
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.borderMuted(ctx),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.mealSubstituteTitle(ingredient.name),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: alternatives.length,
                itemBuilder: (_, i) {
                  final alt = alternatives[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(alt.name, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      '${alt.avgPricePerUnit.toStringAsFixed(2)}${currencySymbol()}/${alt.unit}',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary(ctx)),
                    ),
                    trailing: Icon(Icons.swap_horiz, size: 18, color: AppColors.primary(ctx)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _applySubstitution(day, ingredientId, alt.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applySubstitution(MealDay day, String oldIngredientId, String newIngredientId) {
    final plan = _plan;
    if (plan == null) return;
    final l10n = S.of(context);
    final iMap = _service.ingredientMap;
    final oldIng = iMap[oldIngredientId];
    final newIng = iMap[newIngredientId];

    final newSubs = Map<String, String>.from(day.substitutions);
    newSubs[oldIngredientId] = newIngredientId;

    final updatedDays = plan.days.map((d) {
      if (d.dayIndex == day.dayIndex && d.mealType == day.mealType) {
        return d.copyWith(substitutions: newSubs);
      }
      return d;
    }).toList();
    final updated = plan.copyWithDays(updatedDays);
    _service.save(updated, widget.householdId);
    setState(() => _plan = updated);

    if (oldIng != null && newIng != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mealSubstitutionApplied(oldIng.name, newIng.name))),
      );
    }

    // Fire-and-forget AI adaptation
    final recipe = _service.recipeMap[day.recipeId];
    if (recipe != null && oldIng != null && newIng != null && widget.apiKey.isNotEmpty) {
      final locale = Localizations.localeOf(context).languageCode;
      _aiService.adaptRecipeForSubstitution(
        apiKey: widget.apiKey,
        recipe: recipe,
        oldIngredient: oldIng,
        newIngredient: newIng,
        ingredientMap: iMap,
        nPessoas: plan.nPessoas,
        locale: locale,
      ).then((steps) {
        if (!mounted || steps == null) return;
        // Update AI content cache with adapted steps
        final existing = _aiContent[recipe.id];
        if (existing != null) {
          setState(() {
            _aiContent[recipe.id] = RecipeAiContent(
              steps: steps,
              tip: existing.tip,
              variation: existing.variation,
              leftoverIdea: existing.leftoverIdea,
              pairingSuggestion: existing.pairingSuggestion,
              storageInfo: existing.storageInfo,
            );
          });
        }
      });
    }
  }

  void _swapRecipe(int dayIndex, MealType mealType, String currentRecipeId) {
    final plan = _plan!;
    final alternatives = _service.alternativesFor(currentRecipeId, plan.nPessoas, ms: widget.settings.mealSettings);
    final iMap = _service.ingredientMap;

    showModalBottomSheet(
      context: context,
      builder: (_) => _SwapSheet(
        alternatives: alternatives,
        currentRecipeId: currentRecipeId,
        nPessoas: plan.nPessoas,
        ingredientMap: iMap,
        service: _service,
        onSelect: (newRecipeId) {
          final updated = _service.swapDay(plan, dayIndex, mealType, newRecipeId);
          _service.save(updated, widget.householdId);
          setState(() => _plan = updated);
          _enrichPlan(updated);
          _recomputeBudgetInsight();
        },
      ),
    );
  }

  void _addWeekToShoppingList(int weekIndex) {
    final plan = _plan;
    if (plan == null) return;
    final weekDays = _getWeekDays(plan, weekIndex);
    final iMap = _service.ingredientMap;
    final totals = <String, double>{};
    final mealLabels = <String, Set<String>>{};
    for (final day in weekDays) {
      if (day.isLeftover || day.isFreeform) continue;
      final recipe = _service.recipeMap[day.recipeId];
      if (recipe == null) continue;
      final scale = plan.nPessoas / recipe.servings;
      for (final ri in recipe.ingredients) {
        totals.update(ri.ingredientId, (v) => v + ri.quantity * scale,
            ifAbsent: () => ri.quantity * scale);
        (mealLabels[ri.ingredientId] ??= {}).add(recipe.name);
      }
    }
    final l10n = S.of(context);
    int count = 0;
    for (final entry in totals.entries) {
      final ing = iMap[entry.key];
      if (ing == null) continue;
      final cost = entry.value * ing.avgPricePerUnit;
      widget.onAddToShoppingList(ShoppingItem(
        productName: ing.name,
        store: '',
        price: cost,
        unitPrice: '${ing.avgPricePerUnit.toStringAsFixed(2)}${currencySymbol()}/${ing.unit}',
        quantity: entry.value,
        unit: ing.unit,
        sourceMealLabels: mealLabels[entry.key]?.toList() ?? const [],
      ));
      count++;
    }
    // Add freeform shopping items
    final freeformItems = _service.freeformShoppingItemsForWeek(plan, weekDays);
    for (final item in freeformItems) {
      widget.onAddToShoppingList(ShoppingItem(
        productName: item.name,
        store: item.store ?? '',
        price: item.estimatedPrice ?? 0,
      ));
      count++;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mealIngredientsAdded(count))),
      );
    }
  }

  void _showConsolidatedList() {
    final plan = _plan!;
    final totals = _service.consolidatedIngredients(plan);
    final iMap = _service.ingredientMap;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ConsolidatedSheet(
        totals: totals,
        ingredientMap: iMap,
        onAddToShoppingList: widget.onAddToShoppingList,
      ),
    );
  }

  void _showFreeformDayPicker(MealPlan plan) {
    final weekDays = _getWeekDays(plan, _selectedWeek);
    final dayIndices = weekDays.map((d) => d.dayIndex).toSet().toList()..sort();
    if (dayIndices.isEmpty) return;
    // Default to first day of the week, dinner
    _addFreeformMeal(dayIndices.first, MealType.dinner);
  }

  void _addFreeformMeal(int dayIndex, MealType mealType) {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FreeformMealSheet(
        dayIndex: dayIndex,
        mealType: mealType,
      ),
    ).then((result) {
      if (result is MealDay && _plan != null) {
        final updatedDays = [
          ..._plan!.days.where((d) =>
              !(d.dayIndex == result.dayIndex && d.mealType == result.mealType)),
          result,
        ];
        final updated = _plan!.copyWithDays(updatedDays);
        _service.save(updated, widget.householdId);
        setState(() => _plan = updated);
      }
    });
  }

  void _editFreeformMeal(MealDay mealDay) {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FreeformMealSheet(
        dayIndex: mealDay.dayIndex,
        mealType: mealDay.mealType,
        existing: mealDay,
      ),
    ).then((result) {
      if (_plan == null) return;
      if (result == 'delete') {
        final updatedDays = _plan!.days
            .where((d) => !(d.dayIndex == mealDay.dayIndex &&
                d.mealType == mealDay.mealType &&
                d.isFreeform))
            .toList();
        final updated = _plan!.copyWithDays(updatedDays);
        _service.save(updated, widget.householdId);
        setState(() => _plan = updated);
      } else if (result is MealDay) {
        final updatedDays = _plan!.days.map((d) {
          if (d.dayIndex == mealDay.dayIndex &&
              d.mealType == mealDay.mealType &&
              d.isFreeform) {
            return result;
          }
          return d;
        }).toList();
        final updated = _plan!.copyWithDays(updatedDays);
        _service.save(updated, widget.householdId);
        setState(() => _plan = updated);
      }
    });
  }

  void _replaceMealWithFreeform(MealDay existing) {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FreeformMealSheet(
        dayIndex: existing.dayIndex,
        mealType: existing.mealType,
      ),
    ).then((result) {
      if (result is MealDay && _plan != null) {
        final updatedDays = _plan!.days.map((d) {
          if (d.dayIndex == existing.dayIndex && d.mealType == existing.mealType) {
            return result;
          }
          return d;
        }).toList();
        final updated = _plan!.copyWithDays(updatedDays);
        _service.save(updated, widget.householdId);
        setState(() => _plan = updated);
      }
    });
  }

  void _setFreeformFeedback(int dayIndex, MealType mealType, MealFeedback feedback) {
    final plan = _plan!;
    final updatedDays = plan.days.map((d) {
      if (d.dayIndex == dayIndex && d.mealType == mealType && d.isFreeform) {
        return d.copyWith(feedback: d.feedback == feedback ? MealFeedback.none : feedback);
      }
      return d;
    }).toList();
    final updated = plan.copyWithDays(updatedDays);
    _service.save(updated, widget.householdId);
    setState(() => _plan = updated);
  }

  @override
  Widget build(BuildContext context) {
    // Auto-complete wizard with sensible defaults instead of blocking access.
    // Users can fine-tune via Settings > Meals.
    if (!_localSettings.mealSettings.wizardCompleted) {
      final ms = _localSettings.mealSettings.copyWith(wizardCompleted: true);
      final updated = _localSettings.copyWith(mealSettings: ms);
      widget.onSaveSettings(updated);
      _localSettings = updated;
    }
    final l10n = S.of(context);
    final bodyContent = !_catalogReady
        ? Center(child: CircularProgressIndicator(color: AppColors.primary(context)))
        : _plan == null
            ? _buildEmptyState()
            : _buildPlanView();

    if (widget.embedded) return bodyContent;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        title: Text(
          l10n.mealPlannerTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.kitchen_outlined),
            tooltip: l10n.mealPlanWithPantry,
            onPressed: _showPlanWithPantrySheet,
          ),
          if (_plan != null)
            IconButton(
              icon: const Icon(Icons.receipt_long_outlined),
              tooltip: l10n.mealCostReconciliation,
              onPressed: () => showMealCostReconciliationSheet(
                context: context,
                mealDays: _plan!.days,
                purchaseHistory: widget.purchaseHistory,
                year: _plan!.year,
                month: _plan!.month,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: widget.onOpenMealSettings,
          ),
        ],
      ),
      body: bodyContent,
    );
  }

  Widget _buildEmptyState() {
    final l10n = S.of(context);
    final budget = _service.monthlyFoodBudget(widget.settings);
    final np = _service.nPessoas(widget.settings);
    final now = DateTime.now();
    final monthName = '${localizedMonthFull(l10n, now.month)} ${now.year}';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_outlined, size: 64, color: AppColors.textMuted(context)),
            const SizedBox(height: 24),
            Text(
              monthName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            _InfoRow(label: l10n.mealBudgetLabel, value: '${budget.toStringAsFixed(2)}${currencySymbol()}'),
            const SizedBox(height: 8),
            _InfoRow(label: l10n.mealPeopleLabel, value: '$np'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showPantryPicker(),
                icon: const Icon(Icons.kitchen_outlined),
                label: Text(l10n.pantryUseWhatWeHave),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              key: MealsTourKeys.generateButton,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _generatePlan,
                icon: _loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: AppColors.onPrimary(context), strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_loading ? l10n.mealGenerating : l10n.mealGeneratePlan),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanView() {
    final l10n = S.of(context);
    final plan = _plan!;
    final budgetUsed = plan.monthlyBudget > 0
        ? plan.totalEstimatedCost / plan.monthlyBudget
        : 0.0;
    final weekDays = _getWeekDays(plan, _selectedWeek);

    return Column(
      children: [
        Container(
          color: AppColors.surface(context),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${plan.totalEstimatedCost.toStringAsFixed(2)}${currencySymbol()} / ${plan.monthlyBudget.toStringAsFixed(2)}${currencySymbol()}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.mealRegenerateTitle),
                          content: Text(l10n.mealRegenerateContent),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l10n.cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(l10n.mealRegenerate),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && mounted) {
                        setState(() => _plan = null);
                        _service.clear(widget.householdId, plan.month, plan.year);
                      }
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(l10n.mealRegenerate),
                    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary(context)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: budgetUsed.clamp(0.0, 1.0),
                backgroundColor: AppColors.border(context),
                color: budgetUsed > 1 ? Colors.red : AppColors.primary(context),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 12),
              // Week navigator (← Week N →) — replaces W1-W4 tabs
              Builder(builder: (_) {
                final daysInMonth = DateTime(plan.year, plan.month + 1, 0).day;
                final weekCount = (daysInMonth / 7).ceil();
                if (_selectedWeek >= weekCount) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedWeek = weekCount - 1);
                  });
                }
                return Row(
                key: MealsTourKeys.weekTabs,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _selectedWeek > 0
                        ? () {
                            setState(() => _selectedWeek--);
                            if (_plan != null) _loadWeeklySummary(_selectedWeek, _plan!);
                            _recomputeBudgetInsight();
                          }
                        : null,
                  ),
                  Text(
                    l10n.mealWeekLabel(_selectedWeek + 1),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _selectedWeek < weekCount - 1
                        ? () {
                            setState(() => _selectedWeek++);
                            if (_plan != null) _loadWeeklySummary(_selectedWeek, _plan!);
                            _recomputeBudgetInsight();
                          }
                        : null,
                  ),
                ],
              );
              }),
              const SizedBox(height: 12),
            ],
          ),
        ),
        // Toggle for detailed view (pantry, nutrition, budget)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _showDetails = !_showDetails),
              icon: Icon(
                _showDetails ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 16,
              ),
              label: Text(_showDetails ? l10n.mealHideDetails : l10n.mealShowDetails),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary(context),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ),
        // Progressive disclosure: pantry, nutrition, budget
        if (_showDetails) ...[
          PantrySummaryChipRow(
            activePantryIds: resolveActivePantry(widget.settings.mealSettings),
            ingredientMap: _service.ingredientMap,
            onEditPantry: () => _showPantryPicker(),
          ),
          if (_weeklySummaries.containsKey(_selectedWeek))
            _WeeklySummaryCard(summary: _weeklySummaries[_selectedWeek]!),
          if (_budgetInsight != null)
            MealPlanBudgetCard(
              insight: _budgetInsight!,
              onViewDetails: () => showMealPlanBudgetSheet(
                context: context,
                insight: _budgetInsight!,
                onApplySwap: (swap) {
                  Navigator.of(context).pop();
                  final updated = _service.swapDay(
                    plan,
                    swap.original.dayIndex,
                    MealType.values.firstWhere(
                      (m) => m.name == swap.original.mealType,
                      orElse: () => MealType.dinner,
                    ),
                    swap.alternativeRecipeId,
                  );
                  _service.save(updated, widget.householdId);
                  setState(() => _plan = updated);
                  _enrichPlan(updated);
                  _recomputeBudgetInsight();
                },
              ),
            ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  key: MealsTourKeys.addToListButton,
                  child: OutlinedButton.icon(
                    onPressed: () => _addWeekToShoppingList(_selectedWeek),
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: Text(l10n.mealAddWeekToList),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary(context),
                      side: BorderSide(color: AppColors.primary(context)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              if (_weekHasBatchCooking(plan, _selectedWeek)) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _batchPlanLoading ? null : () => _showBatchPrepGuide(plan, _selectedWeek),
                  icon: _batchPlanLoading
                      ? SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary(context)))
                      : const Icon(Icons.kitchen, size: 18),
                  label: Text(l10n.mealBatchPrepGuide),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary(context),
                    side: BorderSide(color: AppColors.primary(context)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: weekDays.length,
                itemBuilder: (_, i) {
                  final day = weekDays[i];
                  if (day.isFreeform) {
                    return FreeformMealCard(
                      mealDay: day,
                      onEdit: () => _editFreeformMeal(day),
                      onAddToShoppingList: widget.onAddToShoppingList,
                      onFeedback: (fb) => _setFreeformFeedback(day.dayIndex, day.mealType, fb),
                    );
                  }
                  return _DayCard(
                    mealDay: day,
                    plan: plan,
                    service: _service,
                    aiContent: _aiContent[day.recipeId],
                    isExpanded: _expanded.contains('${day.dayIndex}_${day.mealType.name}'),
                    onToggleExpand: () => setState(() {
                      final key = '${day.dayIndex}_${day.mealType.name}';
                      if (_expanded.contains(key)) {
                        _expanded.remove(key);
                      } else {
                        _expanded.add(key);
                      }
                    }),
                    onSwap: () => _swapRecipe(day.dayIndex, day.mealType, day.recipeId),
                    onReplaceFreeform: () => _replaceMealWithFreeform(day),
                    onAddIngredientToList: widget.onAddToShoppingList,
                    onFeedback: (fb) => _setFeedback(day.dayIndex, day.mealType, fb),
                    onViewPrepGuide: () => _showMealPrepGuide(day),
                    activePantryIds: resolveActivePantry(widget.settings.mealSettings),
                    onSubstituteIngredient: (ingredientId) =>
                        _showIngredientSubstitutionSheet(day, ingredientId),
                  );
                },
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _showConsolidatedList,
                        icon: const Icon(Icons.list_alt),
                        label: Text(l10n.mealConsolidatedList),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.textPrimary(context),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton.small(
                      heroTag: 'addFreeform',
                      onPressed: () => _showFreeformDayPicker(plan),
                      backgroundColor: AppColors.primary(context),
                      child: Icon(Icons.edit_note, color: AppColors.onPrimary(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<MealDay> _getWeekDays(MealPlan plan, int weekIndex) {
    final start = weekIndex * 7 + 1;
    final daysInMonth = DateTime(plan.year, plan.month + 1, 0).day;
    final end = (weekIndex + 1) * 7 < daysInMonth ? start + 6 : daysInMonth;
    return plan.days.where((d) => d.dayIndex >= start && d.dayIndex <= end).toList();
  }
}

// -- Day Card -----------------------------------------------------------------

class _DayCard extends StatelessWidget {
  final MealDay mealDay;
  final MealPlan plan;
  final MealPlannerService service;
  final RecipeAiContent? aiContent;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onSwap;
  final VoidCallback onReplaceFreeform;
  final void Function(ShoppingItem) onAddIngredientToList;
  final ValueChanged<MealFeedback> onFeedback;
  final VoidCallback onViewPrepGuide;
  final Set<String> activePantryIds;
  final void Function(String ingredientId) onSubstituteIngredient;

  const _DayCard({
    required this.mealDay,
    required this.plan,
    required this.service,
    required this.aiContent,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onSwap,
    required this.onReplaceFreeform,
    required this.onAddIngredientToList,
    required this.onFeedback,
    required this.onViewPrepGuide,
    required this.onSubstituteIngredient,
    this.activePantryIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final recipe = service.recipeMap[mealDay.recipeId];
    if (recipe == null) return const SizedBox();
    final iMap = service.ingredientMap;
    final costPerPerson = plan.nPessoas > 0
        ? mealDay.costEstimate / plan.nPessoas
        : mealDay.costEstimate;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.surface(context),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            color: AppColors.primary(context)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        mealDay.mealType.localizedLabel(l10n),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF16A34A)),
                      ),
                    ),
                    if (mealDay.isLeftover) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.recycling, size: 12, color: Color(0xFF92400E)),
                            const SizedBox(width: 4),
                            Text(
                              l10n.mealLeftover,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF92400E)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (activePantryIds.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      PantryCoverageBadge(
                        coverageRatio: computePantryCoverage(
                          recipe,
                          activePantryIds,
                        ).coverageRatio,
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${mealDay.costEstimate.toStringAsFixed(2)}${currencySymbol()}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context)),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 18, color: AppColors.textMuted(context)),
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
                Text(
                  recipe.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Stars(recipe.complexity),
                    const SizedBox(width: 10),
                    Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted(context)),
                    const SizedBox(width: 3),
                    Text('${recipe.prepMinutes}min',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted(context))),
                    const SizedBox(width: 10),
                    Icon(Icons.person_outline, size: 14, color: AppColors.textMuted(context)),
                    const SizedBox(width: 3),
                    Text(l10n.mealCostPerPerson(costPerPerson.toStringAsFixed(2)),
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted(context))),
                  ],
                ),
                if (recipe.nutrition != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _NutriBadge('${recipe.nutrition!.kcal}', 'kcal', AppColors.error(context)),
                      const SizedBox(width: 6),
                      _NutriBadge('${recipe.nutrition!.proteinG.round()}g', l10n.mealNutriProt, AppColors.primary(context)),
                      const SizedBox(width: 6),
                      _NutriBadge('${recipe.nutrition!.carbsG.round()}g', l10n.mealNutriCarbs, AppColors.warning(context)),
                      const SizedBox(width: 6),
                      _NutriBadge('${recipe.nutrition!.fatG.round()}g', l10n.mealNutriFat, const Color(0xFF8B5CF6)),
                      if (recipe.nutrition!.fiberG >= 5) ...[
                        const SizedBox(width: 6),
                        _NutriBadge('${recipe.nutrition!.fiberG.round()}g', l10n.mealNutriFiber, AppColors.success(context)),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onToggleExpand,
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 16,
                        ),
                        label: Text(
                          isExpanded ? l10n.close : l10n.mealIngredients,
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary(context),
                          side: BorderSide(color: AppColors.border(context)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewPrepGuide,
                        icon: const Icon(Icons.menu_book_outlined, size: 16),
                        label: Text(l10n.mealViewPrepGuide, style: const TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary(context),
                          side: BorderSide(color: AppColors.primary(context).withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSwap,
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: Text(l10n.mealSwap, style: const TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary(context),
                          side: BorderSide(color: AppColors.border(context)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MealFeedbackButton(
                        icon: Icons.thumb_up_outlined,
                        activeIcon: Icons.thumb_up,
                        isActive: mealDay.feedback == MealFeedback.liked,
                        color: const Color(0xFF16A34A),
                        label: l10n.mealFeedbackLike,
                        onTap: () => onFeedback(MealFeedback.liked),
                      ),
                      const SizedBox(width: 10),
                      MealFeedbackButton(
                        icon: Icons.thumb_down_outlined,
                        activeIcon: Icons.thumb_down,
                        isActive: mealDay.feedback == MealFeedback.disliked,
                        color: AppColors.error(context),
                        label: l10n.mealFeedbackDislike,
                        onTap: () => onFeedback(MealFeedback.disliked),
                      ),
                      const SizedBox(width: 10),
                      MealFeedbackButton(
                        icon: Icons.skip_next_outlined,
                        activeIcon: Icons.skip_next,
                        isActive: mealDay.feedback == MealFeedback.skipped,
                        color: AppColors.textMuted(context),
                        label: l10n.mealFeedbackSkip,
                        onTap: () => onFeedback(MealFeedback.skipped),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: AppColors.border(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.mealIngredients,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary(context)),
                  ),
                  const SizedBox(height: 8),
                  ...recipe.ingredients.map((ri) {
                    // Apply substitution if present
                    final effectiveId = mealDay.substitutions[ri.ingredientId] ?? ri.ingredientId;
                    final ing = iMap[effectiveId] ?? iMap[ri.ingredientId];
                    if (ing == null) return const SizedBox();
                    final isSubstituted = mealDay.substitutions.containsKey(ri.ingredientId);
                    final scale = plan.nPessoas / recipe.servings;
                    final qty = ri.quantity * scale;
                    final cost = qty * ing.avgPricePerUnit;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => onSubstituteIngredient(ri.ingredientId),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(ing.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          decoration: isSubstituted ? TextDecoration.underline : null,
                                          color: isSubstituted ? AppColors.primary(context) : null,
                                        )),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.swap_horiz, size: 14, color: AppColors.textMuted(context)),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            '${_fmt(qty)} ${ing.unit}',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary(context)),
                          ),
                          const SizedBox(width: 12),
                          Semantics(
                            button: true,
                            label: l10n.addToList(ing.name),
                            child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Material(
                              color: AppColors.primary(context),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () => onAddIngredientToList(ShoppingItem(
                                  productName: ing.name,
                                  store: '',
                                  price: cost,
                                  unitPrice:
                                      '${ing.avgPricePerUnit.toStringAsFixed(2)}${currencySymbol()}/${ing.unit}',
                                )),
                                borderRadius: BorderRadius.circular(10),
                                child: Icon(Icons.add, size: 18, color: AppColors.onPrimary(context)),
                              ),
                            ),
                          ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (aiContent != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.mealPreparation,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary(context)),
                    ),
                    const SizedBox(height: 6),
                    ...aiContent!.steps.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${e.key + 1}. ${e.value}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        )),
                    if (aiContent!.tip.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.warningBackground(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline,
                                size: 16, color: AppColors.warning(context)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                aiContent!.tip,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF92400E)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Variation
                    if (aiContent!.variation.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.infoBackground(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.shuffle, size: 16, color: AppColors.primary(context)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.mealVariation,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary(context))),
                                  const SizedBox(height: 2),
                                  Text(aiContent!.variation, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Pairing suggestion
                    if (aiContent!.pairingSuggestion.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.successBackground(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.restaurant, size: 16, color: AppColors.success(context)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.mealPairing,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success(context))),
                                  const SizedBox(height: 2),
                                  Text(aiContent!.pairingSuggestion, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Storage info
                    if (aiContent!.storageInfo.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.kitchen, size: 16, color: AppColors.textSecondary(context)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.mealStorage,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary(context))),
                                  const SizedBox(height: 2),
                                  Text(aiContent!.storageInfo, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Leftover transformation idea
                    if (mealDay.isLeftover && aiContent!.leftoverIdea.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_fix_high, size: 16, color: Color(0xFF92400E)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.mealLeftoverIdea,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                                  const SizedBox(height: 2),
                                  Text(aiContent!.leftoverIdea, style: const TextStyle(fontSize: 12, color: Color(0xFF92400E))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(1);
  }
}

// -- Swap Bottom Sheet --------------------------------------------------------

class _SwapSheet extends StatelessWidget {
  final List<Recipe> alternatives;
  final String currentRecipeId;
  final int nPessoas;
  final Map<String, Ingredient> ingredientMap;
  final MealPlannerService service;
  final void Function(String) onSelect;

  const _SwapSheet({
    required this.alternatives,
    required this.currentRecipeId,
    required this.nPessoas,
    required this.ingredientMap,
    required this.service,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final currentRecipe = service.recipeMap[currentRecipeId];
    final currentCost = currentRecipe != null
        ? service.recipeCost(currentRecipe, nPessoas, ingredientMap)
        : 0.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.mealAlternatives,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...alternatives.take(6).map((r) {
              final cost = service.recipeCost(r, nPessoas, ingredientMap);
              final delta = cost - currentCost;
              final deltaStr = delta >= 0
                  ? '+${delta.toStringAsFixed(2)}${currencySymbol()}'
                  : '${delta.toStringAsFixed(2)}${currencySymbol()}';
              final deltaColor =
                  delta > 0 ? Colors.red : const Color(0xFF16A34A);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(r.name, style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                  l10n.mealTotalCost(cost.toStringAsFixed(2)),
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
                ),
                trailing: Text(
                  deltaStr,
                  style: TextStyle(
                      fontSize: 13,
                      color: deltaColor,
                      fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSelect(r.id);
                },
              );
            }),
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

class _ConsolidatedSheet extends StatelessWidget {
  final Map<String, double> totals;
  final Map<String, Ingredient> ingredientMap;
  final void Function(ShoppingItem) onAddToShoppingList;

  const _ConsolidatedSheet({
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
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.borderMuted(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.mealConsolidatedTitle,
                  style: const
                      TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
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
                  Text(
                    _categoryLabel(cat, l10n).toUpperCase(),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted(context),
                        letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  ...items.map((entry) {
                    final ing = ingredientMap[entry.key]!;
                    final cost = entry.value * ing.avgPricePerUnit;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(ing.name,
                                  style: const TextStyle(fontSize: 14))),
                          Text(
                            '${_fmt(entry.value)} ${ing.unit}',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary(context)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${cost.toStringAsFixed(2)}${currencySymbol()}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 10),
                          Semantics(
                            button: true,
                            label: l10n.addToList(ing.name),
                            child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Material(
                              color: AppColors.primary(context),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () => onAddToShoppingList(ShoppingItem(
                                  productName: ing.name,
                                  store: '',
                                  price: cost,
                                  unitPrice:
                                      '${ing.avgPricePerUnit.toStringAsFixed(2)}${currencySymbol()}/${ing.unit}',
                                )),
                                borderRadius: BorderRadius.circular(10),
                                child: Icon(Icons.add, size: 18, color: AppColors.onPrimary(context)),
                              ),
                            ),
                          ),
                          ),
                        ],
                      ),
                    );
                  }),
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

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(1);
  }
}

// -- Helpers ------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 14)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  final int complexity;
  const _Stars(this.complexity);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < complexity ? Icons.star : Icons.star_border,
          size: 13,
          color: AppColors.warning(context),
        ),
      ),
    );
  }
}

class _NutriBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _NutriBadge(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$value $label',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  final WeeklyNutritionSummary summary;
  const _WeeklySummaryCard({required this.summary});

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
              Row(
                children: [
                  Icon(Icons.analytics_outlined, size: 18, color: AppColors.textSecondary(context)),
                  const SizedBox(width: 8),
                  Text(l10n.mealWeeklySummary,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${summary.overallScore}/10',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: scoreColor),
                    ),
                  ),
                ],
              ),
              if (summary.highlights.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...summary.highlights.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline, size: 14, color: AppColors.success(context)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(h, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )),
              ],
              if (summary.concerns.isNotEmpty) ...[
                const SizedBox(height: 4),
                ...summary.concerns.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_outlined, size: 14, color: AppColors.warning(context)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(c, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
