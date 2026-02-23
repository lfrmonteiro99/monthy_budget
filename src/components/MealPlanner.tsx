import { useState, useMemo, useCallback } from "react";
import {
  ChevronLeft,
  ChevronRight,
  RefreshCw,
  ShoppingCart,
  ChefHat,
  Clock,
  Users,
  Euro,
  AlertTriangle,
  Sparkles,
  Utensils,
  Soup,
  ArrowLeft,
  Check,
} from "lucide-react";
import type { AppSettings } from "../types";
import type {
  MealPlan,
  MealSlot,
  ShoppingListItem,
  ProteinType,
  VarietyLevel,
  MealPlanGenerationConfig,
} from "../types/mealPlanner";
import { RECIPES_MAP } from "../data/recipes";
import { INGREDIENTS_MAP } from "../data/ingredients";
import { generateMealPlan, generateShoppingList as regenerateShoppingList, calculateRecipeCost } from "../utils/mealPlanGenerator";
import { formatCurrency } from "../utils/calculations";
import ShoppingList from "./ShoppingList";

interface MealPlannerProps {
  settings: AppSettings;
  onUpdateSettings: (settings: AppSettings) => void;
}

type SubView = "planner" | "shopping" | "config";

const PROTEIN_LABELS: Record<ProteinType, string> = {
  frango: "Frango",
  porco: "Porco",
  vaca: "Vaca",
  peixe: "Peixe",
  ovos: "Ovos",
  leguminosas: "Leguminosas",
  sem_proteina: "Sem proteina",
};

const VARIETY_LABELS: Record<VarietyLevel, string> = {
  baixa: "Baixa",
  media: "Media",
  alta: "Alta",
};

const MEAL_PLAN_STORAGE_KEY = "orcamento_meal_plan";
const SHOPPING_LIST_STORAGE_KEY = "orcamento_shopping_list";

