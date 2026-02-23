import { useState } from "react";
import {
  ArrowLeft,
  UtensilsCrossed,
  Sparkles,
  ChevronDown,
  ChevronUp,
  ShoppingCart,
  Plus,
  Check,
  Trash2,
  AlertCircle,
  CalendarDays,
} from "lucide-react";
import type {
  AppSettings,
  BudgetSummary,
  MealPlanDay,
  ShoppingListItem,
} from "../types";
import { generateMealPlan, getDaysInNextMonth, getMonthName } from "../utils/mealGenerator";

interface MealPlanningProps {
  settings: AppSettings;
  summary: BudgetSummary;
  onSave: (settings: AppSettings) => void;
  onBack: () => void;
}

type MealTab = "plan" | "shopping";

export default function MealPlanning({ settings, summary, onSave, onBack }: MealPlanningProps) {
  const [activeTab, setActiveTab] = useState<MealTab>("plan");
  const [expandedDay, setExpandedDay] = useState<number | null>(null);
  const [generating, setGenerating] = useState(false);

  const { mealPlanConfig } = settings;
  const validFoods = mealPlanConfig.availableFoods.filter((f) => f.name.trim());
  const hasFoods = validFoods.length > 0;
  const hasMealPlan = mealPlanConfig.mealPlan.length > 0;
  const { year, month, days } = getDaysInNextMonth();
  const monthName = getMonthName(month);

  const handleGenerate = () => {
    setGenerating(true);
    // Simulate a brief delay to feel like AI processing
    setTimeout(() => {
      const meals = generateMealPlan(
        validFoods,
        days,
        settings.personalInfo.dependentes,
        summary,
      );
      onSave({
        ...settings,
        mealPlanConfig: {
          ...settings.mealPlanConfig,
          mealPlan: meals,
        },
      });
      setGenerating(false);
    }, 800);
  };

  const handleAddToShoppingList = (meal: MealPlanDay) => {
    const currentList = [...settings.mealPlanConfig.shoppingList];

    for (const ingredient of meal.ingredients) {
      const existingIdx = currentList.findIndex(
        (item) => item.name.toLowerCase() === ingredient.foodName.toLowerCase() && item.unit === ingredient.unit,
      );

      if (existingIdx >= 0) {
        currentList[existingIdx] = {
          ...currentList[existingIdx],
          quantity: currentList[existingIdx].quantity + ingredient.quantity,
        };
      } else {
        currentList.push({
          id: `shop_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
          name: ingredient.foodName,
          quantity: ingredient.quantity,
          unit: ingredient.unit,
          checked: false,
        });
      }
    }

    onSave({
      ...settings,
      mealPlanConfig: {
        ...settings.mealPlanConfig,
        shoppingList: currentList,
      },
    });
  };

  const handleAddAllToShoppingList = () => {
    const currentList: ShoppingListItem[] = [];

    for (const meal of settings.mealPlanConfig.mealPlan) {
      for (const ingredient of meal.ingredients) {
        const existingIdx = currentList.findIndex(
          (item) => item.name.toLowerCase() === ingredient.foodName.toLowerCase() && item.unit === ingredient.unit,
        );

        if (existingIdx >= 0) {
          currentList[existingIdx] = {
            ...currentList[existingIdx],
            quantity: currentList[existingIdx].quantity + ingredient.quantity,
          };
        } else {
          currentList.push({
            id: `shop_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
            name: ingredient.foodName,
            quantity: ingredient.quantity,
            unit: ingredient.unit,
            checked: false,
          });
        }
      }
    }

    onSave({
      ...settings,
      mealPlanConfig: {
        ...settings.mealPlanConfig,
        shoppingList: currentList,
      },
    });
  };

  const toggleShoppingItem = (id: string) => {
    onSave({
      ...settings,
      mealPlanConfig: {
        ...settings.mealPlanConfig,
        shoppingList: settings.mealPlanConfig.shoppingList.map((item) =>
          item.id === id ? { ...item, checked: !item.checked } : item,
        ),
      },
    });
  };

  const removeShoppingItem = (id: string) => {
    onSave({
      ...settings,
      mealPlanConfig: {
        ...settings.mealPlanConfig,
        shoppingList: settings.mealPlanConfig.shoppingList.filter((item) => item.id !== id),
      },
    });
  };

  const clearShoppingList = () => {
    onSave({
      ...settings,
      mealPlanConfig: {
        ...settings.mealPlanConfig,
        shoppingList: [],
      },
    });
  };

  const clearMealPlan = () => {
    onSave({
      ...settings,
      mealPlanConfig: {
        ...settings.mealPlanConfig,
        mealPlan: [],
      },
    });
  };

  return (
    <div className="min-h-screen bg-slate-50 animate-fade-in">
      {/* Header */}
      <div className="bg-white border-b border-slate-100 px-4 py-4 sticky top-0 z-10">
        <div className="flex items-center gap-3">
          <button
            onClick={onBack}
            className="p-2 hover:bg-slate-100 rounded-xl transition-colors"
          >
            <ArrowLeft size={22} className="text-slate-600" />
          </button>
          <div className="flex-1">
            <h1 className="text-lg font-bold text-slate-800 tracking-tight">
              Plano de Refeições
            </h1>
            <p className="text-slate-400 text-xs font-medium mt-0.5">
              {monthName} {year} - Jantares
            </p>
          </div>
          <UtensilsCrossed size={22} className="text-orange-500" />
        </div>

        {/* Tabs */}
        <div className="flex gap-2 mt-4">
          <button
            onClick={() => setActiveTab("plan")}
            className={`flex-1 py-2.5 rounded-xl text-sm font-semibold transition-all ${
              activeTab === "plan"
                ? "bg-orange-500 text-white shadow-sm"
                : "bg-slate-100 text-slate-500 hover:bg-slate-200"
            }`}
          >
            <CalendarDays size={14} className="inline mr-1.5 -mt-0.5" />
            Plano ({mealPlanConfig.mealPlan.length})
          </button>
          <button
            onClick={() => setActiveTab("shopping")}
            className={`flex-1 py-2.5 rounded-xl text-sm font-semibold transition-all ${
              activeTab === "shopping"
                ? "bg-orange-500 text-white shadow-sm"
                : "bg-slate-100 text-slate-500 hover:bg-slate-200"
            }`}
          >
            <ShoppingCart size={14} className="inline mr-1.5 -mt-0.5" />
            Compras ({mealPlanConfig.shoppingList.length})
          </button>
        </div>
      </div>

      <div className="max-w-lg mx-auto px-4 py-5">
        {activeTab === "plan" ? (
          <MealPlanView
            hasFoods={hasFoods}
            hasMealPlan={hasMealPlan}
            generating={generating}
            mealPlan={mealPlanConfig.mealPlan}
            expandedDay={expandedDay}
            validFoodsCount={validFoods.length}
            dependentes={settings.personalInfo.dependentes}
            onToggleDay={(day) => setExpandedDay(expandedDay === day ? null : day)}
            onGenerate={handleGenerate}
            onAddToShoppingList={handleAddToShoppingList}
            onAddAllToShoppingList={handleAddAllToShoppingList}
            onClearMealPlan={clearMealPlan}
          />
        ) : (
          <ShoppingListView
            shoppingList={mealPlanConfig.shoppingList}
            onToggleItem={toggleShoppingItem}
            onRemoveItem={removeShoppingItem}
            onClearList={clearShoppingList}
          />
        )}

        <div className="h-4" />
      </div>
    </div>
  );
}

