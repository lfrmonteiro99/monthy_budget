#!/usr/bin/env python3
"""
Meal generation validation script.

Loads the recipe/ingredient catalogs and simulates the Dart generation
algorithm in Python so we can verify:
  - Course types are correct (soups are soups, desserts are desserts, etc.)
  - No recipe repeats on the same day/meal
  - Good weekly variety
  - Costs are reasonable
  - Multi-course settings work correctly

Run: python3 scripts/test_meal_generation.py
"""
import json
import random
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RECIPES_PATH = ROOT / "assets" / "meal_planner" / "recipes.json"
INGREDIENTS_PATH = ROOT / "assets" / "meal_planner" / "ingredients.json"

# ── Load data ────────────────────────────────────────────────────────────────

def load_catalog():
    with open(RECIPES_PATH) as f:
        recipes = json.load(f)
    with open(INGREDIENTS_PATH) as f:
        ingredients = json.load(f)
    recipe_map = {r["id"]: r for r in recipes}
    ingredient_map = {i["id"]: i for i in ingredients}
    return recipes, ingredients, recipe_map, ingredient_map


def recipe_cost(recipe, n_pessoas, ingredient_map):
    scale = n_pessoas / recipe.get("servings", 4)
    total = 0.0
    for ri in recipe.get("ingredients", []):
        ing = ingredient_map.get(ri["ingredientId"])
        if ing:
            total += ri["quantity"] * scale * ing["avgPricePerUnit"]
    return total


# ── Generation (simplified Python port) ──────────────────────────────────────

def generate_plan(
    recipes, ingredient_map,
    n_pessoas=4,
    monthly_budget=500.0,
    enabled_meals=("lunch", "dinner"),
    include_soup_or_starter=False,
    include_dessert=False,
    objective="balancedHealth",
    days_in_month=30,
    eating_out_weekdays=set(),
):
    """Simplified Python port of MealPlannerService.generate()"""
    rng = random.Random(42)  # deterministic for reproducibility

    # Categorize recipes
    soups = [r for r in recipes if r.get("courseType") == "soupOrStarter"
             and any(mt in r.get("suitableMealTypes", []) for mt in enabled_meals)]
    desserts = [r for r in recipes if r.get("courseType") == "dessert"
                and any(mt in r.get("suitableMealTypes", []) for mt in enabled_meals)]
    mains = [r for r in recipes if r.get("courseType", "mainCourse") == "mainCourse"
             and any(mt in r.get("suitableMealTypes", []) for mt in enabled_meals)]

    # Apply objective filter to mains
    if objective == "vegetarian":
        filtered = [r for r in mains if r.get("isVegetarian")]
        if filtered:
            mains = filtered
    elif objective == "highProtein":
        filtered = [r for r in mains if r.get("isHighProtein")]
        if filtered:
            mains = filtered
    elif objective == "lowCarb":
        filtered = [r for r in mains if r.get("isLowCarb")]
        if filtered:
            mains = filtered
    elif objective == "minimizeCost":
        mains.sort(key=lambda r: recipe_cost(r, n_pessoas, ingredient_map))

    days = []
    recent_mains = {}      # mealType -> [last 2 recipe IDs]
    recent_soups = []       # last 3 soup IDs
    recent_desserts = []    # last 2 dessert IDs
    used_today = set()

    for day in range(1, days_in_month + 1):
        weekday = (day - 1) % 7  # 0=Mon
        if weekday in eating_out_weekdays:
            continue

        used_today = set()

        for meal_type in enabled_meals:
            # ── Soup/Starter ──
            if include_soup_or_starter and meal_type in ("lunch", "dinner"):
                pool = [s for s in soups if s["id"] not in used_today]
                pool = [s for s in pool if s["id"] not in recent_soups]
                if not pool:
                    pool = [s for s in soups if s["id"] not in used_today]
                if not pool:
                    pool = soups[:]
                if pool:
                    rng.shuffle(pool)
                    picked = pool[0]
                    days.append({
                        "dayIndex": day,
                        "mealType": meal_type,
                        "courseType": "soupOrStarter",
                        "recipeId": picked["id"],
                        "recipeName": picked["name"],
                        "recipeCourseType": picked.get("courseType", "mainCourse"),
                        "cost": recipe_cost(picked, n_pessoas, ingredient_map),
                    })
                    used_today.add(picked["id"])
                    recent_soups.append(picked["id"])
                    if len(recent_soups) > 3:
                        recent_soups.pop(0)

            # ── Main Course ──
            recent = recent_mains.get(meal_type, [])
            pool = [r for r in mains if r["id"] not in used_today]
            pool = [r for r in pool if r["id"] not in recent]
            if not pool:
                pool = [r for r in mains if r["id"] not in used_today]
            if not pool:
                pool = mains[:]

            if objective != "minimizeCost":
                rng.shuffle(pool)

            picked = pool[0]
            days.append({
                "dayIndex": day,
                "mealType": meal_type,
                "courseType": "mainCourse",
                "recipeId": picked["id"],
                "recipeName": picked["name"],
                "recipeCourseType": picked.get("courseType", "mainCourse"),
                "cost": recipe_cost(picked, n_pessoas, ingredient_map),
            })
            used_today.add(picked["id"])

            # Track recent mains (last 2)
            recent = list(recent_mains.get(meal_type, []))
            recent.append(picked["id"])
            if len(recent) > 2:
                recent.pop(0)
            recent_mains[meal_type] = recent

            # ── Dessert ──
            if include_dessert and meal_type in ("lunch", "dinner"):
                pool = [d for d in desserts if d["id"] not in used_today]
                pool = [d for d in pool if d["id"] not in recent_desserts]
                if not pool:
                    pool = [d for d in desserts if d["id"] not in used_today]
                if not pool:
                    pool = desserts[:]
                if pool:
                    rng.shuffle(pool)
                    picked = pool[0]
                    days.append({
                        "dayIndex": day,
                        "mealType": meal_type,
                        "courseType": "dessert",
                        "recipeId": picked["id"],
                        "recipeName": picked["name"],
                        "recipeCourseType": picked.get("courseType", "mainCourse"),
                        "cost": recipe_cost(picked, n_pessoas, ingredient_map),
                    })
                    used_today.add(picked["id"])
                    recent_desserts.append(picked["id"])
                    if len(recent_desserts) > 2:
                        recent_desserts.pop(0)

    return days