function loadMealPlan(): MealPlan | null {
  try {
    const raw = localStorage.getItem(MEAL_PLAN_STORAGE_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

function saveMealPlan(plan: MealPlan | null): void {
  try {
    if (plan) {
      localStorage.setItem(MEAL_PLAN_STORAGE_KEY, JSON.stringify(plan));
    } else {
      localStorage.removeItem(MEAL_PLAN_STORAGE_KEY);
    }
  } catch {
    // storage full
  }
}

function loadShoppingList(): ShoppingListItem[] | null {
  try {
    const raw = localStorage.getItem(SHOPPING_LIST_STORAGE_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

function saveShoppingList(list: ShoppingListItem[]): void {
  try {
    localStorage.setItem(SHOPPING_LIST_STORAGE_KEY, JSON.stringify(list));
  } catch {
    // storage full
  }
}

export default function MealPlanner({
  settings,
  onUpdateSettings,
}: MealPlannerProps) {
  const [mealPlan, setMealPlan] = useState<MealPlan | null>(() => loadMealPlan());
  const [shoppingList, setShoppingList] = useState<ShoppingListItem[]>(
    () => loadShoppingList() ?? [],
  );
  const [currentWeek, setCurrentWeek] = useState(0);
  const [subView, setSubView] = useState<SubView>("planner");
  const [isGenerating, setIsGenerating] = useState(false);

  // Derive food budget from expenses with category "alimentacao"
  const foodBudget = useMemo(() => {
    return settings.expenses
      .filter((e) => e.enabled && e.category === "alimentacao")
      .reduce((sum, e) => sum + e.amount, 0);
  }, [settings.expenses]);

  // Calculate number of people from settings
  const numberOfPeople = useMemo(() => {
    const prefs = settings.mealPlannerPreferences;
    if (prefs?.numberOfPeopleOverride) return prefs.numberOfPeopleOverride;
    const activeSalaries = settings.salaries.filter((s) => s.enabled).length;
    return activeSalaries + settings.personalInfo.dependentes;
  }, [settings]);

  const prefs = useMemo(() => settings.mealPlannerPreferences ?? {
    numberOfPeopleOverride: null,
    varietyLevel: "media" as VarietyLevel,
    excludedProteins: [] as string[],
    weeksToGenerate: 4,
    mealsPerDay: ["almoco" as const, "jantar" as const],
  }, [settings.mealPlannerPreferences]);

  const handleGenerate = useCallback(() => {
    if (foodBudget <= 0 || numberOfPeople <= 0) return;

    setIsGenerating(true);

    // Use setTimeout to let the UI update with the loading state
    setTimeout(() => {
      const config: MealPlanGenerationConfig = {
        budget: foodBudget,
        numberOfPeople,
        weeks: prefs.weeksToGenerate,
        mealsPerDay: prefs.mealsPerDay,
        excludedProteins: prefs.excludedProteins as ProteinType[],
        varietyLevel: prefs.varietyLevel,
      };

      const plan = generateMealPlan(config);
      setMealPlan(plan);
      saveMealPlan(plan);
      setShoppingList(plan.shoppingList);
      saveShoppingList(plan.shoppingList);
      setCurrentWeek(0);
      setIsGenerating(false);
    }, 100);
  }, [foodBudget, numberOfPeople, prefs]);

  const handleSwapMeal = useCallback(
    (weekIdx: number, dayIdx: number, mealType: "almoco" | "jantar") => {
      if (!mealPlan) return;

      const updatedWeeks = [...mealPlan.weeks];
      const week = { ...updatedWeeks[weekIdx] };
      const days = [...week.days];
      const day = { ...days[dayIdx] };

      // Get current recipe to avoid picking the same one
      const currentRecipe = day[mealType];
      const currentRecipeId = currentRecipe?.recipeId;

      // Pick a random different recipe for this meal type
      const candidates = Object.values(RECIPES_MAP).filter(
        (r) => r.suitableFor.includes(mealType) && r.id !== currentRecipeId,
      );

      if (candidates.length === 0) return;

      const newRecipe = candidates[Math.floor(Math.random() * candidates.length)];
      const newCost = calculateRecipeCost(newRecipe, mealPlan.numberOfPeople);
      const oldCost = currentRecipe?.estimatedCost ?? 0;

      day[mealType] = {
        recipeId: newRecipe.id,
        recipeName: newRecipe.name,
        estimatedCost: newCost,
      };

      days[dayIdx] = day;
      week.days = days;
      week.estimatedCost = Math.round((week.estimatedCost - oldCost + newCost) * 100) / 100;
      updatedWeeks[weekIdx] = week;

      const totalCost = updatedWeeks.reduce((s, w) => s + w.estimatedCost, 0);

      const updatedPlan: MealPlan = {
        ...mealPlan,
        weeks: updatedWeeks,
        totalEstimatedCost: Math.round(totalCost * 100) / 100,
      };

      // Regenerate shopping list from updated plan
      const newShoppingList = regenerateShoppingList(
        updatedPlan.weeks,
        updatedPlan.numberOfPeople,
      );
      updatedPlan.shoppingList = newShoppingList;

      setMealPlan(updatedPlan);
      saveMealPlan(updatedPlan);
      setShoppingList(newShoppingList);
      saveShoppingList(newShoppingList);
    },
    [mealPlan],
  );

  const handleAddMealToShoppingList = useCallback(
    (meal: MealSlot) => {
      const recipe = RECIPES_MAP[meal.recipeId];
      if (!recipe) return;

      const people = mealPlan?.numberOfPeople ?? numberOfPeople;

      setShoppingList((prev) => {
        const updated = [...prev];

        for (const ri of recipe.ingredients) {
          const existingIdx = updated.findIndex(
            (item) => item.ingredientId === ri.ingredientId,
          );

          if (existingIdx >= 0) {
            // Increase quantity of existing item
            const item = { ...updated[existingIdx] };
            const additionalQty = ri.quantityPerServing * people;
            // Convert to same unit as existing
            const ingredient = INGREDIENTS_MAP[ri.ingredientId];
            if (!ingredient) continue;

            item.totalQuantity += additionalQty / (ri.unit === "g" && item.unit === "kg" ? 1000 : 1);
            item.purchaseQuantity = Math.ceil(item.totalQuantity / ingredient.minPurchase) * ingredient.minPurchase;
            item.estimatedCost = Math.round(item.purchaseQuantity * ingredient.pricePerUnit * 100) / 100;
            if (!item.fromRecipes.includes(recipe.name)) {
              item.fromRecipes = [...item.fromRecipes, recipe.name];
            }
            updated[existingIdx] = item;
          }
          // Items not in the list are already in the plan's shopping list
        }

        saveShoppingList(updated);
        return updated;
      });
    },
    [mealPlan, numberOfPeople],
  );

  const handleToggleShoppingItem = useCallback((ingredientId: string) => {
    setShoppingList((prev) => {
      const updated = prev.map((item) =>
        item.ingredientId === ingredientId ? { ...item, checked: !item.checked } : item,
      );
      saveShoppingList(updated);
      return updated;
    });
  }, []);

  const handleUpdatePreferences = useCallback(
    (updates: Partial<typeof prefs>) => {
      onUpdateSettings({
        ...settings,
        mealPlannerPreferences: { ...prefs, ...updates },
      });
    },
    [settings, prefs, onUpdateSettings],
  );

  // Budget utilization
  const budgetUsed = mealPlan?.totalEstimatedCost ?? 0;
  const budgetPercentage = foodBudget > 0 ? (budgetUsed / foodBudget) * 100 : 0;
  const isOverBudget = budgetPercentage > 100;

  if (subView === "shopping") {
    return (
      <ShoppingList
        items={shoppingList}
        onToggleItem={handleToggleShoppingItem}
        onBack={() => setSubView("planner")}
        totalEstimatedCost={shoppingList.reduce((s, i) => s + i.estimatedCost, 0)}
      />
    );
  }

  if (subView === "config") {
    return (
      <MealPlannerConfig
        prefs={prefs}
        numberOfPeople={numberOfPeople}
        foodBudget={foodBudget}
        onUpdate={handleUpdatePreferences}
        onBack={() => setSubView("planner")}
      />
    );
  }

  return (
    <div className="min-h-screen bg-slate-50 animate-fade-in">
      {/* Header */}
      <div className="bg-white border-b border-slate-100 px-5 pt-5 pb-5">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="text-lg font-bold text-slate-800 tracking-tight">
              Planeador de Refeicoes
            </h1>
            <p className="text-slate-400 text-xs font-medium mt-0.5 tracking-wide uppercase">
              {numberOfPeople} {numberOfPeople === 1 ? "pessoa" : "pessoas"} · {prefs.weeksToGenerate} semanas
            </p>
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => setSubView("config")}
              className="p-2.5 bg-slate-50 hover:bg-slate-100 rounded-xl transition-colors border border-slate-200"
              title="Configurar"
            >
              <Users size={20} className="text-slate-500" />
            </button>
          </div>
        </div>

        {/* Budget summary bar */}
        {foodBudget > 0 && (
          <div className="bg-slate-50 rounded-2xl px-4 py-4 border border-slate-100">
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs font-semibold text-slate-400 uppercase tracking-wide">
                Orcamento Alimentacao
              </span>
              <span className="text-xs font-bold text-slate-600">
                {formatCurrency(budgetUsed)} / {formatCurrency(foodBudget)}
              </span>
            </div>
            <div className="w-full bg-slate-200 rounded-full h-2">
              <div
                className={`h-2 rounded-full transition-all ${
                  isOverBudget ? "bg-red-500" : budgetPercentage > 80 ? "bg-amber-500" : "bg-emerald-500"
                }`}
                style={{ width: `${Math.min(budgetPercentage, 100)}%` }}
              />
            </div>
            {isOverBudget && (
              <div className="flex items-center gap-1 mt-2 text-xs text-red-500 font-medium">
                <AlertTriangle size={12} />
                Acima do orcamento em {formatCurrency(budgetUsed - foodBudget)}
              </div>
            )}
          </div>
        )}

        {foodBudget <= 0 && (
          <div className="bg-amber-50 rounded-2xl px-4 py-4 border border-amber-100">
            <div className="flex items-center gap-2 text-amber-600 text-sm font-medium">
              <AlertTriangle size={16} />
              Defina um valor de Alimentacao nas despesas para planear refeicoes.
            </div>
          </div>
        )}
      </div>

      <div className="max-w-lg mx-auto px-4 py-5 space-y-4">
        {/* Generate / Regenerate button */}
        <button
          onClick={handleGenerate}
          disabled={foodBudget <= 0 || numberOfPeople <= 0 || isGenerating}
          className={`w-full flex items-center justify-center gap-2 py-4 rounded-2xl font-semibold text-sm transition-all shadow-sm ${
            foodBudget <= 0 || numberOfPeople <= 0
              ? "bg-slate-100 text-slate-400 cursor-not-allowed"
              : "bg-blue-500 hover:bg-blue-600 text-white active:scale-[0.98]"
          }`}
        >
          {isGenerating ? (
            <>
              <RefreshCw size={18} className="animate-spin" />
              A gerar plano...
            </>
          ) : mealPlan ? (
            <>
              <RefreshCw size={18} />
              Gerar novo plano
            </>
          ) : (
            <>
              <Sparkles size={18} />
              Gerar plano mensal
            </>
          )}
        </button>

        {/* Meal Plan Display */}
        {mealPlan && (
          <>
            {/* Week Navigation */}
            <div className="flex items-center justify-between bg-white rounded-2xl p-4 shadow-sm border border-slate-100">
              <button
                onClick={() => setCurrentWeek(Math.max(0, currentWeek - 1))}
                disabled={currentWeek === 0}
                className="p-2 rounded-xl hover:bg-slate-100 disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
              >
                <ChevronLeft size={20} className="text-slate-600" />
              </button>
              <div className="text-center">
                <span className="text-sm font-bold text-slate-700">
                  {mealPlan.weeks[currentWeek]?.weekLabel}
                </span>
                <p className="text-xs text-slate-400 mt-0.5">
                  Custo estimado: {formatCurrency(mealPlan.weeks[currentWeek]?.estimatedCost ?? 0)}
                </p>
              </div>
              <button
                onClick={() =>
                  setCurrentWeek(Math.min(mealPlan.weeks.length - 1, currentWeek + 1))
                }
                disabled={currentWeek >= mealPlan.weeks.length - 1}
                className="p-2 rounded-xl hover:bg-slate-100 disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
              >
                <ChevronRight size={20} className="text-slate-600" />
              </button>
            </div>

            {/* Week dots */}
            <div className="flex justify-center gap-2">
              {mealPlan.weeks.map((_, idx) => (
                <button
                  key={idx}
                  onClick={() => setCurrentWeek(idx)}
                  className={`w-2.5 h-2.5 rounded-full transition-all ${
                    idx === currentWeek ? "bg-blue-500 scale-110" : "bg-slate-200"
                  }`}
                />
              ))}
            </div>

            {/* Days */}
            <div className="space-y-3">
              {mealPlan.weeks[currentWeek]?.days.map((day) => (
                <DayCard
                  key={day.dayIndex}
                  day={day}
                  onSwapMeal={(mealType) =>
                    handleSwapMeal(currentWeek, day.dayIndex, mealType)
                  }
                  onAddToList={handleAddMealToShoppingList}
                  numberOfPeople={mealPlan.numberOfPeople}
                />
              ))}
            </div>

            {/* Shopping List button */}
            <button
              onClick={() => setSubView("shopping")}
              className="w-full flex items-center justify-center gap-2 py-4 rounded-2xl bg-emerald-500 hover:bg-emerald-600 text-white font-semibold text-sm transition-all shadow-sm active:scale-[0.98]"
            >
              <ShoppingCart size={18} />
              Lista de compras ({shoppingList.filter((i) => !i.checked).length} itens)
            </button>

            {/* Total summary */}
            <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100">
              <h3 className="text-xs font-semibold text-slate-400 mb-3 tracking-wide uppercase">
                Resumo do Plano
              </h3>
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <p className="text-slate-400 text-xs">Custo total estimado</p>
                  <p className={`font-bold text-lg ${isOverBudget ? "text-red-500" : "text-emerald-500"}`}>
                    {formatCurrency(mealPlan.totalEstimatedCost)}
                  </p>
                </div>
                <div>
                  <p className="text-slate-400 text-xs">Custo medio/refeicao</p>
                  <p className="font-bold text-lg text-slate-700">
                    {formatCurrency(
                      mealPlan.totalEstimatedCost /
                        Math.max(
                          1,
                          mealPlan.weeks.reduce(
                            (sum, w) =>
                              sum +
                              w.days.reduce(
                                (ds, d) => ds + (d.almoco ? 1 : 0) + (d.jantar ? 1 : 0),
                                0,
                              ),
                            0,
                          ),
                        ),
                    )}
                  </p>
                </div>
                <div>
                  <p className="text-slate-400 text-xs">Total refeicoes</p>
                  <p className="font-bold text-lg text-slate-700">
                    {mealPlan.weeks.reduce(
                      (sum, w) =>
                        sum +
                        w.days.reduce(
                          (ds, d) => ds + (d.almoco ? 1 : 0) + (d.jantar ? 1 : 0),
                          0,
                        ),
                      0,
                    )}
                  </p>
                </div>
                <div>
                  <p className="text-slate-400 text-xs">Poupanca estimada</p>
                  <p className={`font-bold text-lg ${foodBudget - mealPlan.totalEstimatedCost >= 0 ? "text-emerald-500" : "text-red-500"}`}>
                    {formatCurrency(Math.max(0, foodBudget - mealPlan.totalEstimatedCost))}
                  </p>
                </div>
              </div>
            </div>
          </>
        )}

        {/* Empty state */}
        {!mealPlan && foodBudget > 0 && (
          <div className="bg-white rounded-2xl p-8 shadow-sm border border-slate-100 text-center">
            <ChefHat size={48} className="text-slate-200 mx-auto mb-4" />
            <p className="text-slate-500 text-sm font-medium mb-2">
              Ainda nao tem plano de refeicoes
            </p>
            <p className="text-slate-400 text-xs">
              Clique em "Gerar plano mensal" para criar um plano
              otimizado para o seu orcamento.
            </p>
          </div>
        )}

        <div className="h-4" />
      </div>
    </div>
  );
}

// ─── Day Card Component ─────────────────────────────────────────────

function DayCard({
  day,
  onSwapMeal,
  onAddToList,
  numberOfPeople,
}: {
  day: import("../types/mealPlanner").DayPlan;
  onSwapMeal: (mealType: "almoco" | "jantar") => void;
  onAddToList: (meal: MealSlot) => void;
  numberOfPeople: number;
}) {
  return (
    <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
      <div className="bg-slate-50 px-4 py-2.5 border-b border-slate-100">
        <span className="text-xs font-bold text-slate-500 tracking-wide uppercase">
          {day.dayLabel}
        </span>
      </div>
      <div className="divide-y divide-slate-50">
        {day.almoco && (
          <MealRow
            meal={day.almoco}
            mealType="almoco"
            onSwap={() => onSwapMeal("almoco")}
            onAddToList={() => onAddToList(day.almoco!)}
            numberOfPeople={numberOfPeople}
          />
        )}
        {day.jantar && (
          <MealRow
            meal={day.jantar}
            mealType="jantar"
            onSwap={() => onSwapMeal("jantar")}
            onAddToList={() => onAddToList(day.jantar!)}
            numberOfPeople={numberOfPeople}
          />
        )}
      </div>
    </div>
  );
}

// ─── Meal Row Component ─────────────────────────────────────────────

function MealRow({
  meal,
  mealType,
  onSwap,
  onAddToList,
  numberOfPeople,
}: {
  meal: MealSlot;
  mealType: "almoco" | "jantar";
  onSwap: () => void;
  onAddToList: () => void;
  numberOfPeople: number;
}) {
  const [showDetails, setShowDetails] = useState(false);
  const recipe = RECIPES_MAP[meal.recipeId];

  return (
    <div className="px-4 py-3">
      <div className="flex items-center gap-3">
        <div
          className={`p-2 rounded-xl ${
            mealType === "almoco"
              ? "bg-amber-50 text-amber-500"
              : "bg-indigo-50 text-indigo-500"
          }`}
        >
          {mealType === "almoco" ? <Utensils size={16} /> : <Soup size={16} />}
        </div>
        <div className="flex-1 min-w-0">
          <button
            onClick={() => setShowDetails(!showDetails)}
            className="text-left w-full"
          >
            <p className="text-sm font-medium text-slate-700 truncate">
              {meal.recipeName}
            </p>
            <div className="flex items-center gap-2 mt-0.5">
              <span className="text-xs text-slate-400">
                {mealType === "almoco" ? "Almoco" : "Jantar"}
              </span>
              {recipe && (
                <>
                  <span className="text-xs text-slate-300">·</span>
                  <span className="text-xs text-slate-400 flex items-center gap-0.5">
                    <Clock size={10} />
                    {recipe.prepTime}min
                  </span>
                </>
              )}
              <span className="text-xs text-slate-300">·</span>
              <span className="text-xs font-medium text-emerald-500">
                {formatCurrency(meal.estimatedCost)}
              </span>
            </div>
          </button>
        </div>
        <button
          onClick={onSwap}
          className="p-2 hover:bg-slate-100 rounded-xl transition-colors"
          title="Trocar refeicao"
        >
          <RefreshCw size={14} className="text-slate-400" />
        </button>
      </div>

      {/* Recipe details (expandable) */}
      {showDetails && recipe && (
        <div className="mt-3 ml-11 space-y-2 animate-slide-down">
          <div className="flex flex-wrap gap-1.5">
            <span className="px-2 py-0.5 bg-slate-100 rounded-full text-[10px] font-medium text-slate-500">
              {PROTEIN_LABELS[recipe.proteinBase]}
            </span>
            {recipe.tags.map((tag) => (
              <span
                key={tag}
                className="px-2 py-0.5 bg-blue-50 rounded-full text-[10px] font-medium text-blue-500"
              >
                {tag}
              </span>
            ))}
          </div>
          <div className="text-xs text-slate-400 space-y-0.5">
            <p className="font-medium text-slate-500">
              Ingredientes ({numberOfPeople}p):
            </p>
            {recipe.ingredients.map((ri) => {
              const ing = INGREDIENTS_MAP[ri.ingredientId];
              const qty = ri.quantityPerServing * numberOfPeople;
              const displayQty =
                ri.unit === "g" && qty >= 1000
                  ? `${(qty / 1000).toFixed(1)}kg`
                  : ri.unit === "ml" && qty >= 1000
                    ? `${(qty / 1000).toFixed(1)}L`
                    : `${Math.round(qty * 10) / 10}${ri.unit}`;
              return (
                <p key={ri.ingredientId}>
                  {ing?.name ?? ri.ingredientId}: {displayQty}
                </p>
              );
            })}
          </div>
          <button
            onClick={onAddToList}
            className="flex items-center gap-1.5 text-xs font-medium text-emerald-600 hover:text-emerald-700 py-1"
          >
            <ShoppingCart size={12} />
            Adicionar a lista de compras
          </button>
        </div>
      )}
    </div>
  );
}

// ─── Config Sub-View ────────────────────────────────────────────────

function MealPlannerConfig({
  prefs,
  numberOfPeople,
  foodBudget,
  onUpdate,
  onBack,
}: {
  prefs: NonNullable<AppSettings["mealPlannerPreferences"]>;
  numberOfPeople: number;
  foodBudget: number;
  onUpdate: (updates: Partial<typeof prefs>) => void;
  onBack: () => void;
}) {
  const allProteins: ProteinType[] = [
    "frango",
    "porco",
    "vaca",
    "peixe",
    "ovos",
    "leguminosas",
  ];

  return (
    <div className="min-h-screen bg-slate-50 animate-fade-in">
      <div className="bg-white border-b border-slate-100 px-4 py-4 flex items-center gap-3 sticky top-0 z-10">
        <button
          onClick={onBack}
          className="p-2 hover:bg-slate-100 rounded-xl transition-colors"
        >
          <ArrowLeft size={22} className="text-slate-600" />
        </button>
        <h1 className="text-lg font-bold text-slate-800 flex-1 tracking-tight">
          Configurar Planeador
        </h1>
        <button
          onClick={onBack}
          className="bg-blue-500 hover:bg-blue-600 text-white pl-3 pr-4 py-2 rounded-xl font-semibold text-sm transition-colors shadow-sm flex items-center gap-1.5"
        >
          <Check size={16} strokeWidth={2.5} />
          OK
        </button>
      </div>

      <div className="max-w-lg mx-auto px-4 py-5 space-y-5">
        {/* Info */}
        <div className="bg-blue-50 rounded-2xl p-4 border border-blue-100">
          <div className="flex items-center gap-3 text-sm text-blue-700">
            <Euro size={18} />
            <div>
              <p className="font-semibold">Orcamento: {formatCurrency(foodBudget)}</p>
              <p className="text-xs text-blue-500 mt-0.5">
                {numberOfPeople} pessoas · {formatCurrency(foodBudget / numberOfPeople)}/pessoa
              </p>
            </div>
          </div>
        </div>

        {/* Number of people override */}
        <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100">
          <label className="block text-xs font-semibold text-slate-500 mb-3 tracking-wide uppercase">
            Numero de pessoas
          </label>
          <div className="flex items-center gap-4">
            <button
              onClick={() =>
                onUpdate({
                  numberOfPeopleOverride: Math.max(1, (prefs.numberOfPeopleOverride ?? numberOfPeople) - 1),
                })
              }
              className="w-11 h-11 rounded-xl border-2 border-slate-200 flex items-center justify-center text-lg font-bold text-slate-500 hover:bg-slate-50 hover:border-slate-300 transition-all active:scale-95"
            >
              -
            </button>
            <span className="text-2xl font-bold text-slate-800 w-8 text-center tabular-nums">
              {prefs.numberOfPeopleOverride ?? numberOfPeople}
            </span>
            <button
              onClick={() =>
                onUpdate({
                  numberOfPeopleOverride: (prefs.numberOfPeopleOverride ?? numberOfPeople) + 1,
                })
              }
              className="w-11 h-11 rounded-xl border-2 border-slate-200 flex items-center justify-center text-lg font-bold text-slate-500 hover:bg-slate-50 hover:border-slate-300 transition-all active:scale-95"
            >
              +
            </button>
            {prefs.numberOfPeopleOverride !== null && (
              <button
                onClick={() => onUpdate({ numberOfPeopleOverride: null })}
                className="text-xs text-blue-500 font-medium ml-2"
              >
                Auto
              </button>
            )}
          </div>
          <p className="text-xs text-slate-400 mt-2">
            Automatico: {numberOfPeople} (salarios ativos + dependentes)
          </p>
        </div>

        {/* Variety level */}
        <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100">
          <label className="block text-xs font-semibold text-slate-500 mb-3 tracking-wide uppercase">
            Nivel de variedade
          </label>
          <div className="flex gap-2">
            {(["baixa", "media", "alta"] as VarietyLevel[]).map((level) => (
              <button
                key={level}
                onClick={() => onUpdate({ varietyLevel: level })}
                className={`flex-1 py-2.5 rounded-xl text-xs font-semibold border-2 transition-all ${
                  prefs.varietyLevel === level
                    ? "bg-blue-500 text-white border-blue-500"
                    : "bg-white text-slate-500 border-slate-200 hover:border-slate-300"
                }`}
              >
                {VARIETY_LABELS[level]}
              </button>
            ))}
          </div>
          <p className="text-xs text-slate-400 mt-2">
            Baixa = menos ingredientes diferentes. Alta = mais variedade.
          </p>
        </div>

        {/* Weeks */}
        <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100">
          <label className="block text-xs font-semibold text-slate-500 mb-3 tracking-wide uppercase">
            Semanas a planear
          </label>
          <div className="flex gap-2">
            {[2, 3, 4].map((w) => (
              <button
                key={w}
                onClick={() => onUpdate({ weeksToGenerate: w })}
                className={`flex-1 py-2.5 rounded-xl text-xs font-semibold border-2 transition-all ${
                  prefs.weeksToGenerate === w
                    ? "bg-blue-500 text-white border-blue-500"
                    : "bg-white text-slate-500 border-slate-200 hover:border-slate-300"
                }`}
              >
                {w} semanas
              </button>
            ))}
          </div>
        </div>

        {/* Meals per day */}
        <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100">
          <label className="block text-xs font-semibold text-slate-500 mb-3 tracking-wide uppercase">
            Refeicoes a planear
          </label>
          <div className="space-y-2">
            {([
              { value: "almoco" as const, label: "Almoco" },
              { value: "jantar" as const, label: "Jantar" },
            ]).map((opt) => (
              <label
                key={opt.value}
                className="flex items-center gap-3 text-sm font-medium text-slate-600 cursor-pointer"
              >
                <input
                  type="checkbox"
                  checked={prefs.mealsPerDay.includes(opt.value)}
                  onChange={(e) => {
                    const newMeals = e.target.checked
                      ? [...prefs.mealsPerDay, opt.value]
                      : prefs.mealsPerDay.filter((m) => m !== opt.value);
                    onUpdate({ mealsPerDay: newMeals.length > 0 ? newMeals : [opt.value] });
                  }}
                />
                {opt.label}
              </label>
            ))}
          </div>
        </div>

        {/* Excluded proteins */}
        <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100">
          <label className="block text-xs font-semibold text-slate-500 mb-3 tracking-wide uppercase">
            Excluir proteinas
          </label>
          <div className="flex flex-wrap gap-2">
            {allProteins.map((protein) => {
              const isExcluded = prefs.excludedProteins.includes(protein);
              return (
                <button
                  key={protein}
                  onClick={() => {
                    const newExcluded = isExcluded
                      ? prefs.excludedProteins.filter((p) => p !== protein)
                      : [...prefs.excludedProteins, protein];
                    onUpdate({ excludedProteins: newExcluded });
                  }}
                  className={`px-3 py-2 rounded-xl text-xs font-semibold border-2 transition-all ${
                    isExcluded
                      ? "bg-red-50 text-red-500 border-red-200"
                      : "bg-white text-slate-500 border-slate-200 hover:border-slate-300"
                  }`}
                >
                  {isExcluded ? "✕ " : ""}
                  {PROTEIN_LABELS[protein]}
                </button>
              );
            })}
          </div>
          <p className="text-xs text-slate-400 mt-2">
            Clique para excluir um tipo de proteina do plano.
          </p>
        </div>
      </div>
    </div>
  );
}
