# Adaptive Features — Design

**Goal:** Transform the app from a static budget viewer into an adaptive decision system with mid-month alerts, end-of-month reviews, and a minimalist mode.

**Scope:** 3 features — (1) mid-month budget alert, (2) end-of-month review, (3) minimalist dashboard preset.

---

## Feature 1: Mid-Month Budget Alert (#3)

### Trigger

When `foodSpent / foodBudget > daysElapsed / daysInMonth` — i.e., spending faster than linear pace.

### Pure Function: `checkBudgetPace()`

Location: `lib/utils/stress_index.dart`

```dart
class BudgetPaceResult {
  final double dailyPace;        // actual €/day
  final double expectedPace;     // budget / daysInMonth
  final double projectedTotal;   // spent + (dailyPace * daysRemaining)
  final double projectedOverspend; // projectedTotal - budget (can be negative = under)
  final bool isOverPace;         // dailyPace > expectedPace
  final String severity;         // 'ok' | 'warning' | 'danger'
}
```

Severity thresholds:
- `ok`: pace ratio <= 1.0 (on track or under)
- `warning`: pace ratio 1.0–1.2 (slightly over)
- `danger`: pace ratio > 1.2 (significantly over)

### Dashboard Banner

Appears below the food spending card when `isOverPace == true`. Styled as:
- **Warning** (yellow border): "A gastar mais rápido que o previsto"
- **Danger** (red border): "Risco de ultrapassar orçamento alimentar"

Shows:
- Ritmo: X€/dia vs Y€/dia previsto
- Projeção: Z€ (diferença: +W€)

### AI Integration

Button "Pedir sugestão" on the banner. Calls AI coach with a mid-month-specific prompt including:
- Current pace vs expected
- Days remaining
- Projected overspend
- Current stress index

Gated behind `canUseAI()` check — returns `true` if API key exists. This prepares for future paid tiers: replace `canUseAI()` logic with tier check without touching UI code.

### Files

- Modify: `lib/utils/stress_index.dart` — add `checkBudgetPace()` + `BudgetPaceResult`
- Modify: `lib/screens/dashboard_screen.dart` — add `_BudgetPaceAlert` widget below food card
- Modify: `lib/services/ai_coach_service.dart` — add `analyzeMidMonth()` method with specific prompt

---

## Feature 2: End-of-Month Review (#10)

### Trigger

Previous month's expense snapshots exist AND `DateTime.now().day <= 7`.

### Data Sources

- **Planeado**: expense snapshots from previous month (already in `expense_snapshots` table)
- **Real (alimentação)**: purchase records from previous month
- **Real (outras despesas)**: current values in settings (user updates when they receive bills)

### Pure Function: `buildMonthReview()`

Location: `lib/utils/month_review.dart`

```dart
class ExpenseDeviation {
  final String label;
  final String category;
  final double planned;
  final double actual;
  final double difference;
  final double percentChange;
}

class MonthReviewResult {
  final String monthLabel;           // "Janeiro 2026"
  final double totalPlanned;
  final double totalActual;
  final double totalDifference;
  final double foodBudget;
  final double foodActual;
  final List<ExpenseDeviation> deviations;  // sorted by abs(difference) desc
  final List<String> suggestions;           // text-based, no AI
}
```

Comparison logic:
- For each expense in previous month's snapshot, compare `snapshot.amount` vs current `settings.expenses` amount for same `expense_id`
- For alimentação: compare snapshot amount vs `purchaseHistory.spentInMonth(prevYear, prevMonth)`
- Top 3 deviations = sorted by `abs(difference)` descending

Suggestions (rule-based, not AI):
- If food overspend > 10%: "Considere rever o orçamento alimentar ou as porções"
- If total overspend > 5%: "Despesas reais superaram o planeado — ajustar valores?"
- If underspend > 15%: "Poupou mais do que previsto — pode reforçar fundo de emergência"

### Dashboard Card (compact)

Appears at top of dashboard content (after header, before stress index) during first 7 days of month. Shows:
- "JANEIRO 2026 — RESUMO"
- Planeado: X€ | Real: Y€ | Diferença: +/-Z€
- Tap to see details

### Bottom Sheet (detail)

Widget: `lib/widgets/month_review_sheet.dart`

Sections:
1. **Totals** — Planeado vs Real with difference
2. **Top desvios** — Up to 3 expenses with biggest change (label, planned, actual, %)
3. **Alimentação** — Budget vs purchase records total
4. **Sugestões** — Rule-based text suggestions
5. **Análise AI** — Button gated behind `canUseAI()`

### Files

- Create: `lib/utils/month_review.dart` — `buildMonthReview()` + models
- Create: `lib/widgets/month_review_sheet.dart` — bottom sheet UI
- Modify: `lib/screens/dashboard_screen.dart` — add review card + trigger logic
- Modify: `lib/services/ai_coach_service.dart` — add `analyzeMonthReview()` method

---

## Feature 3: Minimalist Dashboard Preset (#6)

### Presets

Two factory constructors on `LocalDashboardConfig`:

```dart
factory LocalDashboardConfig.minimalist() => const LocalDashboardConfig(
  showHeroCard: true,           // Liquidez mensal
  showStressIndex: false,
  showSummaryCards: false,
  showSalaryBreakdown: false,
  showFoodSpending: true,       // Custo alimentar
  showPurchaseHistory: false,
  showExpensesBreakdown: false,
  showCharts: false,
  enabledCharts: [],
);

factory LocalDashboardConfig.full() => const LocalDashboardConfig();
```

Note: Mid-month alert (#1) and month review card (#2) are NOT controlled by these toggles — they are safety features that always show when triggered.

### Settings UI

In the Dashboard section of settings, add two buttons above the individual toggles:
- "Minimalista" — applies `LocalDashboardConfig.minimalist()`
- "Completo" — applies `LocalDashboardConfig.full()`

### Files

- Modify: `lib/models/local_dashboard_config.dart` — add factory constructors
- Modify: `lib/screens/settings_screen.dart` — add preset buttons

---

## AI Tier Preparation

All AI calls route through `canUseAI()`:

```dart
// In ai_coach_service.dart
Future<bool> canUseAI() async {
  final key = await loadApiKey();
  return key.isNotEmpty;
  // Future: check subscription tier here
}
```

UI shows the AI button only when `canUseAI()` returns true. This keeps the UI clean for free users and makes tier-gating a single-point change later.

---

## Files Summary

### New files
- `lib/utils/month_review.dart` — MonthReviewResult + buildMonthReview()
- `lib/widgets/month_review_sheet.dart` — Month review bottom sheet UI

### Modified files
- `lib/utils/stress_index.dart` — add checkBudgetPace() + BudgetPaceResult
- `lib/models/local_dashboard_config.dart` — add minimalist/full factories
- `lib/screens/dashboard_screen.dart` — budget pace alert + month review card
- `lib/screens/settings_screen.dart` — minimalist/full preset buttons
- `lib/services/ai_coach_service.dart` — canUseAI() + mid-month/review prompts

### Unchanged
- `lib/utils/calculations.dart`
- `lib/widgets/trend_sheet.dart`
- `lib/widgets/projection_sheet.dart`
- `supabase/schema.sql` (no new tables)
