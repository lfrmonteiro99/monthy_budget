import { useState } from "react";
import {
  ArrowLeft,
  Check,
  ShoppingCart,
  ChevronDown,
  ChevronUp,
} from "lucide-react";
import type { ShoppingListItem, IngredientCategory } from "../types/mealPlanner";
import { INGREDIENT_CATEGORY_LABELS } from "../types/mealPlanner";
import { formatCurrency } from "../utils/calculations";

interface ShoppingListProps {
  items: ShoppingListItem[];
  onToggleItem: (ingredientId: string) => void;
  onBack: () => void;
  totalEstimatedCost: number;
}

const CATEGORY_COLORS: Record<IngredientCategory, string> = {
  proteina: "bg-red-100 text-red-600",
  legumes: "bg-green-100 text-green-600",
  fruta: "bg-orange-100 text-orange-600",
  laticinios: "bg-blue-100 text-blue-600",
  cereais_massas: "bg-amber-100 text-amber-600",
  conservas: "bg-slate-100 text-slate-600",
  temperos: "bg-purple-100 text-purple-600",
  gorduras: "bg-yellow-100 text-yellow-600",
  outros: "bg-gray-100 text-gray-600",
};

function formatQuantity(qty: number, unit: string): string {
  if (unit === "kg" && qty < 1) return `${Math.round(qty * 1000)}g`;
  if (unit === "L" && qty < 1) return `${Math.round(qty * 1000)}ml`;
  if (unit === "un" || unit === "dz") return `${Math.round(qty)} ${unit}`;
  return `${qty.toFixed(qty % 1 === 0 ? 0 : 1)}${unit}`;
}

export default function ShoppingList({
  items,
  onToggleItem,
  onBack,
  totalEstimatedCost,
}: ShoppingListProps) {
  const [expandedCategory, setExpandedCategory] = useState<IngredientCategory | null>(null);

  // Group items by category
  const grouped = items.reduce(
    (acc, item) => {
      if (!acc[item.category]) acc[item.category] = [];
      acc[item.category].push(item);
      return acc;
    },
    {} as Record<IngredientCategory, ShoppingListItem[]>,
  );

  const checkedCount = items.filter((i) => i.checked).length;
  const totalCount = items.length;
  const remainingCost = items
    .filter((i) => !i.checked)
    .reduce((s, i) => s + i.estimatedCost, 0);

  return (
    <div className="min-h-screen bg-slate-50 animate-fade-in">
      {/* Header */}
      <div className="bg-white border-b border-slate-100 px-4 py-4 flex items-center gap-3 sticky top-0 z-10">
        <button
          onClick={onBack}
          className="p-2 hover:bg-slate-100 rounded-xl transition-colors"
        >
          <ArrowLeft size={22} className="text-slate-600" />
        </button>
        <div className="flex-1">
          <h1 className="text-lg font-bold text-slate-800 tracking-tight">
            Lista de Compras
          </h1>
          <p className="text-xs text-slate-400">
            {checkedCount}/{totalCount} comprados
          </p>
        </div>
        <div className="text-right">
          <p className="text-xs text-slate-400">Custo estimado</p>
          <p className="text-sm font-bold text-emerald-500">
            {formatCurrency(totalEstimatedCost)}
          </p>
        </div>
      </div>

      <div className="max-w-lg mx-auto px-4 py-5 space-y-3">
        {/* Progress bar */}
        <div className="bg-white rounded-2xl p-4 shadow-sm border border-slate-100">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-semibold text-slate-400 uppercase tracking-wide">
              Progresso
            </span>
            <span className="text-xs font-bold text-slate-600">
              {checkedCount} de {totalCount}
            </span>
          </div>
          <div className="w-full bg-slate-200 rounded-full h-2">
            <div
              className="h-2 rounded-full bg-emerald-500 transition-all"
              style={{
                width: `${totalCount > 0 ? (checkedCount / totalCount) * 100 : 0}%`,
              }}
            />
          </div>
          <div className="flex justify-between mt-2 text-xs text-slate-400">
            <span>Falta: {formatCurrency(remainingCost)}</span>
            <span>Comprado: {formatCurrency(totalEstimatedCost - remainingCost)}</span>
          </div>
        </div>

        {/* Items grouped by category */}
        {(Object.entries(grouped) as [IngredientCategory, ShoppingListItem[]][]).map(
          ([category, categoryItems]) => {
            const categoryTotal = categoryItems.reduce((s, i) => s + i.estimatedCost, 0);
            const allChecked = categoryItems.every((i) => i.checked);
            const isExpanded = expandedCategory === category;

            return (
              <div
                key={category}
                className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden"
              >
                <button
                  onClick={() =>
                    setExpandedCategory(isExpanded ? null : category)
                  }
                  className="w-full flex items-center gap-3 px-4 py-3 hover:bg-slate-50 transition-colors"
                >
                  <span
                    className={`px-2.5 py-1 rounded-lg text-[10px] font-bold ${CATEGORY_COLORS[category]}`}
                  >
                    {categoryItems.length}
                  </span>
                  <span
                    className={`flex-1 text-left text-sm font-semibold ${
                      allChecked ? "text-slate-300 line-through" : "text-slate-700"
                    }`}
                  >
                    {INGREDIENT_CATEGORY_LABELS[category]}
                  </span>
                  <span className="text-xs font-medium text-slate-400 mr-2">
                    {formatCurrency(categoryTotal)}
                  </span>
                  {isExpanded ? (
                    <ChevronUp size={16} className="text-slate-400" />
                  ) : (
                    <ChevronDown size={16} className="text-slate-400" />
                  )}
                </button>

                {isExpanded && (
                  <div className="border-t border-slate-50 animate-slide-down">
                    {categoryItems.map((item) => (
                      <ShoppingItem
                        key={item.ingredientId}
                        item={item}
                        onToggle={() => onToggleItem(item.ingredientId)}
                      />
                    ))}
                  </div>
                )}
              </div>
            );
          },
        )}

        {items.length === 0 && (
          <div className="bg-white rounded-2xl p-8 shadow-sm border border-slate-100 text-center">
            <ShoppingCart size={48} className="text-slate-200 mx-auto mb-4" />
            <p className="text-slate-500 text-sm font-medium">
              Lista de compras vazia
            </p>
            <p className="text-slate-400 text-xs mt-1">
              Gere um plano de refeicoes para preencher a lista.
            </p>
          </div>
        )}

        <div className="h-4" />
      </div>
    </div>
  );
}