# ── Validation checks ────────────────────────────────────────────────────────

class ValidationResult:
    def __init__(self, name):
        self.name = name
        self.checks = []
        self.errors = []

    def check(self, condition, message):
        self.checks.append(message)
        if not condition:
            self.errors.append(message)

    @property
    def passed(self):
        return len(self.errors) == 0


def validate_plan(label, days, recipes, ingredient_map, settings):
    v = ValidationResult(label)
    recipe_map = {r["id"]: r for r in recipes}

    include_soup = settings.get("include_soup_or_starter", False)
    include_dessert = settings.get("include_dessert", False)
    enabled_meals = settings.get("enabled_meals", ("lunch", "dinner"))

    # 1. Course type correctness
    for d in days:
        r = recipe_map.get(d["recipeId"])
        if not r:
            continue
        actual_ct = r.get("courseType", "mainCourse")
        assigned_ct = d["courseType"]

        if assigned_ct == "soupOrStarter":
            v.check(actual_ct == "soupOrStarter",
                    f"Day {d['dayIndex']} {d['mealType']}: soup slot has recipe '{d['recipeName']}' "
                    f"but its courseType is '{actual_ct}' (should be soupOrStarter)")
        elif assigned_ct == "mainCourse":
            v.check(actual_ct == "mainCourse",
                    f"Day {d['dayIndex']} {d['mealType']}: main slot has recipe '{d['recipeName']}' "
                    f"but its courseType is '{actual_ct}' (should be mainCourse)")
        elif assigned_ct == "dessert":
            v.check(actual_ct == "dessert",
                    f"Day {d['dayIndex']} {d['mealType']}: dessert slot has recipe '{d['recipeName']}' "
                    f"but its courseType is '{actual_ct}' (should be dessert)")

    # 2. No duplicate recipes within same day + meal type
    by_day_meal = defaultdict(list)
    for d in days:
        by_day_meal[(d["dayIndex"], d["mealType"])].append(d)

    for (day, mt), entries in by_day_meal.items():
        ids = [e["recipeId"] for e in entries]
        v.check(len(ids) == len(set(ids)),
                f"Day {day} {mt}: duplicate recipes in same meal: {ids}")

    # 3. Multi-course completeness
    if include_soup:
        for (day, mt), entries in by_day_meal.items():
            if mt in ("lunch", "dinner"):
                has_soup = any(e["courseType"] == "soupOrStarter" for e in entries)
                v.check(has_soup,
                        f"Day {day} {mt}: missing soup/starter (setting enabled)")

    if include_dessert:
        for (day, mt), entries in by_day_meal.items():
            if mt in ("lunch", "dinner"):
                has_dessert = any(e["courseType"] == "dessert" for e in entries)
                v.check(has_dessert,
                        f"Day {day} {mt}: missing dessert (setting enabled)")

    # 4. Weekly variety (main courses)
    main_by_week = defaultdict(list)
    for d in days:
        if d["courseType"] == "mainCourse":
            week = (d["dayIndex"] - 1) // 7
            main_by_week[week].append(d["recipeId"])

    for week, ids in main_by_week.items():
        unique = set(ids)
        v.check(len(unique) >= min(5, len(ids)),
                f"Week {week}: only {len(unique)} unique mains out of {len(ids)} meals")
        counts = Counter(ids)
        for rid, cnt in counts.items():
            name = recipe_map.get(rid, {}).get("name", rid)
            v.check(cnt <= 3,
                    f"Week {week}: '{name}' used {cnt} times (max 3)")

    # 5. Cost sanity
    for d in days:
        v.check(d["cost"] >= 0, f"Day {d['dayIndex']}: negative cost {d['cost']}")
        v.check(d["cost"] < 100, f"Day {d['dayIndex']}: absurd cost {d['cost']:.2f}")

    # 6. No consecutive-day main course repeats
    prev_main = {}  # mealType -> recipeId
    for d in sorted(days, key=lambda x: (x["dayIndex"], x["mealType"])):
        if d["courseType"] == "mainCourse":
            mt = d["mealType"]
            if mt in prev_main and prev_main[mt][0] == d["dayIndex"] - 1:
                v.check(prev_main[mt][1] != d["recipeId"],
                        f"Day {d['dayIndex']} {mt}: same main '{d['recipeName']}' as yesterday")
            prev_main[mt] = (d["dayIndex"], d["recipeId"])

    return v


