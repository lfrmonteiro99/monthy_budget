# Expense History & Dashboard Config — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Track monthly expense snapshots in Supabase, show historical trends (total + stacked by category) in the trend sheet, and make all dashboard sections toggleable via per-device local settings (SharedPreferences).

**Architecture:** New `expense_snapshots` Supabase table auto-populated on Dashboard render. New `LocalDashboardConfig` stored in SharedPreferences replaces the household-level `DashboardConfig`. Trend sheet updated to show total expenses and category breakdown using stacked bar charts. Stress index calculation unchanged.

**Tech Stack:** Flutter, Supabase (Dart client), SharedPreferences, fl_chart

---

### Task 1: Create Supabase table and RLS

**Files:**
- Modify: `supabase/schema.sql` (append at end)

**Context:** The app uses a `my_household_id()` function for RLS. All tables follow the same pattern. The `expense_snapshots` table needs read/write for all household members (same as `purchase_records`).

**Step 1: Add the table and policies to schema.sql**

Append to the end of `supabase/schema.sql` (after line 151), before the realtime section or at the very end:

```sql
-- ─── Expense Snapshots ──────────────────────────────────────
create table expense_snapshots (
  id            uuid primary key default gen_random_uuid(),
  household_id  uuid not null references households(id) on delete cascade,
  month         text not null,
  expense_id    text not null,
  label         text not null,
  category      text not null,
  amount        double precision not null,
  enabled       boolean not null default true,
  created_at    timestamptz default now(),
  unique(household_id, month, expense_id)
);

alter table expense_snapshots enable row level security;

create policy "read snapshots"   on expense_snapshots for select using (household_id = my_household_id());
create policy "insert snapshots" on expense_snapshots for insert with check (household_id = my_household_id());
create policy "update snapshots" on expense_snapshots for update using (household_id = my_household_id());
```

**Step 2: Run this SQL in Supabase dashboard**

The user must run the SQL above manually in the Supabase SQL Editor. There's no migration system — schema.sql is documentation only.

**Step 3: Verify**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter analyze supabase/`
Expected: N/A (SQL file, no Dart analysis). Just confirm the file was saved correctly.

---

### Task 2: Create the ExpenseSnapshot model

**Files:**
- Create: `lib/models/expense_snapshot.dart`

**Context:** Simple data class mirroring the Supabase columns. Needs `fromJson` for reading DB rows and a grouping helper.

**Step 1: Create the model file**

Create `lib/models/expense_snapshot.dart`:

```dart
class ExpenseSnapshot {
  final String expenseId;
  final String label;
  final String category;
  final double amount;
  final bool enabled;

  const ExpenseSnapshot({
    required this.expenseId,
    required this.label,
    required this.category,
    required this.amount,
    required this.enabled,
  });

  factory ExpenseSnapshot.fromJson(Map<String, dynamic> json) => ExpenseSnapshot(
        expenseId: json['expense_id'] as String,
        label: json['label'] as String,
        category: json['category'] as String,
        amount: (json['amount'] as num).toDouble(),
        enabled: json['enabled'] as bool? ?? true,
      );
}
```

**Step 2: Verify**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter analyze lib/models/expense_snapshot.dart`
Expected: No errors.

---

### Task 3: Create the ExpenseSnapshotService

**Files:**
- Create: `lib/services/expense_snapshot_service.dart`

**Context:** Follows the same pattern as `PurchaseHistoryService` and `SettingsService`. Uses Supabase client directly. Two methods: `snapshotIfNeeded` (upsert current month) and `loadHistory` (fetch last N months grouped by month key).

**Step 1: Create the service file**

