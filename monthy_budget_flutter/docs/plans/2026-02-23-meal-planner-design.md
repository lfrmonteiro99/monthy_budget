# Meal Planner Design

**Date:** 2026-02-23
**Branch:** claude/budget-calculator-app-TFWgZ

---

## Context

Monthly dinner planner integrated into the budget app. Generates a 30-day dinner plan constrained by the food budget defined in settings, minimising cost through ingredient clustering. Hybrid architecture: local algorithm controls all numeric decisions; OpenAI enriches recipe content only.

---

## Requirements

- Monthly plan (dinners only, ~30 days)
- Must not exceed `expenses[alimentacao].amount` from settings
- Minimise cost (cheapest valid plan wins)
- `nPessoas` = `sum(salaries[enabled].titulares)` + `personalInfo.dependentes`
- Ingredient prices: curated static catalog with average Portuguese market prices
- Ingredient-level add-to-shopping-list integration (existing `ShoppingListService`)
- "Trocar refeição" per day with cost recalculation
- OpenAI enrichment (steps, tips) loads asynchronously after plan is ready

---

## Data Models

### `IngredientCategory` (enum)
`proteina | carbo | vegetal | gordura | condimento`

### `RecipeType` (enum)
`carne | peixe | vegetariano | ovos | leguminosas`

### `Ingredient`
| Field | Type | Description |
|---|---|---|
| `id` | String | Unique key |
| `name` | String | Display name (PT) |
| `category` | IngredientCategory | |
| `unit` | String | `kg`, `unidade`, `litro`, `g` |
| `avgPricePerUnit` | double | € per unit |
| `minPurchaseQty` | double | Minimum realistic purchase quantity |

### `RecipeIngredient`
| Field | Type | Description |
|---|---|---|
| `ingredientId` | String | FK to Ingredient |
| `quantity` | double | In ingredient's unit |

### `Recipe` (catalog entry)
| Field | Type | Description |
|---|---|---|
| `id` | String | |
| `name` | String | |
| `proteinId` | String | Dominant protein ingredient id |
| `ingredients` | List\<RecipeIngredient\> | |
| `prepMinutes` | int | |
| `complexity` | int | 1–5 |
| `type` | RecipeType | |
| `servings` | int | Base servings (scales to nPessoas) |

### `MealDay`
| Field | Type | Description |
|---|---|---|
| `dayIndex` | int | 1–30 |
| `recipeId` | String | |
| `isLeftover` | bool | |
| `costEstimate` | double | Cost for nPessoas |

### `MealPlan`
| Field | Type | Description |
|---|---|---|
| `month` | int | |
| `year` | int | |
| `nPessoas` | int | Derived from settings |
| `monthlyBudget` | double | From settings alimentacao |
| `days` | List\<MealDay\> | |
| `totalEstimatedCost` | double | |
| `generatedAt` | DateTime | |

---

## Algorithm

```
INPUT: nPessoas, monthlyBudget, month/year

STEP 1 — Protein cluster selection
  5 base proteins ordered by cost (ascending):
  leguminosas → ovos → carne picada → frango → peixe barato
  Distribute across 4 weeks:
    Week 1: frango (dominant) + leguminosas (variety)
    Week 2: carne picada (dominant) + ovos (variety)
    Week 3: leguminosas (dominant) + frango (variety)
    Week 4: peixe (dominant) + carne picada (variety)

STEP 2 — Budget allocation
  weekBudget = monthlyBudget / 4
  dailyBudget = weekBudget / 7

STEP 3 — Greedy recipe selection per week
  For each week:
    Filter recipes by dominant protein
    Sort by cost/person ascending
    Select 5 recipes (cheapest first)
    Select 2 variety recipes
    = 7 dinners

STEP 4 — Waste minimisation
  Group recipes sharing heavy ingredients (chicken, potato, carrot)
  within the same week → min purchase quantities are consumed

STEP 5 — Budget validation
  totalCost = sum(recipe.costForNPessoas) across 30 days
  IF totalCost > monthlyBudget:
    Replace most expensive recipes with cheaper alternatives
    Repeat until totalCost <= monthlyBudget

STEP 6 — OpenAI enrichment (async, non-blocking)
  For each unique recipe in the plan:
    Call GPT with: name, ingredients, nPessoas
    Return: preparation steps, tips, one variation suggestion
  Plan is usable immediately; AI content loads progressively
```

**Hard guarantee:** budget validation runs locally before any OpenAI call. The LLM never touches numeric decisions.

---

## UX

### New tab: "Refeições" (icon: `restaurant_outlined`) — 5th tab in bottom nav

### State 1: No plan
- Displays food budget and nPessoas read from settings (read-only)
- Single "Gerar Plano Mensal" CTA

### State 2: Plan generated
- Header: `180,40€ / 220,00€` with progress bar
- Week tabs: `[Sem.1] [Sem.2] [Sem.3] [Sem.4]`
- Day cards:
  - Recipe name, complexity stars, prep time, cost/person
  - Expandable ingredient list — each ingredient has `[+ Lista]` button
  - `[Trocar]` button per card
- `[Ver lista consolidada]` sticky bottom button

### Swap bottom sheet
- Shows 3 alternative recipes from same protein cluster
- Each shows cost delta vs current
- Selection triggers total cost recalculation

### Consolidated list bottom sheet
- Ingredients grouped by category (Proteínas, Vegetais, Carbos…)
- Aggregated quantities across full month
- `[+ Lista]` per item → adds to existing ShoppingList

---

## Services

| Service | Responsibility |
|---|---|
| `MealPlannerService` | Algorithm, persistence (SharedPreferences key: `meal_plan`) |
| `MealPlannerAiService` | OpenAI enrichment calls, reuses existing API key |

---

## Static Assets

```
assets/meal_planner/
├── ingredients.json    # ~40 ingredients with avg PT prices
└── recipes.json        # ~70 recipes referencing ingredient ids
```

Registered in `pubspec.yaml` under `flutter.assets`.

---

## Integration Points

```dart
// Budget
final foodBudget = settings.expenses
  .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
  .fold(0.0, (sum, e) => sum + e.amount);

// nPessoas
final nPessoas = settings.salaries
  .where((s) => s.enabled)
  .fold(0, (sum, s) => sum + s.titulares)
  + settings.personalInfo.dependentes;

// Add ingredient to shopping list (existing infrastructure)
_addToShoppingList(ShoppingItem(
  productName: ingredient.name,
  store: '',
  price: ingredient.avgPricePerUnit * quantity,
));
```

---

## Success Metric

Deviation between estimated cost and real monthly spend < 10%.
