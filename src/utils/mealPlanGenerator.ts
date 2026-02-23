import type {
  MealPlan,
  WeekPlan,
  DayPlan,
  MealSlot,
  ShoppingListItem,
  MealPlanGenerationConfig,
  ProteinType,
  MealType,
  VarietyLevel,
  RecipeIngredient,
} from "../types/mealPlanner";
import { RECIPES } from "../data/recipes";
import { INGREDIENTS_MAP } from "../data/ingredients";
import type { Recipe } from "../types/mealPlanner";

const DAY_LABELS = [
  "Segunda",
  "Terca",
  "Quarta",
  "Quinta",
  "Sexta",
  "Sabado",
  "Domingo",
];

// ─── Cost Calculation ───────────────────────────────────────────────

/**
 * Calculate the cost of a single recipe for a given number of people.
 * Uses ingredient average prices from the database.
 */
export function calculateRecipeCost(recipe: Recipe, numberOfPeople: number): number {
  let totalCost = 0;

  for (const ri of recipe.ingredients) {
    const ingredient = INGREDIENTS_MAP[ri.ingredientId];
    if (!ingredient) continue;

    const totalQuantity = ri.quantityPerServing * numberOfPeople;
    const costForIngredient = calculateIngredientCost(ri, totalQuantity);
    totalCost += costForIngredient;
  }

  return Math.round(totalCost * 100) / 100;
}

/**
 * Calculate the cost of an ingredient given a required quantity.
 * Converts recipe units to purchase units for accurate pricing.
 */
function calculateIngredientCost(ri: RecipeIngredient, totalQuantity: number): number {
  const ingredient = INGREDIENTS_MAP[ri.ingredientId];
  if (!ingredient) return 0;

  // Convert recipe quantity to ingredient's base unit for pricing
  const quantityInBaseUnit = convertToBaseUnit(totalQuantity, ri.unit, ingredient.unit);

  return quantityInBaseUnit * ingredient.pricePerUnit;
}

/**
 * Convert quantity from recipe unit to ingredient's pricing unit.
 */
function convertToBaseUnit(
  quantity: number,
  fromUnit: string,
  toUnit: string,
): number {
  // Same unit family
  if (fromUnit === toUnit) return quantity;

  // g -> kg
  if (fromUnit === "g" && toUnit === "kg") return quantity / 1000;
  // kg -> g
  if (fromUnit === "kg" && toUnit === "g") return quantity * 1000;
  // ml -> L
  if (fromUnit === "ml" && toUnit === "L") return quantity / 1000;
  // L -> ml
  if (fromUnit === "L" && toUnit === "ml") return quantity * 1000;
  // un -> un, dz -> dz (direct)
  if (fromUnit === "un" && toUnit === "un") return quantity;
  // un -> dz (eggs: 3 units = 3/12 dozens)
  if (fromUnit === "un" && toUnit === "dz") return quantity / 12;
  // dz -> un
  if (fromUnit === "dz" && toUnit === "un") return quantity * 12;

  // Fallback: assume same
  return quantity;
}

// ─── Protein Clustering ─────────────────────────────────────────────

/**
 * Available protein types for generation, respecting exclusions.
 */
const ALL_PROTEINS: ProteinType[] = [
  "frango",
  "porco",
  "vaca",
  "peixe",
  "ovos",
  "leguminosas",
];

/**
 * Select proteins for the month based on variety level.
 * Returns proteins distributed across weeks.
 */
function selectMonthlyProteins(
  weeks: number,
  excluded: ProteinType[],
  variety: VarietyLevel,
): ProteinType[][] {
  const available = ALL_PROTEINS.filter((p) => !excluded.includes(p));
  if (available.length === 0) return Array(weeks).fill(["sem_proteina"]);

  // Number of dominant proteins per week based on variety
  const proteinsPerWeek = variety === "baixa" ? 2 : variety === "media" ? 3 : 4;

  const weeklyProteins: ProteinType[][] = [];

  for (let w = 0; w < weeks; w++) {
    // Rotate available proteins so each week has slightly different emphasis
    const offset = w * proteinsPerWeek;
    const weekProteins: ProteinType[] = [];

    for (let i = 0; i < Math.min(proteinsPerWeek, available.length); i++) {
      const idx = (offset + i) % available.length;
      weekProteins.push(available[idx]);
    }

    weeklyProteins.push(weekProteins);
  }

  return weeklyProteins;
}

