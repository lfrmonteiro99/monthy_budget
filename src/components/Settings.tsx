import { useState } from "react";
import {
  ArrowLeft,
  Plus,
  Trash2,
  UserRound,
  Wallet,
  Receipt,
  LayoutDashboard,
  ChevronDown,
  ChevronUp,
  Check,
} from "lucide-react";
import type {
  AppSettings,
  ExpenseItem,
  ExpenseCategory,
  ChartType,
  MaritalStatus,
  TitularCount,
  MealAllowanceType,
} from "../types";
import { EXPENSE_CATEGORY_LABELS, CHART_LABELS } from "../types";
import { getApplicableTable } from "../data/irsTables";
import { SOCIAL_SECURITY_RATE } from "../data/irsTables";
import { formatPercentage } from "../utils/calculations";

interface SettingsProps {
  settings: AppSettings;
  onSave: (settings: AppSettings) => void;
  onBack: () => void;
}

const MARITAL_STATUS_OPTIONS: { value: MaritalStatus; label: string }[] = [
  { value: "solteiro", label: "Solteiro(a)" },
  { value: "casado", label: "Casado(a)" },
  { value: "uniao_facto", label: "Uniao de Facto" },
  { value: "divorciado", label: "Divorciado(a)" },
  { value: "viuvo", label: "Viuvo(a)" },
];

const CATEGORY_OPTIONS: { value: ExpenseCategory; label: string }[] = Object.entries(
  EXPENSE_CATEGORY_LABELS,
).map(([value, label]) => ({ value: value as ExpenseCategory, label }));

type SettingsSection = "personal" | "salaries" | "expenses" | "dashboard";