function MealPlanView({
  hasFoods,
  hasMealPlan,
  generating,
  mealPlan,
  expandedDay,
  validFoodsCount,
  dependentes,
  onToggleDay,
  onGenerate,
  onAddToShoppingList,
  onAddAllToShoppingList,
  onClearMealPlan,
}: {
  hasFoods: boolean;
  hasMealPlan: boolean;
  generating: boolean;
  mealPlan: MealPlanDay[];
  expandedDay: number | null;
  validFoodsCount: number;
  dependentes: number;
  onToggleDay: (day: number) => void;
  onGenerate: () => void;
  onAddToShoppingList: (meal: MealPlanDay) => void;
  onAddAllToShoppingList: () => void;
  onClearMealPlan: () => void;
}) {
  if (!hasFoods) {
    return (
      <div className="bg-amber-50 rounded-2xl px-5 py-8 text-center border border-amber-100">
        <AlertCircle size={40} className="text-amber-300 mx-auto mb-3" />
        <p className="text-slate-700 text-sm font-semibold mb-2">
          Sem alimentos configurados
        </p>
        <p className="text-slate-500 text-xs leading-relaxed mb-4">
          Antes de gerar o plano de refeições, configure os alimentos disponíveis nas Definições (secção "Alimentos Disponíveis").
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Info card */}
      <div className="bg-orange-50 rounded-2xl px-5 py-4 border border-orange-100">
        <div className="flex items-start gap-3">
          <Sparkles size={18} className="text-orange-500 mt-0.5 shrink-0" />
          <div>
            <p className="text-slate-700 text-sm font-semibold">Gerador de Refeições</p>
            <p className="text-slate-500 text-xs leading-relaxed mt-1">
              {validFoodsCount} alimento(s) disponíveis
              {dependentes > 0 && ` · ${dependentes} dependente(s)`}
            </p>
          </div>
        </div>
      </div>

      {/* Generate button */}
      <button
        onClick={onGenerate}
        disabled={generating}
        className={`w-full py-4 rounded-2xl text-sm font-bold transition-all shadow-sm flex items-center justify-center gap-2 ${
          generating
            ? "bg-slate-200 text-slate-400 cursor-wait"
            : "bg-gradient-to-r from-orange-500 to-amber-500 text-white hover:from-orange-600 hover:to-amber-600 active:scale-[0.98]"
        }`}
      >
        {generating ? (
          <>
            <div className="w-4 h-4 border-2 border-slate-300 border-t-slate-500 rounded-full animate-spin" />
            A gerar refeições...
          </>
        ) : (
          <>
            <Sparkles size={16} />
            {hasMealPlan ? "Regenerar Refeições" : "Gerar Refeições do Mês"}
          </>
        )}
      </button>

      {/* Meal plan list */}
      {hasMealPlan && (
        <>
          <div className="flex items-center justify-between">
            <h3 className="text-xs font-semibold text-slate-400 tracking-wide uppercase">
              Jantares do Mês
            </h3>
            <div className="flex gap-2">
              <button
                onClick={onAddAllToShoppingList}
                className="text-xs font-semibold text-orange-500 hover:text-orange-600 flex items-center gap-1 transition-colors"
              >
                <ShoppingCart size={12} />
                Adicionar tudo
              </button>
              <span className="text-slate-200">|</span>
              <button
                onClick={onClearMealPlan}
                className="text-xs font-semibold text-slate-400 hover:text-red-500 transition-colors"
              >
                Limpar
              </button>
            </div>
          </div>

          <div className="space-y-2">
            {mealPlan.map((meal) => (
              <div key={meal.day} className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
                <button
                  onClick={() => onToggleDay(meal.day)}
                  className="w-full px-4 py-3.5 flex items-center gap-3 hover:bg-slate-50 transition-colors"
                >
                  <div className="w-9 h-9 rounded-xl bg-orange-50 text-orange-500 flex items-center justify-center text-sm font-bold shrink-0">
                    {meal.day}
                  </div>
                  <div className="flex-1 text-left min-w-0">
                    <p className="text-sm font-semibold text-slate-700 truncate">{meal.name}</p>
                    <p className="text-xs text-slate-400 truncate">{meal.description}</p>
                  </div>
                  <div className="p-1 rounded-lg text-slate-300">
                    {expandedDay === meal.day ? (
                      <ChevronUp size={14} strokeWidth={2.5} />
                    ) : (
                      <ChevronDown size={14} strokeWidth={2.5} />
                    )}
                  </div>
                </button>

                {expandedDay === meal.day && (
                  <div className="px-4 pb-4 pt-0 border-t border-slate-50 animate-slide-down">
                    <div className="mt-3 space-y-2">
                      <p className="text-xs font-semibold text-slate-400 tracking-wide uppercase">
                        Ingredientes
                      </p>
                      {meal.ingredients.map((ing, i) => (
                        <div key={i} className="flex items-center justify-between py-1.5">
                          <span className="text-sm text-slate-600">{ing.foodName}</span>
                          <span className="text-xs font-medium text-slate-400">
                            {ing.unit === "q.b." ? "q.b." : `${ing.quantity}${ing.unit}`}
                          </span>
                        </div>
                      ))}
                    </div>
                    <button
                      onClick={() => onAddToShoppingList(meal)}
                      className="mt-3 w-full py-2.5 rounded-xl border-2 border-dashed border-orange-200 text-orange-500 text-xs font-semibold flex items-center justify-center gap-1.5 hover:bg-orange-50 hover:border-orange-300 transition-all"
                    >
                      <Plus size={14} />
                      Adicionar à lista de compras
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
}

function ShoppingListView({
  shoppingList,
  onToggleItem,
  onRemoveItem,
  onClearList,
}: {
  shoppingList: ShoppingListItem[];
  onToggleItem: (id: string) => void;
  onRemoveItem: (id: string) => void;
  onClearList: () => void;
}) {
  const checkedCount = shoppingList.filter((i) => i.checked).length;

  if (shoppingList.length === 0) {
    return (
      <div className="bg-slate-100 rounded-2xl px-5 py-8 text-center">
        <ShoppingCart size={40} className="text-slate-300 mx-auto mb-3" />
        <p className="text-slate-500 text-sm font-medium">
          A lista de compras está vazia
        </p>
        <p className="text-slate-400 text-xs mt-1">
          Gere um plano de refeições e adicione ingredientes
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Summary */}
      <div className="bg-white rounded-2xl px-5 py-4 border border-slate-100 shadow-sm">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm font-semibold text-slate-700">
              {shoppingList.length} produto(s)
            </p>
            <p className="text-xs text-slate-400 mt-0.5">
              {checkedCount} comprado(s) · {shoppingList.length - checkedCount} por comprar
            </p>
          </div>
          <button
            onClick={onClearList}
            className="text-xs font-semibold text-slate-400 hover:text-red-500 px-3 py-1.5 rounded-lg hover:bg-red-50 transition-all"
          >
            Limpar tudo
          </button>
        </div>
        {shoppingList.length > 0 && (
          <div className="mt-3 bg-slate-100 rounded-full h-2 overflow-hidden">
            <div
              className="bg-emerald-400 h-full rounded-full transition-all duration-300"
              style={{ width: `${(checkedCount / shoppingList.length) * 100}%` }}
            />
          </div>
        )}
      </div>

      {/* Items */}
      <div className="space-y-2">
        {shoppingList
          .sort((a, b) => (a.checked === b.checked ? 0 : a.checked ? 1 : -1))
          .map((item) => (
            <div
              key={item.id}
              className={`bg-white rounded-xl px-4 py-3 border border-slate-100 shadow-sm flex items-center gap-3 transition-all ${
                item.checked ? "opacity-50" : ""
              }`}
            >
              <button
                onClick={() => onToggleItem(item.id)}
                className={`w-6 h-6 rounded-lg border-2 flex items-center justify-center shrink-0 transition-all ${
                  item.checked
                    ? "bg-emerald-500 border-emerald-500 text-white"
                    : "border-slate-200 hover:border-emerald-300"
                }`}
              >
                {item.checked && <Check size={14} strokeWidth={3} />}
              </button>
              <div className="flex-1 min-w-0">
                <p className={`text-sm font-medium ${item.checked ? "line-through text-slate-400" : "text-slate-700"}`}>
                  {item.name}
                </p>
              </div>
              <span className="text-xs font-semibold text-slate-400 shrink-0">
                {item.unit === "q.b." ? "q.b." : `${item.quantity}${item.unit}`}
              </span>
              <button
                onClick={() => onRemoveItem(item.id)}
                className="p-1.5 text-slate-300 hover:text-red-500 hover:bg-red-50 rounded-lg transition-all shrink-0"
              >
                <Trash2 size={14} />
              </button>
            </div>
          ))}
      </div>
    </div>
  );
}
