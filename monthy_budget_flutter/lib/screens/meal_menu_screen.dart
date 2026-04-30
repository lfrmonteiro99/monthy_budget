import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

import '../models/app_settings.dart';
import '../models/meal_planner.dart';
import '../models/meal_settings.dart';
import '../models/purchase_record.dart';
import '../models/shopping_item.dart';
import '../services/meal_planner_service.dart';
import '../theme/app_colors.dart';
import 'meal_planner_screen.dart';

/// Compact 7×3 weekly meal-menu screen (Mockup #3 — Ementa).
///
/// Displays:
/// - [CalmPageHeader] with trailing [CalmActionPill] "Gerar".
/// - [CalmCard] containing a [CalmWeekGrid] (3 rows × 7 days = 21 cells).
/// - KPI summary card with 4 [CalmKpiRow]s.
///
/// Cell tap drills into the existing [MealPlannerScreen] (detail view).
/// "Gerar" navigates to [MealPlannerScreen] in regeneration mode.
class MealMenuScreen extends StatefulWidget {
  final AppSettings settings;
  final String apiKey;
  final List<String> favorites;
  final void Function(ShoppingItem) onAddToShoppingList;
  final String householdId;
  final ValueChanged<AppSettings> onSaveSettings;
  final VoidCallback onOpenMealSettings;
  final PurchaseHistory purchaseHistory;

