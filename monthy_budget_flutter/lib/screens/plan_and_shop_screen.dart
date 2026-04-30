import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../models/app_settings.dart';
import '../models/grocery_data.dart';
import '../models/meal_planner.dart';
import '../models/product.dart';
import '../models/purchase_record.dart';
import '../models/shopping_item.dart';
import '../services/barcode_scan_service.dart';
import '../services/meal_planner_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'grocery_screen.dart';
// TODO(M3/issue-952): replace MealPlannerScreen with MealMenuScreen once #952 merges.
import 'meal_planner_screen.dart';
import 'shopping_list_screen.dart';

/// ISO 8601 week-of-year helper.
int _isoWeekNumber(DateTime date) {
  // Shift to Thursday of the same week (ISO week is determined by Thursday).
  final thursday = date.add(Duration(days: 3 - (date.weekday - 1) % 7));
  final startOfYear = DateTime(thursday.year);
  final ordinal = thursday.difference(startOfYear).inDays + 1;
  return ((ordinal - 1) ~/ 7) + 1;
}

class PlanAndShopScreen extends StatefulWidget {
  // Shopping List params — kept for app_home.dart compatibility (Wave N cleanup).
  final List<ShoppingItem> shoppingItems;
  final ValueChanged<ShoppingItem> onToggleChecked;
  final ValueChanged<ShoppingItem> onRemove;
  final VoidCallback onClearChecked;
  final void Function(double? amount, List<ShoppingItem> checkedItems,
      {bool isMealPurchase}) onFinalize;
  final PurchaseHistory purchaseHistory;
  final ValueChanged<ShoppingItem>? onAddToShoppingList;
  final ValueChanged<ShoppingItem>? onMarkAtHome;
  final BarcodeScanService? barcodeScanService;

  // Grocery params — kept for app_home.dart compatibility (Wave N cleanup).
  final List<Product> products;
  final GroceryData? groceryData;
  final bool groceryLoading;
  final Set<String> weeklyPantryIds;
  final ValueChanged<String>? onToggleWeeklyPantry;

  // Meal Planner params — kept for app_home.dart compatibility (Wave N cleanup).
  final AppSettings settings;
  final String apiKey;
  final List<String> favorites;
  final String householdId;
  final ValueChanged<AppSettings> onSaveSettings;
  final VoidCallback onOpenMealSettings;

  // Tour params — kept for app_home.dart compatibility (Wave N cleanup).
  final bool showShoppingTour;
  final VoidCallback? onShoppingTourComplete;
  final bool showGroceryTour;
  final VoidCallback? onGroceryTourComplete;
  final bool showMealsTour;
  final VoidCallback? onMealsTourComplete;

  // Premium gate
  final bool canAccessMeals;

  const PlanAndShopScreen({
    super.key,
    required this.shoppingItems,
    required this.onToggleChecked,
    required this.onRemove,
    required this.onClearChecked,
    required this.onFinalize,
    required this.purchaseHistory,
    this.onAddToShoppingList,
    this.onMarkAtHome,
    this.barcodeScanService,
    required this.products,
    this.groceryData,
    this.groceryLoading = false,
    this.weeklyPantryIds = const {},
    this.onToggleWeeklyPantry,
    required this.settings,
    required this.apiKey,
    required this.favorites,
    required this.householdId,
    required this.onSaveSettings,
    required this.onOpenMealSettings,
    this.showShoppingTour = false,
    this.onShoppingTourComplete,
    this.showGroceryTour = false,
    this.onGroceryTourComplete,
    this.showMealsTour = false,
    this.onMealsTourComplete,
    this.canAccessMeals = true,
  });

  @override
  State<PlanAndShopScreen> createState() => _PlanAndShopScreenState();
}

class _PlanAndShopScreenState extends State<PlanAndShopScreen> {
  final _service = MealPlannerService();