export default function Settings({ settings, onSave, onBack }: SettingsProps) {
  const [draft, setDraft] = useState<AppSettings>(structuredClone(settings));
  const [openSection, setOpenSection] = useState<SettingsSection | null>("personal");

  const toggleSection = (section: SettingsSection) => {
    setOpenSection(openSection === section ? null : section);
  };

  const isCasado =
    draft.personalInfo.maritalStatus === "casado" ||
    draft.personalInfo.maritalStatus === "uniao_facto";

  const handleSave = () => {
    onSave(draft);
    onBack();
  };

  const addExpense = () => {
    const id = `expense_${Date.now()}`;
    const newExpense: ExpenseItem = {
      id,
      label: "",
      amount: 0,
      category: "outros",
      enabled: true,
    };
    setDraft({
      ...draft,
      expenses: [...draft.expenses, newExpense],
    });
  };

  const removeExpense = (id: string) => {
    setDraft({
      ...draft,
      expenses: draft.expenses.filter((e) => e.id !== id),
    });
  };

  const updateExpense = (id: string, updates: Partial<ExpenseItem>) => {
    setDraft({
      ...draft,
      expenses: draft.expenses.map((e) => (e.id === id ? { ...e, ...updates } : e)),
    });
  };

  const toggleChart = (chart: ChartType) => {
    const enabled = draft.dashboardConfig.enabledCharts;
    const newEnabled = enabled.includes(chart)
      ? enabled.filter((c) => c !== chart)
      : [...enabled, chart];
    setDraft({
      ...draft,
      dashboardConfig: { ...draft.dashboardConfig, enabledCharts: newEnabled },
    });
  };

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
        <h1 className="text-lg font-bold text-slate-800 flex-1 tracking-tight">
          Definicoes
        </h1>
        <button
          onClick={handleSave}
          className="bg-blue-500 hover:bg-blue-600 text-white pl-3 pr-4 py-2 rounded-xl font-semibold text-sm transition-colors shadow-sm flex items-center gap-1.5"
        >
          <Check size={16} strokeWidth={2.5} />
          Guardar
        </button>
      </div>

      <div className="max-w-lg mx-auto pb-8">
        {/* Dados Pessoais */}
        <SectionHeader
          icon={<UserRound size={20} />}
          title="Dados Pessoais"
          open={openSection === "personal"}
          onClick={() => toggleSection("personal")}
        />
        {openSection === "personal" && (
          <div className="bg-white px-5 py-5 space-y-5 animate-slide-down border-b border-slate-100">
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-2 tracking-wide uppercase">
                Estado Civil
              </label>
              <select
                value={draft.personalInfo.maritalStatus}
                onChange={(e) =>
                  setDraft({
                    ...draft,
                    personalInfo: {
                      ...draft.personalInfo,
                      maritalStatus: e.target.value as MaritalStatus,
                    },
                  })
                }
                className="w-full border border-slate-200 rounded-xl px-4 py-3 text-sm bg-white text-slate-700 font-medium focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-shadow"
              >
                {MARITAL_STATUS_OPTIONS.map((opt) => (
                  <option key={opt.value} value={opt.value}>
                    {opt.label}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-2 tracking-wide uppercase">
                Numero de Dependentes
              </label>
              <div className="flex items-center gap-4">
                <button
                  onClick={() =>
                    setDraft({
                      ...draft,
                      personalInfo: {
                        ...draft.personalInfo,
                        dependentes: Math.max(0, draft.personalInfo.dependentes - 1),
                      },
                    })
                  }
                  className="w-11 h-11 rounded-xl border-2 border-slate-200 flex items-center justify-center text-lg font-bold text-slate-500 hover:bg-slate-50 hover:border-slate-300 transition-all active:scale-95"
                >
                  -
                </button>
                <span className="text-2xl font-bold text-slate-800 w-8 text-center tabular-nums">
                  {draft.personalInfo.dependentes}
                </span>
                <button
                  onClick={() =>
                    setDraft({
                      ...draft,
                      personalInfo: {
                        ...draft.personalInfo,
                        dependentes: draft.personalInfo.dependentes + 1,
                      },
                    })
                  }
                  className="w-11 h-11 rounded-xl border-2 border-slate-200 flex items-center justify-center text-lg font-bold text-slate-500 hover:bg-slate-50 hover:border-slate-300 transition-all active:scale-95"
                >
                  +
                </button>
              </div>
            </div>

            <div className="bg-blue-50 rounded-xl p-4 text-sm border border-blue-100">
              <p className="text-blue-600 text-xs leading-relaxed">
                Seguranca Social: {formatPercentage(SOCIAL_SECURITY_RATE)}
              </p>
            </div>
          </div>
        )}

        {/* Vencimentos */}
        <SectionHeader
          icon={<Wallet size={20} />}
          title="Vencimentos"
          open={openSection === "salaries"}
          onClick={() => toggleSection("salaries")}
        />
        {openSection === "salaries" && (
          <div className="bg-white px-5 py-5 space-y-4 animate-slide-down border-b border-slate-100">
            {draft.salaries.map((salary, idx) => (
              <div
                key={idx}
                className={`border-2 rounded-2xl p-4 space-y-3 transition-all ${
                  salary.enabled
                    ? "border-slate-200 bg-white"
                    : "border-slate-100 bg-slate-50 opacity-50"
                }`}
              >
                <div className="flex items-center justify-between">
                  <input
                    type="text"
                    value={salary.label}
                    onChange={(e) => {
                      const newSalaries = [...draft.salaries] as [typeof salary, typeof salary];
                      newSalaries[idx] = { ...salary, label: e.target.value };
                      setDraft({ ...draft, salaries: newSalaries });
                    }}
                    className="text-sm font-semibold text-slate-700 border-none p-0 focus:ring-0 bg-transparent placeholder-slate-300"
                    placeholder={`Vencimento ${idx + 1}`}
                  />
                  <label className="flex items-center gap-2 text-xs font-medium text-slate-400 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={salary.enabled}
                      onChange={(e) => {
                        const newSalaries = [...draft.salaries] as [typeof salary, typeof salary];
                        newSalaries[idx] = { ...salary, enabled: e.target.checked };
                        setDraft({ ...draft, salaries: newSalaries });
                      }}
                    />
                    Ativo
                  </label>
                </div>
                <div>
                  <label className="block text-xs font-medium text-slate-400 mb-1.5">
                    Salario Bruto Mensal
                  </label>
                  <div className="relative">
                    <input
                      type="number"
                      value={salary.grossAmount || ""}
                      onChange={(e) => {
                        const newSalaries = [...draft.salaries] as [typeof salary, typeof salary];
                        newSalaries[idx] = {
                          ...salary,
                          grossAmount: parseFloat(e.target.value) || 0,
                        };
                        setDraft({ ...draft, salaries: newSalaries });
                      }}
                      placeholder="0.00"
                      className="w-full border border-slate-200 rounded-xl px-4 py-3 pr-10 text-sm font-medium text-slate-700 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-shadow placeholder-slate-300"
                      min="0"
                      step="50"
                    />
                    <span className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 text-sm font-semibold">
                      EUR
                    </span>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-medium text-slate-400 mb-1.5">
                    Subsidio de Alimentacao
                  </label>
                  <div className="flex gap-1.5">
                    {([
                      { value: "none", label: "Sem" },
                      { value: "card", label: "Cartao" },
                      { value: "cash", label: "Com base" },
                    ] as { value: MealAllowanceType; label: string }[]).map((opt) => (
                      <button
                        key={opt.value}
                        onClick={() => {
                          const newSalaries = [...draft.salaries] as [typeof salary, typeof salary];
                          newSalaries[idx] = { ...salary, mealAllowanceType: opt.value };
                          setDraft({ ...draft, salaries: newSalaries });
                        }}
                        className={`flex-1 py-2 rounded-lg text-xs font-semibold border-2 transition-all ${
                          salary.mealAllowanceType === opt.value
                            ? "bg-blue-500 text-white border-blue-500"
                            : "bg-white text-slate-500 border-slate-200 hover:border-slate-300"
                        }`}
                      >
                        {opt.label}
                      </button>
                    ))}
                  </div>
                </div>

                {salary.mealAllowanceType !== "none" && (
                  <div className="flex gap-3">
                    <div className="flex-1">
                      <label className="block text-xs font-medium text-slate-400 mb-1.5">
                        Valor/dia
                      </label>
                      <div className="relative">
                        <input
                          type="number"
                          value={salary.mealAllowancePerDay || ""}
                          onChange={(e) => {
                            const newSalaries = [...draft.salaries] as [typeof salary, typeof salary];
                            newSalaries[idx] = {
                              ...salary,
                              mealAllowancePerDay: parseFloat(e.target.value) || 0,
                            };
                            setDraft({ ...draft, salaries: newSalaries });
                          }}
                          placeholder="0.00"
                          className="w-full border border-slate-200 rounded-xl px-3 py-2.5 pr-8 text-sm font-medium text-slate-700 focus:ring-2 focus:ring-blue-500 transition-shadow placeholder-slate-300"
                          min="0"
                          step="0.10"
                        />
                        <span className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs font-semibold">
                          EUR
                        </span>
                      </div>
                    </div>
                    <div className="w-24">
                      <label className="block text-xs font-medium text-slate-400 mb-1.5">
                        Dias/mes
                      </label>
                      <input
                        type="number"
                        value={salary.workingDaysPerMonth || ""}
                        onChange={(e) => {
                          const newSalaries = [...draft.salaries] as [typeof salary, typeof salary];
                          newSalaries[idx] = {
                            ...salary,
                            workingDaysPerMonth: parseInt(e.target.value) || 0,
                          };
                          setDraft({ ...draft, salaries: newSalaries });
                        }}
                        placeholder="22"
                        className="w-full border border-slate-200 rounded-xl px-3 py-2.5 text-sm font-medium text-slate-700 focus:ring-2 focus:ring-blue-500 transition-shadow placeholder-slate-300"
                        min="0"
                        max="31"
                        step="1"
                      />
                    </div>
                  </div>
                )}

                {isCasado && (
                  <div>
                    <label className="block text-xs font-medium text-slate-400 mb-1.5">
                      N. Titulares
                    </label>
                    <div className="flex gap-2">
                      {([1, 2] as TitularCount[]).map((n) => (
                        <button
                          key={n}
                          onClick={() => {
                            const newSalaries = [...draft.salaries] as [typeof salary, typeof salary];
                            newSalaries[idx] = { ...salary, titulares: n };
                            setDraft({ ...draft, salaries: newSalaries });
                          }}
                          className={`flex-1 py-2 rounded-lg text-xs font-semibold border-2 transition-all ${
                            salary.titulares === n
                              ? "bg-blue-500 text-white border-blue-500"
                              : "bg-white text-slate-500 border-slate-200 hover:border-slate-300"
                          }`}
                        >
                          {n} Titular{n > 1 ? "es" : ""}
                        </button>
                      ))}
                    </div>
                  </div>
                )}

                {(() => {
                  const table = getApplicableTable(
                    draft.personalInfo.maritalStatus,
                    salary.titulares,
                    draft.personalInfo.dependentes,
                  );
                  return (
                    <div className="bg-slate-50 rounded-lg px-3 py-2 text-xs text-slate-500">
                      {table.label} — {table.description}
                    </div>
                  );
                })()}
              </div>
            ))}
          </div>
        )}

        {/* Despesas Mensais */}
        <SectionHeader
          icon={<Receipt size={20} />}
          title="Despesas Mensais"
          open={openSection === "expenses"}
          onClick={() => toggleSection("expenses")}
        />
        {openSection === "expenses" && (
          <div className="bg-white px-5 py-5 space-y-3 animate-slide-down border-b border-slate-100">
            {draft.expenses.map((expense) => (
              <div
                key={expense.id}
                className={`border-2 rounded-2xl p-4 space-y-3 transition-all ${
                  expense.enabled
                    ? "border-slate-200 bg-white"
                    : "border-slate-100 bg-slate-50 opacity-50"
                }`}
              >
                <div className="flex items-center gap-3">
                  <input
                    type="checkbox"
                    checked={expense.enabled}
                    onChange={(e) => updateExpense(expense.id, { enabled: e.target.checked })}
                  />
                  <input
                    type="text"
                    value={expense.label}
                    onChange={(e) => updateExpense(expense.id, { label: e.target.value })}
                    placeholder="Nome da despesa"
                    className="flex-1 text-sm font-semibold border-none p-0 focus:ring-0 bg-transparent placeholder-slate-300 text-slate-700"
                  />
                  <button
                    onClick={() => removeExpense(expense.id)}
                    className="p-2 text-slate-300 hover:text-red-500 hover:bg-red-50 rounded-lg transition-all"
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
                <div className="flex gap-3">
                  <div className="flex-1">
                    <select
                      value={expense.category}
                      onChange={(e) =>
                        updateExpense(expense.id, {
                          category: e.target.value as ExpenseCategory,
                        })
                      }
                      className="w-full border border-slate-200 rounded-xl px-3 py-2.5 text-xs bg-white text-slate-600 font-medium focus:ring-2 focus:ring-blue-500 transition-shadow"
                    >
                      {CATEGORY_OPTIONS.map((opt) => (
                        <option key={opt.value} value={opt.value}>
                          {opt.label}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="relative w-28">
                    <input
                      type="number"
                      value={expense.amount || ""}
                      onChange={(e) =>
                        updateExpense(expense.id, {
                          amount: parseFloat(e.target.value) || 0,
                        })
                      }
                      placeholder="0.00"
                      className="w-full border border-slate-200 rounded-xl px-3 py-2.5 pr-7 text-sm font-medium text-slate-700 focus:ring-2 focus:ring-blue-500 transition-shadow placeholder-slate-300"
                      min="0"
                      step="5"
                    />
                    <span className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs font-semibold">
                      EUR
                    </span>
                  </div>
                </div>
              </div>
            ))}
            <button
              onClick={addExpense}
              className="w-full border-2 border-dashed border-slate-200 rounded-2xl py-4 flex items-center justify-center gap-2 text-sm font-semibold text-slate-400 hover:border-blue-400 hover:text-blue-500 hover:bg-blue-50 transition-all"
            >
              <Plus size={18} />
              Adicionar Despesa
            </button>
          </div>
        )}

        {/* Dashboard Config */}
        <SectionHeader
          icon={<LayoutDashboard size={20} />}
          title="Dashboard"
          open={openSection === "dashboard"}
          onClick={() => toggleSection("dashboard")}
        />
        {openSection === "dashboard" && (
          <div className="bg-white px-5 py-5 space-y-5 animate-slide-down border-b border-slate-100">
            <label className="flex items-center gap-3 text-sm font-medium text-slate-700 cursor-pointer">
              <input
                type="checkbox"
                checked={draft.dashboardConfig.showSummaryCards}
                onChange={(e) =>
                  setDraft({
                    ...draft,
                    dashboardConfig: {
                      ...draft.dashboardConfig,
                      showSummaryCards: e.target.checked,
                    },
                  })
                }
              />
              Mostrar cartoes de resumo
            </label>
            <div>
              <p className="text-xs font-semibold text-slate-500 mb-3 tracking-wide uppercase">
                Graficos visiveis
              </p>
              <div className="space-y-2.5">
                {(Object.entries(CHART_LABELS) as [ChartType, string][]).map(([key, label]) => (
                  <label
                    key={key}
                    className="flex items-center gap-3 text-sm font-medium text-slate-600 cursor-pointer hover:text-slate-800 transition-colors"
                  >
                    <input
                      type="checkbox"
                      checked={draft.dashboardConfig.enabledCharts.includes(key)}
                      onChange={() => toggleChart(key)}
                    />
                    {label}
                  </label>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function SectionHeader({
  icon,
  title,
  open,
  onClick,
}: {
  icon: React.ReactNode;
  title: string;
  open: boolean;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className={`w-full flex items-center gap-3 px-5 py-4 bg-white border-b border-slate-100 mt-2 hover:bg-slate-50 transition-colors ${
        open ? "bg-slate-50" : ""
      }`}
    >
      <span className="text-blue-500">{icon}</span>
      <span className="flex-1 text-left font-semibold text-slate-700 text-sm">{title}</span>
      <div
        className={`p-1 rounded-lg transition-all ${
          open ? "bg-blue-50 text-blue-500 rotate-0" : "text-slate-300"
        }`}
      >
        {open ? (
          <ChevronUp size={16} strokeWidth={2.5} />
        ) : (
          <ChevronDown size={16} strokeWidth={2.5} />
        )}
      </div>
    </button>
  );
}
