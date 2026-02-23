import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/meal_plan.dart';
import '../models/app_settings.dart';
import '../data/ingredients_db.dart';
import '../data/recipes_db.dart';
import '../utils/meal_plan_engine.dart';
import '../utils/formatters.dart';
import '../services/meal_plan_service.dart';

class MealPlanScreen extends StatefulWidget {
  final AppSettings settings;

  const MealPlanScreen({super.key, required this.settings});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = MealPlanService();

  MealPlan? _plan;
  Map<int, ShoppingList> _shoppingLists = {};
  int _currentWeek = 0; // 0-indexed
  bool _loaded = false;

  // Config state for generation
  late VarietyLevel _selectedVariety;
  late int _nPessoas;
  late double _orcamentoMensal;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initConfig();
    _loadData();
  }

  void _initConfig() {
    // n pessoas = enabled salaries + dependentes
    final enabledSalaries =
        widget.settings.salaries.where((s) => s.enabled).length;
    _nPessoas = enabledSalaries + widget.settings.personalInfo.dependentes;
    if (_nPessoas < 1) _nPessoas = 1;

    // orcamento = alimentacao expense
    _orcamentoMensal = widget.settings.expenses
        .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
        .fold(0.0, (sum, e) => sum + e.amount);
    if (_orcamentoMensal <= 0) _orcamentoMensal = 300;

    _selectedVariety = VarietyLevel.equilibrado;
  }

  Future<void> _loadData() async {
    final plan = await _service.loadPlan();
    final lists = await _service.loadShoppingLists();
    setState(() {
      _plan = plan;
      _shoppingLists = lists;
      _loaded = true;
    });
  }

  MealPlanConfig get _config => MealPlanConfig(
        nPessoas: _nPessoas,
        orcamentoMensal: _orcamentoMensal,
        nivelVariedade: _selectedVariety,
      );

  void _generatePlan() {
    final now = DateTime.now();
    final engine = MealPlanEngine(config: _config);
    final plan = engine.generateMonthPlan(mes: now.month, ano: now.year);

    // Generate shopping lists for all weeks
    final lists = <int, ShoppingList>{};
    for (final week in plan.semanas) {
      lists[week.semana] = engine.generateShoppingList(week);
    }

    setState(() {
      _plan = plan;
      _shoppingLists = lists;
      _currentWeek = 0;
    });

    _service.savePlan(plan);
    _service.saveShoppingLists(lists);
  }

  void _swapMeal(int weekIdx, int dayIdx, bool isAlmoco, Recipe newRecipe) {
    if (_plan == null) return;
    final engine = MealPlanEngine(config: _config);
    final newMeal = engine.buildPlannedMeal(newRecipe);

    final weeks = List<WeekPlan>.from(_plan!.semanas);
    final days = List<DayPlan>.from(weeks[weekIdx].dias);

    if (isAlmoco) {
      days[dayIdx] = days[dayIdx].copyWith(almoco: newMeal);
    } else {
      days[dayIdx] = days[dayIdx].copyWith(jantar: newMeal);
    }

    weeks[weekIdx] = weeks[weekIdx].copyWith(dias: days);
    final updatedPlan = _plan!.copyWith(semanas: weeks);

    // Regenerate shopping list for this week
    final updatedList = engine.generateShoppingList(weeks[weekIdx]);

    setState(() {
      _plan = updatedPlan;
      _shoppingLists[weeks[weekIdx].semana] = updatedList;
    });

    _service.savePlan(updatedPlan);
    _service.saveShoppingList(weeks[weekIdx].semana, updatedList);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refeicao trocada. Lista atualizada.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _updateWeekRealCost(int weekIdx, double cost) {
    if (_plan == null) return;
    final weeks = List<WeekPlan>.from(_plan!.semanas);
    weeks[weekIdx] = weeks[weekIdx].copyWith(custoRealSemanal: cost);
    final updatedPlan = _plan!.copyWith(semanas: weeks);
    setState(() => _plan = updatedPlan);
    _service.savePlan(updatedPlan);
  }

  void _toggleShoppingItem(int semana, int itemIdx) {
    final list = _shoppingLists[semana];
    if (list == null) return;
    final items = List<ShoppingListItem>.from(list.items);
    items[itemIdx] = items[itemIdx].copyWith(checked: !items[itemIdx].checked);
    final updated = list.copyWith(items: items);
    setState(() => _shoppingLists[semana] = updated);
    _service.saveShoppingList(semana, updated);
  }

  void _addMealToShoppingList(PlannedMeal meal) {
    if (_plan == null) return;
    final currentWeekSemana = _plan!.semanas[_currentWeek].semana;
    final currentList = _shoppingLists[currentWeekSemana] ??
        ShoppingList(semana: currentWeekSemana);

    final engine = MealPlanEngine(config: _config);
    final newItems = engine.generateItemsForMeal(meal);

    // Merge with existing items
    final merged = List<ShoppingListItem>.from(currentList.items);
    for (final newItem in newItems) {
      final existingIdx = merged
          .indexWhere((i) => i.ingredientId == newItem.ingredientId);
      if (existingIdx < 0) {
        merged.add(newItem);
      }
      // If already exists, skip (don't duplicate)
    }

    final updated = currentList.copyWith(items: merged);
    setState(() => _shoppingLists[currentWeekSemana] = updated);
    _service.saveShoppingList(currentWeekSemana, updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${newItems.length} ingredientes adicionados a lista'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plano Alimentar',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B)),
            ),
            Text(
              'ORCAMENTO ALIMENTAR',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 1.2),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3B82F6),
          unselectedLabelColor: const Color(0xFF94A3B8),
          indicatorColor: const Color(0xFF3B82F6),
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Plano Semanal'),
            Tab(text: 'Lista Compras'),
            Tab(text: 'Custos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _plan == null ? _buildGenerateView() : _buildWeekPlanTab(),
          _buildShoppingListTab(),
          _buildCostsTab(),
        ],
      ),
    );
  }

  // ─── Generate Plan View ─────────────────────────────────────────────

  Widget _buildGenerateView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(Icons.restaurant_menu_outlined,
              size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Gere o plano alimentar mensal\nbaseado no seu orcamento.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Config card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CONFIGURACAO',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.2)),
                const SizedBox(height: 16),
                // People + budget info
                Row(
                  children: [
                    Expanded(
                      child: _infoRow(
                          'Pessoas', '$_nPessoas', Icons.people_outline),
                    ),
                    Expanded(
                      child: _infoRow('Orcamento',
                          formatCurrency(_orcamentoMensal), Icons.euro),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _infoRow(
                    'Orcamento diario',
                    formatCurrency(_orcamentoMensal / 30),
                    Icons.calendar_today),
                const SizedBox(height: 16),
                const Text('NIVEL DE VARIEDADE',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Row(
                  children: VarietyLevel.values.map((v) {
                    final selected = _selectedVariety == v;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right:
                                v != VarietyLevel.variado ? 8 : 0),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedVariety = v),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF3B82F6)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                v.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _generatePlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Gerar Plano Mensal',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF64748B))),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  // ─── Week Plan Tab ──────────────────────────────────────────────────

  Widget _buildWeekPlanTab() {
    final week = _plan!.semanas[_currentWeek];
    final budgetUsed = week.custoEstimadoSemanal;
    final weekBudget = _plan!.config.orcamentoSemanal;
    final pct = weekBudget > 0 ? (budgetUsed / weekBudget).clamp(0.0, 1.5) : 0.0;

    return Column(
      children: [
        // Top control bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: Color(0xFF64748B)),
                    onPressed: _currentWeek > 0
                        ? () => setState(() => _currentWeek--)
                        : null,
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                        minWidth: 36, minHeight: 36),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Semana ${_currentWeek + 1} de ${_plan!.semanas.length}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 2),
                          _buildClusterBadge(week.proteinaDominante),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: Color(0xFF64748B)),
                    onPressed:
                        _currentWeek < _plan!.semanas.length - 1
                            ? () => setState(() => _currentWeek++)
                            : null,
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                        minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Budget bar
              Row(
                children: [
                  Text('Orcamento: ${formatCurrency(weekBudget)}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF94A3B8))),
                  const Spacer(),
                  Text('Estimado: ${formatCurrency(budgetUsed)}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _budgetColor(pct))),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct.clamp(0.0, 1.0),
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor:
                      AlwaysStoppedAnimation(_budgetColor(pct)),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        // Protein timeline bar
        _buildProteinTimeline(week),
        // Day cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: week.dias.length,
            itemBuilder: (_, i) =>
                _buildDayCard(week.dias[i], _currentWeek, i, week),
          ),
        ),
        // Regenerate button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: _generatePlan,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Regenerar Plano',
                  style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProteinTimeline(WeekPlan week) {
    final dayNames = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: List.generate(7, (i) {
          final day = week.dias[i];
          // Get dominant protein from lunch
          ProteinCluster? cluster;
          if (day.almoco != null) {
            final recipe = getRecipe(day.almoco!.receitaId);
            cluster = recipe?.proteinCluster;
          }
          return Expanded(
            child: Column(
              children: [
                Text(dayNames[i],
                    style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8))),
                const SizedBox(height: 3),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _clusterColor(
                        cluster ?? week.proteinaDominante),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      _clusterLetter(
                          cluster ?? week.proteinaDominante),
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayCard(
      DayPlan day, int weekIdx, int dayIdx, WeekPlan week) {
    final dayNames = [
      'Domingo',
      'Segunda',
      'Terca',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sabado'
    ];
    final dayName = dayNames[day.data.weekday % 7];
    final dayStr =
        '${day.data.day.toString().padLeft(2, '0')}/${day.data.month.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                Text('$dayName, $dayStr',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B))),
                const Spacer(),
                Text('Est: ${formatCurrency(day.custoEstimadoDiario)}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569))),
              ],
            ),
          ),
          // Lunch
          if (day.almoco != null)
            _buildMealRow('Almoco', day.almoco!, weekIdx, dayIdx, true, week),
          if (day.almoco != null && day.jantar != null)
            const Divider(height: 1, color: Color(0xFFF8FAFC)),
          // Dinner
          if (day.jantar != null)
            _buildMealRow(
                'Jantar', day.jantar!, weekIdx, dayIdx, false, week),
        ],
      ),
    );
  }

  Widget _buildMealRow(String label, PlannedMeal meal, int weekIdx,
      int dayIdx, bool isAlmoco, WeekPlan week) {
    // Count ingredient reuse across the week
    final ingredientCounts = <String, int>{};
    for (final d in week.dias) {
      for (final m in [d.almoco, d.jantar]) {
        if (m == null) continue;
        for (final i in m.ingredientes) {
          ingredientCounts[i.ingredientId] =
              (ingredientCounts[i.ingredientId] ?? 0) + 1;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.0)),
              if (meal.isSobras)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Sobras',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF059669))),
                ),
              const Spacer(),
              if (!meal.isSobras)
                Text(
                    '${formatCurrency(meal.custoEstimadoPorPessoa)}/pp',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(meal.nomeReceita,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B))),
              ),
              // Swap button
              GestureDetector(
                onTap: () => _showSwapSheet(
                    meal, weekIdx, dayIdx, isAlmoco, week),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.swap_horiz,
                      size: 20, color: Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Ingredient chips
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ...meal.ingredientes
                  .where((i) {
                    final ingredient = getIngredient(i.ingredientId);
                    return ingredient?.categoria ==
                            IngredientCategory.proteina ||
                        ingredient?.categoria ==
                            IngredientCategory.carboidrato ||
                        ingredient?.categoria ==
                            IngredientCategory.vegetal;
                  })
                  .map((i) {
                    final count =
                        ingredientCounts[i.ingredientId] ?? 1;
                    return _ingredientChip(i, count, meal);
                  }),
            ],
          ),
          // Add all to shopping list
          if (!meal.isSobras)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: GestureDetector(
                onTap: () => _addMealToShoppingList(meal),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_shopping_cart,
                        size: 13, color: Color(0xFF3B82F6)),
                    SizedBox(width: 4),
                    Text('Adicionar a lista',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3B82F6))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _ingredientChip(
      PlannedIngredient ingredient, int weekCount, PlannedMeal meal) {
    final isShared = weekCount > 1;
    return GestureDetector(
      onTap: () =>
          _showIngredientSheet(ingredient, meal),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isShared
              ? const Color(0xFFF0FDFA)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isShared
                ? const Color(0xFF99F6E4)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ingredient.nome,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569))),
            if (isShared)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('x$weekCount',
                    style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3B82F6))),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Shopping List Tab ──────────────────────────────────────────────

  Widget _buildShoppingListTab() {
    if (_plan == null) {
      return _buildEmptyState(
          'Gere o plano alimentar primeiro\npara ver a lista de compras.');
    }

    final semana = _plan!.semanas[_currentWeek].semana;
    final list = _shoppingLists[semana];

    if (list == null || list.items.isEmpty) {
      return _buildEmptyState('Sem itens na lista de compras\npara esta semana.');
    }

    final grouped = list.byCategory;
    final categories = grouped.keys.toList();

    return Column(
      children: [
        // Week selector
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: Color(0xFF64748B)),
                onPressed: _currentWeek > 0
                    ? () => setState(() => _currentWeek--)
                    : null,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Semana ${_currentWeek + 1}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B)),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right,
                    color: Color(0xFF64748B)),
                onPressed:
                    _currentWeek < _plan!.semanas.length - 1
                        ? () => setState(() => _currentWeek++)
                        : null,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
        // Summary card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shopping_basket,
                  size: 20, color: Color(0xFF3B82F6)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${list.checkedItems}/${list.totalItems} itens',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B))),
                    const SizedBox(height: 2),
                    Text(
                        'Total estimado: ${formatCurrency(list.custoEstimadoTotal)}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Items grouped by category
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (_, catIdx) {
              final catName = categories[catIdx];
              final items = grouped[catName]!;
              // Sort: unchecked first, then checked
              items.sort((a, b) {
                if (a.checked != b.checked) {
                  return a.checked ? 1 : -1;
                }
                return a.nome.compareTo(b.nome);
              });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(_categoryIcon(catName),
                            size: 14,
                            color: const Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(catName.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1.2)),
                        const SizedBox(width: 8),
                        Text('${items.length} itens',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFCBD5E1))),
                      ],
                    ),
                  ),
                  ...items.map((item) {
                    final globalIdx = list.items.indexOf(item);
                    return _buildShoppingItem(
                        item, semana, globalIdx);
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShoppingItem(
      ShoppingListItem item, int semana, int idx) {
    return Opacity(
      opacity: item.checked ? 0.4 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _toggleShoppingItem(semana, idx),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: item.checked
                      ? const Color(0xFF3B82F6)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: item.checked
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: item.checked
                    ? const Icon(Icons.check,
                        size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nome,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                      decoration: item.checked
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatQuantity(item.quantidadeCompra, item.unidade),
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                  if (item.receitasQueUsam.isNotEmpty)
                    Text(
                      item.receitasQueUsam.join(', '),
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFFCBD5E1)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Text(
              '~${formatCurrency(item.precoEstimado)}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Costs Tab ──────────────────────────────────────────────────────

  Widget _buildCostsTab() {
    if (_plan == null) {
      return _buildEmptyState(
          'Gere o plano alimentar primeiro\npara ver a analise de custos.');
    }

    final estimado = _plan!.custoEstimadoTotal;
    final real = _plan!.custoRealTotal;
    final desvio = _plan!.desvioPercentual;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hero deviation card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            children: [
              const Text('DESVIO MENSAL',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              if (real != null && desvio != null) ...[
                Text(
                  '${desvio >= 0 ? '+' : ''}${formatCurrency(real - estimado)}',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: _desvioColor(desvio)),
                ),
                Text(
                  '${desvio >= 0 ? '+' : ''}${desvio.toStringAsFixed(1)}%',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _desvioColor(desvio)),
                ),
              ] else ...[
                const Text('--',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8))),
                const Text('Insira custos reais abaixo',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _costLabel('Estimado', estimado, const Color(0xFF3B82F6)),
                  const SizedBox(width: 24),
                  _costLabel(
                      'Real',
                      real ?? 0,
                      real != null
                          ? _desvioColor(desvio ?? 0)
                          : const Color(0xFF94A3B8)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Weekly breakdown
        const Text('CUSTOS SEMANAIS',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
                letterSpacing: 1.2)),
        const SizedBox(height: 8),
        ..._plan!.semanas.asMap().entries.map((entry) {
          final weekIdx = entry.key;
          final week = entry.value;
          return _buildWeekCostRow(week, weekIdx);
        }),
        const SizedBox(height: 16),
        // Monthly budget info
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  size: 16, color: Color(0xFF94A3B8)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Orcamento mensal: ${formatCurrency(_plan!.config.orcamentoMensal)} para ${_plan!.config.nPessoas} pessoa${_plan!.config.nPessoas > 1 ? 's' : ''}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCostRow(WeekPlan week, int weekIdx) {
    final est = week.custoEstimadoSemanal;
    final real = week.custoRealSemanal;
    final hasReal = real != null;
    final desvio = hasReal && est > 0
        ? ((real - est) / est) * 100
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text('Semana ${week.semana}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B))),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Est: ${formatCurrency(est)}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          // Real cost input
          SizedBox(
            width: 90,
            child: GestureDetector(
              onTap: () => _showRealCostInput(weekIdx, real),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: hasReal
                      ? const Color(0xFFF8FAFC)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasReal
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!hasReal)
                      const Icon(Icons.edit_outlined,
                          size: 12, color: Color(0xFF94A3B8)),
                    if (!hasReal) const SizedBox(width: 4),
                    Text(
                      hasReal ? formatCurrency(real) : 'Real',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: hasReal
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: hasReal
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 52,
            child: Text(
              desvio != null
                  ? '${desvio >= 0 ? '+' : ''}${desvio.toStringAsFixed(1)}%'
                  : '--',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: desvio != null
                    ? _desvioColor(desvio)
                    : const Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _costLabel(String label, double value, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8))),
        Text(formatCurrency(value),
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color)),
      ],
    );
  }

  // ─── Bottom Sheets ──────────────────────────────────────────────────

  void _showSwapSheet(PlannedMeal currentMeal, int weekIdx, int dayIdx,
      bool isAlmoco, WeekPlan week) {
    final engine = MealPlanEngine(config: _config);
    final suggestions =
        engine.getSwapSuggestions(currentMeal, week.proteinaDominante);

    final sameCluster = suggestions
        .where((r) => r.proteinCluster == week.proteinaDominante)
        .toList();
    final otherCluster = suggestions
        .where((r) => r.proteinCluster != week.proteinaDominante)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Trocar Refeicao',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              if (sameCluster.isNotEmpty) ...[
                Text(
                    'MESMA PROTEINA (${week.proteinaDominante.label})'
                        .toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.0)),
                const SizedBox(height: 8),
                ...sameCluster.map((r) => _buildSwapOption(
                    r, currentMeal, weekIdx, dayIdx, isAlmoco, engine)),
                const SizedBox(height: 16),
              ],
              if (otherCluster.isNotEmpty) ...[
                const Text('OUTRAS PROTEINAS',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.0)),
                const SizedBox(height: 8),
                ...otherCluster.map((r) => _buildSwapOption(
                    r, currentMeal, weekIdx, dayIdx, isAlmoco, engine)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwapOption(Recipe recipe, PlannedMeal currentMeal,
      int weekIdx, int dayIdx, bool isAlmoco, MealPlanEngine engine) {
    final newCost = engine.calculateRecipeCostPerPerson(recipe);
    final currentCost = currentMeal.custoEstimadoPorPessoa;
    final diff = newCost - currentCost;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _swapMeal(weekIdx, dayIdx, isAlmoco, recipe);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: _clusterColor(recipe.proteinCluster),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.nome,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B))),
                  Text(
                      '${formatCurrency(newCost)}/pessoa  |  ${recipe.tempoPreparacao} min',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: diff <= 0
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${diff >= 0 ? '+' : ''}${formatCurrency(diff)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: diff <= 0
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIngredientSheet(
      PlannedIngredient ingredient, PlannedMeal meal) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final ing = getIngredient(ingredient.ingredientId);

        // Find which meals in the current week use this ingredient
        final week = _plan?.semanas[_currentWeek];
        final usedIn = <String>[];
        if (week != null) {
          for (final day in week.dias) {
            for (final m in [day.almoco, day.jantar]) {
              if (m == null) continue;
              if (m.ingredientes
                  .any((i) => i.ingredientId == ingredient.ingredientId)) {
                if (!usedIn.contains(m.nomeReceita)) {
                  usedIn.add(m.nomeReceita);
                }
              }
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(ingredient.nome,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B))),
              const SizedBox(height: 12),
              _infoRow(
                  'Quantidade',
                  _formatQuantity(
                      ingredient.quantidade, ingredient.unidade),
                  Icons.scale),
              if (ing != null)
                _infoRow(
                    'Preco medio',
                    '${formatCurrency(ing.precoMedioUnitario)}/${ing.unidadeBase}',
                    Icons.euro),
              _infoRow('Preco estimado',
                  '~${formatCurrency(ingredient.precoEstimado)}', Icons.receipt_long),
              const SizedBox(height: 8),
              if (usedIn.isNotEmpty) ...[
                const Text('PRESENTE EM',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.0)),
                const SizedBox(height: 4),
                ...usedIn.map((name) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.restaurant,
                              size: 12, color: Color(0xFFCBD5E1)),
                          const SizedBox(width: 6),
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B))),
                        ],
                      ),
                    )),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Add this single ingredient to shopping list
                    _addSingleIngredientToList(ingredient);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label: const Text('Adicionar a Lista'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addSingleIngredientToList(PlannedIngredient ingredient) {
    if (_plan == null) return;
    final semana = _plan!.semanas[_currentWeek].semana;
    final currentList =
        _shoppingLists[semana] ?? ShoppingList(semana: semana);

    // Check if already in list
    if (currentList.items
        .any((i) => i.ingredientId == ingredient.ingredientId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrediente ja esta na lista.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final ing = getIngredient(ingredient.ingredientId);
    final minPurchase = ing?.quantidadeCompraMinima ?? ingredient.quantidade;
    final purchaseQty = (ingredient.quantidade / minPurchase).ceil() * minPurchase;
    final cost = (ing?.precoMedioUnitario ?? 0) * purchaseQty;

    final newItem = ShoppingListItem(
      ingredientId: ingredient.ingredientId,
      nome: ingredient.nome,
      categoria: ing?.categoria ?? IngredientCategory.outro,
      quantidadeNecessaria: ingredient.quantidade,
      quantidadeCompra: purchaseQty,
      unidade: ingredient.unidade,
      precoEstimado: cost,
      receitasQueUsam: [],
    );

    final updated =
        currentList.copyWith(items: [...currentList.items, newItem]);
    setState(() => _shoppingLists[semana] = updated);
    _service.saveShoppingList(semana, updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${ingredient.nome} adicionado a lista.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showRealCostInput(int weekIdx, double? currentValue) {
    final controller = TextEditingController(
      text: currentValue?.toStringAsFixed(2) ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Custo Real - Semana ${weekIdx + 1}',
            style: const TextStyle(fontSize: 16)),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: '0.00',
            suffixText: 'EUR',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(
                  controller.text.replaceAll(',', '.'));
              if (value != null) {
                _updateWeekRealCost(weekIdx, value);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────

  Widget _buildClusterBadge(ProteinCluster cluster) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _clusterColor(cluster).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        cluster.label,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _clusterColor(cluster)),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu_outlined,
                size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF64748B)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Color _clusterColor(ProteinCluster cluster) {
    switch (cluster) {
      case ProteinCluster.frango:
        return const Color(0xFFFBBF24);
      case ProteinCluster.ovos:
        return const Color(0xFF34D399);
      case ProteinCluster.carnePicada:
        return const Color(0xFFF87171);
      case ProteinCluster.leguminosas:
        return const Color(0xFF60A5FA);
      case ProteinCluster.peixeBarato:
        return const Color(0xFF38BDF8);
    }
  }

  String _clusterLetter(ProteinCluster cluster) {
    switch (cluster) {
      case ProteinCluster.frango:
        return 'F';
      case ProteinCluster.ovos:
        return 'O';
      case ProteinCluster.carnePicada:
        return 'C';
      case ProteinCluster.leguminosas:
        return 'L';
      case ProteinCluster.peixeBarato:
        return 'P';
    }
  }

  Color _budgetColor(double pct) {
    if (pct > 0.95) return const Color(0xFFEF4444);
    if (pct > 0.80) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  Color _desvioColor(double desvio) {
    if (desvio > 5) return const Color(0xFFEF4444);
    if (desvio > 0) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _formatQuantity(double qty, String unit) {
    if (unit == 'unidade' || unit == 'duzia') {
      if (qty == qty.roundToDouble()) {
        return '${qty.round()} $unit';
      }
      return '${qty.toStringAsFixed(1)} $unit';
    }
    if (qty < 1) {
      return '${(qty * 1000).round()} g';
    }
    return '${qty.toStringAsFixed(2)} $unit';
  }

  IconData _categoryIcon(String category) {
    final map = {
      'Proteinas': Icons.restaurant,
      'Carboidratos': Icons.rice_bowl,
      'Legumes e Verduras': Icons.eco,
      'Gorduras e Oleos': Icons.water_drop,
      'Lacticinios': Icons.egg,
      'Temperos': Icons.local_fire_department,
      'Frutas': Icons.nutrition,
      'Outros': Icons.category,
    };
    return map[category] ?? Icons.category;
  }
}
