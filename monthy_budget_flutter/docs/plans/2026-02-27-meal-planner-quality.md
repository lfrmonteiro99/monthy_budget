# Meal Planner Quality Overhaul — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix critical algorithm bugs, expand the recipe catalog from 25→65+, and polish the meal planner UX so generated plans are realistic, varied, and respect user settings.

**Architecture:** All changes are local to the meal planner subsystem (service, models, JSON catalogs, screen). No Supabase schema changes. The core fix is replacing the deterministic index-based recipe picker with a shuffle-based approach that respects meal types, avoids same-day duplicates, and uses real costs.

**Tech Stack:** Dart/Flutter, JSON asset catalogs, existing MealPlannerService

---

## Tier 1 — Fix What's Broken

### Task 1: Add `suitableMealTypes` to Recipe model

The current Recipe model has no concept of which meals a recipe suits. Bacalhau Cozido can appear at breakfast. This field gates all subsequent meal-type filtering.

**Files:**
- Modify: `lib/models/meal_planner.dart:54-141` (Recipe class)

**Step 1: Add the field to Recipe**

In `lib/models/meal_planner.dart`, add a `suitableMealTypes` field to the Recipe class:

```dart
// After line 72 (maxBatchDays)
final List<String> suitableMealTypes; // e.g. ['lunch','dinner'], ['breakfast','snack']
```

Default in constructor: `this.suitableMealTypes = const ['lunch', 'dinner']`

In `fromJson`: `suitableMealTypes: List<String>.from(json['suitableMealTypes'] ?? ['lunch', 'dinner'])`

In `toJson`: `'suitableMealTypes': suitableMealTypes,`

**Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No new issues

---

### Task 2: Fix cost distortion — remove `mealBudgetRatio` multiplier

**Bug:** Lines 265-268 and 176-179 of `meal_planner_service.dart` multiply the real ingredient cost by `mealBudgets[type] / totalBudget` (0.10–0.40). A recipe that costs 8€ in ingredients shows as 0.80€–3.20€. This makes budget enforcement nearly inert and all displayed costs wrong.

**Files:**
- Modify: `lib/services/meal_planner_service.dart:176-179,265-268`

**Step 1: Remove mealBudgetRatio from main loop**

Replace lines 265-268:
```dart
        final mealBudgetRatio = totalBudget > 0
            ? (mealBudgets[mealType] ?? 0) / totalBudget
            : 1.0;
        final cost = recipeCost(recipe, np, iMap) * mealBudgetRatio;
```
With:
```dart
        final cost = recipeCost(recipe, np, iMap);
```

**Step 2: Remove mealBudgetRatio from batch cooking block**

Replace lines 176-179:
```dart
            final mealBudgetRatio = totalBudget > 0
                ? (mealBudgets[mealType] ?? 0) / totalBudget
                : 1.0;
            final cost = recipeCost(recipe, np, iMap) * mealBudgetRatio;
```
With:
```dart
            final cost = recipeCost(recipe, np, iMap);
```

**Step 3: Remove now-unused `mealBudgets` computation (lines 76-83)**

Delete lines 76-83 (the `enabledWeights`, `totalWeight`, `mealBudgets` block) since they're no longer referenced.

**Step 4: Run flutter analyze**

Run: `flutter analyze`
Expected: No new issues (no other code references `mealBudgets`)

---

### Task 3: Fix unsafe fallback — preserve allergy filters

**Bug:** Line 131 `if (pool.isEmpty) pool = _recipes.toList();` discards ALL dietary/allergy filtering. A celiac user who excludes all non-gluten-free recipes gets the entire unfiltered catalog, including gluten-containing recipes.

**Files:**
- Modify: `lib/services/meal_planner_service.dart:86-133`

**Step 1: Split basePool into hard filters + soft filters**

Replace line 131:
```dart
      if (pool.isEmpty) pool = _recipes.toList(); // fallback: no filters
```
With:
```dart
      if (pool.isEmpty) {
        // Fallback: keep allergy/dietary hard filters, drop only soft filters (objective)
        pool = _recipes.where((r) {
          if (ms.glutenFree && !r.glutenFree) return false;
          if (ms.lactoseFree && !r.lactoseFree) return false;
          if (ms.nutFree && !r.nutFree) return false;
          if (ms.shellfishFree && !r.shellfishFree) return false;
          if (ms.excludedProteins.contains(r.proteinId)) return false;
          for (final ri in r.ingredients) {
            final ing = iMap[ri.ingredientId];
            if (ing == null) continue;
            if (ms.dislikedIngredients.any((d) =>
                d.toLowerCase() == ing.name.toLowerCase())) {
              return false;
            }
          }
          return true;
        }).toList();
      }
      // Ultimate fallback: if still empty after allergy filters, use full list
      // (better to show something than an empty plan)
      if (pool.isEmpty) pool = _recipes.toList();
```

**Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No new issues

---

### Task 4: Fix deterministic selection — add meal-type filtering + shuffle

**Bug:** Lines 258-263 pick recipes by `(weekIndex * 7 + slotInWeek) % pool.length`. This is completely deterministic (same plan every month) and the index is identical for all meal types on the same day (lunch and dinner get the same recipe).

**Files:**
- Modify: `lib/services/meal_planner_service.dart:67,86,214,258-263`

**Step 1: Add dart:math import and Random parameter**

At the top of the file, add `import 'dart:math';`

Add a `Random` instance at the start of `generate()`, after line 68:
```dart
    final rng = Random();
```

**Step 2: Filter pool by suitableMealTypes in basePool**

Inside `basePool()`, add meal-type filter as the first check (after line 87):
```dart
        if (!r.suitableMealTypes.contains(mealType.name)) return false;
```

**Step 3: Track used recipes per day to avoid duplicates**

Before the day loop (before line 158), add:
```dart
    final usedRecipesPerDay = <int, Set<String>>{};
```

Inside the day loop, before the mealType loop (after line 168):
```dart
      usedRecipesPerDay[day] = {};
```

**Step 4: Replace deterministic picker with shuffle + dedup**

Replace lines 258-263:
```dart
        // Pick recipe (rotate by day slot)
        final weekIndex = ((day - 1) ~/ 7).clamp(0, 3);
        final slotInWeek = (day - 1) % 7;
        final fallbackPool = pool.isNotEmpty ? pool : _recipes;
        final recipe = fallbackPool[
            (weekIndex * 7 + slotInWeek) % fallbackPool.length];
```
With:
```dart
        // Pick recipe: shuffle + avoid same-day duplicates
        final usedToday = usedRecipesPerDay[day]!;
        var available = pool.where((r) => !usedToday.contains(r.id)).toList();
        if (available.isEmpty) available = pool.toList();
        if (available.isEmpty) available = _recipes.toList();
        available.shuffle(rng);
        final recipe = available.first;
        usedToday.add(recipe.id);
```

**Step 5: Run flutter analyze**

Run: `flutter analyze`
Expected: No new issues

---

### Task 5: Fix `_enforceBudget` to respect dietary constraints

**Bug:** `_enforceBudget()` (lines 327-334) searches for cheaper replacements in `_recipes` (the full unfiltered catalog). It can swap a gluten-free recipe with a gluten-containing one. Also only searches same-protein, severely limiting options.

**Files:**
- Modify: `lib/services/meal_planner_service.dart:67,316-349`

**Step 1: Pass MealSettings to _enforceBudget**

Change the signature of `_enforceBudget` to accept `MealSettings`:
```dart
MealPlan _enforceBudget(MealPlan plan, int np, Map<String, Ingredient> iMap, MealSettings ms) {
```

Update the call site at line 312:
```dart
    plan = _enforceBudget(plan, np, iMap, ms);
```

**Step 2: Filter replacement candidates through allergy filters**

Replace lines 327-334:
```dart
      final cheaper = _recipes
          .where((r) =>
              r.proteinId == currentRecipe.proteinId &&
              r.id != currentRecipe.id)
          .map((r) => (recipe: r, cost: recipeCost(r, np, iMap)))
          .where((e) => e.cost < expensive.costEstimate)
          .toList()
        ..sort((a, b) => a.cost.compareTo(b.cost));
```
With:
```dart
      final cheaper = _recipes.where((r) {
        if (r.id == currentRecipe.id) return false;
        if (ms.glutenFree && !r.glutenFree) return false;
        if (ms.lactoseFree && !r.lactoseFree) return false;
        if (ms.nutFree && !r.nutFree) return false;
        if (ms.shellfishFree && !r.shellfishFree) return false;
        if (ms.excludedProteins.contains(r.proteinId)) return false;
        if (!r.suitableMealTypes.contains(expensive.mealType.name)) return false;
        return true;
      })
          .map((r) => (recipe: r, cost: recipeCost(r, np, iMap)))
          .where((e) => e.cost < expensive.costEstimate)
          .toList()
        ..sort((a, b) => a.cost.compareTo(b.cost));
```

**Step 3: Run flutter analyze**

Run: `flutter analyze`
Expected: No new issues

---

### Task 6: Fix days 29-31 invisible in UI

**Bug:** `_getWeekDays()` at line 364-368 calculates weeks 0-3 (days 1-28). Days 29-31 are never displayed.

**Files:**
- Modify: `lib/screens/meal_planner_screen.dart:364-368`

**Step 1: Fix _getWeekDays to include days 29-31 in week 4**

