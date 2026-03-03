# E-Fatura Tax Deduction Tracker — Design

**Goal:** Surface how much IRS tax benefit Portuguese users accumulate from their categorised expenses, showing per-category deduction amounts (e.g. "Your health expenses this year: €X → potential IRS deduction: €Y") on the Dashboard and in a dedicated detail screen.

**Architecture:** Pure client-side calculation using existing `actual_expenses` data grouped by calendar year. A new utility (`tax_deductions.dart`) applies country-specific deduction rules to expense totals. A compact Dashboard card shows the yearly total, tappable to open a full per-category breakdown screen. For non-PT countries the card is hidden; the architecture supports future country-specific deduction rules via an abstract class.

**Tech Stack:** Flutter, Dart, existing Supabase `actual_expenses` table (read-only, no schema changes), existing `ActualExpenseService.loadHistory()`, existing `ExpenseCategory` enum, existing `Country` enum.

---

## Portuguese IRS Deduction Rules (2025)

| Category | ExpenseCategory mapping | Rate | Annual Cap | Notes |
|---|---|---|---|---|
| Saúde | `saude` | 15% | €1,000 | Health expenses |
| Educação | `educacao` | 30% | €800 | Education & training |
| Habitação | `habitacao` | 15% | €502 | Rent / mortgage interest |
| Despesas Gerais | `outros` | 35% | €250 | General family expenses |
| Transportes públicos | `transportes` | 35% | €250 (shared with Gerais) | Deductible within the general/outros ceiling |
| Alimentação | `alimentacao` | 15% of VAT (≈ 15% × 23% = ~3.45% effective) | €250 | Restaurants/food — only VAT portion is deductible |
| Telecomunicações | `telecomunicacoes` | — | — | NOT deductible on its own |
| Energia | `energia` | — | — | NOT deductible on its own |
| Água | `agua` | — | — | NOT deductible on its own |
| Lazer | `lazer` | — | — | NOT deductible |

**Transportes + Outros shared cap:** Both `transportes` and `outros` contribute to the "Despesas Gerais Familiares" pool. The combined deduction is capped at €250. Transportes at 35% and outros at 35%, summed and capped together.

**Alimentação special rule:** Only 15% of the VAT is deductible, not 15% of the total. Assuming standard 23% VAT rate: effective deduction ≈ `amount × 0.23 × 0.15`. Simplified in the app as `amount × 0.0345`, capped at €250.

---

## Data Model — `DeductionRule` & `DeductionResult`

```dart
/// A single deduction rule for one expense category.
class DeductionRule {
  final ExpenseCategory category;
  final double rate;           // e.g. 0.15 for 15%
  final double annualCap;     // e.g. 1000.0
  final bool isVatBased;      // true for alimentação (rate applies to VAT, not total)
  final double vatRate;        // e.g. 0.23 — only used when isVatBased=true
  final String? sharedCapGroup; // categories sharing a cap (e.g. 'despesas_gerais')

  const DeductionRule({
    required this.category,
    required this.rate,
    required this.annualCap,
    this.isVatBased = false,
    this.vatRate = 0.23,
    this.sharedCapGroup,
  });
}

/// Result for one category after applying the deduction rule.
class CategoryDeductionResult {
  final ExpenseCategory category;
  final double totalSpent;       // total expenses in this category this year
  final double rawDeduction;     // rate × spent (before cap)
  final double effectiveDeduction; // after applying annual cap (and shared cap)
  final double annualCap;
  final bool isAtCap;

  const CategoryDeductionResult({ ... });
}

/// Aggregate result for all categories in a year.
class YearlyDeductionSummary {
  final int year;
  final double totalDeduction;        // sum of all effective deductions
  final List<CategoryDeductionResult> categories; // only deductible categories
  final List<ExpenseCategory> nonDeductible;      // categories with no deduction

  const YearlyDeductionSummary({ ... });
}
```

**Key design decisions:**
- `sharedCapGroup` allows transportes and outros to share their €250 ceiling. The utility sums their raw deductions and applies the group cap proportionally.
- `isVatBased` flag handles alimentação's special VAT-only deduction.
- Non-deductible categories (telecomunicacoes, energia, agua, lazer) are excluded from calculation but listed in the detail screen as "não dedutível" for user awareness.