function ShoppingItem({
  item,
  onToggle,
}: {
  item: ShoppingListItem;
  onToggle: () => void;
}) {
  const [showRecipes, setShowRecipes] = useState(false);

  return (
    <div
      className={`px-4 py-3 border-b border-slate-50 last:border-0 transition-colors ${
        item.checked ? "bg-slate-50" : ""
      }`}
    >
      <div className="flex items-center gap-3">
        <button
          onClick={onToggle}
          className={`w-6 h-6 rounded-lg border-2 flex items-center justify-center transition-all flex-shrink-0 ${
            item.checked
              ? "bg-emerald-500 border-emerald-500"
              : "border-slate-200 hover:border-emerald-300"
          }`}
        >
          {item.checked && <Check size={14} className="text-white" strokeWidth={3} />}
        </button>

        <button
          onClick={() => setShowRecipes(!showRecipes)}
          className="flex-1 text-left min-w-0"
        >
          <p
            className={`text-sm font-medium truncate ${
              item.checked ? "text-slate-300 line-through" : "text-slate-700"
            }`}
          >
            {item.name}
          </p>
          <p className="text-xs text-slate-400 mt-0.5">
            {formatQuantity(item.purchaseQuantity, item.unit)}
            {item.purchaseQuantity !== item.totalQuantity && (
              <span className="text-slate-300">
                {" "}(precisa {formatQuantity(item.totalQuantity, item.unit)})
              </span>
            )}
          </p>
        </button>

        <span
          className={`text-sm font-semibold flex-shrink-0 ${
            item.checked ? "text-slate-300" : "text-slate-700"
          }`}
        >
          {formatCurrency(item.estimatedCost)}
        </span>
      </div>

      {showRecipes && item.fromRecipes.length > 0 && (
        <div className="mt-2 ml-9 animate-slide-down">
          <p className="text-[10px] text-slate-400 font-medium uppercase tracking-wide mb-1">
            Usado em:
          </p>
          <div className="flex flex-wrap gap-1">
            {item.fromRecipes.map((recipe) => (
              <span
                key={recipe}
                className="px-2 py-0.5 bg-blue-50 rounded-full text-[10px] text-blue-500 font-medium"
              >
                {recipe}
              </span>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
