# Meal Planner Settings Design

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:writing-plans to create the implementation plan from this design.

**Goal:** Add a configurable meal settings system that allows users to control which meals to generate, dietary restrictions, financial strategy, kitchen logistics, and batch cooking — with a first-time wizard and detailed settings section.

**Architecture:** New `MealSettings` model embedded in `AppSettings` (serialized in existing `settings_json`), a 5-step wizard screen shown on first use, a new "Refeições" section in SettingsScreen, and a fully updated generator that respects all rules. Recipe catalog updated with dietary/equipment/batch attributes.

**Tech Stack:** Flutter/Dart, Supabase (existing settings_json), local JSON asset catalog

---

## 1. MealSettings Model

New file: `lib/models/meal_settings.dart`

```dart
enum MealType { breakfast, lunch, snack, dinner }

enum MealObjective {
  minimizeCost, balancedHealth, highProtein,
  lowCarb, vegetarian, custom
}

enum KitchenEquipment { oven, airFryer, foodProcessor, pressureCooker, microwave }

class MealSettings {
  // Which meals to generate per day
  final Set<MealType> enabledMeals;       // default: {lunch, dinner}

  // Primary objective
  final MealObjective objective;          // default: balancedHealth

  // Dietary restrictions
  final bool glutenFree;
  final bool lactoseFree;
  final bool nutFree;
  final bool shellfishFree;
  final List<String> otherRestrictions;   // free text list

  // Negative preferences (ingredient names as chips)
  final List<String> dislikedIngredients;

  // Excluded proteins (ingredient ids)
  final List<String> excludedProteins;

  // Veggie days per week (0–7)
  final int veggieDaysPerWeek;

  // Financial strategy
  final bool prioritizeLowCost;
  final bool minimizeWaste;
  final int maxNewIngredientsPerWeek;     // slider 1–10, default 5

  // Kitchen logistics
  final int maxPrepMinutes;              // 15 / 30 / 45 / 60
  final int maxComplexity;              // 1–5
  final Set<KitchenEquipment> availableEquipment;

  // Batch cooking
  final bool batchCookingEnabled;
  final int maxBatchDays;               // 1–4
  final int? preferredCookingWeekday;   // 0=Mon … 6=Sun, null=none

  // Leftovers
  final bool reuseLeftovers;

  // UI mode
  final bool advancedMode;
  final bool wizardCompleted;
}
```

Budget weight per meal type (fixed, redistributed proportionally for active meals only):

| MealType  | Weight |
|-----------|--------|
| breakfast | 10%    |
| lunch     | 35%    |
| snack     | 15%    |
| dinner    | 40%    |

`MealSettings` is added to `AppSettings` as `final MealSettings mealSettings` and serialized inside the existing `settings_json` field — zero Supabase schema changes required.

---

## 2. Recipe Catalog Updates

Each recipe in `assets/meal_planner/recipes.json` gains new fields:

```json
{
  "id": "frango_assado",
  "glutenFree": true,
  "lactoseFree": true,
  "nutFree": true,
  "shellfishFree": true,
  "isVegetarian": false,
  "isHighProtein": true,
  "isLowCarb": true,
  "requiresEquipment": ["oven"],
  "batchCookable": true,
  "maxBatchDays": 3
}
```

All existing recipes must be annotated with these attributes. The `Recipe` Dart model is updated with these fields (safe defaults: `glutenFree: false`, `requiresEquipment: []`, `batchCookable: false`, `maxBatchDays: 1`).

---

## 3. Wizard Screen (`MealWizardScreen`)

Shown automatically when `mealSettings.wizardCompleted == false`. Full-screen with progress bar (5 steps). On completion, saves settings and immediately generates the plan.

**Step 1 — Refeições**
Four toggles: PA / Almoço / Lanche / Jantar. Each shows its budget weight dynamically (e.g. "Jantar · 40% do orçamento").

**Step 2 — Objetivo**
Radio select: Minimizar custo / Equilíbrio / Alta proteína / Baixo carboidrato / Vegetariano / Personalizado. Selecting "Vegetariano" auto-sets `veggieDaysPerWeek = 7`.