---

## Abstract Deduction System (Country Extensibility)

```dart
/// Base class for country-specific deduction rule sets.
abstract class TaxDeductionSystem {
  Country get country;
  List<DeductionRule> get rules;

  /// Override for special shared-cap logic, VAT logic, etc.
  YearlyDeductionSummary calculate(
    int year,
    Map<ExpenseCategory, double> spentByCategory,
  );
}

class PtTaxDeductionSystem extends TaxDeductionSystem {
  @override Country get country => Country.pt;
  @override List<DeductionRule> get rules => _ptRules2025;
  // ... full implementation
}
```

Future country implementations (ES, FR, UK) would subclass `TaxDeductionSystem`. A factory function mirrors the existing `getTaxSystem(Country)` pattern:

```dart
TaxDeductionSystem? getTaxDeductionSystem(Country country) {
  switch (country) {
    case Country.pt: return PtTaxDeductionSystem();
    default: return null; // no deduction system yet
  }
}
```

Returning `null` signals the Dashboard to hide the deduction card entirely.

---

## Utility — `lib/utils/tax_deductions.dart`

Pure Dart file, no Flutter dependencies. Contains:

1. **`DeductionRule`** — immutable data class (see above)
2. **`CategoryDeductionResult`** — immutable result per category
3. **`YearlyDeductionSummary`** — aggregate result
4. **`TaxDeductionSystem`** — abstract base class
5. **`PtTaxDeductionSystem`** — Portuguese IRS 2025 rules
6. **`getTaxDeductionSystem(Country)`** — factory function

### Calculation Algorithm (PT)

```dart
YearlyDeductionSummary calculate(int year, Map<ExpenseCategory, double> spentByCategory) {
  final results = <CategoryDeductionResult>[];
  final groupTotals = <String, double>{};  // shared cap group raw totals

  // Pass 1: Calculate raw deductions per category
  for (final rule in rules) {
    final spent = spentByCategory[rule.category] ?? 0.0;
    double raw;
    if (rule.isVatBased) {
      raw = spent * rule.vatRate * rule.rate;  // alimentação: amount × 23% × 15%
    } else {
      raw = spent * rule.rate;
    }
    // Individual cap
    final capped = min(raw, rule.annualCap);

    if (rule.sharedCapGroup != null) {
      groupTotals[rule.sharedCapGroup!] =
          (groupTotals[rule.sharedCapGroup!] ?? 0) + capped;
    }

    results.add(CategoryDeductionResult(
      category: rule.category,
      totalSpent: spent,
      rawDeduction: raw,
      effectiveDeduction: capped, // may be adjusted in pass 2
      annualCap: rule.annualCap,
      isAtCap: raw >= rule.annualCap,
    ));
  }

  // Pass 2: Apply shared group caps (despesas_gerais: transportes + outros ≤ €250)
  for (final group in groupTotals.entries) {
    final groupCap = _sharedCaps[group.key]!;
    if (group.value > groupCap) {
      // Proportionally reduce each category in the group
      final ratio = groupCap / group.value;
      for (var i = 0; i < results.length; i++) {
        final r = results[i];
        final rule = rules.firstWhere((rl) => rl.category == r.category);
        if (rule.sharedCapGroup == group.key) {
          results[i] = r.copyWith(
            effectiveDeduction: r.effectiveDeduction * ratio,
            isAtCap: true,
          );
        }
      }
    }
  }

  final total = results.fold(0.0, (s, r) => s + r.effectiveDeduction);

  return YearlyDeductionSummary(
    year: year,
    totalDeduction: total,
    categories: results,
    nonDeductible: [
      ExpenseCategory.telecomunicacoes,
      ExpenseCategory.energia,
      ExpenseCategory.agua,
      ExpenseCategory.lazer,
    ],
  );
}
```

### Helper: Aggregate expenses by category for a year