Create `lib/services/expense_snapshot_service.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_settings.dart';
import '../models/expense_snapshot.dart';

class ExpenseSnapshotService {
  final _client = Supabase.instance.client;

  /// Upserts expense snapshots for the given month if they differ from current values.
  Future<void> snapshotIfNeeded(
    String householdId,
    String month,
    List<ExpenseItem> expenses,
  ) async {
    // Check if snapshot already exists for this month
    final existing = await _client
        .from('expense_snapshots')
        .select('expense_id, amount, enabled')
        .eq('household_id', householdId)
        .eq('month', month);

    final existingMap = <String, Map<String, dynamic>>{};
    for (final row in existing) {
      existingMap[row['expense_id'] as String] = row;
    }

    // Build list of rows that need upsert
    final toUpsert = <Map<String, dynamic>>[];
    for (final e in expenses) {
      final ex = existingMap[e.id];
      if (ex == null ||
          (ex['amount'] as num).toDouble() != e.amount ||
          (ex['enabled'] as bool) != e.enabled) {
        toUpsert.add({
          'household_id': householdId,
          'month': month,
          'expense_id': e.id,
          'label': e.label,
          'category': e.category.name,
          'amount': e.amount,
          'enabled': e.enabled,
        });
      }
    }

    if (toUpsert.isNotEmpty) {
      await _client
          .from('expense_snapshots')
          .upsert(toUpsert, onConflict: 'household_id,month,expense_id');
    }
  }

  /// Loads expense snapshots for the last [months] months, grouped by month key.
  Future<Map<String, List<ExpenseSnapshot>>> loadHistory(
    String householdId, {
    int months = 12,
  }) async {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - months + 1);
    final cutoffKey = '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}';

    final rows = await _client
        .from('expense_snapshots')
        .select()
        .eq('household_id', householdId)
        .gte('month', cutoffKey)
        .order('month', ascending: true);

    final result = <String, List<ExpenseSnapshot>>{};
    for (final row in rows) {
      final month = row['month'] as String;
      result.putIfAbsent(month, () => []);
      result[month]!.add(ExpenseSnapshot.fromJson(row));
    }
    return result;
  }
}
```

**Step 2: Verify**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter analyze lib/services/expense_snapshot_service.dart`
Expected: No errors.

---

### Task 4: Create LocalDashboardConfig model and service

**Files:**
- Create: `lib/models/local_dashboard_config.dart`
- Create: `lib/services/local_config_service.dart`

**Context:** This replaces the `DashboardConfig` class that currently lives in `AppSettings` (household-level). The new config is stored per-device in SharedPreferences. The app already has `shared_preferences: ^2.5.0` in pubspec.yaml.

**Step 1: Create the model file**

Create `lib/models/local_dashboard_config.dart`:

```dart
import 'dart:convert';
import 'app_settings.dart';

class LocalDashboardConfig {
  final bool showHeroCard;
  final bool showStressIndex;
  final bool showSummaryCards;
  final bool showSalaryBreakdown;
  final bool showFoodSpending;
  final bool showPurchaseHistory;
  final bool showExpensesBreakdown;
  final bool showCharts;
  final List<ChartType> enabledCharts;

  const LocalDashboardConfig({
    this.showHeroCard = true,
    this.showStressIndex = true,
    this.showSummaryCards = true,
    this.showSalaryBreakdown = true,
    this.showFoodSpending = true,
    this.showPurchaseHistory = true,
    this.showExpensesBreakdown = true,
    this.showCharts = true,
    this.enabledCharts = const [
      ChartType.expensesPie,
      ChartType.incomeVsExpenses,
      ChartType.deductionsBreakdown,
      ChartType.savingsRate,
    ],
  });

  LocalDashboardConfig copyWith({
    bool? showHeroCard,
    bool? showStressIndex,
    bool? showSummaryCards,
    bool? showSalaryBreakdown,
    bool? showFoodSpending,
    bool? showPurchaseHistory,
    bool? showExpensesBreakdown,
    bool? showCharts,
    List<ChartType>? enabledCharts,
  }) {
    return LocalDashboardConfig(
      showHeroCard: showHeroCard ?? this.showHeroCard,
      showStressIndex: showStressIndex ?? this.showStressIndex,
      showSummaryCards: showSummaryCards ?? this.showSummaryCards,
      showSalaryBreakdown: showSalaryBreakdown ?? this.showSalaryBreakdown,
      showFoodSpending: showFoodSpending ?? this.showFoodSpending,
      showPurchaseHistory: showPurchaseHistory ?? this.showPurchaseHistory,
      showExpensesBreakdown: showExpensesBreakdown ?? this.showExpensesBreakdown,
      showCharts: showCharts ?? this.showCharts,
      enabledCharts: enabledCharts ?? this.enabledCharts,
    );
  }