Replace lines 364-368:
```dart
  List<MealDay> _getWeekDays(MealPlan plan, int weekIndex) {
    final start = weekIndex * 7 + 1;
    final end = start + 6;
    return plan.days.where((d) => d.dayIndex >= start && d.dayIndex <= end).toList();
  }
```
With:
```dart
  List<MealDay> _getWeekDays(MealPlan plan, int weekIndex) {
    final start = weekIndex * 7 + 1;
    final daysInMonth = DateTime(plan.year, plan.month + 1, 0).day;
    final end = weekIndex == 4 ? daysInMonth : start + 6;
    return plan.days.where((d) => d.dayIndex >= start && d.dayIndex <= end).toList();
  }
```

**Step 2: Fix week tab count — allow 5th week when month has 29-31 days**

Find the week tab builder in the screen (the `_selectedWeek` logic and tab count). Currently it shows 4 tabs (weeks 0-3). Update the week count:

```dart
final daysInMonth = DateTime(_plan!.year, _plan!.month + 1, 0).day;
final weekCount = (daysInMonth / 7).ceil();
```

Use `weekCount` instead of hardcoded `4` for the tab/chip generation and clamp `_selectedWeek`.

**Step 3: Run flutter analyze**

Run: `flutter analyze`
Expected: No new issues

---

### Task 7: Fix leftover stale reference

**Bug:** Lines 197-211: when `reuseLeftovers` is on, lunch copies the previous dinner's recipeId. But `_enforceBudget` (which runs after plan generation) may swap that dinner recipe. The leftover now points to a recipe the user isn't actually eating.

**Files:**
- Modify: `lib/services/meal_planner_service.dart:316-349`

**Step 1: Add leftover correction pass after budget enforcement**

After the `days.sort(...)` line in `_enforceBudget` (line 347), before `return`, add:

```dart
    // Fix stale leftover references
    for (int i = 0; i < days.length; i++) {
      if (!days[i].isLeftover) continue;
      final dinnerDay = days[i].dayIndex - 1;
      final dinner = days.where(
        (d) => d.dayIndex == dinnerDay && d.mealType == MealType.dinner,
      ).firstOrNull;
      if (dinner != null && dinner.recipeId != days[i].recipeId) {
        days[i] = days[i].copyWith(recipeId: dinner.recipeId, costEstimate: 0);
      }
    }
```

**Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No new issues

---

### Task 8: Commit Tier 1

```bash
git add lib/models/meal_planner.dart lib/services/meal_planner_service.dart lib/screens/meal_planner_screen.dart
git commit -m "claude/budget-calculator-app-TFWgZ: fix meal planner critical bugs — cost distortion, allergy fallback, deterministic selection, days 29-31, stale leftovers"
```

---

## Tier 2 — Expand Recipe Catalog

### Task 9: Add missing ingredients to ingredients.json

Currently 25 ingredients. Add ~15 missing ingredients needed for Portuguese cuisine and breakfast/snack recipes.

**Files:**
- Modify: `assets/meal_planner/ingredients.json`

**Step 1: Add new ingredient entries**

Append these ingredients to the JSON array:

```json
{"id":"porco","name":"Carne de Porco","category":"proteina","unit":"kg","avgPricePerUnit":4.50,"minPurchaseQty":0.5},
{"id":"sardinha","name":"Sardinhas","category":"proteina","unit":"kg","avgPricePerUnit":4.00,"minPurchaseQty":0.5},
{"id":"atum_lata","name":"Atum (lata)","category":"proteina","unit":"unidade","avgPricePerUnit":1.20,"minPurchaseQty":1.0},
{"id":"iogurte","name":"Iogurte Natural","category":"proteina","unit":"unidade","avgPricePerUnit":0.30,"minPurchaseQty":4.0},
{"id":"leite","name":"Leite","category":"proteina","unit":"litro","avgPricePerUnit":0.75,"minPurchaseQty":1.0},
{"id":"queijo","name":"Queijo Flamengo","category":"proteina","unit":"kg","avgPricePerUnit":6.50,"minPurchaseQty":0.2},
{"id":"fiambre","name":"Fiambre","category":"proteina","unit":"kg","avgPricePerUnit":5.00,"minPurchaseQty":0.2},
{"id":"cereais","name":"Cereais/Muesli","category":"carbo","unit":"kg","avgPricePerUnit":3.50,"minPurchaseQty":0.5},
{"id":"pao_forma","name":"Pão de Forma","category":"carbo","unit":"unidade","avgPricePerUnit":1.50,"minPurchaseQty":1.0},
{"id":"aveia","name":"Flocos de Aveia","category":"carbo","unit":"kg","avgPricePerUnit":2.00,"minPurchaseQty":0.5},
{"id":"fruta","name":"Fruta da Época","category":"vegetal","unit":"kg","avgPricePerUnit":1.50,"minPurchaseQty":1.0},
{"id":"banana","name":"Banana","category":"vegetal","unit":"kg","avgPricePerUnit":1.20,"minPurchaseQty":1.0},
{"id":"alface","name":"Alface","category":"vegetal","unit":"unidade","avgPricePerUnit":0.60,"minPurchaseQty":1.0},
{"id":"cogumelos","name":"Cogumelos","category":"vegetal","unit":"kg","avgPricePerUnit":3.50,"minPurchaseQty":0.3},
{"id":"manteiga","name":"Manteiga","category":"gordura","unit":"kg","avgPricePerUnit":7.00,"minPurchaseQty":0.25},
{"id":"natas","name":"Natas","category":"gordura","unit":"litro","avgPricePerUnit":1.50,"minPurchaseQty":0.2}
```

**Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues

---

### Task 10: Add pork recipes (5 new)

**Files:**
- Modify: `assets/meal_planner/recipes.json`

**Step 1: Add 5 pork recipes**

Append to recipes.json:

```json
{
  "id":"costeletas_porco","name":"Costeletas de Porco Grelhadas","proteinId":"porco",
  "type":"carne","complexity":1,"prepMinutes":20,"servings":4,
  "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
  "isVegetarian":false,"isHighProtein":true,"isLowCarb":true,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"porco","quantity":0.6},
    {"ingredientId":"batata","quantity":0.5},
    {"ingredientId":"alho","quantity":0.02},
    {"ingredientId":"azeite","quantity":0.05}
  ]
},
{
  "id":"porco_alentejana","name":"Carne de Porco à Alentejana","proteinId":"porco",
  "type":"carne","complexity":3,"prepMinutes":45,"servings":4,
  "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":false,
  "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"porco","quantity":0.5},
    {"ingredientId":"batata","quantity":0.4},
    {"ingredientId":"alho","quantity":0.03},
    {"ingredientId":"azeite","quantity":0.05}
  ]
},
{
  "id":"bifanas","name":"Bifanas","proteinId":"porco",
  "type":"carne","complexity":1,"prepMinutes":15,"servings":4,
  "glutenFree":false,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
  "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"porco","quantity":0.5},
    {"ingredientId":"pao","quantity":4.0},
    {"ingredientId":"alho","quantity":0.02},
    {"ingredientId":"azeite","quantity":0.03}
  ]
},
{
  "id":"porco_assado","name":"Lombo de Porco Assado","proteinId":"porco",
  "type":"carne","complexity":2,"prepMinutes":50,"servings":4,
  "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
  "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
  "requiresEquipment":["oven"],"batchCookable":true,"maxBatchDays":3,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"porco","quantity":0.8},
    {"ingredientId":"batata","quantity":0.6},
    {"ingredientId":"cebola","quantity":0.2},
    {"ingredientId":"azeite","quantity":0.05}
  ]
},
{
  "id":"feijoada_porco","name":"Feijoada à Transmontana","proteinId":"porco",
  "type":"carne","complexity":3,"prepMinutes":60,"servings":4,
  "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
  "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":true,"maxBatchDays":3,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"porco","quantity":0.4},
    {"ingredientId":"feijao","quantity":0.3},
    {"ingredientId":"chourico","quantity":0.1},
    {"ingredientId":"cenoura","quantity":0.2},
    {"ingredientId":"azeite","quantity":0.05}
  ]
}
```

---

### Task 11: Add fish/seafood recipes (5 new — sardines, tuna, more variety)

**Files:**
- Modify: `assets/meal_planner/recipes.json`

**Step 1: Add fish recipes**

