import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../constants/app_constants.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/meal_planner.dart';
import '../models/meal_settings.dart';
import '../models/purchase_record.dart';
import '../models/shopping_item.dart';
import '../services/analytics_service.dart';
import '../services/meal_planner_service.dart';
import '../services/meal_planner_ai_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/freeform_meal_card.dart';
import '../widgets/freeform_meal_sheet.dart';
import '../models/meal_budget_insight.dart';
import '../utils/meal_budget_insights.dart';
import '../widgets/meal_cost_reconciliation_sheet.dart';
import '../widgets/meal_plan_budget_sheet.dart';
import '../widgets/nutrition_dashboard_card.dart';
import '../onboarding/meals_tour.dart';
import '../utils/pantry_matching.dart';
import '../utils/rate_limiter.dart';
import '../utils/waste_calculator.dart';
import '../widgets/pantry_quick_picker_sheet.dart';
import 'meal_wizard_screen.dart';
import '../widgets/meal_planner/meal_day_card.dart';
import '../widgets/meal_planner/meal_swap_sheet.dart';
import '../widgets/meal_planner/meal_consolidated_sheet.dart';
import '../widgets/meal_planner/meal_weekly_summary_card.dart';

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
  late int _viewMonth;
  late int _viewYear;
  bool _showFullMonth = false;

  final Map<String, RecipeAiContent> _aiContent = {};
  final Set<String> _aiPending = {};
  final Set<String> _expanded = {};
  bool _tourShown = false;

  final Map<int, WeeklyNutritionSummary> _weeklySummaries = {};
  final Set<int> _weeklySummaryPending = {};
  bool _batchPlanLoading = false;
  final _rateLimiter = RateLimiter(minInterval: AppConstants.rateLimitInterval);
  MealPlanBudgetInsight? _budgetInsight;

  late AppSettings _localSettings;

  @override
  void initState() {
    super.initState();
    _localSettings = widget.settings;
    final now = DateTime.now();
    _viewMonth = now.month;
    _viewYear = now.year;
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
    final saved = await _service.load(widget.householdId, _viewMonth, _viewYear);
    if (!mounted) return;
    if (saved != null) {
      // Pre-populate AI content from persisted cache for immediate render
      final locale = Localizations.localeOf(context).languageCode;
      for (final recipeId
          in saved.days
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
      Future.delayed(AppConstants.tourStartDelay, () {
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

  List<WasteItem> _computeWasteItems() {
    final plan = _plan;
    if (plan == null) return [];
    final weekDays = _getWeekDays(plan, _selectedWeek);
    final totals = <String, double>{};
    for (final day in weekDays) {
      if (day.isLeftover || day.isFreeform) continue;
      final recipe = _service.recipeMap[day.recipeId];
      if (recipe == null) continue;
      final dayGuests = plan.extraGuests[day.dayIndex] ?? 0;
      final scale = (plan.nPessoas + dayGuests) / recipe.servings;
      for (final ri in recipe.ingredients) {
        final effectiveId =
            day.substitutions[ri.ingredientId] ?? ri.ingredientId;
        totals.update(
          effectiveId,
          (v) => v + ri.quantity * scale,
          ifAbsent: () => ri.quantity * scale,
        );
      }
    }
    return WasteCalculator.excessIngredients(totals, _service.ingredientMap);
  }

  void _showWasteDetails(List<WasteItem> items) {
    final l10n = S.of(context);
    final iMap = _service.ingredientMap;
    CalmBottomSheet.show(
      context,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        expand: false,
        builder: (ctx, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ClipRRect(
                // Justified: drag-handle indicator, no Calm equivalent
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  width: 40,
                  height: 4,
                  child: ColoredBox(color: AppColors.ink20(ctx)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.warning(ctx),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.mealWasteEstimate,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  final ingredient = iMap[item.ingredientId];
                  final name = ingredient?.name ?? item.ingredientId;
                  return CalmListTile(
                    title: name,
                    subtitle: l10n.mealWasteExcess(
                      item.excessQty.toStringAsFixed(2),
                      item.unit,
                    ),
                    trailingWidget: Text(
                      '\u20AC${item.estimatedWasteCost.toStringAsFixed(2)}',
                      style: CalmText.amount(context)
                          .copyWith(color: AppColors.warning(ctx)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePlan() async {
    if (!_rateLimiter.tryCall()) {
      CalmSnack.show(
        context,
        S.of(context).rateLimitMessage,
        duration: AppConstants.snackBarShort,
      );
      return;
    }
    setState(() => _loading = true);
    final forMonth = DateTime(_viewYear, _viewMonth);

    // Collect feedback and ratings from previous plan
    final previousFeedback = <String, MealFeedback>{};
    final previousRatings = <String, int>{};
    if (_plan != null) {
      for (final day in _plan!.days) {
        if (day.feedback != MealFeedback.none) {
          previousFeedback[day.recipeId] = day.feedback;
        }
        if (day.effectiveRating != null) {
          previousRatings[day.recipeId] = day.effectiveRating!;
        }
      }
    }

    // Save current plan for undo before regenerating
    final hadPreviousPlan = _plan != null;
    if (_plan != null) {
      await _service.savePreviousPlan(_plan!);
    }

    final plan = _service.generate(
      _localSettings,
      forMonth,
      favorites: widget.favorites,
      previousFeedback: previousFeedback,
      previousRatings: previousRatings,
    );
    await _service.save(plan, widget.householdId);
    unawaited(
      AnalyticsService.instance.trackEvent(
        'meal_plan_generated',
        properties: {
          'days_planned': plan.days.length,
          'favorite_count': widget.favorites.length,
          'had_previous_plan': hadPreviousPlan,
        },
      ),
    );
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
      CalmSnack.show(
        context,
        l10n.mealPlanUndoMessage,
        duration: AppConstants.snackBarUndo,
        action: SnackBarAction(
          label: l10n.mealPlanUndoAction,
          onPressed: () => _undoRegeneration(),
        ),
      );
    }
  }

  Widget _buildMonthNavigator(S l10n) {
    final monthName = '${localizedMonthFull(l10n, _viewMonth)} $_viewYear';
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.mealPlannerPreviousMonth,
            onPressed: _loading ? null : () => _changeMonth(-1),
          ),
          Expanded(
            child: Center(
              child: Text(
                monthName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.mealPlannerNextMonth,
            onPressed: _loading ? null : () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Future<void> _changeMonth(int delta) async {
    var m = _viewMonth + delta;
    var y = _viewYear;
    while (m < 1) {
      m += 12;
      y -= 1;
    }
    while (m > 12) {
      m -= 12;
      y += 1;
    }
    setState(() {
      _viewMonth = m;
      _viewYear = y;
      _plan = null;
      _selectedWeek = 0;
      _expanded.clear();
      _weeklySummaries.clear();
      _weeklySummaryPending.clear();
      _budgetInsight = null;
      _aiContent.clear();
      _aiPending.clear();
    });
    final saved = await _service.load(widget.householdId, _viewMonth, _viewYear);
    if (!mounted) return;
    if (saved != null) {
      final locale = Localizations.localeOf(context).languageCode;
      for (final recipeId in saved.days
          .where((d) => !d.isFreeform && d.recipeId.isNotEmpty)
          .map((d) => d.recipeId)
          .toSet()) {
        final cached = _aiService.getCached(recipeId, locale: locale);
        if (cached != null) _aiContent[recipeId] = cached;
      }
    }
    if (!mounted) return;
    setState(() => _plan = saved);
    if (saved != null) {
      _enrichPlan(saved);
      _loadWeeklySummary(0, saved);
      _recomputeBudgetInsight();
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
      if (_aiContent.containsKey(recipeId) || _aiPending.contains(recipeId)) {
        continue;
      }
      _aiPending.add(recipeId);
      final recipe = _service.recipeMap[recipeId];
      if (recipe == null) continue;
      _aiService
          .enrichRecipe(
            apiKey: widget.apiKey,
            recipe: recipe,
            ingredientMap: iMap,
            nPessoas: plan.nPessoas,
            locale: locale,
          )
          .then((content) {
            if (content != null && mounted) {
              setState(() => _aiContent[recipeId] = content);
            }
            _aiPending.remove(recipeId);
          });
    }
  }

  void _loadWeeklySummary(int weekIndex, MealPlan plan) {
    if (_weeklySummaries.containsKey(weekIndex) ||
        _weeklySummaryPending.contains(weekIndex)) {
      return;
    }
    _weeklySummaryPending.add(weekIndex);
    final weekDays = _getWeekDays(plan, weekIndex);
    final recipes = weekDays
        .where((d) => !d.isFreeform && d.recipeId.isNotEmpty)
        .map((d) => _service.recipeMap[d.recipeId])
        .whereType<Recipe>()
        .toList();
    final locale = Localizations.localeOf(context).languageCode;
    _aiService
        .analyzeWeeklyNutrition(
          apiKey: widget.apiKey,
          weekRecipes: recipes,
          nPessoas: plan.nPessoas,
          locale: locale,
        )
        .then((summary) {
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
      CalmSnack.show(
        context,
        S.of(context).rateLimitMessage,
        duration: AppConstants.snackBarShort,
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
    _aiService
        .generateBatchPlan(
          apiKey: widget.apiKey,
          batchRecipes: batchRecipes,
          nPessoas: plan.nPessoas,
          locale: locale,
        )
        .then((result) {
          if (!mounted) return;
          setState(() => _batchPlanLoading = false);
          // Use AI result or build a deterministic local plan as fallback.
          final guide =
              result ??
              MealPlannerAiService.buildLocalBatchPlan(
                batchRecipes: batchRecipes,
                nPessoas: plan.nPessoas,
                locale: locale,
              );
          _showBatchPlanSheet(guide);
        });
  }

  void _showBatchPlanSheet(BatchCookingPlan plan) {
    final l10n = S.of(context);
    CalmBottomSheet.show(
      context,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
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
                  child: ColoredBox(color: AppColors.ink20(context)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.mealBatchPrepGuide,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (plan.totalTimeEstimate.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.mealBatchTotalTime(plan.totalTimeEstimate),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.ink70(context),
                      ),
                    ),
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
                  ...plan.prepOrder.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CalmListTile(
                        leadingIcon: Icons.circle,
                        leadingColor: AppColors.ink(context),
                        title: '${e.key + 1}. ${e.value}',
                      ),
                    ),
                  ),
                  if (plan.parallelTips.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    CalmEyebrow(l10n.mealBatchParallelTips.toUpperCase()),
                    const SizedBox(height: 8),
                    ...plan.parallelTips.map(
                      (tip) => CalmListTile(
                        leadingIcon: Icons.tips_and_updates_outlined,
                        leadingColor: AppColors.warning(context),
                        title: tip,
                      ),
                    ),
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
    // Use local prepSteps as primary source, fall back to AI steps,
    // then deterministic local fallback so the guide never fails silently.
    final locale = Localizations.localeOf(context).languageCode;
    final steps = recipe.prepSteps.isNotEmpty
        ? recipe.prepSteps
        : (aiContent?.steps != null && aiContent!.steps.isNotEmpty)
        ? aiContent.steps
        : MealPlannerAiService.buildLocalPrepSteps(
            recipe: recipe,
            nPessoas: _plan?.nPessoas ?? 2,
            locale: locale,
          );

    CalmBottomSheet.show(
      context,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ClipRRect(
                // Justified: drag-handle indicator, no Calm equivalent
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  width: 40,
                  height: 4,
                  child: ColoredBox(color: AppColors.ink20(ctx)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.mealPrepGuideTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.ink70(ctx),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.mealPrepTime(recipe.prepMinutes.toString()),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.ink50(ctx),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  ...steps.asMap().entries.map(
                    (e) => CalmListTile(
                      leadingIcon: Icons.circle,
                      leadingColor: AppColors.ink(ctx),
                      title: '${e.key + 1}. ${e.value}',
                    ),
                  ),
                  // Show AI-enriched extras if available
                  if (aiContent != null) ...[
                    if (aiContent.tip.isNotEmpty)
                      CalmListTile(
                        leadingIcon: Icons.lightbulb_outline,
                        leadingColor: AppColors.warning(ctx),
                        title: aiContent.tip,
                      ),
                    if (aiContent.variation.isNotEmpty)
                      CalmListTile(
                        leadingIcon: Icons.shuffle,
                        leadingColor: AppColors.ink(ctx),
                        title: l10n.mealVariation,
                        subtitle: aiContent.variation,
                      ),
                    if (aiContent.storageInfo.isNotEmpty)
                      CalmListTile(
                        leadingIcon: Icons.kitchen,
                        leadingColor: AppColors.ink70(ctx),
                        title: l10n.mealStorage,
                        subtitle: aiContent.storageInfo,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setRating(int dayIndex, MealType mealType, int rating) {
    final plan = _plan;
    if (plan == null) return;
    final updatedDays = plan.days.map((d) {
      if (d.dayIndex != dayIndex || d.mealType != mealType) return d;
      // Sync feedback for backward compat
      final feedback = rating >= 4
          ? MealFeedback.liked
          : rating <= 2
          ? MealFeedback.disliked
          : MealFeedback.none;
      return d.copyWith(rating: rating, feedback: feedback);
    }).toList();
    final updated = plan.copyWithDays(updatedDays);
    _service.save(updated, widget.householdId);
    setState(() => _plan = updated);
    _recomputeBudgetInsight();
  }

  void _showPantryPicker() {
    final ms = _localSettings.mealSettings;
    CalmBottomSheet.show(
      context,
      builder: (_) => PantryQuickPickerSheet(
        availableIngredients: _service.ingredients,
        stapleIds: ms.stapleIngredients.toSet(),
        weeklyIds: ms.weeklyPantryIngredients.toSet(),
        onStaplesChanged: (ids) {
          final updated = ms.copyWith(stapleIngredients: ids.toList());
          final settings = _localSettings.copyWith(mealSettings: updated);
          setState(() => _localSettings = settings);
          widget.onSaveSettings(settings);
        },
        onWeeklyChanged: (ids) {
          final updated = ms.copyWith(
            weeklyPantryIngredients: ids.toList(),
            weeklyPantryUpdatedAt: DateTime.now(),
          );
          final settings = _localSettings.copyWith(mealSettings: updated);
          setState(() => _localSettings = settings);
          widget.onSaveSettings(settings);
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

    CalmBottomSheet.show(
      context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
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
                    child: ColoredBox(color: AppColors.ink20(ctx)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.mealPantrySelectTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.mealPantrySelectHint,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.ink70(ctx),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.mealPantrySelected(selected.length),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink(ctx),
                      ),
                    ),
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
                      title: Text(
                        ing.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        ing.category.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.ink50(ctx),
                        ),
                      ),
                      value: isSelected,
                      activeColor: AppColors.ink(ctx),
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
                      final updated = ms.copyWith(
                        pantryIngredients: selected.toList(),
                      );
                      widget.onSaveSettings(
                        widget.settings.copyWith(mealSettings: updated),
                      );
                      // Generate plan with pantry boost
                      _generatePlan();
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(l10n.mealPantryApply),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ink(ctx),
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
    // Resolve effective ingredient (may already be substituted)
    final effectiveId = day.substitutions[ingredientId] ?? ingredientId;
    final ingredient = iMap[effectiveId] ?? iMap[ingredientId];
    if (ingredient == null) return;
    final l10n = S.of(context);

    // Group all ingredients by category, prioritizing same category first
    final sameCategory =
        _service.ingredients
            .where(
              (i) => i.category == ingredient.category && i.id != effectiveId,
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    final otherCategories =
        _service.ingredients
            .where(
              (i) => i.category != ingredient.category && i.id != effectiveId,
            )
            .toList()
          ..sort((a, b) {
            final catCmp = a.category.name.compareTo(b.category.name);
            return catCmp != 0 ? catCmp : a.name.compareTo(b.name);
          });

    CalmBottomSheet.show(
      context,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ClipRRect(
                // Justified: drag-handle indicator, no Calm equivalent
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  width: 40,
                  height: 4,
                  child: ColoredBox(color: AppColors.ink20(ctx)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.mealSubstituteTitle(ingredient.name),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.mealSubstituteHint,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.ink70(ctx),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  // Same category header
                  if (sameCategory.isNotEmpty) ...[
                    CalmEyebrow(l10n.mealSubstituteSameCategory.toUpperCase()),
                    const SizedBox(height: 4),
                    CalmCard(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: sameCategory
                            .map(
                              (alt) => CalmListTile(
                                leadingIcon: Icons.swap_horiz,
                                leadingColor: AppColors.ink(ctx),
                                title: alt.name,
                                subtitle:
                                    '${alt.avgPricePerUnit.toStringAsFixed(2)}${currencySymbol()}/${alt.unit}',
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _applySubstitution(day, ingredientId, alt.id);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                  // Other categories
                  if (otherCategories.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    CalmEyebrow(
                      l10n.mealSubstituteOtherCategories.toUpperCase(),
                    ),
                    const SizedBox(height: 4),
                    CalmCard(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: otherCategories
                            .map(
                              (alt) => CalmListTile(
                                leadingIcon: Icons.swap_horiz,
                                leadingColor: AppColors.ink50(ctx),
                                title: alt.name,
                                subtitle:
                                    '${alt.category.name} · ${alt.avgPricePerUnit.toStringAsFixed(2)}${currencySymbol()}/${alt.unit}',
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _applySubstitution(day, ingredientId, alt.id);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applySubstitution(
    MealDay day,
    String oldIngredientId,
    String newIngredientId,
  ) {
    final plan = _plan;
    if (plan == null) return;
    final l10n = S.of(context);
    final iMap = _service.ingredientMap;
    final oldIng = iMap[oldIngredientId];
    final newIng = iMap[newIngredientId];

    final newSubs = Map<String, String>.from(day.substitutions);
    newSubs[oldIngredientId] = newIngredientId;

    final updatedDays = plan.days.map((d) {
      if (d.dayIndex == day.dayIndex &&
          d.mealType == day.mealType &&
          d.courseType == day.courseType) {
        return d.copyWith(substitutions: newSubs);
      }
      return d;
    }).toList();
    final updated = plan.copyWithDays(updatedDays);
    _service.save(updated, widget.householdId);
    setState(() => _plan = updated);

    if (oldIng != null && newIng != null && mounted) {
      CalmSnack.success(
        context,
        l10n.mealSubstitutionApplied(oldIng.name, newIng.name),
      );
    }

    // Fire-and-forget AI adaptation
    final recipe = _service.recipeMap[day.recipeId];
    if (recipe != null &&
        oldIng != null &&
        newIng != null &&
        widget.apiKey.isNotEmpty) {
      final locale = Localizations.localeOf(context).languageCode;
      _aiService
          .adaptRecipeForSubstitution(
            apiKey: widget.apiKey,
            recipe: recipe,
            oldIngredient: oldIng,
            newIngredient: newIng,
            ingredientMap: iMap,
            nPessoas: plan.nPessoas,
            locale: locale,
          )
          .then((steps) {
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

  void _swapRecipeCourse(
    int dayIndex,
    MealType mealType,
    String currentRecipeId,
    CourseType courseType,
  ) {
    final plan = _plan!;
    final iMap = _service.ingredientMap;

    CalmBottomSheet.show(
      context,
      builder: (_) => SwapSheet(
        currentRecipeId: currentRecipeId,
        nPessoas: plan.nPessoas,
        ingredientMap: iMap,
        service: _service,
        mealSettings: widget.settings.mealSettings,
        currentMealType: mealType,
        courseType: courseType,
        onSelect: (newRecipeId) {
          final updated = _service.swapDay(
            plan,
            dayIndex,
            mealType,
            newRecipeId,
            courseType: courseType,
          );
          _service.save(updated, widget.householdId);
          setState(() => _plan = updated);
          _enrichPlan(updated);
          _recomputeBudgetInsight();
        },
      ),
    );
  }

  void _swapRecipe(int dayIndex, MealType mealType, String currentRecipeId) {
    final plan = _plan!;
    final iMap = _service.ingredientMap;

    CalmBottomSheet.show(
      context,
      builder: (_) => SwapSheet(
        currentRecipeId: currentRecipeId,
        nPessoas: plan.nPessoas,
        ingredientMap: iMap,
        service: _service,
        mealSettings: widget.settings.mealSettings,
        currentMealType: mealType,
        onSelect: (newRecipeId) {
          final newRecipe = _service.recipeMap[newRecipeId];
          // If cross-type swap: update mealType when recipe doesn't fit current type
          MealType? newMealType;
          if (newRecipe != null &&
              !newRecipe.suitableMealTypes.contains(mealType.name)) {
            newMealType = MealType.values.firstWhere(
              (t) => newRecipe.suitableMealTypes.contains(t.name),
              orElse: () => mealType,
            );
          }
          final updated = _service.swapDay(
            plan,
            dayIndex,
            mealType,
            newRecipeId,
            newMealType: newMealType,
          );
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
      final dayGuests = plan.extraGuests[day.dayIndex] ?? 0;
      final scale = (plan.nPessoas + dayGuests) / recipe.servings;
      for (final ri in recipe.ingredients) {
        // BUG FIX: apply ingredient substitutions to shopping list
        final effectiveId =
            day.substitutions[ri.ingredientId] ?? ri.ingredientId;
        totals.update(
          effectiveId,
          (v) => v + ri.quantity * scale,
          ifAbsent: () => ri.quantity * scale,
        );
        (mealLabels[effectiveId] ??= {}).add(recipe.name);
      }
    }
    final l10n = S.of(context);
    int count = 0;
    for (final entry in totals.entries) {
      final ing = iMap[entry.key];
      if (ing == null) continue;
      final cost = entry.value * ing.avgPricePerUnit;
      widget.onAddToShoppingList(
        ShoppingItem(
          productName: ing.name,
          store: '',
          price: cost,
          unitPrice:
              '${ing.avgPricePerUnit.toStringAsFixed(2)}${currencySymbol()}/${ing.unit}',
          quantity: entry.value,
          unit: ing.unit,
          sourceMealLabels: mealLabels[entry.key]?.toList() ?? const [],
        ),
      );
      count++;
    }
    // Add freeform shopping items
    final freeformItems = _service.freeformShoppingItemsForWeek(plan, weekDays);
    for (final item in freeformItems) {
      widget.onAddToShoppingList(
        ShoppingItem(
          productName: item.name,
          store: item.store ?? '',
          price: item.estimatedPrice ?? 0,
        ),
      );
      count++;
    }
    if (mounted) {
      CalmSnack.success(context, l10n.mealIngredientsAdded(count));
    }
  }

  void _showConsolidatedList() {
    final plan = _plan!;
    final totals = _service.consolidatedIngredients(plan);
    final iMap = _service.ingredientMap;

    CalmBottomSheet.show(
      context,
      builder: (_) => ConsolidatedSheet(
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
    CalmBottomSheet.show<dynamic>(
      context,
      builder: (_) => FreeformMealSheet(dayIndex: dayIndex, mealType: mealType),
    ).then((result) {
      if (result is MealDay && _plan != null) {
        final updatedDays = [
          ..._plan!.days.where(
            (d) =>
                !(d.dayIndex == result.dayIndex &&
                    d.mealType == result.mealType),
          ),
          result,
        ];
        final updated = _plan!.copyWithDays(updatedDays);
        _service.save(updated, widget.householdId);
        setState(() => _plan = updated);
      }
    });
  }

  void _editFreeformMeal(MealDay mealDay) {
    CalmBottomSheet.show<dynamic>(
      context,
      builder: (_) => FreeformMealSheet(
        dayIndex: mealDay.dayIndex,
        mealType: mealDay.mealType,
        existing: mealDay,
      ),
    ).then((result) {
      if (_plan == null) return;
      if (result == 'delete') {
        final updatedDays = _plan!.days
            .where(
              (d) =>
                  !(d.dayIndex == mealDay.dayIndex &&
                      d.mealType == mealDay.mealType &&
                      d.isFreeform),
            )
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
    CalmBottomSheet.show<dynamic>(
      context,
      builder: (_) => FreeformMealSheet(
        dayIndex: existing.dayIndex,
        mealType: existing.mealType,
      ),
    ).then((result) {
      if (result is MealDay && _plan != null) {
        final updatedDays = _plan!.days.map((d) {
          if (d.dayIndex == existing.dayIndex &&
              d.mealType == existing.mealType) {
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

  void _setFreeformFeedback(
    int dayIndex,
    MealType mealType,
    MealFeedback feedback,
  ) {
    final plan = _plan!;
    final updatedDays = plan.days.map((d) {
      if (d.dayIndex == dayIndex && d.mealType == mealType && d.isFreeform) {
        return d.copyWith(
          feedback: d.feedback == feedback ? MealFeedback.none : feedback,
        );
      }
      return d;
    }).toList();
    final updated = plan.copyWithDays(updatedDays);
    _service.save(updated, widget.householdId);
    setState(() => _plan = updated);
  }

  @override
  Widget build(BuildContext context) {
    // Show the meal wizard when it hasn't been completed yet (#16).
    if (!_localSettings.mealSettings.wizardCompleted) {
      return MealWizardScreen(
        initial: _localSettings.mealSettings,
        onComplete: (ms) {
          final updated = _localSettings.copyWith(mealSettings: ms);
          widget.onSaveSettings(updated);
          setState(() => _localSettings = updated);
          _init();
        },
      );
    }
    final l10n = S.of(context);
    final inner = !_catalogReady
        ? Center(
            child: CircularProgressIndicator(color: AppColors.ink(context)),
          )
        : _plan == null
        ? _buildEmptyState()
        : _buildPlanView();

    final bodyContent = _catalogReady
        ? Column(
            children: [
              _buildMonthNavigator(l10n),
              Expanded(child: inner),
            ],
          )
        : inner;

    if (widget.embedded) return bodyContent;

    return CalmScaffold(
      title: l10n.mealPlannerTitle,
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
        if (_plan != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.mealRegenerate,
            onPressed: _confirmRegenerate,
          ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: widget.onOpenMealSettings,
        ),
      ],
      body: bodyContent,
    );
  }

  Future<void> _confirmRegenerate() async {
    final l10n = S.of(context);
    final plan = _plan;
    if (plan == null) return;
    final confirmed = await CalmDialog.confirm(
      context,
      title: l10n.mealRegenerateTitle,
      body: l10n.mealRegenerateContent,
      confirmLabel: l10n.mealRegenerate,
      cancelLabel: l10n.cancel,
    );
    if (confirmed == true && mounted) {
      setState(() => _plan = null);
      _service.clear(widget.householdId, plan.month, plan.year);
    }
  }

  Widget _buildEmptyState() {
    final l10n = S.of(context);
    final budget = _service.monthlyFoodBudget(widget.settings);
    final np = _service.nPessoas(widget.settings);
    final monthName = '${localizedMonthFull(l10n, _viewMonth)} $_viewYear';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero — month + planned budget. Single Fraunces display per screen.
        CalmHero(
          eyebrow: monthName.toUpperCase(),
          amount: '${budget.toStringAsFixed(2)}${currencySymbol()}',
          subtitle: '${l10n.mealPeopleLabel} · $np',
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
        const SizedBox(height: 40),
        Icon(
          Icons.restaurant_outlined,
          size: 32,
          color: AppColors.ink50(context),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.mealGeneratePlan,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.ink70(context),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showPantryPicker(),
            icon: const Icon(Icons.kitchen_outlined),
            label: Text(l10n.pantryUseWhatWeHave),
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
                    child: CircularProgressIndicator(
                      color: AppColors.bg(context),
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_loading ? l10n.mealGenerating : l10n.mealGeneratePlan),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanView() {
    final l10n = S.of(context);
    final plan = _plan!;
    final budgetUsed = plan.monthlyBudget > 0
        ? plan.totalEstimatedCost / plan.monthlyBudget
        : 0.0;
    final weekDays = _showFullMonth
        ? plan.days
        : _getWeekDays(plan, _selectedWeek);

    final budgetPill = budgetUsed > 1.0
        ? CalmPill(
            label: '${(budgetUsed * 100).toStringAsFixed(0)}%',
            color: AppColors.bad(context),
          )
        : budgetUsed > 0.85
        ? CalmPill(
            label: '${(budgetUsed * 100).toStringAsFixed(0)}%',
            color: AppColors.warn(context),
          )
        : CalmPill(
            label: '${(budgetUsed * 100).toStringAsFixed(0)}%',
            color: AppColors.ok(context),
          );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: CalmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CalmEyebrow(l10n.mealPlannerMonthlyPlanEyebrow),
                          const SizedBox(height: 8),
                          Text(
                            '${plan.totalEstimatedCost.toStringAsFixed(2)}${currencySymbol()}',
                            style: CalmText.display(context, size: 32),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '/ ${plan.monthlyBudget.toStringAsFixed(2)}${currencySymbol()}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.ink70(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    budgetPill,
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: budgetUsed.clamp(0.0, 1.0),
                    backgroundColor: AppColors.ink20(context),
                    color: budgetUsed > 1
                        ? AppColors.bad(context)
                        : AppColors.ink(context),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: AppColors.line(context), height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CalmEyebrow(
                      _showFullMonth
                          ? l10n.mealPlannerFullMonthView.toUpperCase()
                          : l10n.mealPlannerWeekEyebrow,
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 28,
                      child: ToggleButtons(
                        constraints: const BoxConstraints(
                          minHeight: 28,
                          minWidth: 64,
                        ),
                        isSelected: [!_showFullMonth, _showFullMonth],
                        onPressed: (i) {
                          setState(() => _showFullMonth = i == 1);
                        },
                        borderRadius: BorderRadius.circular(8),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              l10n.mealPlannerWeekView,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              l10n.mealPlannerFullMonthView,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (!_showFullMonth)
                  // Week navigator (← Week N →) — replaces W1-W4 tabs
                  Builder(
                    builder: (_) {
                    final daysInMonth = DateTime(
                      plan.year,
                      plan.month + 1,
                      0,
                    ).day;
                    final weekCount = (daysInMonth / 7).ceil();
                    if (_selectedWeek >= weekCount) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => _selectedWeek = weekCount - 1);
                        }
                      });
                    }
                    return Row(
                      key: MealsTourKeys.weekTabs,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _selectedWeek > 0
                              ? () {
                                  setState(() => _selectedWeek--);
                                  if (_plan != null) {
                                    _loadWeeklySummary(_selectedWeek, _plan!);
                                  }
                                  _recomputeBudgetInsight();
                                }
                              : null,
                        ),
                        Text(
                          l10n.mealWeekLabel(_selectedWeek + 1),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _selectedWeek < weekCount - 1
                              ? () {
                                  setState(() => _selectedWeek++);
                                  if (_plan != null) {
                                    _loadWeeklySummary(_selectedWeek, _plan!);
                                  }
                                  _recomputeBudgetInsight();
                                }
                              : null,
                        ),
                        const Spacer(),
                        SizedBox(
                          key: MealsTourKeys.addToListButton,
                          height: 32,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _addWeekToShoppingList(_selectedWeek),
                            icon: const Icon(Icons.add_shopping_cart, size: 16),
                            label: Text(
                              l10n.mealAddWeekToList,
                              style: const TextStyle(fontSize: 11),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.ink(context),
                              side: BorderSide(
                                color: AppColors.ink(context),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                          ),
                        ),
                        if (_weekHasBatchCooking(plan, _selectedWeek)) ...[
                          const SizedBox(width: 4),
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: IconButton(
                              onPressed: _batchPlanLoading
                                  ? null
                                  : () => _showBatchPrepGuide(
                                      plan,
                                      _selectedWeek,
                                    ),
                              icon: _batchPlanLoading
                                  ? SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.ink(context),
                                      ),
                                    )
                                  : Icon(
                                      Icons.kitchen,
                                      size: 18,
                                      color: AppColors.ink(context),
                                    ),
                              padding: EdgeInsets.zero,
                              tooltip: l10n.mealBatchPrepGuide,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        // Always-visible compact detail chip row (replaces toggle)
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: CalmEyebrow(l10n.mealPlannerDetailEyebrow),
        ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            children: [
              ActionChip(
                avatar: const Icon(Icons.eco_outlined, size: 14),
                label: Text(l10n.mealShowDetails),
                labelStyle: const TextStyle(fontSize: 11),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: () => _showPantryPicker(),
              ),
              const SizedBox(width: 6),
              if (_weeklySummaries.containsKey(_selectedWeek))
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    avatar: const Icon(Icons.monitor_heart_outlined, size: 14),
                    label: Text(
                      '${_weeklySummaries[_selectedWeek]!.overallScore}/10',
                    ),
                    labelStyle: const TextStyle(fontSize: 11),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () {
                      CalmBottomSheet.show(
                        context,
                        builder: (_) => CalmBottomSheetContent(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NutritionDashboardCard(
                                weekDays: _getWeekDays(plan, _selectedWeek),
                                recipeMap: _service.recipeMap,
                                ingredientMap: _service.ingredientMap,
                                nPessoas: plan.nPessoas,
                                settings: widget.settings.mealSettings,
                              ),
                              if (_weeklySummaries.containsKey(_selectedWeek))
                                WeeklySummaryCard(
                                  summary: _weeklySummaries[_selectedWeek]!,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (_budgetInsight != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    avatar: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 14,
                    ),
                    label: Text(
                      '${_budgetInsight!.weeklyEstimatedCost.toStringAsFixed(0)}${currencySymbol()}',
                    ),
                    labelStyle: const TextStyle(fontSize: 11),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () => showMealPlanBudgetSheet(
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
                ),
              Builder(
                builder: (_) {
                  final wasteItems = _computeWasteItems();
                  if (wasteItems.isEmpty) return const SizedBox.shrink();
                  final totalWaste = wasteItems.fold(
                    0.0,
                    (s, w) => s + w.estimatedWasteCost,
                  );
                  return ActionChip(
                    avatar: Icon(
                      Icons.delete_outline,
                      size: 14,
                      color: AppColors.warning(context),
                    ),
                    label: Text('\u20AC${totalWaste.toStringAsFixed(2)}'),
                    labelStyle: const TextStyle(fontSize: 11),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: AppColors.warningBackground(context),
                    side: BorderSide(color: AppColors.warningBorder(context)),
                    onPressed: () => _showWasteDetails(wasteItems),
                  );
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: CalmEyebrow(l10n.mealPlannerMealsEyebrow),
        ),
        Expanded(
          child: Stack(
            children: [
              Builder(
                builder: (_) {
                  // Group courses by (dayIndex, mealType) for multi-course display
                  final grouped = <String, List<MealDay>>{};
                  for (final day in weekDays) {
                    final key = '${day.dayIndex}_${day.mealType.name}';
                    (grouped[key] ??= []).add(day);
                  }
                  // Sort courses within each group: soup first, main, dessert last
                  const courseOrder = {
                    CourseType.soupOrStarter: 0,
                    CourseType.mainCourse: 1,
                    CourseType.dessert: 2,
                  };
                  for (final group in grouped.values) {
                    group.sort(
                      (a, b) => (courseOrder[a.courseType] ?? 1).compareTo(
                        courseOrder[b.courseType] ?? 1,
                      ),
                    );
                  }
                  final groupKeys = grouped.keys.toList();
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 80),
                    itemCount: groupKeys.length,
                    itemBuilder: (_, i) {
                      final courses = grouped[groupKeys[i]]!;
                      final mainDay = courses.firstWhere(
                        (d) => d.courseType == CourseType.mainCourse,
                        orElse: () => courses.first,
                      );
                      if (mainDay.isFreeform) {
                        return FreeformMealCard(
                          mealDay: mainDay,
                          onEdit: () => _editFreeformMeal(mainDay),
                          onAddToShoppingList: widget.onAddToShoppingList,
                          onFeedback: (fb) => _setFreeformFeedback(
                            mainDay.dayIndex,
                            mainDay.mealType,
                            fb,
                          ),
                        );
                      }
                      return DayCard(
                        mealDay: mainDay,
                        allCourses: courses,
                        plan: plan,
                        service: _service,
                        aiContent: _aiContent[mainDay.recipeId],
                        isExpanded: _expanded.contains(
                          '${mainDay.dayIndex}_${mainDay.mealType.name}',
                        ),
                        onToggleExpand: () => setState(() {
                          final key =
                              '${mainDay.dayIndex}_${mainDay.mealType.name}';
                          if (_expanded.contains(key)) {
                            _expanded.remove(key);
                          } else {
                            _expanded.add(key);
                          }
                        }),
                        onSwap: () => _swapRecipe(
                          mainDay.dayIndex,
                          mainDay.mealType,
                          mainDay.recipeId,
                        ),
                        onSwapCourse: (day) => _swapRecipeCourse(
                          day.dayIndex,
                          day.mealType,
                          day.recipeId,
                          day.courseType,
                        ),
                        onReplaceFreeform: () =>
                            _replaceMealWithFreeform(mainDay),
                        onAddIngredientToList: widget.onAddToShoppingList,
                        onRating: (rating) => _setRating(
                          mainDay.dayIndex,
                          mainDay.mealType,
                          rating,
                        ),
                        onViewPrepGuide: () => _showMealPrepGuide(mainDay),
                        activePantryIds: resolveActivePantry(
                          widget.settings.mealSettings,
                        ),
                        onSubstituteIngredient: (ingredientId) =>
                            _showIngredientSubstitutionSheet(
                              mainDay,
                              ingredientId,
                            ),
                        onSubstituteCourseIngredient: (day, ingredientId) =>
                            _showIngredientSubstitutionSheet(day, ingredientId),
                      );
                    },
                  );
                },
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
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
                      backgroundColor: AppColors.ink(context),
                      child: Icon(
                        Icons.edit_note,
                        color: AppColors.bg(context),
                      ),
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
    return plan.days
        .where((d) => d.dayIndex >= start && d.dayIndex <= end)
        .toList();
  }
}