  Map<String, dynamic> toJson() => {
        'showHeroCard': showHeroCard,
        'showStressIndex': showStressIndex,
        'showSummaryCards': showSummaryCards,
        'showSalaryBreakdown': showSalaryBreakdown,
        'showFoodSpending': showFoodSpending,
        'showPurchaseHistory': showPurchaseHistory,
        'showExpensesBreakdown': showExpensesBreakdown,
        'showCharts': showCharts,
        'enabledCharts': enabledCharts.map((c) => c.jsonValue).toList(),
      };

  factory LocalDashboardConfig.fromJson(Map<String, dynamic> json) {
    return LocalDashboardConfig(
      showHeroCard: json['showHeroCard'] ?? true,
      showStressIndex: json['showStressIndex'] ?? true,
      showSummaryCards: json['showSummaryCards'] ?? true,
      showSalaryBreakdown: json['showSalaryBreakdown'] ?? true,
      showFoodSpending: json['showFoodSpending'] ?? true,
      showPurchaseHistory: json['showPurchaseHistory'] ?? true,
      showExpensesBreakdown: json['showExpensesBreakdown'] ?? true,
      showCharts: json['showCharts'] ?? true,
      enabledCharts: (json['enabledCharts'] as List<dynamic>?)
              ?.map((e) => ChartType.fromJson(e as String))
              .toList() ??
          const [
            ChartType.expensesPie,
            ChartType.incomeVsExpenses,
            ChartType.deductionsBreakdown,
            ChartType.savingsRate,
          ],
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory LocalDashboardConfig.fromJsonString(String s) {
    try {
      return LocalDashboardConfig.fromJson(jsonDecode(s) as Map<String, dynamic>);
    } catch (_) {
      return const LocalDashboardConfig();
    }
  }
}
```

**Step 2: Create the service file**

Create `lib/services/local_config_service.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/local_dashboard_config.dart';

class LocalConfigService {
  static const _key = 'dashboard_config';

  Future<LocalDashboardConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return const LocalDashboardConfig();
    return LocalDashboardConfig.fromJsonString(json);
  }

  Future<void> save(LocalDashboardConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, config.toJsonString());
  }
}
```

**Step 3: Verify**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter analyze lib/models/local_dashboard_config.dart lib/services/local_config_service.dart`
Expected: No errors.

---

### Task 5: Wire services into main.dart

**Files:**
- Modify: `lib/main.dart`

**Context:** `_AppHomeState` currently holds all services and state. We need to add `ExpenseSnapshotService`, `LocalConfigService`, and their state variables. Load them in `_loadAll()` and `_refreshData()`. Pass `LocalDashboardConfig` to `DashboardScreen` and `SettingsScreen`.

**Step 1: Add imports**

At the top of `lib/main.dart` (after line 18 — the `household_service` import), add:

```dart
import 'services/expense_snapshot_service.dart';
import 'services/local_config_service.dart';
import 'models/local_dashboard_config.dart';
import 'models/expense_snapshot.dart';
```

**Step 2: Add service instances and state fields**

In `_AppHomeState` (after line 76 — `_productsService`), add:

```dart
  final _expenseSnapshotService = ExpenseSnapshotService();
  final _localConfigService = LocalConfigService();
```

After line 84 (`_purchaseHistory`), add:

```dart
  LocalDashboardConfig _dashboardConfig = const LocalDashboardConfig();
  Map<String, List<ExpenseSnapshot>> _expenseHistory = {};
```

**Step 3: Load in `_loadAll()`**