// ─── Recipe Selection ───────────────────────────────────────────────

/**
 * Select a recipe for a meal slot, preferring recipes that use
 * the week's dominant proteins and avoiding recent repetitions.
 */
function selectRecipe(
  mealType: MealType,
  weekProteins: ProteinType[],
  usedRecipeIds: Set<string>,
  recentRecipeIds: Set<string>,
  numberOfPeople: number,
  weeklyBudgetRemaining: number,
): Recipe | null {
  // Get all recipes suitable for this meal type
  const candidates = RECIPES.filter((r) => r.suitableFor.includes(mealType));

  if (candidates.length === 0) return null;

  // Score each candidate
  const scored = candidates.map((recipe) => {
    let score = 0;
    const cost = calculateRecipeCost(recipe, numberOfPeople);

    // Budget check: prefer recipes within remaining budget
    if (cost <= weeklyBudgetRemaining) {
      score += 20;
    } else {
      score -= 30; // Heavy penalty for over-budget
    }

    // Prefer dominant proteins for the week
    if (weekProteins.includes(recipe.proteinBase)) {
      score += 15;
    }

    // Avoid recently used recipes (within same week)
    if (recentRecipeIds.has(recipe.id)) {
      score -= 25;
    }

    // Avoid repeating the same recipe across the month
    if (usedRecipeIds.has(recipe.id)) {
      score -= 10;
    }

    // Bonus for economico tag
    if (recipe.tags.includes("economico")) {
      score += 5;
    }

    // Bonus for rapido at dinner
    if (mealType === "jantar" && recipe.tags.includes("rapido")) {
      score += 3;
    }

    // Lower cost = slightly better
    score += Math.max(0, 10 - cost);

    return { recipe, score, cost };
  });

  // Sort by score descending, then add randomness
  scored.sort((a, b) => b.score - a.score);

  // Take top 5 candidates and pick randomly for variety
  const topN = scored.slice(0, Math.min(5, scored.length));
  const pick = topN[Math.floor(Math.random() * topN.length)];

  return pick.recipe;
}

// ─── Shopping List Generation ───────────────────────────────────────

/**
 * Aggregate all ingredients from a meal plan into a consolidated shopping list.
 * Same ingredient from multiple recipes gets merged (quantity summed).
 */
export function generateShoppingList(
  weeks: WeekPlan[],
  numberOfPeople: number,
): ShoppingListItem[] {
  // Accumulate: ingredientId -> { total quantity (in recipe units), recipes }
  const accumulator = new Map<
    string,
    {
      totalQuantityG: number; // accumulated in smallest unit (g/ml/un)
      unit: string;
      fromRecipes: Set<string>;
    }
  >();

  for (const week of weeks) {
    for (const day of week.days) {
      const meals = [day.almoco, day.jantar].filter(Boolean) as MealSlot[];

      for (const meal of meals) {
        const recipe = RECIPES.find((r) => r.id === meal.recipeId);
        if (!recipe) continue;

        for (const ri of recipe.ingredients) {
          const totalForRecipe = ri.quantityPerServing * numberOfPeople;
          const existing = accumulator.get(ri.ingredientId);

          if (existing) {
            existing.totalQuantityG += totalForRecipe;
            existing.fromRecipes.add(recipe.name);
          } else {
            accumulator.set(ri.ingredientId, {
              totalQuantityG: totalForRecipe,
              unit: ri.unit,
              fromRecipes: new Set([recipe.name]),
            });
          }
        }
      }
    }
  }

  // Convert to shopping list items with proper purchase quantities
  const items: ShoppingListItem[] = [];

  for (const [ingredientId, data] of accumulator) {
    const ingredient = INGREDIENTS_MAP[ingredientId];
    if (!ingredient) continue;

    // Convert accumulated quantity to base purchase unit
    const quantityInBaseUnit = convertToBaseUnit(
      data.totalQuantityG,
      data.unit,
      ingredient.unit,
    );

    // Round up to minimum purchase increments
    const purchaseQuantity = roundUpToPurchaseUnit(
      quantityInBaseUnit,
      ingredient.minPurchase,
    );

    const estimatedCost = Math.round(purchaseQuantity * ingredient.pricePerUnit * 100) / 100;

    items.push({
      ingredientId,
      name: ingredient.name,
      category: ingredient.category,
      totalQuantity: Math.round(quantityInBaseUnit * 100) / 100,
      purchaseQuantity: Math.round(purchaseQuantity * 100) / 100,
      unit: ingredient.unit,
      estimatedCost,
      fromRecipes: Array.from(data.fromRecipes),
      checked: false,
    });
  }

  // Sort by category, then by name
  items.sort((a, b) => {
    if (a.category !== b.category) return a.category.localeCompare(b.category);
    return a.name.localeCompare(b.name);
  });

  return items;
}

