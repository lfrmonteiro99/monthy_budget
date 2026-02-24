import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/meal_planner.dart';
import '../models/shopping_item.dart';
import '../services/meal_planner_service.dart';
import '../services/meal_planner_ai_service.dart';

class MealPlannerScreen extends StatefulWidget {
  final AppSettings settings;
  final String apiKey;
  final List<String> favorites;
  final void Function(ShoppingItem) onAddToShoppingList;
  final String householdId;

  const MealPlannerScreen({
    super.key,
    required this.settings,
    required this.apiKey,
    required this.favorites,
    required this.onAddToShoppingList,
    required this.householdId,
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
  final Set<int> _expanded = {};

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
    final plan = _service.generate(widget.settings, now, favorites: widget.favorites);
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

  void _swapRecipe(int dayIndex, String currentRecipeId) {
    final plan = _plan!;
    final alternatives = _service.alternativesFor(currentRecipeId, plan.nPessoas);
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
          final updated = _service.swapDay(plan, dayIndex, newRecipeId);
          _service.save(updated, widget.householdId);
          setState(() => _plan = updated);
          _enrichPlan(updated);
        },
      ),
    );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Planeador de Refeições',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: !_catalogReady
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : _plan == null
              ? _buildEmptyState()
              : _buildPlanView(),
    );
  }

  Widget _buildEmptyState() {
    final budget = _service.monthlyFoodBudget(widget.settings);
    final np = _service.nPessoas(widget.settings);
    final now = DateTime.now();
    const months = ['', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
    final monthName = '${months[now.month]} ${now.year}';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant_outlined, size: 64, color: Color(0xFF94A3B8)),
            const SizedBox(height: 24),
            Text(
              monthName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            _InfoRow(label: 'Orçamento alimentação', value: '${budget.toStringAsFixed(2)}€'),
            const SizedBox(height: 8),
            _InfoRow(label: 'Pessoas no agregado', value: '$np'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _generatePlan,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_loading ? 'A gerar...' : 'Gerar Plano Mensal'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
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
    final plan = _plan!;
    final budgetUsed = plan.monthlyBudget > 0
        ? plan.totalEstimatedCost / plan.monthlyBudget
        : 0.0;
    final weekDays = _getWeekDays(plan, _selectedWeek);

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${plan.totalEstimatedCost.toStringAsFixed(2)}€ / ${plan.monthlyBudget.toStringAsFixed(2)}€',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      final plan = _plan!;
                      setState(() => _plan = null);
                      _service.clear(widget.householdId, plan.month, plan.year);
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Regenerar'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: budgetUsed.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFFE2E8F0),
                color: budgetUsed > 1 ? Colors.red : const Color(0xFF3B82F6),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(4, (i) {
                  final selected = _selectedWeek == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedWeek = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Sem.${i + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
            ],
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
                  isExpanded: _expanded.contains(weekDays[i].dayIndex),
                  onToggleExpand: () => setState(() {
                    if (_expanded.contains(weekDays[i].dayIndex)) {
                      _expanded.remove(weekDays[i].dayIndex);
                    } else {
                      _expanded.add(weekDays[i].dayIndex);
                    }
                  }),
                  onSwap: () => _swapRecipe(weekDays[i].dayIndex, weekDays[i].recipeId),
                  onAddIngredientToList: widget.onAddToShoppingList,
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: FilledButton.icon(
                  onPressed: _showConsolidatedList,
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Ver lista consolidada'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
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
    final end = start + 6;
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

  const _DayCard({
    required this.mealDay,
    required this.plan,
    required this.service,
    required this.aiContent,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onSwap,
    required this.onAddIngredientToList,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = service.recipeMap[mealDay.recipeId];
    if (recipe == null) return const SizedBox();
    final iMap = service.ingredientMap;
    final costPerPerson = plan.nPessoas > 0
        ? mealDay.costEstimate / plan.nPessoas
        : mealDay.costEstimate;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
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
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Dia ${mealDay.dayIndex}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3B82F6)),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${mealDay.costEstimate.toStringAsFixed(2)}€',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B)),
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
                    const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 3),
                    Text('${recipe.prepMinutes}min',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    const SizedBox(width: 10),
                    const Icon(Icons.person_outline, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 3),
                    Text('${costPerPerson.toStringAsFixed(2)}€/pess',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
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
                          isExpanded ? 'Fechar' : 'Ingredientes',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSwap,
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: const Text('Trocar', style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingredientes',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B)),
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
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => onAddIngredientToList(ShoppingItem(
                              productName: ing.name,
                              store: '',
                              price: cost,
                              unitPrice:
                                  '${ing.avgPricePerUnit.toStringAsFixed(2)}€/${ing.unit}',
                            )),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (aiContent != null) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Preparação',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B)),
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
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb_outline,
                                size: 16, color: Color(0xFFF59E0B)),
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
            const Text('Alternativas',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...alternatives.take(3).map((r) {
              final cost = service.recipeCost(r, nPessoas, ingredientMap);
              final delta = cost - currentCost;
              final deltaStr = delta >= 0
                  ? '+${delta.toStringAsFixed(2)}€'
                  : '${delta.toStringAsFixed(2)}€';
              final deltaColor =
                  delta > 0 ? Colors.red : const Color(0xFF16A34A);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(r.name, style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                  '${cost.toStringAsFixed(2)}€ total',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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
                child: const Text('Cancelar'),
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
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Lista Consolidada',
                  style:
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
                    _categoryLabel(cat).toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
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
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${cost.toStringAsFixed(2)}€',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => onAddToShoppingList(ShoppingItem(
                              productName: ing.name,
                              store: '',
                              price: cost,
                              unitPrice:
                                  '${ing.avgPricePerUnit.toStringAsFixed(2)}€/${ing.unit}',
                            )),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add, size: 16, color: Colors.white),
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

  String _categoryLabel(IngredientCategory cat) {
    switch (cat) {
      case IngredientCategory.proteina:
        return 'Proteínas';
      case IngredientCategory.vegetal:
        return 'Vegetais';
      case IngredientCategory.carbo:
        return 'Hidratos';
      case IngredientCategory.gordura:
        return 'Gorduras';
      case IngredientCategory.condimento:
        return 'Condimentos';
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
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
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
          color: const Color(0xFFF59E0B),
        ),
      ),
    );
  }
}