In `_loadAll()` (line 129), the existing `Future.wait` loads 6 things. Add `_localConfigService.load()` as item 7. Then after the existing `setState`:

After `_loaded = true;` (line 145), still inside `setState`, add:

```dart
      _dashboardConfig = results[6] as LocalDashboardConfig;
```

And add `_localConfigService.load()` to the `Future.wait` list (after `_productsService.load()`).

Then **after** the `setState` block (after line 147), add a separate call to load expense history (it requires `householdId` and doesn't block init):

```dart
    _expenseSnapshotService.loadHistory(widget.householdId).then((history) {
      if (mounted) setState(() => _expenseHistory = history);
    });
```

**Step 4: Add local config save callback**

After `_saveSettings` (line 153), add:

```dart
  void _saveDashboardConfig(LocalDashboardConfig config) {
    setState(() => _dashboardConfig = config);
    _localConfigService.save(config);
  }
```

**Step 5: Add snapshot trigger callback**

After the new `_saveDashboardConfig`, add:

```dart
  void _snapshotExpenses() {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _expenseSnapshotService
        .snapshotIfNeeded(widget.householdId, monthKey, _settings.expenses)
        .then((_) => _expenseSnapshotService.loadHistory(widget.householdId))
        .then((history) {
      if (mounted) setState(() => _expenseHistory = history);
    });
  }
```

**Step 6: Update `_refreshData()` to reload expense history**

In `_refreshData()`, after the existing `setState` (line 126), add:

```dart
    _expenseSnapshotService.loadHistory(widget.householdId).then((history) {
      if (mounted) setState(() => _expenseHistory = history);
    });
```

**Step 7: Pass new params to DashboardScreen**

In the `screens` list (line 304), update the `DashboardScreen` constructor. Add these params:

```dart
        dashboardConfig: _dashboardConfig,
        expenseHistory: _expenseHistory,
        onSnapshotExpenses: _snapshotExpenses,
```

**Step 8: Pass new params to SettingsScreen**

In `_buildSettingsScreen()` (line 260), add:

```dart
      dashboardConfig: _dashboardConfig,
      onSaveDashboardConfig: _saveDashboardConfig,
```

Do the same for the inline `SettingsScreen` in the MealPlanner's `onOpenMealSettings` callback (line 348).

**Step 9: Verify**

This will NOT compile yet — `DashboardScreen` and `SettingsScreen` don't accept these params yet. That's expected. We'll fix them in Tasks 6 and 7.

---

### Task 6: Update DashboardScreen

**Files:**
- Modify: `lib/screens/dashboard_screen.dart`

**Context:** The Dashboard needs to accept `LocalDashboardConfig` + `expenseHistory` + `onSnapshotExpenses`, use the config flags for visibility, and trigger expense snapshots in the postFrameCallback.

**Step 1: Add imports**

At the top of `lib/screens/dashboard_screen.dart`, add after existing imports:

```dart
import '../models/local_dashboard_config.dart';
import '../models/expense_snapshot.dart';
```

**Step 2: Add fields to DashboardScreen constructor**

Add these fields to the `DashboardScreen` class (after `onSaveSettings`, line 14):

```dart
  final LocalDashboardConfig dashboardConfig;
  final Map<String, List<ExpenseSnapshot>> expenseHistory;
  final VoidCallback onSnapshotExpenses;
```

And their `required` params in the constructor.

**Step 3: Trigger expense snapshot in the postFrameCallback**

In `build()`, the existing `addPostFrameCallback` (line 41) saves `stressHistory`. Add the expense snapshot call in the same callback, after the stressHistory save:

```dart
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // existing stressHistory save
        ...
        onSnapshotExpenses();
      });
```

**Important:** Move the `onSnapshotExpenses()` call to fire unconditionally in `addPostFrameCallback` (not just when stress score changes). The service internally checks if the snapshot is stale.

**Step 4: Apply visibility flags**

Replace all existing conditional sections with `dashboardConfig` flags:

In the dashboard body (line 112 onwards), change:

```dart
// Before:
if (settings.dashboardConfig.showSummaryCards) _buildSummaryCards(),

// After — use local config:
if (dashboardConfig.showHeroCard) _buildHeroCard(isPositive) else _buildEmptyState(),
// ... (apply same pattern for each section)
```

Full list of changes in the `if (hasData)` block:

```dart
              if (hasData) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      if (dashboardConfig.showStressIndex)
                        _StressIndexCard(
                          result: stressResult,
                          onShowTrend: stressResult.score > 0 ? () {
                            showTrendSheet(
                              context: context,
                              stressHistory: settings.stressHistory,
                              expenseHistory: expenseHistory,
                              currentTotalExpenses: summary.totalExpenses,
                            );
                          } : null,
                        ),
                      if (dashboardConfig.showStressIndex) const SizedBox(height: 16),
                      if (dashboardConfig.showSummaryCards) _buildSummaryCards(),
                      if (dashboardConfig.showSummaryCards) const SizedBox(height: 16),
                      if (dashboardConfig.showSalaryBreakdown) _buildSalaryBreakdown(),
                      if (dashboardConfig.showFoodSpending) _buildFoodSpendingCard(context),
                      if (dashboardConfig.showPurchaseHistory && purchaseHistory.records.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildPurchaseHistoryCard(context),
                      ],
                      if (dashboardConfig.showExpensesBreakdown && summary.totalExpenses > 0) ...[
                        const SizedBox(height: 16),
                        _buildExpensesBreakdown(),
                      ],
                      if (dashboardConfig.showCharts) ...[
                        const SizedBox(height: 16),
                        BudgetCharts(
                          summary: summary,
                          expenses: settings.expenses,
                          enabledCharts: dashboardConfig.enabledCharts,
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
```

Note the `BudgetCharts` now reads `enabledCharts` from `dashboardConfig` (local) instead of `settings.dashboardConfig` (household).

Also note the hero card section (line 107) should also be wrapped:

```dart
if (hasData && dashboardConfig.showHeroCard) _buildHeroCard(isPositive)
else if (!hasData) _buildEmptyState(),
```

**Step 5: Update showTrendSheet call signature**

The trend sheet call now passes `expenseHistory` instead of `spendingByMonth` + `currentFoodBudget`. This will be compiled in Task 8 when we update the trend sheet.

**Step 6: Verify partial compilation**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter analyze lib/screens/dashboard_screen.dart`
Expected: Errors about `showTrendSheet` signature mismatch — will be fixed in Task 8.

---

### Task 7: Update SettingsScreen — replace household DashboardConfig with local config

**Files:**
- Modify: `lib/screens/settings_screen.dart`

**Context:** The settings screen currently reads/writes `DashboardConfig` from `_draft` (AppSettings). It needs to read/write `LocalDashboardConfig` instead, using a separate callback. The dashboard section already exists (line 755) — we just need to expand it with all the new toggle fields and change the data source.

**Step 1: Add new constructor params**

Add to `SettingsScreen` (after `initialSection`, line 20):

```dart
  final LocalDashboardConfig? dashboardConfig;
  final ValueChanged<LocalDashboardConfig>? onSaveDashboardConfig;
```

Make them nullable with defaults so existing callsites that don't pass them still compile.

**Step 2: Add local state in _SettingsScreenState**

After `_openSection` (line 44), add:

```dart
  late LocalDashboardConfig _localDashboard;
```

In `initState()`, after the existing initialization (line 54), add:

```dart
    _localDashboard = widget.dashboardConfig ?? const LocalDashboardConfig();
```

**Step 3: Rewrite `_buildDashboardSection()` (line 755)**

Replace the entire method with expanded toggles. Every section from the dashboard gets a toggle:

```dart
  Widget _buildDashboardSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_android, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Estas definições são guardadas neste dispositivo.',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _label('SECÇÕES VISÍVEIS'),
          const SizedBox(height: 8),
          _dashToggle('Liquidez mensal', _localDashboard.showHeroCard,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showHeroCard: v))),
          _dashToggle('Índice de Tranquilidade', _localDashboard.showStressIndex,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showStressIndex: v))),
          _dashToggle('Cartões de resumo', _localDashboard.showSummaryCards,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showSummaryCards: v))),
          _dashToggle('Detalhe por vencimento', _localDashboard.showSalaryBreakdown,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showSalaryBreakdown: v))),
          _dashToggle('Alimentação', _localDashboard.showFoodSpending,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showFoodSpending: v))),
          _dashToggle('Histórico de compras', _localDashboard.showPurchaseHistory,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showPurchaseHistory: v))),
          _dashToggle('Breakdown despesas', _localDashboard.showExpensesBreakdown,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showExpensesBreakdown: v))),
          _dashToggle('Gráficos', _localDashboard.showCharts,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showCharts: v))),
          if (_localDashboard.showCharts) ...[
            const SizedBox(height: 16),
            _label('GRÁFICOS VISÍVEIS'),
            const SizedBox(height: 8),
            ...ChartType.values.map((chart) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(chart.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                  value: _localDashboard.enabledCharts.contains(chart),
                  activeColor: const Color(0xFF3B82F6),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (_) {
                    final enabled = List<ChartType>.from(_localDashboard.enabledCharts);
                    if (enabled.contains(chart)) {
                      enabled.remove(chart);
                    } else {
                      enabled.add(chart);
                    }
                    setState(() => _localDashboard = _localDashboard.copyWith(enabledCharts: enabled));
                  },
                )),
          ],
        ],
      ),
    );
  }

  Widget _dashToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
      value: value,
      activeTrackColor: const Color(0xFF3B82F6),
      onChanged: onChanged,
    );
  }