/**
 * Round up a quantity to the nearest multiple of the minimum purchase unit.
 * E.g., if you need 1.3kg of potatoes and min purchase is 2kg, buy 2kg.
 */
function roundUpToPurchaseUnit(quantity: number, minPurchase: number): number {
  if (minPurchase <= 0) return quantity;
  return Math.ceil(quantity / minPurchase) * minPurchase;
}

// ─── Main Generator ─────────────────────────────────────────────────

/**
 * Generate a complete meal plan for the month.
 *
 * Algorithm:
 * 1. Select protein clusters for each week
 * 2. For each day, select lunch and dinner recipes
 * 3. Prefer ingredient reuse within the week
 * 4. Stay within budget
 * 5. Generate aggregated shopping list
 */
export function generateMealPlan(config: MealPlanGenerationConfig): MealPlan {
  const {
    budget,
    numberOfPeople,
    weeks: weekCount,
    mealsPerDay,
    excludedProteins,
    varietyLevel,
  } = config;

  const weeklyBudget = budget / weekCount;
  const weeklyProteins = selectMonthlyProteins(weekCount, excludedProteins, varietyLevel);

  const allUsedRecipes = new Set<string>();
  const generatedWeeks: WeekPlan[] = [];

  for (let w = 0; w < weekCount; w++) {
    const proteins = weeklyProteins[w];
    const weekRecentRecipes = new Set<string>();
    let weekCost = 0;

    const days: DayPlan[] = [];

    for (let d = 0; d < 7; d++) {
      let almoco: MealSlot | null = null;
      let jantar: MealSlot | null = null;

      if (mealsPerDay.includes("almoco")) {
        const recipe = selectRecipe(
          "almoco",
          proteins,
          allUsedRecipes,
          weekRecentRecipes,
          numberOfPeople,
          weeklyBudget - weekCost,
        );

        if (recipe) {
          const cost = calculateRecipeCost(recipe, numberOfPeople);
          almoco = {
            recipeId: recipe.id,
            recipeName: recipe.name,
            estimatedCost: cost,
          };
          weekCost += cost;
          weekRecentRecipes.add(recipe.id);
          allUsedRecipes.add(recipe.id);
        }
      }

      if (mealsPerDay.includes("jantar")) {
        const recipe = selectRecipe(
          "jantar",
          proteins,
          allUsedRecipes,
          weekRecentRecipes,
          numberOfPeople,
          weeklyBudget - weekCost,
        );

        if (recipe) {
          const cost = calculateRecipeCost(recipe, numberOfPeople);
          jantar = {
            recipeId: recipe.id,
            recipeName: recipe.name,
            estimatedCost: cost,
          };
          weekCost += cost;
          weekRecentRecipes.add(recipe.id);
          allUsedRecipes.add(recipe.id);
        }
      }

      days.push({
        dayIndex: d,
        dayLabel: DAY_LABELS[d],
        almoco,
        jantar,
      });
    }

    generatedWeeks.push({
      weekIndex: w,
      weekLabel: `Semana ${w + 1}`,
      days,
      estimatedCost: Math.round(weekCost * 100) / 100,
    });
  }

  const totalCost = generatedWeeks.reduce((s, w) => s + w.estimatedCost, 0);
  const shoppingList = generateShoppingList(generatedWeeks, numberOfPeople);

  return {
    id: `plan_${Date.now()}`,
    createdAt: new Date().toISOString(),
    weeks: generatedWeeks,
    totalEstimatedCost: Math.round(totalCost * 100) / 100,
    numberOfPeople,
    monthlyBudget: budget,
    shoppingList,
  };
}
