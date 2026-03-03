# Engagement Features Design — Trends & Projections

**Goal:** Shift the app from a static budget recorder to a dynamic financial oracle by adding historical trend visualization and interactive what-if projections, triggered from existing Dashboard cards.

**Scope:** 2 features — Histórico de Evolução (trends) + Simulação de Futuro (projections). Everything else from the original 10 ideas is backlogged.

**Architecture:** Bottom-sheet detail views triggered by tapping existing Dashboard cards. Pure client-side calculations (no new API calls). Uses fl_chart for visualization. Zero new tabs or navigation changes.

---

## Feature 1: Histórico de Evolução

### Trigger
Tap the `_StressIndexCard` on Dashboard. A visual affordance (chart icon + "Evolução" label) is added next to the existing "Ver detalhes" toggle.

### Bottom Sheet Content

**1. Stress Index Trend (LineChart)**
- Data source: `AppSettings.stressHistory` (Map<String, int>)
- X-axis: months, last 6-12 entries sorted chronologically
- Y-axis: 0-100
- Background color bands: 0-39 red, 40-59 amber, 60-79 blue, 80-100 green
- Dots on each data point with score label
- Current month highlighted with larger dot

**2. Monthly Spending (BarChart)**
- Data source: `PurchaseHistory.records` aggregated by year-month
- Each bar = total spent that month
- Horizontal dashed line = current food budget (reference only — budgets aren't versioned historically)
- Last 6 months shown

### Data Limitations
Settings aren't versioned, so historical budget amounts aren't available. The current budget is shown as a reference line, not as a "what the budget was in month X."

---

## Feature 2: Simulação de Futuro

### Trigger
Tap the food spending card (`_buildFoodSpendingCard`) on Dashboard. A visual affordance (auto_graph icon + "Simular" label) is added.

### Bottom Sheet Content — Two Panels

#### Panel 1: Alimentação (food projection)

**Header:** "Projeção — [Month] [Year]" + "Gastou X€ de Y€ em Z dias"

**Slider:**
- Range: 0€ to remaining budget × 1.5
- Default: current daily average × remaining days
- Label: "Gasto diário estimado: X€/dia"
- Updates projections in real-time

**Pre-built scenario chips:**
- "Ritmo atual" — current daily average extrapolated
- "Sem mais compras" — spending stays as-is
- "Reduzir 20%" — daily average × 0.8

**Live results:**
1. Projeção fim de mês (projected total)
2. Restante projetado (green/red)
3. Impacto no Índice de Tranquilidade (score delta, e.g., "+4 pts")

**Calculation:**
```
dailyAvg = foodSpent / max(dayOfMonth, 1)
projectedTotal = foodSpent + (adjustedDaily * daysRemaining)
simulatedStress = calculateStressIndex(with simulated food spend)
```

#### Panel 2: Despesas (expense what-if)

**Banner:** "Simulação — alterações não são guardadas"

**Global control:** Percentage slider "Reduzir todas em X%" (0-50%)

**Per-expense rows:**
- Each active expense from `settings.expenses`
- Shows: label, current amount, toggle switch (simulate removal), editable amount field (simulation only)

**Live results:**
1. Liquidez simulada (recalculated netLiquidity)
2. Delta: "+X€/mês" vs current
3. Taxa de poupança simulada
4. Índice simulado (recalculated stress score)

**Key principle:** Read-only simulator. Uses existing `calculateBudgetSummary()` and `calculateStressIndex()` with modified inputs. Nothing saves to settings.

---

## Files Involved

### New files
- `lib/widgets/trend_sheet.dart` — Bottom sheet with stress trend + spending charts
- `lib/widgets/projection_sheet.dart` — Bottom sheet with food + expense simulator

### Modified files
- `lib/screens/dashboard_screen.dart` — Add tap affordances to stress card and food card
- `lib/models/purchase_record.dart` — Add `spentByMonth()` helper for aggregation

### Unchanged
- `lib/utils/stress_index.dart` — Reused as-is for simulated calculations
- `lib/utils/calculations.dart` — Reused as-is for simulated budget summary
- `lib/models/app_settings.dart` — Read-only, no changes

---

## Design Constraints
- No new Supabase tables or API calls
- No new tabs or navigation destinations
- fl_chart already in pubspec.yaml
- All calculations are pure Dart functions, cheap to run on every slider tick
- Portuguese language throughout (matching existing app)