```

**Step 4: Update `_handleSave()` to save local dashboard config**

In `_handleSave()` (line 78), after the existing saves (line 89), add:

```dart
    widget.onSaveDashboardConfig?.call(_localDashboard);
```

**Step 5: Remove the `_toggleChart` method (line 157)**

Delete the old `_toggleChart` method — it's been replaced by the inline chart toggle logic in `_buildDashboardSection()`.

**Step 6: Remove old `dashboardConfig` references from `_handleSave()`**

The `widget.onSave(_draft)` call still saves `_draft` (AppSettings) which includes `dashboardConfig`. That's fine — it won't break anything since the field is still in AppSettings. We keep it for backwards compat but it's no longer read by the Dashboard.

**Step 7: Add import for LocalDashboardConfig**

At the top of `settings_screen.dart`, add:

```dart
import '../models/local_dashboard_config.dart';
```

**Step 8: Verify**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter analyze lib/screens/settings_screen.dart`
Expected: No errors.

---

### Task 8: Update the Trend Sheet — expense history charts

**Files:**
- Modify: `lib/widgets/trend_sheet.dart`

**Context:** Currently shows 2 charts: stress index line chart + food spending bar chart. Replace the food spending bar chart with: (1) total expenses bar chart, (2) stacked category bar chart. Data source changes from `spendingByMonth: Map<String, double>` to `expenseHistory: Map<String, List<ExpenseSnapshot>>`.