def print_analysis(label, days, recipe_map):
    print(f"\n{'='*70}")
    print(f"  {label}")
    print(f"{'='*70}")

    mains = [d for d in days if d["courseType"] == "mainCourse"]
    soups = [d for d in days if d["courseType"] == "soupOrStarter"]
    desserts = [d for d in days if d["courseType"] == "dessert"]

    print(f"  Total entries: {len(days)}")
    print(f"  Main courses:  {len(mains)} ({len(set(d['recipeId'] for d in mains))} unique)")
    if soups:
        print(f"  Soups/starters:{len(soups)} ({len(set(d['recipeId'] for d in soups))} unique)")
    if desserts:
        print(f"  Desserts:      {len(desserts)} ({len(set(d['recipeId'] for d in desserts))} unique)")

    total_cost = sum(d["cost"] for d in days)
    print(f"  Total cost:    {total_cost:.2f} EUR")

    # Top 5 main recipes
    main_counts = Counter(d["recipeName"] for d in mains)
    print(f"\n  Top main recipes:")
    for name, cnt in main_counts.most_common(5):
        print(f"    {name}: {cnt}x")

    if soups:
        soup_counts = Counter(d["recipeName"] for d in soups)
        print(f"\n  Soup distribution:")
        for name, cnt in soup_counts.most_common():
            print(f"    {name}: {cnt}x")

    if desserts:
        dessert_counts = Counter(d["recipeName"] for d in desserts)
        print(f"\n  Dessert distribution:")
        for name, cnt in dessert_counts.most_common():
            print(f"    {name}: {cnt}x")

    # Weekly uniqueness
    main_by_week = defaultdict(set)
    for d in mains:
        week = (d["dayIndex"] - 1) // 7
        main_by_week[week].add(d["recipeId"])
    print(f"\n  Weekly main variety:")
    for week in sorted(main_by_week):
        print(f"    Week {week+1}: {len(main_by_week[week])} unique recipes")

    # Sample: first 3 days
    print(f"\n  Sample (first 3 days):")
    for day_idx in range(1, 4):
        day_entries = [d for d in days if d["dayIndex"] == day_idx]
        for d in day_entries:
            ct_icon = {"soupOrStarter": "🥣", "mainCourse": "🍽️", "dessert": "🍨"}.get(d["courseType"], "?")
            print(f"    Dia {d['dayIndex']} {d['mealType']:7s} {ct_icon} {d['recipeName']}")


