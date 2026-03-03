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
import '../widgets/meal_cost_reconciliation_sheet.dart';
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

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _service.loadCatalog();
    final now = DateTime.now();
    final saved = await _service.load(widget.householdId, now.month, now.year);
    setState(() {
      _plan = saved;
      _catalogReady = true;
    });
    if (saved != null) _enrichPlan(saved);
  }

  Future<void> _generatePlan() async {
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

    final plan = _service.generate(widget.settings, now,
      favorites: widget.favorites,
      previousFeedback: previousFeedback,
    );
    await _service.save(plan, widget.householdId);
    setState(() {
      _plan = plan;
      _loading = false;
      _selectedWeek = 0;
      _expanded.clear();
    });
    _enrichPlan(plan);
  }

  void _enrichPlan(MealPlan plan) {
    if (widget.apiKey.isEmpty) return;
    final iMap = _service.ingredientMap;
    final uniqueRecipeIds = plan.days.map((d) => d.recipeId).toSet();
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
      ).then((content) {
        if (content != null && mounted) {
          setState(() => _aiContent[recipeId] = content);
        }
        _aiPending.remove(recipeId);
      });
    }
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
    for (final day in weekDays) {
      if (day.isLeftover) continue;
      final recipe = _service.recipeMap[day.recipeId];
      if (recipe == null) continue;
      final scale = plan.nPessoas / recipe.servings;
      for (final ri in recipe.ingredients) {
        totals.update(ri.ingredientId, (v) => v + ri.quantity * scale,
            ifAbsent: () => ri.quantity * scale);
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
        unitPrice: '${ing.avgPricePerUnit.toStringAsFixed(2)}\u20AC/${ing.unit}',
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

  @override
  Widget build(BuildContext context) {
    if (!widget.settings.mealSettings.wizardCompleted) {
      return MealWizardScreen(
        initial: widget.settings.mealSettings,
        onComplete: (ms) {
          widget.onSaveSettings(widget.settings.copyWith(mealSettings: ms));
        },
      );
    }
    final l10n = S.of(context);
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
      body: !_catalogReady
          ? Center(child: CircularProgressIndicator(color: AppColors.primary(context)))
          : _plan == null
              ? _buildEmptyState()
              : _buildPlanView(),
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
            _InfoRow(label: l10n.mealBudgetLabel, value: '${budget.toStringAsFixed(2)}\u20AC'),
            const SizedBox(height: 8),
            _InfoRow(label: l10n.mealPeopleLabel, value: '$np'),
            const SizedBox(height: 32),
            SizedBox(
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
                    '${plan.totalEstimatedCost.toStringAsFixed(2)}\u20AC / ${plan.monthlyBudget.toStringAsFixed(2)}\u20AC',
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
              Builder(builder: (_) {
                final daysInMonth = DateTime(plan.year, plan.month + 1, 0).day;
                final weekCount = (daysInMonth / 7).ceil();
                if (_selectedWeek >= weekCount) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedWeek = weekCount - 1);
                  });
                }
                return Row(
                children: List.generate(weekCount, (i) {
                  final selected = _selectedWeek == i;
                  return Expanded(
                    child: Semantics(
                      button: true,
                      label: l10n.mealWeekLabel(i + 1),
                      selected: selected,
                      child: Material(
                      color: selected ? AppColors.primary(context) : AppColors.surfaceVariant(context),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                      onTap: () => setState(() => _selectedWeek = i),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.mealWeekAbbr(i + 1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? AppColors.onPrimary(context) : AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ),
                    ),
                    ),
                  );
                }),
              );
              }),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: double.infinity,
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
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: weekDays.length,
                itemBuilder: (_, i) => _DayCard(
                  mealDay: weekDays[i],
                  plan: plan,
                  service: _service,
                  aiContent: _aiContent[weekDays[i].recipeId],
                  isExpanded: _expanded.contains('${weekDays[i].dayIndex}_${weekDays[i].mealType.name}'),
                  onToggleExpand: () => setState(() {
                    final key = '${weekDays[i].dayIndex}_${weekDays[i].mealType.name}';
                    if (_expanded.contains(key)) {
                      _expanded.remove(key);
                    } else {
                      _expanded.add(key);
                    }
                  }),
                  onSwap: () => _swapRecipe(weekDays[i].dayIndex, weekDays[i].mealType, weekDays[i].recipeId),
                  onAddIngredientToList: widget.onAddToShoppingList,
                  onFeedback: (fb) => _setFeedback(weekDays[i].dayIndex, weekDays[i].mealType, fb),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
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
  final void Function(ShoppingItem) onAddIngredientToList;
  final ValueChanged<MealFeedback> onFeedback;

  const _DayCard({
    required this.mealDay,
    required this.plan,
    required this.service,
    required this.aiContent,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onSwap,
    required this.onAddIngredientToList,
    required this.onFeedback,
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
                    const Spacer(),
                    Text(
                      '${mealDay.costEstimate.toStringAsFixed(2)}\u20AC',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context)),
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
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary(context),
                          side: BorderSide(color: AppColors.border(context)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSwap,
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: Text(l10n.mealSwap, style: const TextStyle(fontSize: 13)),
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
                      _FeedbackButton(
                        icon: Icons.thumb_up_outlined,
                        activeIcon: Icons.thumb_up,
                        isActive: mealDay.feedback == MealFeedback.liked,
                        color: const Color(0xFF16A34A),
                        onTap: () => onFeedback(MealFeedback.liked),
                      ),
                      const SizedBox(width: 16),
                      _FeedbackButton(
                        icon: Icons.thumb_down_outlined,
                        activeIcon: Icons.thumb_down,
                        isActive: mealDay.feedback == MealFeedback.disliked,
                        color: AppColors.error(context),
                        onTap: () => onFeedback(MealFeedback.disliked),
                      ),
                      const SizedBox(width: 16),
                      _FeedbackButton(
                        icon: Icons.skip_next_outlined,
                        activeIcon: Icons.skip_next,
                        isActive: mealDay.feedback == MealFeedback.skipped,
                        color: AppColors.textMuted(context),
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
                    final ing = iMap[ri.ingredientId];
                    if (ing == null) return const SizedBox();
                    final scale = plan.nPessoas / recipe.servings;
                    final qty = ri.quantity * scale;
                    final cost = qty * ing.avgPricePerUnit;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(ing.name,
                                style: const TextStyle(fontSize: 13)),
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
                                      '${ing.avgPricePerUnit.toStringAsFixed(2)}\u20AC/${ing.unit}',
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
                  ? '+${delta.toStringAsFixed(2)}\u20AC'
                  : '${delta.toStringAsFixed(2)}\u20AC';
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
                            '${cost.toStringAsFixed(2)}\u20AC',
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
                                      '${ing.avgPricePerUnit.toStringAsFixed(2)}\u20AC/${ing.unit}',
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

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;
  const _FeedbackButton({required this.icon, required this.activeIcon, required this.isActive, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(isActive ? activeIcon : icon, size: 20, color: isActive ? color : AppColors.borderMuted(context)),
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
