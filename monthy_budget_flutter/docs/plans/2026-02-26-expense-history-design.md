# Expense History & Dashboard Config — Design

**Goal:** Track monthly expense snapshots in Supabase, show historical trends (total + stacked by category) in the trend sheet, and make all dashboard sections toggleable via per-device local settings.

**Scope:** 3 features — (1) expense snapshots, (2) updated trend sheet, (3) local dashboard config.

---

## Feature 1: Expense Snapshots (Supabase)

### Table

```sql
CREATE TABLE expense_snapshots (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  household_id  uuid NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  month         text NOT NULL,              -- "2026-02"
  expense_id    text NOT NULL,              -- matches ExpenseItem.id
  label         text NOT NULL,              -- "Eletricidade"
  category      text NOT NULL,              -- "energia"
  amount        double precision NOT NULL,
  enabled       boolean NOT NULL DEFAULT true,
  created_at    timestamptz DEFAULT now(),
  UNIQUE(household_id, month, expense_id)
);
```

RLS: Users can only read/write rows where `household_id` matches their profile's `household_id` (same pattern as `household_settings`, `purchase_records`).

### Auto-Snapshot Behavior

- Dashboard `build()` already has a `addPostFrameCallback` that persists `stressHistory`
- Add expense snapshot logic in the same callback: if current month's snapshot is missing or stale, upsert all expenses for the month
- `UNIQUE(household_id, month, expense_id)` ensures re-visits update rather than duplicate
- If user edits an expense mid-month, next Dashboard render updates the snapshot

### Service: `ExpenseSnapshotService`

Two methods:
1. `snapshotIfNeeded(householdId, month, expenses)` — checks if snapshot exists for month, upserts if needed
2. `loadHistory(householdId, {months: 12})` — returns `Map<String, List<ExpenseSnapshot>>` grouped by month key

### Data Model: `ExpenseSnapshot`

```dart
class ExpenseSnapshot {
  final String expenseId;
  final String label;
  final String category;
  final double amount;
  final bool enabled;
}
```

---

## Feature 2: Updated Trend Sheet

### Charts (3 total)

1. **Índice de Tranquilidade** (LineChart) — unchanged, uses `stressHistory`
2. **Despesas Totais por mês** (BarChart) — sum of all expense snapshots per month. Reference line = current total expenses (replaces old food-only chart)
3. **Despesas por Categoria** (Stacked BarChart) — one color per category per month, shows composition over time

### Data Flow

`showTrendSheet()` receives:
- `stressHistory` (unchanged)
- `expenseHistory: Map<String, List<ExpenseSnapshot>>` (new — from `ExpenseSnapshotService.loadHistory()`)
- `currentTotalExpenses: double` (replaces `currentFoodBudget`)

### Stress Index

No changes to calculation. Index continues using current-month values only. Historical data is visualization-only.

---

## Feature 3: Local Dashboard Config

### Why Local

Dashboard visibility preferences are personal, not household-shared. Each device/user can configure independently.

### Model

```dart
class LocalDashboardConfig {
  final bool showHeroCard;           // Liquidez mensal
  final bool showStressIndex;        // Índice de Tranquilidade
  final bool showSummaryCards;       // Cards resumo
  final bool showSalaryBreakdown;    // Detalhe por vencimento
  final bool showFoodSpending;       // Card alimentação
  final bool showPurchaseHistory;    // Histórico de compras
  final bool showExpensesBreakdown;  // Breakdown despesas
  final bool showCharts;             // Gráficos
  final List<ChartType> enabledCharts;
}
```

All default to `true`. Stored in `SharedPreferences` as JSON under key `dashboard_config`.

### Migration

Remove `DashboardConfig` from `AppSettings`. On first load, if `SharedPreferences` has no `dashboard_config`, create defaults. No data migration needed — existing `DashboardConfig` values in Supabase are ignored going forward.

### Service: `LocalConfigService`

- `load()` → `LocalDashboardConfig` (reads SharedPreferences)
- `save(LocalDashboardConfig)` (writes SharedPreferences)

### Settings UI

New section in settings screen: "Dashboard" with toggle switches for each section. Placed after existing sections.

### Dashboard Impact

`DashboardScreen` receives `LocalDashboardConfig` as a parameter. Each section is wrapped with its corresponding visibility flag.

---

## Files Involved

### New files
- `lib/models/expense_snapshot.dart` — ExpenseSnapshot data class
- `lib/models/local_dashboard_config.dart` — LocalDashboardConfig model
- `lib/services/expense_snapshot_service.dart` — Supabase CRUD for snapshots
- `lib/services/local_config_service.dart` — SharedPreferences for dashboard config

### Modified files
- `lib/screens/dashboard_screen.dart` — use LocalDashboardConfig, pass expense history to trend sheet
- `lib/widgets/trend_sheet.dart` — replace food chart with total + stacked category charts
- `lib/screens/settings_screen.dart` — add dashboard toggles section
- `lib/main.dart` — load LocalDashboardConfig on init, pass to Dashboard
- `lib/models/app_settings.dart` — remove DashboardConfig field (migration)

### SQL
- `expense_snapshots` table creation + RLS policies

### Unchanged
- `lib/utils/stress_index.dart`
- `lib/utils/calculations.dart`
- `lib/widgets/projection_sheet.dart`
