# Implementation Plan: IRS What-If Tax Simulator

## 1. Goal

Add a **"What-If Tax Simulator"** screen that lets users tweak salary and personal parameters and instantly see how changes affect their net take-home pay and overall budget. The simulator presents a **side-by-side comparison** (Current vs Simulated) so the impact of each change is immediately clear.

### Key Use Cases

| Scenario | What the user tweaks |
|---|---|
| "If I get a €200 raise, what's my net?" | `grossAmount` |
| "Should we file jointly or separately?" | `titulares` (1 vs 2) |
| "Card vs cash meal allowance?" | `mealAllowanceType` |
| "What if I add a dependent?" | `dependentes` |
| "What if I get subsidies as twelfths?" | `subsidyMode` |
| "What if my spouse enables their salary?" | `salaries[1].enabled` |

### Non-Goals

- **No new tax logic.** The simulator reuses `calculateNetSalary()` and `calculateBudgetSummary()` from `lib/utils/calculations.dart`.
- **No persistence.** Simulated values are ephemeral — clearly labelled "Simulation — not saved". The user's real settings are never modified.
- **No Supabase changes.** Everything is client-side computation.

---

## 2. Architecture

### 2.1 Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                       TaxSimulatorScreen                    │
│                                                             │
│  ┌──────────────┐         ┌──────────────────┐              │
│  │ Current Side  │         │ Simulated Side    │             │
│  │ (read-only)   │         │ (editable fields) │             │
│  └──────┬───────┘         └──────┬───────────┘              │
│         │                        │                           │
│         │  AppSettings           │  Cloned AppSettings       │
│         │  (from parent)         │  (local state)            │
│         ▼                        ▼                           │
│  calculateBudgetSummary()  calculateBudgetSummary()          │
│         │                        │                           │
│         ▼                        ▼                           │
│  BudgetSummary (current)   BudgetSummary (simulated)         │
│         │                        │                           │
│         └────────┬───────────────┘                           │
│                  ▼                                           │
│          Delta Comparison Panel                              │
│          (net diff, tax diff, savings rate diff)             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 State Management

The screen is a `StatefulWidget`. State consists of:

| State variable | Type | Purpose |
|---|---|---|
| `_simSalaries` | `List<SalaryInfo>` | Cloned from `widget.settings.salaries`, editable |
| `_simPersonalInfo` | `PersonalInfo` | Cloned from `widget.settings.personalInfo`, editable |
| `_currentSummary` | `BudgetSummary` | Computed once from real settings |
| `_simSummary` | `BudgetSummary` | Recomputed on every change via `setState()` |

On every field change → call `_recalculate()`:

```dart
void _recalculate() {
  final taxSystem = getTaxSystem(widget.settings.country);
  setState(() {
    _simSummary = calculateBudgetSummary(
      _simSalaries,
      _simPersonalInfo,
      widget.settings.expenses, // expenses stay the same
      taxSystem,
      monthlyBudgets: widget.monthlyBudgets,
    );
  });
}
```

### 2.3 Integration Points

The simulator **does not** introduce any new services, models, or tax logic. It only:

1. **Reads** the current `AppSettings` (passed as a constructor parameter, same pattern as `ProjectionSheet`, `CoachScreen`, etc.)
2. **Calls** existing pure functions (`calculateNetSalary`, `calculateBudgetSummary`) with modified copies of `SalaryInfo`/`PersonalInfo`.
3. **Uses** existing `getTaxSystem(Country)` factory to get the correct country tax engine.

---

## 3. UI Design

### 3.1 Screen Layout

The screen uses a **full-page route** (not a bottom sheet) for ample space, following the same `MaterialPageRoute` pattern used by `ExpenseTrendsScreen`, `SavingsGoalsScreen`, etc.

#### Mobile Layout (< 600dp width) — Vertical Stack