```json
{
  "id":"sardinhas_assadas","name":"Sardinhas Assadas","proteinId":"sardinha",
  "type":"peixe","complexity":1,"prepMinutes":15,"servings":4,
  "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
  "isVegetarian":false,"isHighProtein":true,"isLowCarb":true,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"sardinha","quantity":0.6},
    {"ingredientId":"batata","quantity":0.4},
    {"ingredientId":"pimento","quantity":0.2},
    {"ingredientId":"azeite","quantity":0.05}
  ]
},
{
  "id":"atum_salada","name":"Salada de Atum","proteinId":"atum_lata",
  "type":"peixe","complexity":1,"prepMinutes":10,"servings":4,
  "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
  "isVegetarian":false,"isHighProtein":true,"isLowCarb":true,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"atum_lata","quantity":2.0},
    {"ingredientId":"alface","quantity":1.0},
    {"ingredientId":"tomate","quantity":0.2},
    {"ingredientId":"cebola","quantity":0.1},
    {"ingredientId":"azeite","quantity":0.03}
  ]
},
{
  "id":"atum_arroz","name":"Arroz de Atum","proteinId":"atum_lata",
  "type":"peixe","complexity":1,"prepMinutes":20,"servings":4,
  "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
  "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":true,"maxBatchDays":2,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"atum_lata","quantity":2.0},
    {"ingredientId":"arroz","quantity":0.3},
    {"ingredientId":"tomate_pelado","quantity":1.0},
    {"ingredientId":"cebola","quantity":0.15},
    {"ingredientId":"azeite","quantity":0.05}
  ]
},
{
  "id":"caldeirada","name":"Caldeirada de Peixe","proteinId":"pescada",
  "type":"peixe","complexity":3,"prepMinutes":45,"servings":4,
  "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
  "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"pescada","quantity":0.5},
    {"ingredientId":"batata","quantity":0.4},
    {"ingredientId":"tomate","quantity":0.3},
    {"ingredientId":"cebola","quantity":0.2},
    {"ingredientId":"pimento","quantity":0.15},
    {"ingredientId":"azeite","quantity":0.05}
  ]
},
{
  "id":"pataniscas_bacalhau","name":"Pataniscas de Bacalhau","proteinId":"bacalhau",
  "type":"peixe","complexity":2,"prepMinutes":30,"servings":4,
  "glutenFree":false,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
  "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"bacalhau","quantity":0.3},
    {"ingredientId":"massa","quantity":0.1},
    {"ingredientId":"ovo","quantity":2.0},
    {"ingredientId":"cebola","quantity":0.1},
    {"ingredientId":"azeite","quantity":0.1}
  ]
}
```

---

### Task 12: Add breakfast/snack recipes (8 new)

Currently zero breakfast or snack recipes. All egg recipes are tagged as lunch/dinner. Add dedicated breakfast/snack recipes.

**Files:**
- Modify: `assets/meal_planner/recipes.json`

**Step 1: Add breakfast and snack recipes**

```json
{
  "id":"papas_aveia","name":"Papas de Aveia com Fruta","proteinId":"aveia",
  "type":"vegetariano","complexity":1,"prepMinutes":10,"servings":4,
  "glutenFree":false,"lactoseFree":false,"nutFree":true,"shellfishFree":true,
  "isVegetarian":true,"isHighProtein":false,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["breakfast"],
  "ingredients":[
    {"ingredientId":"aveia","quantity":0.2},
    {"ingredientId":"leite","quantity":0.5},
    {"ingredientId":"banana","quantity":0.4}
  ]
},
{
  "id":"torradas_queijo","name":"Torradas com Queijo e Fiambre","proteinId":"queijo",
  "type":"carne","complexity":1,"prepMinutes":5,"servings":4,
  "glutenFree":false,"lactoseFree":false,"nutFree":true,"shellfishFree":true,
  "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["breakfast","snack"],
  "ingredients":[
    {"ingredientId":"pao_forma","quantity":1.0},
    {"ingredientId":"queijo","quantity":0.15},
    {"ingredientId":"fiambre","quantity":0.15},
    {"ingredientId":"manteiga","quantity":0.03}
  ]
},
{
  "id":"cereais_leite","name":"Cereais com Leite e Fruta","proteinId":"cereais",
  "type":"vegetariano","complexity":1,"prepMinutes":5,"servings":4,
  "glutenFree":false,"lactoseFree":false,"nutFree":true,"shellfishFree":true,
  "isVegetarian":true,"isHighProtein":false,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["breakfast"],
  "ingredients":[
    {"ingredientId":"cereais","quantity":0.2},
    {"ingredientId":"leite","quantity":0.5},
    {"ingredientId":"fruta","quantity":0.3}
  ]
},
{
  "id":"iogurte_fruta","name":"Iogurte com Fruta e Aveia","proteinId":"iogurte",
  "type":"vegetariano","complexity":1,"prepMinutes":5,"servings":4,
  "glutenFree":false,"lactoseFree":false,"nutFree":true,"shellfishFree":true,
  "isVegetarian":true,"isHighProtein":true,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["breakfast","snack"],
  "ingredients":[
    {"ingredientId":"iogurte","quantity":4.0},
    {"ingredientId":"fruta","quantity":0.3},
    {"ingredientId":"aveia","quantity":0.1}
  ]
},
{
  "id":"ovos_pequeno_almoco","name":"Ovos Mexidos com Torrada","proteinId":"ovo",
  "type":"ovos","complexity":1,"prepMinutes":10,"servings":4,
  "glutenFree":false,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
  "isVegetarian":true,"isHighProtein":true,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["breakfast"],
  "ingredients":[
    {"ingredientId":"ovo","quantity":6.0},
    {"ingredientId":"pao_forma","quantity":1.0},
    {"ingredientId":"manteiga","quantity":0.03}
  ]
},
{
  "id":"panquecas","name":"Panquecas de Aveia","proteinId":"aveia",
  "type":"vegetariano","complexity":2,"prepMinutes":20,"servings":4,
  "glutenFree":false,"lactoseFree":false,"nutFree":true,"shellfishFree":true,
  "isVegetarian":true,"isHighProtein":false,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["breakfast","snack"],
  "ingredients":[
    {"ingredientId":"aveia","quantity":0.15},
    {"ingredientId":"ovo","quantity":2.0},
    {"ingredientId":"leite","quantity":0.2},
    {"ingredientId":"banana","quantity":0.3}
  ]
},
{
  "id":"tosta_mista","name":"Tosta Mista","proteinId":"queijo",
  "type":"carne","complexity":1,"prepMinutes":5,"servings":4,
  "glutenFree":false,"lactoseFree":false,"nutFree":true,"shellfishFree":true,
  "isVegetarian":false,"isHighProtein":true,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["snack","lunch"],
  "ingredients":[
    {"ingredientId":"pao_forma","quantity":1.0},
    {"ingredientId":"queijo","quantity":0.1},
    {"ingredientId":"fiambre","quantity":0.1}
  ]
},
{
  "id":"fruta_iogurte","name":"Tigela de Fruta com Iogurte","proteinId":"iogurte",
  "type":"vegetariano","complexity":1,"prepMinutes":5,"servings":4,
  "glutenFree":true,"lactoseFree":false,"nutFree":true,"shellfishFree":true,
  "isVegetarian":true,"isHighProtein":false,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["snack"],
  "ingredients":[
    {"ingredientId":"iogurte","quantity":4.0},
    {"ingredientId":"fruta","quantity":0.4},
    {"ingredientId":"banana","quantity":0.3}
  ]
}
```