  const MealMenuScreen({
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
  State<MealMenuScreen> createState() => _MealMenuScreenState();
}

class _MealMenuScreenState extends State<MealMenuScreen> {
  final _service = MealPlannerService();

  MealPlan? _plan;

  // Row indices: 0 = Pequeno-almoço, 1 = Almoço, 2 = Jantar
  static const _mealTypes = [
    MealType.breakfast,
    MealType.lunch,
    MealType.dinner,
  ];

  // Day labels PT — used directly because the global l10n keys are for
  // full names; these short 3-char labels are not in the existing arb files.
  // TODO(l10n): add weekdayShortSeg..Dom keys to the arb files.
  static const _dayLabels = [
    'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom',
  ];

  static const _mealRowLabels = ['Peq.', 'Almoço', 'Jantar'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await _service.loadCatalog();
      final now = DateTime.now();
      final saved =
          await _service.load(widget.householdId, now.month, now.year);
      if (!mounted) return;
      setState(() => _plan = saved);
    } catch (_) {
      if (!mounted) return;
      setState(() => _plan = null);
    }
  }

  // ── Grid cell text ──────────────────────────────────────────────────────

  /// Returns the display label for a given [mealType] on [dayIndex] (1-based,
  /// within the first 7 days = Mon–Sun of the plan's month).
  String _cellText(int dayIndex, MealType mealType) {
    final plan = _plan;
    if (plan == null) return '';
    final match = plan.days.where(
      (d) => d.dayIndex == dayIndex && d.mealType == mealType,
    );
    if (match.isEmpty) return '';
    final day = match.first;
    if (day.isFreeform) return day.freeformTitle ?? '';
    final recipe = _service.recipeMap[day.recipeId];
    return recipe?.name ?? '';
  }

  /// Build 7-cell list for [row] (0=Peq., 1=Almoço, 2=Jantar).
  List<String> _rowCells(int row) {
    final mealType = _mealTypes[row];
    // Day indices 1–7 map to Mon–Sun (first week of the plan).
    return List.generate(7, (d) => _cellText(d + 1, mealType));
  }

  // ── Selection: today's planned meals are highlighted ───────────────────

  Set<(int, int)> _selectedCells() {
    final plan = _plan;
    if (plan == null) return const {};
    final now = DateTime.now();
    // dayIndex in MealPlan is 1-based day-of-month.
    final todayIdx = now.day;
    // Column = dayIndex - 1 (0-based, first week). Only highlight if in 1-7.
    final col = todayIdx - 1;
    if (col < 0 || col > 6) return const {};
    final selected = <(int, int)>{};
    for (var row = 0; row < _mealTypes.length; row++) {
      final mealType = _mealTypes[row];
      final hasEntry = plan.days.any(
        (d) => d.dayIndex == todayIdx && d.mealType == mealType,
      );
      if (hasEntry) selected.add((row, col));
    }
    return selected;
  }

  // ── KPI computation ─────────────────────────────────────────────────────

  int _plannedCount() {
    final plan = _plan;
    if (plan == null) return 0;
    // First week: dayIndex 1–7, 3 meal types each = 21 slots.
    final weekDays = plan.days.where(
      (d) => d.dayIndex >= 1 && d.dayIndex <= 7,
    );
    // A slot counts as planned when it has a recipe or freeform title.
    return weekDays.where((d) {
      if (d.isFreeform) return (d.freeformTitle ?? '').isNotEmpty;
      return d.recipeId.isNotEmpty;
    }).length;
  }

  double _totalCost() {
    final plan = _plan;
    if (plan == null) return 0;
    return plan.days
        .where((d) => d.dayIndex >= 1 && d.dayIndex <= 7)
        .fold(0.0, (sum, d) => sum + d.costEstimate);
  }

  double _costPerPersonPerDay() {
    final plan = _plan;
    if (plan == null || plan.nPessoas == 0) return 0;
    final total = _totalCost();
    return total / 7 / plan.nPessoas;
  }

  int _outsideCount() {
    final plan = _plan;
    if (plan == null) return 0;
    // "Fora de casa" = freeform meals tagged or named to indicate eating out.
    // The plan model has no explicit out-of-house flag; we approximate by
    // counting freeform entries that have no shopping items (i.e. not home-cooked).
    // TODO: add an explicit `isOutside` flag to MealDay when the data model evolves.
    return plan.days
        .where((d) =>
            d.dayIndex >= 1 &&
            d.dayIndex <= 7 &&
            d.isFreeform &&
            d.freeformShoppingItems.isEmpty)
        .length;
  }

  String _fmtCost(double v) =>
      '€${v.toStringAsFixed(2).replaceAll('.', ',')}';

  // ── Navigation ──────────────────────────────────────────────────────────

  void _openDetail() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MealPlannerScreen(
          settings: widget.settings,
          apiKey: widget.apiKey,
          favorites: widget.favorites,
          onAddToShoppingList: widget.onAddToShoppingList,
          householdId: widget.householdId,
          onSaveSettings: widget.onSaveSettings,
          onOpenMealSettings: widget.onOpenMealSettings,
          purchaseHistory: widget.purchaseHistory,
        ),
      ),
    );
  }

  void _onCellTap(int row, int day) {
    // Row 0=breakfast, 1=lunch, 2=dinner; day 0-based within the first week.
    // Navigate to the detail screen; it does not currently accept a
    // pre-selected cell, so we just open it at the root.
    // TODO: when MealPlannerScreen exposes an `initialDayIndex` / `initialMealType`
    // parameter, forward row/day here.
    _openDetail();
  }

  void _onGerar() {
    // Navigate to detail screen — MealPlannerScreen handles the wizard and
    // the "generate" flow internally via its own _generatePlan() method.
    _openDetail();
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Always render the full structure. While the plan is still loading the
    // helper counts return 0 and `_rowCells` returns empty strings, so the
    // grid + KPI sections show a graceful empty state instead of a spinner —
    // keeps the layout stable, lets widget tests assert on static structure
    // without waiting for platform channels to wire up.
    return CalmScaffold(
      bodyPadding: EdgeInsets.zero,
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final planned = _plannedCount();
    final total = _totalCost();
    final perPersonDay = _costPerPersonPerDay();
    final outside = _outsideCount();

    final weekGrid = CalmWeekGrid(
      days: _dayLabels,
      rows: List.generate(
        3,
        (i) => CalmWeekGridRow(
          label: _mealRowLabels[i],
          cells: _rowCells(i),
        ),
      ),
      selected: _selectedCells(),
      onCellTap: _onCellTap,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // ── Header ──────────────────────────────────────────────────────
        CalmPageHeader(
          eyebrow: 'ESTA SEMANA', // TODO(l10n): add key thisWeekEyebrow
          title: 'Ementa', // TODO(l10n): add key ementaTitle
          trailing: CalmActionPill(
            icon: Icons.auto_awesome,
            label: 'Gerar', // TODO(l10n): add key generateLabel
            onTap: _onGerar,
          ),
        ),

        const SizedBox(height: 24),

        // ── 7×3 grid ────────────────────────────────────────────────────
        CalmCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: weekGrid,
        ),

        const SizedBox(height: 24),

        // ── KPI section eyebrow ──────────────────────────────────────────
        CalmEyebrow('RESUMO · SEMANA'), // TODO(l10n): add key weekSummaryEyebrow

        const SizedBox(height: 8),

        // ── KPI rows card ────────────────────────────────────────────────
        CalmCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TODO(l10n): keys for KPI labels
              CalmKpiRow(
                'Refeições planeadas',
                '$planned de 21',
              ),
              Divider(color: AppColors.line(context), height: 1),
              CalmKpiRow(
                'Custo estimado',
                _fmtCost(total),
              ),
              Divider(color: AppColors.line(context), height: 1),
              CalmKpiRow(
                'Custo/pessoa/dia',
                _fmtCost(perPersonDay),
              ),
              Divider(color: AppColors.line(context), height: 1),
              CalmKpiRow(
                'Fora de casa',
                '$outside ${outside == 1 ? 'refeição' : 'refeições'}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
