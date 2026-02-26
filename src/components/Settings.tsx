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
  Moon,
  Sun,
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
  dark: boolean;
  onToggleDark: () => void;
}

const MARITAL_STATUS_OPTIONS: { value: MaritalStatus; label: string }[] = [
  { value: "solteiro", label: "Solteiro(a)" },
  { value: "casado", label: "Casado(a)" },
  { value: "uniao_facto", label: "União de Facto" },
  { value: "divorciado", label: "Divorciado(a)" },
  { value: "viuvo", label: "Viúvo(a)" },
];

const CATEGORY_OPTIONS: { value: ExpenseCategory; label: string }[] = Object.entries(
  EXPENSE_CATEGORY_LABELS,
).map(([value, label]) => ({ value: value as ExpenseCategory, label }));

type SettingsSection = "personal" | "salaries" | "expenses" | "dashboard";

export default function Settings({ settings, onSave, onBack, dark, onToggleDark }: SettingsProps) {
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

  const moveExpense = (index: number, direction: -1 | 1) => {
    const newIndex = index + direction;
    if (newIndex < 0 || newIndex >= draft.expenses.length) return;
    const newExpenses = [...draft.expenses];
    [newExpenses[index], newExpenses[newIndex]] = [newExpenses[newIndex], newExpenses[index]];
    setDraft({ ...draft, expenses: newExpenses });
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
    <div className="min-h-screen bg-slate-50 dark:bg-slate-900 animate-fade-in transition-colors duration-300">
      {/* Header */}
      <div className="bg-white/95 dark:bg-slate-800/95 backdrop-blur-sm border-b border-slate-100 dark:border-slate-700 px-4 py-4 flex items-center gap-3 sticky top-0 z-10 shadow-sm transition-colors duration-300">
        <button
          onClick={onBack}
          aria-label="Voltar ao dashboard"
          className="p-2 hover:bg-slate-100 dark:hover:bg-slate-700 rounded-xl transition-all active:scale-95"
        >
          <ArrowLeft size={22} className="text-slate-600 dark:text-slate-300" />
        </button>
        <h1 className="text-lg font-bold text-slate-800 dark:text-slate-100 flex-1 tracking-tight">
          Definições
        </h1>
        <button
          onClick={onToggleDark}
          aria-label={dark ? "Ativar modo claro" : "Ativar modo escuro"}
          className="p-2 hover:bg-slate-100 dark:hover:bg-slate-700 rounded-xl transition-all active:scale-95"
        >
          {dark ? <Sun size={18} className="text-amber-400" /> : <Moon size={18} className="text-slate-400" />}
        </button>
        <button
          onClick={handleSave}
          className="bg-blue-500 hover:bg-blue-600 text-white pl-3 pr-4 py-2.5 rounded-xl font-semibold text-sm transition-all shadow-sm hover:shadow active:scale-[0.97] flex items-center gap-1.5"
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
          <div className="bg-white dark:bg-slate-800 px-5 py-5 space-y-5 animate-slide-down border-b border-slate-100 dark:border-slate-700 transition-colors duration-300">
            <div>
              <label className="block text-xs font-semibold text-slate-500 dark:text-slate-400 mb-2 tracking-wide uppercase">
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
                className="w-full border border-slate-200 dark:border-slate-600 rounded-xl px-4 py-3 text-sm bg-white dark:bg-slate-700 text-slate-700 dark:text-slate-200 font-medium focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-shadow"
              >
                {MARITAL_STATUS_OPTIONS.map((opt) => (
                  <option key={opt.value} value={opt.value}>
                    {opt.label}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-500 dark:text-slate-400 mb-2 tracking-wide uppercase">
                Número de Dependentes
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
                  aria-label="Remover dependente"
                  className="w-11 h-11 rounded-xl border-2 border-slate-200 dark:border-slate-600 flex items-center justify-center text-lg font-bold text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-700 hover:border-slate-300 dark:hover:border-slate-500 transition-all active:scale-95"
                >
                  -
                </button>
                <span className="text-2xl font-bold text-slate-800 dark:text-slate-100 w-8 text-center tabular-nums">
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
                  aria-label="Adicionar dependente"
                  className="w-11 h-11 rounded-xl border-2 border-slate-200 dark:border-slate-600 flex items-center justify-center text-lg font-bold text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-700 hover:border-slate-300 dark:hover:border-slate-500 transition-all active:scale-95"
                >
                  +
                </button>
              </div>
            </div>

            <div className="bg-blue-50 dark:bg-blue-900/20 rounded-xl p-4 text-sm border border-blue-100 dark:border-blue-800/40">
              <p className="text-blue-600 dark:text-blue-400 text-xs leading-relaxed">
                Segurança Social: {formatPercentage(SOCIAL_SECURITY_RATE)}
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
          <div className="bg-white dark:bg-slate-800 px-5 py-5 space-y-4 animate-slide-down border-b border-slate-100 dark:border-slate-700 transition-colors duration-300">
            {draft.salaries.map((salary, idx) => (
              <div
                key={idx}
                className={`border-2 rounded-2xl p-4 space-y-3 transition-all ${
                  salary.enabled
                    ? "border-slate-200 dark:border-slate-600 bg-white dark:bg-slate-800"
                    : "border-slate-100 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/50 opacity-50"
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
                    className="text-sm font-semibold text-slate-700 dark:text-slate-200 border-b border-dashed border-transparent hover:border-slate-300 dark:hover:border-slate-500 focus:border-blue-400 px-0.5 py-0.5 focus:ring-0 bg-transparent placeholder-slate-300 dark:placeholder-slate-600 transition-colors"
                    placeholder={`Vencimento ${idx + 1}`}
                  />
                  <label className="flex items-center gap-2 text-xs font-medium text-slate-400 dark:text-slate-500 cursor-pointer">
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
                  <label className="block text-xs font-medium text-slate-400 dark:text-slate-500 mb-1.5">
                    Salário Bruto Mensal
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
                      className="w-full border border-slate-200 dark:border-slate-600 rounded-xl px-4 py-3 pr-10 text-sm font-medium text-slate-700 dark:text-slate-200 bg-white dark:bg-slate-700 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-shadow placeholder-slate-300 dark:placeholder-slate-500"
                      min="0"
                      step="50"
                    />
                    <span className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 dark:text-slate-500 text-sm font-semibold">
                      EUR
                    </span>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-medium text-slate-400 dark:text-slate-500 mb-1.5">
                    Subsídio de Alimentação
                  </label>
                  <div className="flex gap-1.5">
                    {([
                      { value: "none", label: "Sem" },
                      { value: "card", label: "Cartão" },
                      { value: "cash", label: "Dinheiro" },
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
                            : "bg-white dark:bg-slate-700 text-slate-500 dark:text-slate-400 border-slate-200 dark:border-slate-600 hover:border-slate-300 dark:hover:border-slate-500"
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
                      <label className="block text-xs font-medium text-slate-400 dark:text-slate-500 mb-1.5">
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
                          className="w-full border border-slate-200 dark:border-slate-600 rounded-xl px-3 py-2.5 pr-8 text-sm font-medium text-slate-700 dark:text-slate-200 bg-white dark:bg-slate-700 focus:ring-2 focus:ring-blue-500 transition-shadow placeholder-slate-300 dark:placeholder-slate-500"
                          min="0"
                          step="0.10"
                        />
                        <span className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 dark:text-slate-500 text-xs font-semibold">
                          EUR
                        </span>
                      </div>
                    </div>
                    <div className="w-24">
                      <label className="block text-xs font-medium text-slate-400 dark:text-slate-500 mb-1.5">
                        Dias/mês
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
                        className="w-full border border-slate-200 dark:border-slate-600 rounded-xl px-3 py-2.5 text-sm font-medium text-slate-700 dark:text-slate-200 bg-white dark:bg-slate-700 focus:ring-2 focus:ring-blue-500 transition-shadow placeholder-slate-300 dark:placeholder-slate-500"
                        min="0"
                        max="31"
                        step="1"
                      />
                    </div>
                  </div>
                )}

                {isCasado && (
                  <div>
                    <label className="block text-xs font-medium text-slate-400 dark:text-slate-500 mb-1.5">
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
                              : "bg-white dark:bg-slate-700 text-slate-500 dark:text-slate-400 border-slate-200 dark:border-slate-600 hover:border-slate-300 dark:hover:border-slate-500"
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
                    <div className="bg-slate-50 dark:bg-slate-700/50 rounded-xl px-3.5 py-2.5 text-xs text-slate-500 dark:text-slate-400 border border-slate-100 dark:border-slate-600">
                      <span className="font-medium">{table.label}</span> — {table.description}
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
          <div className="bg-white dark:bg-slate-800 px-5 py-5 space-y-3 animate-slide-down border-b border-slate-100 dark:border-slate-700 transition-colors duration-300">
            {draft.expenses.map((expense, idx) => (
              <div
                key={expense.id}
                className={`border-2 rounded-2xl p-4 space-y-3 transition-all ${
                  expense.enabled
                    ? "border-slate-200 dark:border-slate-600 bg-white dark:bg-slate-800"
                    : "border-slate-100 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/50 opacity-50"
                }`}
              >
                <div className="flex items-center gap-2">
                  {/* Reorder handle */}
                  <div className="flex flex-col -space-y-1">
                    <button
                      onClick={() => moveExpense(idx, -1)}
                      disabled={idx === 0}
                      aria-label="Mover despesa para cima"
                      className="p-0.5 text-slate-300 dark:text-slate-600 hover:text-slate-500 dark:hover:text-slate-400 disabled:opacity-30 disabled:cursor-default transition-colors"
                    >
                      <ChevronUp size={14} strokeWidth={2.5} />
                    </button>
                    <button
                      onClick={() => moveExpense(idx, 1)}
                      disabled={idx === draft.expenses.length - 1}
                      aria-label="Mover despesa para baixo"
                      className="p-0.5 text-slate-300 dark:text-slate-600 hover:text-slate-500 dark:hover:text-slate-400 disabled:opacity-30 disabled:cursor-default transition-colors"
                    >
                      <ChevronDown size={14} strokeWidth={2.5} />
                    </button>
                  </div>
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
                    className="flex-1 text-sm font-semibold border-none p-0 focus:ring-0 bg-transparent placeholder-slate-300 dark:placeholder-slate-600 text-slate-700 dark:text-slate-200"
                  />
                  <button
                    onClick={() => removeExpense(expense.id)}
                    aria-label={`Remover despesa ${expense.label}`}
                    className="p-2.5 text-slate-300 dark:text-slate-600 hover:text-red-500 dark:hover:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-xl transition-all"
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
                      className="w-full border border-slate-200 dark:border-slate-600 rounded-xl px-3 py-2.5 text-xs bg-white dark:bg-slate-700 text-slate-600 dark:text-slate-300 font-medium focus:ring-2 focus:ring-blue-500 transition-shadow"
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
                      className="w-full border border-slate-200 dark:border-slate-600 rounded-xl px-3 py-2.5 pr-7 text-sm font-medium text-slate-700 dark:text-slate-200 bg-white dark:bg-slate-700 focus:ring-2 focus:ring-blue-500 transition-shadow placeholder-slate-300 dark:placeholder-slate-500"
                      min="0"
                      step="5"
                    />
                    <span className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 dark:text-slate-500 text-xs font-semibold">
                      EUR
                    </span>
                  </div>
                </div>
              </div>
            ))}
            <button
              onClick={addExpense}
              className="w-full border-2 border-dashed border-slate-200 dark:border-slate-600 rounded-2xl py-4 flex items-center justify-center gap-2 text-sm font-semibold text-slate-400 dark:text-slate-500 hover:border-blue-400 dark:hover:border-blue-500 hover:text-blue-500 hover:bg-blue-50/50 dark:hover:bg-blue-900/20 transition-all active:scale-[0.98]"
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
          <div className="bg-white dark:bg-slate-800 px-5 py-5 space-y-5 animate-slide-down border-b border-slate-100 dark:border-slate-700 transition-colors duration-300">
            <label className="flex items-center gap-3 text-sm font-medium text-slate-700 dark:text-slate-200 cursor-pointer">
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
              Mostrar cartões de resumo
            </label>
            <div>
              <p className="text-xs font-semibold text-slate-500 dark:text-slate-400 mb-3 tracking-wide uppercase">
                Gráficos visíveis
              </p>
              <div className="space-y-2.5">
                {(Object.entries(CHART_LABELS) as [ChartType, string][]).map(([key, label]) => (
                  <label
                    key={key}
                    className="flex items-center gap-3 text-sm font-medium text-slate-600 dark:text-slate-300 cursor-pointer hover:text-slate-800 dark:hover:text-slate-100 transition-colors"
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
      aria-expanded={open}
      className={`w-full flex items-center gap-3 px-5 py-4 border-b border-slate-100 dark:border-slate-700 mt-1.5 transition-all active:scale-[0.99] ${
        open ? "bg-blue-50/40 dark:bg-blue-900/20" : "bg-white dark:bg-slate-800 hover:bg-slate-50 dark:hover:bg-slate-750"
      }`}
    >
      <span className={`transition-colors ${open ? "text-blue-500" : "text-slate-400 dark:text-slate-500"}`}>{icon}</span>
      <span className={`flex-1 text-left font-semibold text-sm transition-colors ${open ? "text-blue-600 dark:text-blue-400" : "text-slate-700 dark:text-slate-200"}`}>{title}</span>
      <div
        className={`p-1.5 rounded-lg transition-all ${
          open ? "bg-blue-100/60 dark:bg-blue-900/40 text-blue-500 dark:text-blue-400" : "text-slate-300 dark:text-slate-600"
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