```dart
/// Aggregates actual expenses for a given year from the expense history map.
Map<ExpenseCategory, double> aggregateYearlyExpenses(
  Map<String, List<ActualExpense>> history,
  int year,
) {
  final result = <ExpenseCategory, double>{};
  for (final entry in history.entries) {
    if (!entry.key.startsWith('$year-')) continue;
    for (final expense in entry.value) {
      final cat = ExpenseCategory.values.cast<ExpenseCategory?>().firstWhere(
        (c) => c!.name == expense.category,
        orElse: () => null,
      );
      if (cat != null) {
        result[cat] = (result[cat] ?? 0) + expense.amount;
      }
    }
  }
  return result;
}
```

---

## UI — Dashboard Card

**Visibility:** Only shown when `getTaxDeductionSystem(settings.country) != null` AND `dashboardConfig.showTaxDeductions == true` (new toggle).

**Position:** After the Savings Goals card, before the Purchase History card (logically: savings → tax benefit → spending history).

**Layout:**
```
┌──────────────────────────────────────────┐
│ 🧾 DEDUÇÕES IRS 2025                    │
│                                          │
│   Dedução estimada: €347,50              │
│                                          │
│   💊 Saúde     €800  → €120,00          │
│   🎓 Educação  €500  → €150,00          │
│   🏠 Habitação €400  → €60,00           │
│                                          │
│   [Ver detalhe completo →]               │
└──────────────────────────────────────────┘
```

- Shows top 3 categories by deduction amount (collapsed)
- Each row: icon + category name + spent + "→" + deduction
- Total deduction highlighted in bold with primary colour
- "Ver detalhe completo →" navigates to the full breakdown screen
- If total deduction is €0 (no deductible expenses recorded), show a subtle prompt: "Registe despesas de saúde, educação ou habitação para ver as suas deduções fiscais"

**Widget:** Private `_TaxDeductionCard` inside `dashboard_screen.dart`, matching the pattern of `_StressIndexCard` and `SavingsGoalCard`.

---

## UI — Detail Screen: `TaxDeductionDetailScreen`

**Navigation:** Pushed from Dashboard card tap ("Ver detalhe completo").

**Layout:**
```
┌──────────────────────────────────────────┐
│ ← Deduções IRS 2025                     │
│                                          │
│ ┌────────────────────────────────────┐   │
│ │  TOTAL ESTIMADO                    │   │
│ │  €347,50                           │   │
│ │  de um máximo de €3,052            │   │
│ └────────────────────────────────────┘   │
│                                          │
│ CATEGORIAS DEDUTÍVEIS                    │
│                                          │
│ 💊 Saúde                                │
│   Gasto: €800,00  |  Dedução: €120,00   │
│   ████████████░░░  12% de €1.000 max    │
│                                          │
│ 🎓 Educação                             │
│   Gasto: €500,00  |  Dedução: €150,00   │
│   ██████████████░  19% de €800 max      │
│                                          │
│ 🏠 Habitação                            │
│   Gasto: €400,00  |  Dedução: €60,00    │
│   ████████░░░░░░░  12% de €502 max      │
│                                          │
│ 🍽 Alimentação (IVA)                    │
│   Gasto: €1.200,00  |  Dedução: €41,40  │
│   ██████░░░░░░░░░  17% de €250 max      │
│                                          │
│ 📦 Desp. Gerais (outros + transportes)  │
│   Gasto: €300,00  |  Dedução: €105,00   │
│   ████████████████  42% de €250 max     │
│                                          │
│ ─────────────────────────────────────    │
│                                          │
│ NÃO DEDUTÍVEIS                           │
│                                          │
│ 📱 Telecomunicações  €45,00             │
│ ⚡ Energia           €80,00             │
│ 💧 Água              €25,00             │
│ 🎮 Lazer             €60,00             │
│                                          │
│ ℹ️ Valores estimados com base nas suas  │
│    despesas. Consulte o e-fatura para    │
│    valores oficiais.                     │
└──────────────────────────────────────────┘
```

**Features:**
- Progress bar for each deductible category: `effectiveDeduction / annualCap`
- Green progress bar when under 80% of cap, amber at 80-99%, full green with checkmark at 100%
- Shared cap group (transportes + outros) displayed as a merged row "Despesas Gerais" with combined amounts
- Non-deductible section in muted colours
- Footer disclaimer: estimated values, check e-fatura for official amounts

---

