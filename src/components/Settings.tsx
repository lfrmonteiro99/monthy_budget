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
} from "lucide-react";
import type {
  AppSettings,
  ExpenseItem,
  ExpenseCategory,
  ChartType,
  MaritalStatus,
  TitularCount,
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
  { value: "uniao_facto", label: "União de Facto" },
  { value: "divorciado", label: "Divorciado(a)" },
  { value: "viuvo", label: "Viúvo(a)" },
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

  const applicableTable = getApplicableTable(
    draft.personalInfo.maritalStatus,
    draft.personalInfo.titulares,
    draft.personalInfo.dependentes,
  );

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
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-indigo-600 text-white px-4 py-4 flex items-center gap-3 sticky top-0 z-10">
        <button onClick={onBack} className="p-1 hover:bg-indigo-700 rounded-lg transition">
          <ArrowLeft size={24} />
        </button>
        <h1 className="text-lg font-semibold flex-1">Definições</h1>
        <button
          onClick={handleSave}
          className="bg-white text-indigo-600 px-4 py-1.5 rounded-lg font-medium text-sm hover:bg-indigo-50 transition"
        >
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
          <div className="bg-white px-4 py-4 space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Estado Civil</label>
              <select
                value={draft.personalInfo.maritalStatus}
                onChange={(e) =>
                  setDraft({
                    ...draft,
                    personalInfo: {
                      ...draft.personalInfo,
                      maritalStatus: e.target.value as MaritalStatus,
                      titulares:
                        e.target.value !== "casado" && e.target.value !== "uniao_facto"
                          ? 1
                          : draft.personalInfo.titulares,
                    },
                  })
                }
                className="w-full border border-gray-300 rounded-lg px-3 py-2.5 text-sm bg-white focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
              >
                {MARITAL_STATUS_OPTIONS.map((opt) => (
                  <option key={opt.value} value={opt.value}>
                    {opt.label}
                  </option>
                ))}
              </select>
            </div>

            {isCasado && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Número de Titulares
                </label>
                <div className="flex gap-3">
                  {([1, 2] as TitularCount[]).map((n) => (
                    <button
                      key={n}
                      onClick={() =>
                        setDraft({
                          ...draft,
                          personalInfo: { ...draft.personalInfo, titulares: n },
                        })
                      }
                      className={`flex-1 py-2.5 rounded-lg text-sm font-medium border transition ${
                        draft.personalInfo.titulares === n
                          ? "bg-indigo-600 text-white border-indigo-600"
                          : "bg-white text-gray-700 border-gray-300 hover:bg-gray-50"
                      }`}
                    >
                      {n} Titular{n > 1 ? "es" : ""}
                    </button>
                  ))}
                </div>
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Número de Dependentes
              </label>
              <div className="flex items-center gap-3">
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
                  className="w-10 h-10 rounded-lg border border-gray-300 flex items-center justify-center text-lg font-bold text-gray-600 hover:bg-gray-50"
                >
                  −
                </button>
                <span className="text-xl font-semibold w-8 text-center">
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
                  className="w-10 h-10 rounded-lg border border-gray-300 flex items-center justify-center text-lg font-bold text-gray-600 hover:bg-gray-50"
                >
                  +
                </button>
              </div>
            </div>

            {/* Info about applicable table */}
            <div className="bg-indigo-50 rounded-lg p-3 text-sm text-indigo-800">
              <p className="font-medium">Tabela IRS aplicável:</p>
              <p>
                {applicableTable.label} — {applicableTable.description}
              </p>
              <p className="mt-1 text-xs text-indigo-600">
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
          <div className="bg-white px-4 py-4 space-y-4">
            {draft.salaries.map((salary, idx) => (
              <div
                key={idx}
                className={`border rounded-lg p-3 space-y-3 ${salary.enabled ? "border-gray-300" : "border-gray-200 opacity-60"}`}
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
                    className="text-sm font-medium text-gray-700 border-none p-0 focus:ring-0 bg-transparent"
                    placeholder={`Vencimento ${idx + 1}`}
                  />
                  <label className="flex items-center gap-2 text-sm text-gray-500">
                    <input
                      type="checkbox"
                      checked={salary.enabled}
                      onChange={(e) => {
                        const newSalaries = [...draft.salaries] as [typeof salary, typeof salary];
                        newSalaries[idx] = { ...salary, enabled: e.target.checked };
                        setDraft({ ...draft, salaries: newSalaries });
                      }}
                      className="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                    />
                    Ativo
                  </label>
                </div>
                <div>
                  <label className="block text-xs text-gray-500 mb-1">Salário Bruto Mensal</label>
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
                      className="w-full border border-gray-300 rounded-lg px-3 py-2.5 pr-8 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                      min="0"
                      step="50"
                    />
                    <span className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">
                      €
                    </span>
                  </div>
                </div>
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
          <div className="bg-white px-4 py-4 space-y-3">
            {draft.expenses.map((expense) => (
              <div
                key={expense.id}
                className={`border rounded-lg p-3 space-y-2 ${expense.enabled ? "border-gray-300" : "border-gray-200 opacity-60"}`}
              >
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    checked={expense.enabled}
                    onChange={(e) => updateExpense(expense.id, { enabled: e.target.checked })}
                    className="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                  />
                  <input
                    type="text"
                    value={expense.label}
                    onChange={(e) => updateExpense(expense.id, { label: e.target.value })}
                    placeholder="Nome da despesa"
                    className="flex-1 text-sm font-medium border-none p-0 focus:ring-0 bg-transparent"
                  />
                  <button
                    onClick={() => removeExpense(expense.id)}
                    className="p-1 text-red-400 hover:text-red-600 transition"
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
                <div className="flex gap-2">
                  <div className="flex-1">
                    <select
                      value={expense.category}
                      onChange={(e) =>
                        updateExpense(expense.id, {
                          category: e.target.value as ExpenseCategory,
                        })
                      }
                      className="w-full border border-gray-300 rounded-lg px-2 py-2 text-xs bg-white focus:ring-2 focus:ring-indigo-500"
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
                      className="w-full border border-gray-300 rounded-lg px-2 py-2 pr-6 text-sm focus:ring-2 focus:ring-indigo-500"
                      min="0"
                      step="5"
                    />
                    <span className="absolute right-2 top-1/2 -translate-y-1/2 text-gray-400 text-xs">
                      €
                    </span>
                  </div>
                </div>
              </div>
            ))}
            <button
              onClick={addExpense}
              className="w-full border-2 border-dashed border-gray-300 rounded-lg py-3 flex items-center justify-center gap-2 text-sm text-gray-500 hover:border-indigo-400 hover:text-indigo-600 transition"
            >
              <Plus size={16} />
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
          <div className="bg-white px-4 py-4 space-y-4">
            <label className="flex items-center gap-3 text-sm text-gray-700">
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
                className="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
              />
              Mostrar cartões de resumo
            </label>
            <div>
              <p className="text-sm font-medium text-gray-700 mb-2">Gráficos visíveis</p>
              <div className="space-y-2">
                {(Object.entries(CHART_LABELS) as [ChartType, string][]).map(([key, label]) => (
                  <label key={key} className="flex items-center gap-3 text-sm text-gray-700">
                    <input
                      type="checkbox"
                      checked={draft.dashboardConfig.enabledCharts.includes(key)}
                      onChange={() => toggleChart(key)}
                      className="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
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
      className="w-full flex items-center gap-3 px-4 py-3.5 bg-white border-b border-gray-200 mt-2 hover:bg-gray-50 transition"
    >
      <span className="text-indigo-600">{icon}</span>
      <span className="flex-1 text-left font-medium text-gray-800">{title}</span>
      {open ? (
        <ChevronUp size={18} className="text-gray-400" />
      ) : (
        <ChevronDown size={18} className="text-gray-400" />
      )}
    </button>
  );
}