**Step 1: Update imports and function signature**

Replace the imports and `showTrendSheet` function signature:

```dart
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/expense_snapshot.dart';
import '../utils/formatters.dart';
```

Update `showTrendSheet` params — replace `spendingByMonth` and `currentFoodBudget` with:

```dart
void showTrendSheet({
  required BuildContext context,
  required Map<String, int> stressHistory,
  required Map<String, List<ExpenseSnapshot>> expenseHistory,
  required double currentTotalExpenses,
}) {
```

And the same for `_TrendSheetContent` constructor params.

**Step 2: Replace `_buildSpendingChart()` with `_buildExpenseTotalChart()` and `_buildExpenseCategoryChart()`**

The total chart shows a simple bar per month (sum of all enabled snapshots). Reference line = `currentTotalExpenses`.

The stacked chart shows one stacked bar per month, with each segment colored by category. Use `_categoryColors` (same colors as in `budget_charts.dart`):

```dart
static const _categoryColors = {
  'telecomunicacoes': Color(0xFF818CF8),
  'energia': Color(0xFFFBBF24),
  'agua': Color(0xFF60A5FA),
  'alimentacao': Color(0xFF34D399),
  'educacao': Color(0xFFA78BFA),
  'habitacao': Color(0xFFF87171),
  'transportes': Color(0xFFFB923C),
  'saude': Color(0xFFF472B6),
  'lazer': Color(0xFF2DD4BF),
  'outros': Color(0xFF94A3B8),
};
```

