// ─── Ingredient Types ───────────────────────────────────────────────

export type IngredientCategory =
  | "proteina"
  | "legumes"
  | "fruta"
  | "laticinios"
  | "cereais_massas"
  | "conservas"
  | "temperos"
  | "gorduras"
  | "outros";

export const INGREDIENT_CATEGORY_LABELS: Record<IngredientCategory, string> = {
  proteina: "Proteinas",
  legumes: "Legumes e Verduras",
  fruta: "Fruta",
  laticinios: "Laticinios",
  cereais_massas: "Cereais e Massas",
  conservas: "Conservas e Enlatados",
  temperos: "Temperos e Condimentos",
  gorduras: "Gorduras e Oleos",
  outros: "Outros",
};

export type MeasureUnit = "kg" | "g" | "L" | "ml" | "un" | "dz";

export interface Ingredient {
  id: string;
  name: string;
  category: IngredientCategory;
  /** Price per base unit (EUR per kg, L, or un) */
  pricePerUnit: number;
  /** Base unit for pricing */
  unit: MeasureUnit;
  /** Minimum practical purchase quantity in base units */
  minPurchase: number;
  /** Minimum purchase price */
  minPurchasePrice: number;
}

// ─── Recipe Types ───────────────────────────────────────────────────

export type MealType = "almoco" | "jantar";
export type ProteinType = "frango" | "porco" | "vaca" | "peixe" | "ovos" | "leguminosas" | "sem_proteina";
export type DifficultyLevel = "facil" | "medio" | "dificil";

export interface RecipeIngredient {
  ingredientId: string;
  /** Quantity per serving in grams, ml, or units */
  quantityPerServing: number;
  /** Unit for this ingredient in the recipe */
  unit: MeasureUnit;
}

export interface Recipe {
  id: string;
  name: string;
  /** Base servings this recipe makes */
  servings: number;
  /** Prep + cook time in minutes */
  prepTime: number;
  ingredients: RecipeIngredient[];
  proteinBase: ProteinType;
  difficulty: DifficultyLevel;
  tags: string[];
  /** Which meal is this suitable for */
  suitableFor: MealType[];
}

// ─── Meal Plan Types ────────────────────────────────────────────────

export interface MealSlot {
  recipeId: string;
  recipeName: string;
  estimatedCost: number;
}

export interface DayPlan {
  dayIndex: number; // 0-6 (Monday-Sunday)
  dayLabel: string;
  almoco: MealSlot | null;
  jantar: MealSlot | null;
}

export interface WeekPlan {
  weekIndex: number; // 0-3
  weekLabel: string;
  days: DayPlan[];
  estimatedCost: number;
}

export interface MealPlan {
  id: string;
  createdAt: string;
  weeks: WeekPlan[];
  totalEstimatedCost: number;
  numberOfPeople: number;
  monthlyBudget: number;
  shoppingList: ShoppingListItem[];
}

// ─── Shopping List Types ────────────────────────────────────────────

export interface ShoppingListItem {
  ingredientId: string;
  name: string;
  category: IngredientCategory;
  totalQuantity: number;
  /** Rounded up to practical purchase quantity */
  purchaseQuantity: number;
  unit: MeasureUnit;
  estimatedCost: number;
  /** Which recipes use this ingredient */
  fromRecipes: string[];
  checked: boolean;
}

// ─── Meal Planner Settings ──────────────────────────────────────────

export type VarietyLevel = "baixa" | "media" | "alta";

export interface MealPlannerPreferences {
  /** Override number of people (null = auto from salaries + dependents) */
  numberOfPeopleOverride: number | null;
  varietyLevel: VarietyLevel;
  /** Excluded protein types */
  excludedProteins: ProteinType[];
  /** Number of weeks to plan */
  weeksToGenerate: number;
  /** Meals to plan per day */
  mealsPerDay: MealType[];
}

export const DEFAULT_MEAL_PLANNER_PREFERENCES: MealPlannerPreferences = {
  numberOfPeopleOverride: null,
  varietyLevel: "media",
  excludedProteins: [],
  weeksToGenerate: 4,
  mealsPerDay: ["almoco", "jantar"],
};

// ─── Generation Config ──────────────────────────────────────────────

export interface MealPlanGenerationConfig {
  budget: number;
  numberOfPeople: number;
  weeks: number;
  mealsPerDay: MealType[];
  excludedProteins: ProteinType[];
  varietyLevel: VarietyLevel;
}