  MealPlan? _plan;
  bool _planLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  void didUpdateWidget(covariant PlanAndShopScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.householdId != widget.householdId) {
      _loadPlan();
    }
  }

  Future<void> _loadPlan() async {
    setState(() => _planLoading = true);
    try {
      await _service.loadCatalog();
      final now = DateTime.now();
      final plan = await _service.load(widget.householdId, now.month, now.year);
      if (mounted) setState(() {
        _plan = plan;
        _planLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _planLoading = false);
    }
  }

  // ─── Navigation helpers ──────────────────────────────────────────────────

  void _openLista(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ShoppingListScreen(
          embedded: false,
          items: widget.shoppingItems,
          onToggleChecked: widget.onToggleChecked,
          onRemove: widget.onRemove,
          onClearChecked: widget.onClearChecked,
          onFinalize: widget.onFinalize,
          purchaseHistory: widget.purchaseHistory,
          onAddToShoppingList: widget.onAddToShoppingList,
          barcodeScanService: widget.barcodeScanService,
          onMarkAtHome: widget.onMarkAtHome,
          showTour: widget.showShoppingTour,
          onTourComplete: widget.onShoppingTourComplete,
        ),
      ),
    );
  }

  void _openEmenta(BuildContext context) {
    // TODO(M3/issue-952): replace with MealMenuScreen once #952 merges.
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => MealPlannerScreen(
          embedded: false,
          settings: widget.settings,
          apiKey: widget.apiKey,
          favorites: widget.favorites,
          onAddToShoppingList: widget.onAddToShoppingList ?? (_) {},
          householdId: widget.householdId,
          onSaveSettings: widget.onSaveSettings,
          onOpenMealSettings: widget.onOpenMealSettings,
          purchaseHistory: widget.purchaseHistory,
          showTour: widget.showMealsTour,
          onTourComplete: widget.onMealsTourComplete,
        ),
      ),
    );
  }

  void _openDespensa(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => GroceryScreen(
          embedded: false,
          products: widget.products,
          groceryData: widget.groceryData,
          isLoading: widget.groceryLoading,
          onAddToShoppingList: widget.onAddToShoppingList,
          weeklyPantryIds: widget.weeklyPantryIds,
          onToggleWeeklyPantry: widget.onToggleWeeklyPantry,
          showTour: widget.showGroceryTour,
          onTourComplete: widget.onGroceryTourComplete,
        ),
      ),
    );
  }

  // ─── Data helpers ─────────────────────────────────────────────────────────

  /// Returns the next 3 upcoming meal slots from the current week's plan.
  /// "Upcoming" = today's remaining + tomorrow's meals, capped at 3.
  List<_MealPreviewRow> _nextMeals() {
    final plan = _plan;
    if (plan == null || plan.days.isEmpty) return [];

    final today = DateTime.now();
    // dayIndex in the plan is 0-based relative to plan generation week.
    // Use today's weekday (Mon=1…Sun=7). Plans are generated Mon-Sun (0-6).
    final todayIdx = today.weekday - 1; // 0=Mon … 6=Sun

    // Sort days: upcoming first (today onwards), then wrap-around if needed.
    final sorted = [...plan.days]
      ..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));

    final preview = <_MealPreviewRow>[];
    for (final day in sorted) {
      if (preview.length >= 3) break;
      if (day.dayIndex < todayIdx) continue;
      if (day.recipeId.isEmpty && !day.isFreeform) continue;

      final recipeName = day.isFreeform
          ? (day.freeformTitle ?? '—')
          : (_service.recipeMap[day.recipeId]?.name ?? '—');

      final eyebrowDay = _dayLabel(day.dayIndex, todayIdx, today);
      final eyebrow = '$eyebrowDay · ${day.mealType.label}';
      final meta = day.costEstimate > 0
          ? formatCurrency(day.costEstimate)
          : '';

      preview.add(_MealPreviewRow(
        eyebrow: eyebrow,
        title: recipeName,
        meta: meta,
      ));
    }
    return preview;
  }

  String _dayLabel(int dayIndex, int todayIdx, DateTime today) {
    if (dayIndex == todayIdx) return 'Hoje';
    if (dayIndex == todayIdx + 1) return 'Amanhã';
    // Return abbreviated weekday name
    const names = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return names[dayIndex % 7];
  }

  // ─── Budget helpers ───────────────────────────────────────────────────────

  double get _weeklyBudget => _plan != null
      ? (_plan!.monthlyBudget / 4.33)
      : 0.0;

  double get _weeklySpent {
    final plan = _plan;
    if (plan == null) return 0.0;
    final today = DateTime.now();
    final todayIdx = today.weekday - 1;
    // Sum costs of days up to and including today.
    return plan.days
        .where((d) => d.dayIndex <= todayIdx)
        .fold(0.0, (s, d) => s + d.costEstimate);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final weekNum = _isoWeekNumber(DateTime.now());

    return CalmScaffold(
      bodyPadding: EdgeInsets.zero,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // 1. Page header ─────────────────────────────────────────────────
          CalmPageHeader(
            eyebrow: 'SEMANA $weekNum',
            title: 'Plano & compras',
          ),

          // 2. Hero budget card ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildHeroCard(context),
          ),
          const SizedBox(height: 16),

          // 3. 3-tile row ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTileRow(context),
          ),
          const SizedBox(height: 16),

          // 4. Upcoming meals card ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildMealsCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    if (_planLoading) {
      return CalmCard(
        child: Center(
          child: SizedBox(
            height: 80,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent(context),
              ),
            ),
          ),
        ),
      );
    }

    if (_plan == null) {
      return CalmCard(
        child: CalmEmptyState(
          icon: Icons.restaurant_outlined,
          title: 'Sem ementa esta semana',
          body: 'Abre a Ementa para gerar o teu plano semanal.',
        ),
      );
    }

    final budget = _weeklyBudget;
    final spent = _weeklySpent;
    final remaining = (budget - spent).clamp(0.0, double.infinity);
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalmHero(
            eyebrow: 'ORÇAMENTO SEMANAL',
            amount: formatCurrency(budget),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.line(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.accent(context),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _kpiLabel(context, 'Planeado', formatCurrency(spent)),
              _kpiLabel(context, 'Restante', formatCurrency(remaining),
                  alignRight: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpiLabel(BuildContext context, String label, String value,
      {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: AppColors.ink50(context))),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.ink(context))),
      ],
    );
  }

  Widget _buildTileRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CalmTile(
            icon: Icons.shopping_basket_outlined,
            label: 'Lista',
            count: '${widget.shoppingItems.length} itens',
            onTap: () => _openLista(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CalmTile(
            icon: Icons.restaurant_menu_outlined,
            label: 'Ementa',
            count: _plan != null
                ? '${_plan!.days.length} refeições'
                : 'sem plano',
            onTap: widget.canAccessMeals ? () => _openEmenta(context) : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CalmTile(
            icon: Icons.kitchen_outlined,
            label: 'Despensa',
            count: '${widget.weeklyPantryIds.length} itens',
            onTap: () => _openDespensa(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMealsCard(BuildContext context) {
    final meals = _nextMeals();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CalmEyebrow('PRÓXIMAS REFEIÇÕES'),
        ),
        CalmCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: meals.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CalmEmptyState(
                    icon: Icons.calendar_today_outlined,
                    title: 'Sem refeições planeadas',
                    body: _plan == null
                        ? 'Cria uma ementa para ver as próximas refeições.'
                        : 'Nenhuma refeição próxima encontrada.',
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < meals.length; i++) ...[
                      CalmMealRow(
                        eyebrow: meals[i].eyebrow,
                        title: meals[i].title,
                        meta: meals[i].meta,
                      ),
                      if (i < meals.length - 1)
                        Divider(
                          color: AppColors.line(context),
                          height: 1,
                          indent: 60,
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

/// Internal data class for the meal preview rows.
class _MealPreviewRow {
  const _MealPreviewRow({
    required this.eyebrow,
    required this.title,
    required this.meta,
  });

  final String eyebrow;
  final String title;
  final String meta;
}