## Dashboard Config Toggle

Add `showTaxDeductions` to `LocalDashboardConfig`:

```dart
final bool showTaxDeductions; // default: true
```

- In `settings_screen.dart`, add a toggle row for "Deduções IRS" in the dashboard config section
- Only show the toggle when `settings.country == Country.pt` (or when `getTaxDeductionSystem(country) != null`)

---

## Data Flow

```
ActualExpenseService.loadHistory(householdId, months: 12)
  → Map<String, List<ActualExpense>>
  → aggregateYearlyExpenses(history, currentYear)
  → Map<ExpenseCategory, double>
  → PtTaxDeductionSystem().calculate(year, spentByCategory)
  → YearlyDeductionSummary
  → _TaxDeductionCard (Dashboard) / TaxDeductionDetailScreen
```

**No new API calls.** The existing `_actualExpenseHistory` in `main.dart` (already loaded for trends) provides all needed data. The deduction calculation is a pure function, cheap to run on every Dashboard rebuild.

---

## i18n Keys Needed

### Portuguese (`app_pt.arb`)
```json
"taxDeductionsTitle": "Deduções IRS {year}",
"taxDeductionsEstimated": "Dedução estimada",
"taxDeductionsViewDetail": "Ver detalhe completo",
"taxDeductionsEmptyPrompt": "Registe despesas de saúde, educação ou habitação para ver as suas deduções fiscais",
"taxDeductionsTotalEstimated": "Total estimado",
"taxDeductionsMaxPossible": "de um máximo de {amount}",
"taxDeductionsDeductibleTitle": "Categorias dedutíveis",
"taxDeductionsNonDeductibleTitle": "Não dedutíveis",
"taxDeductionsSpent": "Gasto: {amount}",
"taxDeductionsDeduction": "Dedução: {amount}",
"taxDeductionsCapProgress": "{percent}% de {cap} max",
"taxDeductionsAtCap": "Limite atingido",
"taxDeductionsGeneralExpenses": "Despesas Gerais",
"taxDeductionsFoodVat": "Alimentação (IVA)",
"taxDeductionsDisclaimer": "Valores estimados com base nas suas despesas registadas. Consulte o e-fatura da AT para valores oficiais.",
"taxDeductionsNotAvailable": "Deduções fiscais não disponíveis para o seu país",
"settingsDashTaxDeductions": "Deduções IRS"
```

### English (`app_en.arb`)
```json
"taxDeductionsTitle": "Tax Deductions {year}",
"taxDeductionsEstimated": "Estimated deduction",
"taxDeductionsViewDetail": "View full breakdown",
"taxDeductionsEmptyPrompt": "Log health, education or housing expenses to see your tax deductions",
"taxDeductionsTotalEstimated": "Total estimated",
"taxDeductionsMaxPossible": "out of a maximum of {amount}",
"taxDeductionsDeductibleTitle": "Deductible categories",
"taxDeductionsNonDeductibleTitle": "Non-deductible",
"taxDeductionsSpent": "Spent: {amount}",
"taxDeductionsDeduction": "Deduction: {amount}",
"taxDeductionsCapProgress": "{percent}% of {cap} max",
"taxDeductionsAtCap": "Cap reached",
"taxDeductionsGeneralExpenses": "General expenses",
"taxDeductionsFoodVat": "Food & restaurants (VAT)",
"taxDeductionsDisclaimer": "Estimated values based on your recorded expenses. Check the official e-fatura portal for actual amounts.",
"taxDeductionsNotAvailable": "Tax deductions not available for your country",
"settingsDashTaxDeductions": "Tax Deductions"
```

### Spanish (`app_es.arb`)
```json
"taxDeductionsTitle": "Deducciones fiscales {year}",
"taxDeductionsEstimated": "Deducción estimada",
"taxDeductionsViewDetail": "Ver desglose completo",
"taxDeductionsNotAvailable": "Deducciones fiscales no disponibles para su país",
"settingsDashTaxDeductions": "Deducciones fiscales"
```

