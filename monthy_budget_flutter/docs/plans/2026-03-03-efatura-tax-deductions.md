# E-Fatura Tax Deduction Tracker — Design

**Goal:** Surface how much IRS tax benefit users accumulate from their categorized expenses. Show per-category deduction amounts (e.g. "Health expenses: €X → IRS deduction: €Y") with a Dashboard card and detail view.

**Architecture:** Pure Dart utility `lib/utils/tax_deductions.dart` + Dashboard card + detail bottom sheet. Uses existing `ActualExpenseService.loadHistory()` data — zero Supabase schema changes. Country-gated: only PT initially, extensible to ES/FR/UK.

**Tech Stack:** Flutter/Dart, existing ActualExpenseService, existing ExpenseCategory enum.

---

## 1. Portuguese IRS Deduction Rules (2025)

| ExpenseCategory | IRS Category | Rate | Annual Cap | Notes |
|---|---|---|---|---|
| saude | Saúde | 15% | €1,000 | Direct deduction |
| educacao | Educação | 30% | €800 | Direct deduction |
| habitacao | Habitação | 15% | €502 | Rent/mortgage interest |
| transportes | Despesas Gerais | 35% | €250 (shared) | Shares cap with 'outros' |
| outros | Despesas Gerais | 35% | €250 (shared) | Combined cap with transportes |
| alimentacao | Restauração | 15% of VAT | €250 | VAT-based (approximate as 15% × 23% × amount) |
| telecomunicacoes | — | 0% | — | Not deductible |
| energia | — | 0% | — | Not deductible |
| agua | — | 0% | — | Not deductible |
| lazer | — | 0% | — | Not deductible |

**Note:** The "Despesas Gerais" €250 cap is shared across transportes + outros. If combined exceeds cap, reduce proportionally.

---

## 2. Data Model

New file: `lib/utils/tax_deductions.dart`

```dart
class DeductionRule {
  final String irsCategory;
  final double rate;
  final double annualCap;
  final bool isVatBased; // alimentacao: 15% of VAT, not of amount
  final String? sharedCapGroup; // 'despesas_gerais' for transportes+outros

  const DeductionRule({...});
}

class CategoryDeductionResult {
  final String category;
  final String irsCategory;
  final double totalSpent;
  final double deductibleAmount;
  final double capUsed;
  final double capRemaining;
}

class YearlyDeductionSummary {
  final int year;
  final List<CategoryDeductionResult> categories;
  final double totalDeductions;
  final Map<String, double> sharedCapUsage; // group → amount used
}
```

---

## 3. Deduction System

```dart
abstract class TaxDeductionSystem {
  Map<String, DeductionRule> get rules; // category name → rule
  YearlyDeductionSummary calculate(Map<String, double> yearlyByCategory);
}

class PtTaxDeductionSystem extends TaxDeductionSystem { ... }

TaxDeductionSystem? getDeductionSystem(Country country) {
  switch (country) {
    case Country.pt: return PtTaxDeductionSystem();
    default: return null; // hidden for non-PT
  }
}
```

Calculation algorithm:
1. For each category with a rule, compute raw deduction = amount × rate (or amount × VAT rate × 15% for alimentacao)
2. Clamp each to its individual cap
3. For shared cap groups, if combined exceeds shared cap, reduce proportionally
4. Sum all for total

---

## 4. Dashboard Card

**Position:** After Savings Goals card, before Charts. Only visible when `country == Country.pt` and deduction system exists.

```
┌──────────────────────────────────────────┐
│ 🧾 DEDUÇÕES IRS 2026                     │
│                                          │
│   €847 em deduções estimadas             │
│   ████████████████░░░░  (de máx. €2,800) │
│                                          │
│  Saúde      €432 / €1,000               │
│  Educação   €240 / €800                  │
│  Habitação  €175 / €502                  │
│                                          │
│  [Ver detalhes ▸]                        │
└──────────────────────────────────────────┘
```

Toggle: `showTaxDeductions` in `LocalDashboardConfig` (default: true for PT).

---

## 5. Detail Bottom Sheet

Shows all deductible categories with progress bars, plus non-deductible categories grayed out. Disclaimer: "Valores estimados. Consulte o Portal das Finanças para valores oficiais."

---

## 6. Data Flow

```
Dashboard render
  → ActualExpenseService.loadHistory(householdId, months: 12)
  → filter to current fiscal year (Jan–Dec)
  → aggregate by category
  → PtTaxDeductionSystem.calculate(yearlyByCategory)
  → render card with YearlyDeductionSummary
```

---

## 7. i18n Keys

- `taxDeductionsTitle`, `taxDeductionsEstimated`, `taxDeductionsOfMax`
- `taxDeductionsCategory` (parameterized), `taxDeductionsViewDetails`
- `taxDeductionsDisclaimer`, `taxDeductionsNoData`
- `taxDeductionsNonDeductible`, `taxDeductionsSharedCap`

---

## 8. Files Involved

### New files
- `lib/utils/tax_deductions.dart` — DeductionRule, TaxDeductionSystem, PtTaxDeductionSystem, calculation logic

### Modified files
- `lib/models/local_dashboard_config.dart` — add `showTaxDeductions` toggle
- `lib/screens/dashboard_screen.dart` — add `_TaxDeductionsCard` widget
- `lib/screens/settings_screen.dart` — add dashboard toggle
- `lib/l10n/app_*.arb` (4 files) — new i18n keys
- `lib/l10n/generated/app_localizations*.dart` (5 files) — auto-generated