# ── Test configurations ──────────────────────────────────────────────────────

CONFIGS = [
    {
        "label": "Config 1: Default (lunch + dinner, no multi-course)",
        "settings": {
            "enabled_meals": ("lunch", "dinner"),
            "include_soup_or_starter": False,
            "include_dessert": False,
            "objective": "balancedHealth",
        },
    },
    {
        "label": "Config 2: Soup + Main Course",
        "settings": {
            "enabled_meals": ("lunch", "dinner"),
            "include_soup_or_starter": True,
            "include_dessert": False,
            "objective": "balancedHealth",
        },
    },
    {
        "label": "Config 3: Soup + Main + Dessert (full multi-course)",
        "settings": {
            "enabled_meals": ("lunch", "dinner"),
            "include_soup_or_starter": True,
            "include_dessert": True,
            "objective": "balancedHealth",
        },
    },
    {
        "label": "Config 4: Vegetarian",
        "settings": {
            "enabled_meals": ("lunch", "dinner"),
            "include_soup_or_starter": False,
            "include_dessert": False,
            "objective": "vegetarian",
        },
    },
    {
        "label": "Config 5: Minimize Cost",
        "settings": {
            "enabled_meals": ("lunch", "dinner"),
            "include_soup_or_starter": False,
            "include_dessert": False,
            "objective": "minimizeCost",
        },
    },
    {
        "label": "Config 6: High Protein + Soup + Dessert",
        "settings": {
            "enabled_meals": ("lunch", "dinner"),
            "include_soup_or_starter": True,
            "include_dessert": True,
            "objective": "highProtein",
        },
    },
    {
        "label": "Config 7: Breakfast + Lunch + Dinner (all meals)",
        "settings": {
            "enabled_meals": ("breakfast", "lunch", "dinner"),
            "include_soup_or_starter": True,
            "include_dessert": True,
            "objective": "balancedHealth",
        },
    },
]


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    print("Loading catalog...")
    recipes, ingredients, recipe_map, ingredient_map = load_catalog()

    # Catalog stats
    soups = [r for r in recipes if r.get("courseType") == "soupOrStarter"]
    desserts = [r for r in recipes if r.get("courseType") == "dessert"]
    mains = [r for r in recipes if r.get("courseType", "mainCourse") == "mainCourse"]
    print(f"Catalog: {len(recipes)} recipes ({len(soups)} soups, {len(mains)} mains, {len(desserts)} desserts)")
    print(f"Ingredients: {len(ingredients)}")

    # Validate catalog
    for r in recipes:
        ct = r.get("courseType")
        assert ct in ("soupOrStarter", "mainCourse", "dessert", None), \
            f"Invalid courseType '{ct}' for recipe {r['id']}"

    all_passed = True
    total_checks = 0
    total_errors = 0

    for cfg in CONFIGS:
        label = cfg["label"]
        settings = cfg["settings"]

        days = generate_plan(
            recipes, ingredient_map,
            n_pessoas=4,
            monthly_budget=500.0,
            **settings,
        )

        print_analysis(label, days, recipe_map)

        result = validate_plan(label, days, recipes, ingredient_map, settings)

        total_checks += len(result.checks)
        total_errors += len(result.errors)

        if result.passed:
            print(f"\n  ✅ ALL {len(result.checks)} CHECKS PASSED")
        else:
            all_passed = False
            print(f"\n  ❌ {len(result.errors)} FAILURES out of {len(result.checks)} checks:")
            for err in result.errors:
                print(f"    ✗ {err}")

    # Summary
    print(f"\n{'='*70}")
    print(f"  SUMMARY: {len(CONFIGS)} configs, {total_checks} checks, {total_errors} errors")
    if all_passed:
        print(f"  ✅ ALL CONFIGS PASSED")
    else:
        print(f"  ❌ SOME CONFIGS FAILED")
    print(f"{'='*70}")

    return 0 if all_passed else 1


if __name__ == "__main__":
    sys.exit(main())