```
┌─────────────────────────────────┐
│ ← What-If Simulator    [Reset] │  AppBar
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ PERSONAL PARAMETERS         │ │  Editable card
│ │ Marital status  [Dropdown]  │ │
│ │ Dependents      [- 0 +]    │ │
│ │ Disability      [Switch]    │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ SALARY 1 — "Vencimento 1"  │ │  Editable card (per salary)
│ │ Gross salary    [TextField] │ │
│ │ Titulares       [1] [2]    │ │  (PT only)
│ │ Subsidies       [Dropdown]  │ │  (PT/ES only)
│ │ Meal allowance  [Dropdown]  │ │  (PT only)
│ │ Amount/day      [TextField] │ │  (PT only)
│ │ Working days    [TextField] │ │
│ │ Exempt income   [TextField] │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ SALARY 2 — "Vencimento 2"  │ │  (if exists)
│ │ Enabled         [Switch]    │ │
│ │ ... same fields ...         │ │
│ └─────────────────────────────┘ │
│                                 │
│ ═══════════════════════════════ │  Divider
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 📊 COMPARISON RESULTS       │ │
│ │                             │ │
│ │          Current  Simulated │ │
│ │ Gross    €2,100   €2,300    │ │
│ │ Tax      €245     €278      │ │
│ │ SS       €231     €253      │ │
│ │ Net      €1,624   €1,769    │ │
│ │ Meal     €154     €154      │ │
│ │ Total    €1,778   €1,923    │ │
│ │ ─────────────────────────── │ │
│ │ Expenses €950     €950      │ │
│ │ Liquid.  €828     €973      │ │
│ │ Savings  46.6%    50.6%     │ │
│ │                             │ │
│ │ ┌───────────────────────┐   │ │
│ │ │ 💰 DELTA              │   │ │
│ │ │ +€145/month net       │   │ │  Green/Red badge
│ │ │ +€1,740/year net      │   │ │
│ │ │ +4.0pp savings rate   │   │ │
│ │ └───────────────────────┘   │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

#### Tablet Layout (≥ 600dp) — Side by Side

On wider screens, the editable parameters sit on the left and the comparison results sit on the right in a two-column `Row` layout, both scrolling independently.

### 3.2 Comparison Results Table

A styled data table or `Column` of `Row` widgets showing:

| Row | Current | Simulated | Delta |
|---|---|---|---|
| Gross Income | `currentSummary.totalGross` | `simSummary.totalGross` | diff |
| Income Tax | `currentSummary.totalIRS` | `simSummary.totalIRS` | diff |
| Social Security | `currentSummary.totalSS` | `simSummary.totalSS` | diff |
| Net Salary | `currentSummary.totalNet` | `simSummary.totalNet` | diff |
| Meal Allowance | `currentSummary.totalMealAllowance` | `simSummary.totalMealAllowance` | diff |
| Total Net (w/ meal) | `currentSummary.totalNetWithMeal` | `simSummary.totalNetWithMeal` | diff |
| Total Expenses | same | same | — |
| Net Liquidity | `currentSummary.netLiquidity` | `simSummary.netLiquidity` | diff |
| Savings Rate | `currentSummary.savingsRate` | `simSummary.savingsRate` | diff |

### 3.3 Delta Banner

A prominent card at the bottom showing:
- **Monthly net difference**: `+€145/month` (green) or `-€45/month` (red)
- **Annualized**: `+€1,740/year`
- **Savings rate change**: `+4.0pp`

Uses `AppColors.success(context)` / `AppColors.error(context)` for color-coding, consistent with `ProjectionSheet`.

### 3.4 Country-Aware Field Visibility

Fields are conditionally shown based on `Country` flags already defined in `tax_system.dart`:

| Field | Condition |
|---|---|
| Titulares | `country.hasTitulares` (PT only) |
| Meal allowance type/amount | `country.hasMealAllowance` (PT only) |
| Subsidy mode | `country.hasSubsidies` (PT, ES) |
| Marital status | `country.maritalStatusAffectsTax` (PT only, but show always for UX) |
| Dependentes | Always shown |
| Disability | Always shown |

### 3.5 Quick Scenario Chips

At the top of the parameters area, optional tappable chips for common scenarios (similar to `ProjectionSheet`'s scenario chips):

- **+€100 raise** — increments gross by 100
- **+€200 raise** — increments gross by 200
- **Toggle titulares** — swaps 1↔2
- **Add dependent** — increments dependentes by 1
- **Card ↔ Cash meal** — toggles meal allowance type

### 3.6 Reset Button

An AppBar action button (icon: `Icons.refresh`) that resets all simulated values back to the current real settings.

---

## 4. Files Involved

### 4.1 Files to Create

| File | Purpose |
|---|---|
| `lib/screens/tax_simulator_screen.dart` | Main simulator screen (`StatefulWidget`) |
| `lib/widgets/tax_simulator/comparison_table.dart` | Reusable comparison table widget |
| `lib/widgets/tax_simulator/delta_banner.dart` | Delta summary banner widget |
| `lib/widgets/tax_simulator/salary_edit_card.dart` | Editable salary card (one per salary entry) |
| `lib/widgets/tax_simulator/personal_info_card.dart` | Editable personal info card |
| `lib/widgets/tax_simulator/scenario_chips.dart` | Quick scenario preset chips |

### 4.2 Files to Modify

| File | Change |
|---|---|
| `lib/main.dart` | Add navigation method `_openTaxSimulator()` and pass it to `DashboardScreen` |
| `lib/screens/dashboard_screen.dart` | Add entry point button/card to open the simulator (e.g., in the Financial Summary section or as a new action) |
| `lib/screens/settings_screen.dart` | Add a "Tax Simulator" menu item in the settings list (alongside existing sections) |
| `lib/l10n/app_en.arb` | Add English i18n keys |
| `lib/l10n/app_pt.arb` | Add Portuguese i18n keys |
| `lib/l10n/app_es.arb` | Add Spanish i18n keys |
| `lib/l10n/app_fr.arb` | Add French i18n keys |

### 4.3 Files NOT Modified

| File | Reason |
|---|---|
| `lib/utils/calculations.dart` | Reused as-is, no changes |
| `lib/data/tax/*.dart` | Tax systems untouched |
| `lib/models/app_settings.dart` | Models reused via `copyWith`, no new fields |
| `lib/models/budget_summary.dart` | Reused as-is |
| `lib/services/settings_service.dart` | No persistence for simulations |
| Any Supabase migration | No backend changes |

---

## 5. i18n Keys

All new keys follow the existing naming convention (`screenSection` prefix pattern).

### New Keys to Add

```json
{
  "taxSimTitle": "What-If Simulator",
  "taxSimSubtitle": "Tweak parameters and see how they affect your take-home pay",
  "taxSimReset": "Reset",
  "taxSimResetTooltip": "Reset to current values",
  "taxSimNotSaved": "Simulation — not saved",

  "taxSimPersonalSection": "PERSONAL PARAMETERS",
  "taxSimMaritalStatus": "Marital status",
  "taxSimDependents": "Dependents",
  "taxSimDisability": "Disability",

  "taxSimSalarySection": "SALARY {n}",
  "@taxSimSalarySection": {
    "placeholders": { "n": { "type": "int" } }
  },
  "taxSimEnabled": "Active",
  "taxSimGrossSalary": "Gross salary",
  "taxSimTitulares": "Tax holders",
  "taxSimSubsidyMode": "Subsidies",
  "taxSimMealType": "Meal allowance",
  "taxSimMealPerDay": "Amount/day",
  "taxSimWorkingDays": "Working days/month",
  "taxSimExemptIncome": "Other exempt income",

  "taxSimQuickScenarios": "QUICK SCENARIOS",
  "taxSimScenarioRaise100": "+€100 raise",
  "taxSimScenarioRaise200": "+€200 raise",
  "taxSimScenarioToggleTitulares": "Toggle holders",
  "taxSimScenarioAddDependent": "+1 dependent",
  "taxSimScenarioToggleMeal": "Card ↔ Cash",

  "taxSimResultsSection": "COMPARISON",
  "taxSimCurrent": "Current",
  "taxSimSimulated": "Simulated",
  "taxSimDelta": "Delta",

  "taxSimRowGross": "Gross income",
  "taxSimRowTax": "Income tax",
  "taxSimRowSS": "Social security",
  "taxSimRowNet": "Net salary",
  "taxSimRowMeal": "Meal allowance",
  "taxSimRowTotalNet": "Total net",
  "taxSimRowExpenses": "Expenses",
  "taxSimRowLiquidity": "Net liquidity",
  "taxSimRowSavingsRate": "Savings rate",

  "taxSimDeltaMonthly": "{sign}{amount}/month",
  "@taxSimDeltaMonthly": {
    "placeholders": {
      "sign": { "type": "String" },
      "amount": { "type": "String" }
    }
  },
  "taxSimDeltaYearly": "{sign}{amount}/year",
  "@taxSimDeltaYearly": {
    "placeholders": {
      "sign": { "type": "String" },
      "amount": { "type": "String" }
    }
  },
  "taxSimDeltaSavingsRate": "{sign}{value}pp savings rate",
  "@taxSimDeltaSavingsRate": {
    "placeholders": {
      "sign": { "type": "String" },
      "value": { "type": "String" }
    }
  },
  "taxSimDeltaBanner": "IMPACT",
  "taxSimNoChange": "No change from current values"
}
```

> **Note:** These keys must be translated into PT, ES, and FR in their respective `.arb` files. Run `flutter gen-l10n` after adding keys.

---

## 6. Detailed Implementation Steps

### Step 1: Create Widget Files (Leaf → Root)

#### 6.1.1 `lib/widgets/tax_simulator/comparison_table.dart`

```dart
/// Displays a table with Current | Simulated | Delta columns.
/// Takes two BudgetSummary objects and computes deltas inline.
class ComparisonTable extends StatelessWidget {
  final BudgetSummary current;
  final BudgetSummary simulated;
  final Country country;
  // ...
}
```

- Each row: label, current value, simulated value, delta (colored).
- Uses `formatCurrency()` and `formatPercentage()` from `lib/utils/formatters.dart`.
- Delta cell: green (`AppColors.success`) for positive net changes, red (`AppColors.error`) for negative.

#### 6.1.2 `lib/widgets/tax_simulator/delta_banner.dart`

```dart
/// A prominent card showing the overall impact.
class DeltaBanner extends StatelessWidget {
  final BudgetSummary current;
  final BudgetSummary simulated;
  // ...
}
```

- Shows monthly net delta, annualized delta, savings rate delta.
- Uses a `Container` with rounded corners and colored background (green-tinted or red-tinted).
- If no difference, shows a muted "No change" message.

#### 6.1.3 `lib/widgets/tax_simulator/salary_edit_card.dart`

```dart
/// Editable card for a single SalaryInfo entry.
class SalaryEditCard extends StatelessWidget {
  final SalaryInfo salary;
  final int index;
  final Country country;
  final ValueChanged<SalaryInfo> onChanged;
  // ...
}
```

- Text fields for gross, meal per day, working days, exempt income.
- Dropdowns/segmented buttons for `SubsidyMode`, `MealAllowanceType`, `titulares`.
- Conditionally shows fields based on `Country` flags.
- Calls `onChanged` with a new `SalaryInfo` via `copyWith()` on every edit.

#### 6.1.4 `lib/widgets/tax_simulator/personal_info_card.dart`

```dart
/// Editable card for PersonalInfo.
class PersonalInfoCard extends StatelessWidget {
  final PersonalInfo personalInfo;
  final Country country;
  final ValueChanged<PersonalInfo> onChanged;
  // ...
}
```

- Dropdown for `MaritalStatus`.
- Stepper (+/-) for `dependentes`.
- Switch for `deficiente`.

#### 6.1.5 `lib/widgets/tax_simulator/scenario_chips.dart`

```dart
/// Quick-action chips for common what-if scenarios.
class ScenarioChips extends StatelessWidget {
  final VoidCallback onRaise100;
  final VoidCallback onRaise200;
  final VoidCallback onToggleTitulares;
  final VoidCallback onAddDependent;
  final VoidCallback onToggleMeal;
  final Country country;
  // ...
}
```

- Renders `ActionChip` widgets, same style as `ProjectionSheet._scenarioChip()`.
- Conditionally hides country-specific chips (e.g., titulares only for PT, meal only for PT).

### Step 2: Create the Main Screen

#### 6.2 `lib/screens/tax_simulator_screen.dart`

```dart
class TaxSimulatorScreen extends StatefulWidget {
  final AppSettings settings;
  final BudgetSummary currentSummary;
  final Map<String, double> monthlyBudgets;

  const TaxSimulatorScreen({
    super.key,
    required this.settings,
    required this.currentSummary,
    this.monthlyBudgets = const {},
  });

  @override
  State<TaxSimulatorScreen> createState() => _TaxSimulatorScreenState();
}

class _TaxSimulatorScreenState extends State<TaxSimulatorScreen> {
  late List<SalaryInfo> _simSalaries;
  late PersonalInfo _simPersonalInfo;
  late BudgetSummary _simSummary;

  @override
  void initState() {
    super.initState();
    _resetToDefaults();
  }

  void _resetToDefaults() {
    _simSalaries = widget.settings.salaries
        .map((s) => s.copyWith())
        .toList();
    _simPersonalInfo = widget.settings.personalInfo.copyWith();
    _recalculate();
  }

  void _recalculate() {
    final taxSystem = getTaxSystem(widget.settings.country);
    _simSummary = calculateBudgetSummary(
      _simSalaries,
      _simPersonalInfo,
      widget.settings.expenses,
      taxSystem,
      monthlyBudgets: widget.monthlyBudgets,
    );
  }

  void _updateSalary(int index, SalaryInfo updated) {
    setState(() {
      _simSalaries[index] = updated;
      _recalculate();
    });
  }

  void _updatePersonalInfo(PersonalInfo updated) {
    setState(() {
      _simPersonalInfo = updated;
      _recalculate();
    });
  }

  // ... build method with ListView containing:
  //   - ScenarioChips
  //   - PersonalInfoCard
  //   - SalaryEditCard (for each salary)
  //   - ComparisonTable
  //   - DeltaBanner
}
```

**Key behaviors:**
- `initState()` deep-clones settings into local state.
- Every edit triggers `setState()` → `_recalculate()` → UI rebuilds with new comparison.
- Reset button calls `_resetToDefaults()`.
- Real-time recalculation (no debounce needed — calculations are pure and fast, <1ms).

### Step 3: Integration — Navigation

#### 6.3.1 `lib/main.dart`

Add a navigation method alongside existing `_openRecurringExpenses()`, `_openExpenseTrends()`, etc.:

```dart
void _openTaxSimulator() {
  final taxSystem = getTaxSystem(_settings.country);
  final summary = calculateBudgetSummary(
    _settings.salaries,
    _settings.personalInfo,
    _settings.expenses,
    taxSystem,
    monthlyBudgets: _monthlyBudgets,
  );
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TaxSimulatorScreen(
        settings: _settings,
        currentSummary: summary,
        monthlyBudgets: _monthlyBudgets,
      ),
    ),
  );
}
```

Pass `_openTaxSimulator` as a callback to `DashboardScreen`:

```dart
DashboardScreen(
  // ... existing params
  onOpenTaxSimulator: _openTaxSimulator,
),
```

#### 6.3.2 `lib/screens/dashboard_screen.dart`

Add a `VoidCallback? onOpenTaxSimulator` parameter to `DashboardScreen`.

Add an entry point. Two options (implement both):

**Option A — Card in Financial Summary section:**
A new card/button row in the dashboard's financial summary area:
```dart
TextButton.icon(
  onPressed: widget.onOpenTaxSimulator,
  icon: Icon(Icons.calculate_outlined),
  label: Text(l10n.taxSimTitle),
)
```

**Option B — Alongside existing "Simulate" button in Food section:**
In the food section header where `dashboardSimulate` currently triggers `showProjectionSheet`, add a second button or make the existing button open a chooser.

#### 6.3.3 `lib/screens/settings_screen.dart`

Add a new section tile in the settings list (after "Income" or "Personal Data"):

```dart
_SettingsTile(
  icon: Icons.calculate_outlined,
  title: l10n.taxSimTitle,
  onTap: () => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TaxSimulatorScreen(
        settings: widget.settings,
        currentSummary: _computeCurrentSummary(),
        monthlyBudgets: widget.monthlyBudgets ?? const {},
      ),
    ),
  ),
),
```

### Step 4: Add i18n Keys

Add all keys from Section 5 to all four `.arb` files:

| File | Language |
|---|---|
| `lib/l10n/app_en.arb` | English translations (as defined above) |
| `lib/l10n/app_pt.arb` | Portuguese translations |
| `lib/l10n/app_es.arb` | Spanish translations |
| `lib/l10n/app_fr.arb` | French translations |

Then run:
```bash
flutter gen-l10n
```

### Step 5: Testing

#### Manual Testing Checklist

- [ ] Open simulator from Dashboard → all fields pre-filled with current values
- [ ] Open simulator from Settings → same behavior
- [ ] Change gross salary → comparison table updates in real-time
- [ ] Change titulares (PT only) → tax recalculates correctly
- [ ] Change meal allowance type (PT only) → meal calculation updates
- [ ] Change dependentes → IRS rate updates
- [ ] Toggle subsidy mode → effective gross changes
- [ ] Enable/disable second salary → totals update
- [ ] Quick scenario chips work correctly
- [ ] Reset button restores all values to current settings
- [ ] Delta banner shows correct monthly/yearly impact
- [ ] Green for positive net changes, red for negative
- [ ] "No change" state shown when values match current
- [ ] Country-specific fields hidden for non-applicable countries (ES, FR, UK)
- [ ] Screen works in all 4 languages (PT, EN, ES, FR)
- [ ] Screen is responsive — stacked on mobile, side-by-side on tablet
- [ ] Accessibility: all fields have proper labels for screen readers

#### Unit Tests (Optional, Recommended)

| Test | File |
|---|---|
| Delta computation helper | `test/widgets/tax_simulator/delta_test.dart` |
| Comparison table renders correct values | `test/widgets/tax_simulator/comparison_table_test.dart` |
| Scenario chips trigger correct mutations | `test/widgets/tax_simulator/scenario_chips_test.dart` |

No new tests needed for `calculations.dart` — those functions already have their own test coverage.

---

## 7. Effort Estimate

| Task | Estimate |
|---|---|
| Widget files (5 files) | 3–4 hours |
| Main screen file | 2–3 hours |
| Integration (main.dart, dashboard, settings) | 1–2 hours |
| i18n keys (4 languages × ~30 keys) | 1–2 hours |
| Testing & polish | 2–3 hours |
| **Total** | **9–14 hours** |

---

## 8. Future Enhancements (Out of Scope)

These are **not** part of this implementation but could be added later:

- **Save scenarios**: Let users name and persist simulation presets to Supabase.
- **Share comparison**: Export the comparison as a PDF or image.
- **Historical comparison**: "What if I had this salary 6 months ago?" using historical tax tables.
- **Multi-country comparison**: "What would I earn in France vs Portugal?"
- **Tax optimization tips**: AI-powered suggestions based on the simulation results.
- **Animated transitions**: Animate the delta values when they change.

---

## 9. File Tree Summary

```
lib/
├── screens/
│   └── tax_simulator_screen.dart          ← NEW
├── widgets/
│   └── tax_simulator/
│       ├── comparison_table.dart           ← NEW
│       ├── delta_banner.dart               ← NEW
│       ├── salary_edit_card.dart           ← NEW
│       ├── personal_info_card.dart         ← NEW
│       └── scenario_chips.dart             ← NEW
├── l10n/
│   ├── app_en.arb                          ← MODIFY (add ~30 keys)
│   ├── app_pt.arb                          ← MODIFY (add ~30 keys)
│   ├── app_es.arb                          ← MODIFY (add ~30 keys)
│   └── app_fr.arb                          ← MODIFY (add ~30 keys)
├── main.dart                               ← MODIFY (add navigation)
└── screens/
    ├── dashboard_screen.dart               ← MODIFY (add entry point)
    └── settings_screen.dart                ← MODIFY (add menu item)
```

**Total: 6 new files, 7 modified files, 0 backend changes.**