---

### Task 13: Add more vegetarian/soup recipes (5 new)

**Files:**
- Modify: `assets/meal_planner/recipes.json`

**Step 1: Add vegetarian and soup recipes**

```json
{
  "id":"caldo_verde","name":"Caldo Verde","proteinId":"chourico",
  "type":"leguminosas","complexity":1,"prepMinutes":25,"servings":4,
  "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
  "isVegetarian":false,"isHighProtein":false,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":true,"maxBatchDays":3,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"batata","quantity":0.4},
    {"ingredientId":"espinafres","quantity":0.3},
    {"ingredientId":"chourico","quantity":0.05},
    {"ingredientId":"cebola","quantity":0.1},
    {"ingredientId":"azeite","quantity":0.05}
  ]
},
{
  "id":"arroz_legumes","name":"Arroz de Legumes","proteinId":"arroz",
  "type":"vegetariano","complexity":1,"prepMinutes":20,"servings":4,
  "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
  "isVegetarian":true,"isHighProtein":false,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":true,"maxBatchDays":2,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"arroz","quantity":0.3},
    {"ingredientId":"cenoura","quantity":0.2},
    {"ingredientId":"courgette","quantity":0.2},
    {"ingredientId":"pimento","quantity":0.15},
    {"ingredientId":"azeite","quantity":0.05}
  ]
},
{
  "id":"massa_cogumelos","name":"Massa com Cogumelos","proteinId":"cogumelos",
  "type":"vegetariano","complexity":2,"prepMinutes":25,"servings":4,
  "glutenFree":false,"lactoseFree":false,"nutFree":true,"shellfishFree":true,
  "isVegetarian":true,"isHighProtein":false,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":true,"maxBatchDays":2,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"massa","quantity":0.3},
    {"ingredientId":"cogumelos","quantity":0.3},
    {"ingredientId":"natas","quantity":0.1},
    {"ingredientId":"alho","quantity":0.02},
    {"ingredientId":"azeite","quantity":0.05}
  ]
},
{
  "id":"sopa_legumes","name":"Sopa de Legumes","proteinId":"batata",
  "type":"vegetariano","complexity":1,"prepMinutes":25,"servings":4,
  "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
  "isVegetarian":true,"isHighProtein":false,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":true,"maxBatchDays":4,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"batata","quantity":0.3},
    {"ingredientId":"cenoura","quantity":0.2},
    {"ingredientId":"cebola","quantity":0.15},
    {"ingredientId":"courgette","quantity":0.2},
    {"ingredientId":"azeite","quantity":0.05}
  ]
},
{
  "id":"salada_grao","name":"Salada de Grão-de-Bico","proteinId":"grao",
  "type":"leguminosas","complexity":1,"prepMinutes":10,"servings":4,
  "glutenFree":true,"lactoseFree":true,"nutFree":true,"shellfishFree":true,
  "isVegetarian":true,"isHighProtein":true,"isLowCarb":false,
  "requiresEquipment":[],"batchCookable":false,"maxBatchDays":1,
  "suitableMealTypes":["lunch","dinner"],
  "ingredients":[
    {"ingredientId":"grao","quantity":0.3},
    {"ingredientId":"tomate","quantity":0.2},
    {"ingredientId":"cebola","quantity":0.1},
    {"ingredientId":"alface","quantity":1.0},
    {"ingredientId":"azeite","quantity":0.05}
  ]
}
```