**Step 3 — Restrições & Preferências**
Checkboxes: Sem glúten / Sem lactose / Sem frutos secos / Sem marisco / Outros (text field). Below: editable chips for `dislikedIngredients` (e.g. "atum", "brócolos").

**Step 4 — Cozinha**
Slider for max prep time (15/30/45/60+ min). Segmented button for complexity (Fácil=2 / Médio=3 / Avançado=5). Equipment checkboxes: Forno / Air Fryer / Robot de cozinha / Panela de pressão / Micro-ondas.

**Step 5 — Estratégia**
Toggle batch cooking + slider for max batch days (1–4) + weekday selector for preferred cooking day. Toggle leftovers reuse. Slider for max new ingredients/week (1–10).

**Finish button:** "Gerar Plano" → saves `MealSettings` with `wizardCompleted: true` → calls `generate()` → shows plan.

**Post-wizard banner:** Persistent info message: *"Podes alterar as definições do planeador em Definições → Refeições"*

---

## 4. Settings Screen — "Refeições" Section

New collapsible section in `SettingsScreen` between "Produtos Favoritos" and "Coach IA". Contains the same fields as the wizard, organized in the same groups, but all visible at once (in advanced mode).

Includes a **"Repor Wizard"** button that resets `wizardCompleted = false` so the user can re-run the guided flow.

---

## 5. MealPlannerScreen Integration

- **⚙️ button in AppBar** → `Navigator.push` to `SettingsScreen`, auto-opens "Refeições" section
- **Wizard gate:** if `!mealSettings.wizardCompleted` → show `MealWizardScreen` instead of normal view
- **"Regenerar" button** → always visible in plan view header, shows confirmation dialog before clearing existing plan

---

## 6. Generator Updates (`MealPlannerService.generate()`)

Signature change: `generate(AppSettings settings, DateTime forMonth, {List<String> favorites})` — `MealSettings` extracted from `settings.mealSettings` internally.

**Pipeline (applied in order):**

1. **Base filter (eliminatory)**
   - Remove recipes requiring unavailable equipment
   - Remove recipes with disliked ingredients or excluded proteins
   - Apply dietary restriction flags
   - Remove recipes above `maxComplexity` or `maxPrepMinutes`

2. **Objective filter**
   - `minimizeCost` → sort by cost ascending
   - `highProtein` → filter `isHighProtein == true`, then sort by cost
   - `lowCarb` → filter `isLowCarb == true`
   - `vegetarian` → filter `isVegetarian == true`
   - `balancedHealth` → current rotation behavior
   - `custom` → restrictions only, no extra filter

3. **Veggie days**
   Distribute `veggieDaysPerWeek` days across the week forcing `isVegetarian == true`.

4. **Waste minimization / new ingredients cap**
   Track ingredient set used per week. Prefer recipes reusing known ingredients. If `maxNewIngredientsPerWeek` reached, filter to recipes introducing zero new ingredients.

5. **Batch cooking**
   If `batchCookingEnabled`, repeat same recipe for consecutive days up to `maxBatchDays`. Start blocks on `preferredCookingWeekday`.

6. **Multi-meal generation**
   Generate one `MealDay` entry per active `MealType` per day. Budget per meal type = total food budget × normalized weight.

7. **Leftovers**
   If `reuseLeftovers`, lunch on day N reuses dinner from day N-1 (same recipe, cost = 0 — already counted).

---

## 7. Data Flow

```
MealSettings (in AppSettings)
  → serialized to settings_json (Supabase)
  → loaded via SettingsService
  → passed to MealPlannerScreen via widget.settings.mealSettings
  → used by MealPlannerService.generate()
  → MealWizardScreen saves via onSave callback (same as rest of settings)
```

---

## 8. New Files

- `lib/models/meal_settings.dart` — MealSettings + enums
- `lib/screens/meal_wizard_screen.dart` — 5-step wizard
- Updates: `lib/models/app_settings.dart`, `lib/models/meal_planner.dart`, `lib/services/meal_planner_service.dart`, `lib/screens/settings_screen.dart`, `lib/screens/meal_planner_screen.dart`
- Asset: `assets/meal_planner/recipes.json` — annotate all recipes with new attributes