For the stacked bar chart, use fl_chart's `BarChartGroupData` with multiple `BarChartRodData` stacked via `BarChartRodStackItem`.

**Step 3: Update `build()` method**

```dart
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        // ... drag handle and title unchanged ...
        if (stressHistory.length >= 2) ...[
          _buildStressChart(),
          const SizedBox(height: 24),
        ],
        if (expenseHistory.isNotEmpty) ...[
          _buildExpenseTotalChart(),
          const SizedBox(height: 24),
          _buildExpenseCategoryChart(),
        ],
      ],
    );
  }
```

**Step 4: Verify**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter analyze lib/`
Expected: No new errors (same pre-existing warnings).

---

### Task 9: Remove DashboardConfig from AppSettings (cleanup)

**Files:**
- Modify: `lib/models/app_settings.dart`

**Context:** `DashboardConfig` is no longer read by Dashboard (it uses `LocalDashboardConfig` now). However, removing it from `AppSettings` would break deserialization of existing saved data. **Keep the class and field in AppSettings** but mark the field as deprecated. Do NOT remove it — the JSON still has `dashboardConfig` in Supabase and removing would cause parse errors.

**Step 1: Add deprecation comment**

In `app_settings.dart`, add a comment above the `dashboardConfig` field (line 413):

```dart
  /// @deprecated Use LocalDashboardConfig (stored in SharedPreferences) instead.
  /// Kept for backwards compatibility with existing serialized data.
  final DashboardConfig dashboardConfig;
```

**Step 2: Verify**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter analyze lib/`
Expected: No new errors.

---

### Task 10: Build APK and commit

**Step 1: Run full analysis**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter analyze lib/`
Expected: Only pre-existing warnings. Zero new errors.

**Step 2: Build the APK**

Run: `cd /c/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter && flutter build apk --release`
Expected: BUILD SUCCESSFUL.

**Step 3: Commit all changes**

Files to stage:
- `supabase/schema.sql` (modified)
- `lib/models/expense_snapshot.dart` (new)
- `lib/models/local_dashboard_config.dart` (new)
- `lib/models/app_settings.dart` (modified — deprecation comment)
- `lib/services/expense_snapshot_service.dart` (new)
- `lib/services/local_config_service.dart` (new)
- `lib/main.dart` (modified)
- `lib/screens/dashboard_screen.dart` (modified)
- `lib/screens/settings_screen.dart` (modified)
- `lib/widgets/trend_sheet.dart` (modified)

Commit message: `claude/budget-calculator-app-TFWgZ: add expense history, trend charts, and local dashboard config`

---

## File Dependency Graph

```
expense_snapshot.dart (Task 2 — model)
       ↓
expense_snapshot_service.dart (Task 3 — Supabase CRUD)
       ↓
local_dashboard_config.dart + local_config_service.dart (Task 4 — local config)
       ↓
main.dart (Task 5 — wire services + state)
       ↓
dashboard_screen.dart (Task 6 — visibility flags + snapshot trigger)
settings_screen.dart (Task 7 — dashboard toggles UI)
       ↓
trend_sheet.dart (Task 8 — new charts)
       ↓
app_settings.dart (Task 9 — deprecation cleanup)
       ↓
Build + Commit (Task 10)
```

Tasks 1-4 are independent of each other. Tasks 5-8 must be sequential. Task 9 can happen anytime. Task 10 is last.