---

### Task 14: Add `suitableMealTypes` to all existing 25 recipes

All existing recipes lack the `suitableMealTypes` field and will default to `["lunch","dinner"]`. That default is correct for all 25 (none are breakfast/snack). Explicitly adding the field is good practice for clarity and future-proofing.

**Files:**
- Modify: `assets/meal_planner/recipes.json`

**Step 1: Add `"suitableMealTypes":["lunch","dinner"]` to each existing recipe**

For every recipe already in the file, add the field. For egg recipes (omelete, tortilha, frittata, ovos_mexidos, ovo_arroz), also add `"breakfast"` since they're plausible breakfasts:

- `omelete_legumes`: `["breakfast","lunch","dinner"]`
- `tortilha`: `["breakfast","lunch","dinner"]`
- `frittata_espinafres`: `["breakfast","lunch","dinner"]`
- `ovos_mexidos_tomate`: `["breakfast","lunch","dinner"]`
- `ovo_arroz`: `["lunch","dinner"]`
- All others: `["lunch","dinner"]`

---

### Task 15: Commit Tier 2

```bash
git add assets/meal_planner/recipes.json assets/meal_planner/ingredients.json
git commit -m "claude/budget-calculator-app-TFWgZ: expand meal catalog — add 23 recipes, 16 ingredients, suitableMealTypes field"
```

---

## Tier 3 — UX and Settings Cleanup

### Task 16: Cross-protein swap in alternativesFor()

**Bug:** `alternativesFor()` only returns recipes with the same `proteinId`. If user has chicken and wants to swap to fish, they can't.

**Files:**
- Modify: `lib/services/meal_planner_service.dart:353-362`

**Step 1: Show all compatible recipes, not just same-protein**

Replace lines 353-362:
```dart
  List<Recipe> alternativesFor(String recipeId, int np) {
    final current = recipeMap[recipeId];
    if (current == null) return [];
    final iMap = ingredientMap;
    return _recipes
        .where((r) => r.proteinId == current.proteinId && r.id != recipeId)
        .toList()
      ..sort((a, b) =>
          recipeCost(a, np, iMap).compareTo(recipeCost(b, np, iMap)));
  }
```
With:
```dart
  List<Recipe> alternativesFor(String recipeId, int np, {MealSettings? ms}) {
    final current = recipeMap[recipeId];
    if (current == null) return [];
    final iMap = ingredientMap;
    var pool = _recipes.where((r) => r.id != recipeId).toList();
    // Apply dietary constraints if settings provided
    if (ms != null) {
      pool = pool.where((r) {
        if (ms.glutenFree && !r.glutenFree) return false;
        if (ms.lactoseFree && !r.lactoseFree) return false;
        if (ms.nutFree && !r.nutFree) return false;
        if (ms.shellfishFree && !r.shellfishFree) return false;
        if (ms.excludedProteins.contains(r.proteinId)) return false;
        return true;
      }).toList();
    }
    // Sort: same protein first, then by cost
    pool.sort((a, b) {
      final aMatch = a.proteinId == current.proteinId ? 0 : 1;
      final bMatch = b.proteinId == current.proteinId ? 0 : 1;
      if (aMatch != bMatch) return aMatch.compareTo(bMatch);
      return recipeCost(a, np, iMap).compareTo(recipeCost(b, np, iMap));
    });
    return pool;
  }
```

**Step 2: Update call sites in meal_planner_screen.dart**

Find `alternativesFor(` call in the screen and pass `ms: widget.settings.mealSettings`.

**Step 3: Show more alternatives (raise `.take(3)` to `.take(6)`)**

In `_SwapSheet` at line 674, change `.take(3)` to `.take(6)`.

**Step 4: Run flutter analyze**

Run: `flutter analyze`
Expected: No new issues

---

### Task 17: Add "add week to shopping list" one-tap button

**Files:**
- Modify: `lib/screens/meal_planner_screen.dart`

**Step 1: Add a button above the week's cards**

In the plan view section, after the week selector chips and before the day cards, add:

```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () => _addWeekToShoppingList(_selectedWeek),
      icon: const Icon(Icons.add_shopping_cart, size: 18),
      label: const Text('Adicionar semana à lista'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF3B82F6),
        side: const BorderSide(color: Color(0xFF3B82F6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    ),
  ),
),
```