### French (`app_fr.arb`)
```json
"taxDeductionsTitle": "Réductions d'impôt {year}",
"taxDeductionsEstimated": "Réduction estimée",
"taxDeductionsViewDetail": "Voir le détail complet",
"taxDeductionsNotAvailable": "Réductions d'impôt non disponibles pour votre pays",
"settingsDashTaxDeductions": "Réductions d'impôt"
```

**Note:** ES/FR only need the title, summary, and "not available" keys for now. Full breakdown keys are added when their deduction systems are implemented.

---

## Files Involved

### New files
- `lib/utils/tax_deductions.dart` — Pure Dart utility: `DeductionRule`, `CategoryDeductionResult`, `YearlyDeductionSummary`, `TaxDeductionSystem`, `PtTaxDeductionSystem`, `getTaxDeductionSystem()`, `aggregateYearlyExpenses()`
- `lib/screens/tax_deduction_detail_screen.dart` — Full per-category breakdown screen with progress bars, non-deductible section, and disclaimer

### Modified files
- `lib/screens/dashboard_screen.dart` — Add `_TaxDeductionCard` widget; insert between savings goals and purchase history; import `tax_deductions.dart`; compute `YearlyDeductionSummary` from `actualExpenseHistory`; pass navigation callback to detail screen
- `lib/models/local_dashboard_config.dart` — Add `showTaxDeductions` bool field (default `true`); update `copyWith`, `toJson`, `fromJson`, `minimalist()`
- `lib/screens/settings_screen.dart` — Add dashboard toggle for "Deduções IRS" (conditional on country having a deduction system)
- `lib/main.dart` — Pass `actualExpenseHistory` to `DashboardScreen` (already available as `_actualExpenseHistory`); add navigation route for `TaxDeductionDetailScreen`
- `lib/l10n/app_pt.arb` — Add ~17 new i18n keys
- `lib/l10n/app_en.arb` — Add ~17 new i18n keys
- `lib/l10n/app_es.arb` — Add ~5 stub i18n keys
- `lib/l10n/app_fr.arb` — Add ~5 stub i18n keys

### Unchanged
- `lib/models/actual_expense.dart` — Read-only, no changes
- `lib/services/actual_expense_service.dart` — Reused as-is (`loadHistory`)
- `lib/models/app_settings.dart` — Read-only (uses `ExpenseCategory`, `Country`)
- `lib/data/tax/tax_system.dart` — Read-only (uses `Country` enum)
- `lib/data/tax/pt_tax_system.dart` — Separate concern (income tax, not deductions)
- `lib/data/tax/tax_factory.dart` — Not modified; deductions have their own factory
- Supabase schema — Zero changes, uses existing `actual_expenses` table

---

## Testing Strategy

### Unit tests — `test/tax_deductions_test.dart`
- PT rules: verify each category rate and cap individually
- Shared cap: transportes + outros combined exceeds €250 → proportional reduction
- Alimentação VAT calculation: `€1000 × 0.23 × 0.15 = €34.50`
- Cap enforcement: saúde at €10,000 spent → deduction capped at €1,000
- Zero expenses → all deductions are €0
- Mixed year data: only expenses matching the requested year are aggregated
- `getTaxDeductionSystem(Country.es)` returns `null`
- `getTaxDeductionSystem(Country.pt)` returns `PtTaxDeductionSystem`

### Widget tests — `test/tax_deduction_card_test.dart`
- Card hidden when country is ES/FR/UK
- Card hidden when `showTaxDeductions == false`
- Card shows empty prompt when no deductible expenses exist
- Card shows top 3 categories sorted by deduction amount
- Tap navigates to detail screen

---

## Future Extensibility

- **ES (deducciones):** Subclass `TaxDeductionSystem` → `EsTaxDeductionSystem` with Spanish IRPF deduction rules
- **FR (réductions d'impôt):** Subclass → `FrTaxDeductionSystem` with French income tax credits
- **UK (tax reliefs):** Subclass → `UkTaxDeductionSystem` with UK-specific reliefs (e.g. Gift Aid)
- **Year-versioned rules:** `PtTaxDeductionSystem` can accept a `year` parameter to load different rule sets as legislation changes (2025, 2026, etc.)
- **E-Fatura API integration:** Future enhancement could pull actual e-fatura data from AT's API for verified deduction amounts instead of estimates