**Step 2: Implement `_addWeekToShoppingList` method**

```dart
void _addWeekToShoppingList(int weekIndex) {
  final plan = _plan;
  if (plan == null) return;
  final weekDays = _getWeekDays(plan, weekIndex);
  final iMap = _service.ingredientMap;
  final totals = <String, double>{};
  for (final day in weekDays) {
    if (day.isLeftover) continue;
    final recipe = _service.recipeMap[day.recipeId];
    if (recipe == null) continue;
    final scale = plan.nPessoas / recipe.servings;
    for (final ri in recipe.ingredients) {
      totals.update(ri.ingredientId, (v) => v + ri.quantity * scale,
          ifAbsent: () => ri.quantity * scale);
    }
  }
  int count = 0;
  for (final entry in totals.entries) {
    final ing = iMap[entry.key];
    if (ing == null) continue;
    final cost = entry.value * ing.avgPricePerUnit;
    widget.onAddToShoppingList(ShoppingItem(
      productName: ing.name,
      store: '',
      price: cost,
      unitPrice: '${ing.avgPricePerUnit.toStringAsFixed(2)}€/${ing.unit}',
    ));
    count++;
  }
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$count ingredientes adicionados à lista')),
    );
  }
}
```

**Step 3: Run flutter analyze**

Run: `flutter analyze`
Expected: No new issues

---

### Task 18: Remove dead settings

**Files:**
- Modify: `lib/models/meal_settings.dart`

**Step 1: Remove `otherRestrictions` and `advancedMode`**

These fields exist in MealSettings but are never used by the algorithm or displayed in the UI.

- Remove `final List<String> otherRestrictions;` from class
- Remove from constructor, copyWith, toJson, fromJson
- Remove `final bool advancedMode;` from class
- Remove from constructor, copyWith, toJson, fromJson

**Step 2: Remove `custom` from MealObjective enum**

The `custom` objective has no implementation in the algorithm. Remove it from the enum to avoid user confusion.

In `meal_settings.dart`, remove the `custom` case from `MealObjective` enum and its label.

**Step 3: Run flutter analyze**

Fix any resulting errors from code that references removed fields.

Run: `flutter analyze`
Expected: No issues

---

### Task 19: Expose missing settings in UI

Several functional settings exist in MealSettings but aren't exposed in the settings UI.

**Files:**
- Modify: `lib/screens/settings_screen.dart` (inside `_buildMealsSection()`)

**Step 1: Add dislikedIngredients chip input**

After the dietary restrictions section (~line 1087), add a chip input for `dislikedIngredients`:

```dart
const SizedBox(height: 16),
_label('INGREDIENTES INDESEJADOS'),
const SizedBox(height: 8),
Wrap(
  spacing: 8,
  runSpacing: 4,
  children: [
    ...ms.dislikedIngredients.map((d) => Chip(
      label: Text(d, style: const TextStyle(fontSize: 13)),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        final updated = List<String>.from(ms.dislikedIngredients)..remove(d);
        setState(() => _draft = _draft.copyWith(
            mealSettings: ms.copyWith(dislikedIngredients: updated)));
      },
    )),
    ActionChip(
      avatar: const Icon(Icons.add, size: 16),
      label: const Text('Adicionar', style: TextStyle(fontSize: 13)),
      onPressed: () => _showAddDislikedDialog(),
    ),
  ],
),
```

Implement `_showAddDislikedDialog()` as a simple TextField dialog.

**Step 2: Add excludedProteins multi-select**

After disliked ingredients, add checkboxes for excluding protein types based on the ingredient catalog (frango, carne_picada, porco, pescada, bacalhau, sardinha, atum_lata, ovo):

```dart
const SizedBox(height: 16),
_label('PROTEÍNAS EXCLUÍDAS'),
const SizedBox(height: 8),
```

Use the protein IDs from the ingredient catalog to generate checkbox tiles.

**Step 3: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues

---

### Task 20: Final commit Tier 3 + build APK

```bash
git add lib/ assets/
git commit -m "claude/budget-calculator-app-TFWgZ: cross-protein swap, weekly shopping list, settings cleanup"
flutter build apk
```

---

## Summary

| Tier | Tasks | What changes |
|------|-------|-------------|
| 1 | 1-8 | Fix 7 critical bugs: cost distortion, allergy fallback, deterministic selection, same-day duplicates, days 29-31, budget enforcement safety, stale leftovers |
| 2 | 9-15 | Expand catalog from 25→48 recipes, 25→41 ingredients, add breakfast/snack/pork/sardine/tuna/soup recipes |
| 3 | 16-20 | Cross-protein swap, weekly add-to-list, remove dead settings, expose missing settings |

Total: ~48 recipes, ~41 ingredients, 7 bug fixes, 4 UX improvements.
