import {
  Settings as SettingsIcon,
  TrendingUp,
  TrendingDown,
  Wallet,
  PiggyBank,
  ArrowDownCircle,
  ArrowUpCircle,
  CircleDollarSign,
  Moon,
  Sun,
} from "lucide-react";
import type { AppSettings, BudgetSummary, SalaryCalculation } from "../types";
import { EXPENSE_CATEGORY_LABELS, type ExpenseCategory } from "../types";
import { formatCurrency, formatPercentage } from "../utils/calculations";
import Charts from "./Charts";

interface DashboardProps {
  settings: AppSettings;
  summary: BudgetSummary;
  onOpenSettings: () => void;
  dark: boolean;
  onToggleDark: () => void;
}

const CATEGORY_DOT_COLORS: Record<ExpenseCategory, string> = {
  telecomunicacoes: "bg-indigo-400",
  energia: "bg-amber-400",
  agua: "bg-blue-400",
  alimentacao: "bg-emerald-400",
  educacao: "bg-violet-400",
  habitacao: "bg-red-400",
  transportes: "bg-orange-400",
  saude: "bg-pink-400",
  lazer: "bg-teal-400",
  outros: "bg-gray-400",
};

export default function Dashboard({ settings, summary, onOpenSettings, dark, onToggleDark }: DashboardProps) {
  const hasData = summary.totalGross > 0;
  const isPositive = summary.netLiquidity >= 0;

  return (
    <div className="min-h-screen bg-slate-50 dark:bg-slate-900 animate-fade-in transition-colors duration-300">
      {/* Header */}
      <div className="bg-gradient-to-b from-white to-slate-50/80 dark:from-slate-800 dark:to-slate-900/80 border-b border-slate-100 dark:border-slate-700 px-5 pt-5 pb-6 transition-colors duration-300">
        <div className="flex items-center justify-between mb-5">
          <div>
            <h1 className="text-lg font-bold text-slate-800 dark:text-slate-100 tracking-tight">
              Orçamento Mensal
            </h1>
            <p className="text-slate-400 dark:text-slate-500 text-xs font-medium mt-0.5 tracking-wide uppercase">
              Resumo financeiro
            </p>
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={onToggleDark}
              aria-label={dark ? "Ativar modo claro" : "Ativar modo escuro"}
              className="p-2.5 bg-white dark:bg-slate-700 hover:bg-slate-50 dark:hover:bg-slate-600 rounded-xl transition-all border border-slate-200 dark:border-slate-600 shadow-sm hover:shadow active:scale-95"
            >
              {dark ? <Sun size={18} className="text-amber-400" /> : <Moon size={18} className="text-slate-400" />}
            </button>
            <button
              onClick={onOpenSettings}
              aria-label="Abrir definições"
              className="p-2.5 bg-white dark:bg-slate-700 hover:bg-slate-50 dark:hover:bg-slate-600 rounded-xl transition-all border border-slate-200 dark:border-slate-600 shadow-sm hover:shadow active:scale-95"
            >
              <SettingsIcon size={20} className="text-slate-500 dark:text-slate-400" />
            </button>
          </div>
        </div>

        {hasData ? (
          <div className={`rounded-2xl px-5 py-5 text-center border transition-colors duration-300 ${
            isPositive
              ? "bg-gradient-to-br from-emerald-50 to-teal-50/50 dark:from-emerald-900/20 dark:to-teal-900/10 border-emerald-100 dark:border-emerald-800/40"
              : "bg-gradient-to-br from-red-50 to-orange-50/50 dark:from-red-900/20 dark:to-orange-900/10 border-red-100 dark:border-red-800/40"
          }`}>
            <p className="text-slate-400 dark:text-slate-500 text-xs font-semibold mb-2 tracking-wide uppercase">
              Liquidez Mensal
            </p>
            <p
              className={`text-4xl font-extrabold tracking-tight ${isPositive ? "text-emerald-500" : "text-red-500"}`}
            >
              {formatCurrency(summary.netLiquidity)}
            </p>
            <div className="flex items-center justify-center gap-1.5 mt-3">
              <div
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold ${
                  isPositive
                    ? "bg-emerald-100/60 dark:bg-emerald-900/40 text-emerald-700 dark:text-emerald-400"
                    : "bg-red-100/60 dark:bg-red-900/40 text-red-700 dark:text-red-400"
                }`}
              >
                {isPositive ? (
                  <TrendingUp size={13} />
                ) : (
                  <TrendingDown size={13} />
                )}
                {isPositive ? "Saldo positivo" : "Saldo negativo"}
              </div>
            </div>
          </div>
        ) : (
          <div className="bg-gradient-to-br from-blue-50 to-indigo-50/50 dark:from-blue-900/20 dark:to-indigo-900/10 rounded-2xl px-5 py-8 text-center border border-blue-100 dark:border-blue-800/40 transition-colors duration-300">
            <div className="w-16 h-16 rounded-2xl bg-blue-100/60 dark:bg-blue-900/40 flex items-center justify-center mx-auto mb-4">
              <CircleDollarSign size={32} className="text-blue-400" />
            </div>
            <p className="text-slate-700 dark:text-slate-200 text-sm font-semibold mb-1.5">
              Bem-vindo ao seu orçamento
            </p>
            <p className="text-slate-400 dark:text-slate-500 text-xs font-medium mb-5">
              Configure os seus dados para ver o resumo mensal.
            </p>
            <button
              onClick={onOpenSettings}
              className="bg-blue-500 hover:bg-blue-600 text-white px-6 py-2.5 rounded-xl text-sm font-semibold transition-all shadow-sm hover:shadow active:scale-[0.98]"
            >
              Abrir Definições
            </button>
          </div>
        )}
      </div>

      {hasData && (
        <div className="max-w-lg mx-auto px-4 py-5 space-y-4">
          {/* Summary Cards */}
          {settings.dashboardConfig.showSummaryCards && (
            <div className="grid grid-cols-2 gap-3">
              <SummaryCard
                icon={<Wallet size={18} />}
                label="Rendim. Bruto"
                value={formatCurrency(summary.totalGross)}
                color="blue"
              />
              <SummaryCard
                icon={<ArrowUpCircle size={18} />}
                label="Rendim. Líquido"
                value={formatCurrency(summary.totalNetWithMeal)}
                sublabel={summary.totalMealAllowance > 0 ? `Incl. sub. alim.: ${formatCurrency(summary.totalMealAllowance)}` : undefined}
                color="emerald"
              />
              <SummaryCard
                icon={<ArrowDownCircle size={18} />}
                label="Descontos"
                value={formatCurrency(summary.totalDeductions)}
                sublabel={`IRS: ${formatCurrency(summary.totalIRS)} | SS: ${formatCurrency(summary.totalSS)}`}
                color="amber"
              />
              <SummaryCard
                icon={<PiggyBank size={18} />}
                label="Taxa Poupança"
                value={formatPercentage(Math.max(0, summary.savingsRate))}
                sublabel={`Despesas: ${formatCurrency(summary.totalExpenses)}`}
                color="violet"
              />
            </div>
          )}

          {/* Salary Breakdown */}
          <div className="bg-white dark:bg-slate-800 rounded-2xl p-5 shadow-sm border border-slate-100 dark:border-slate-700 transition-colors duration-300">
            <h3 className="text-xs font-semibold text-slate-400 dark:text-slate-500 mb-4 tracking-wide uppercase">
              Detalhe Vencimentos
            </h3>
            <div className="space-y-3">
              {summary.salary1.grossAmount > 0 && (
                <SalaryRow
                  label={settings.salaries[0].label || "Vencimento 1"}
                  calc={summary.salary1}
                />
              )}
              {summary.salary2.grossAmount > 0 && (
                <SalaryRow
                  label={settings.salaries[1].label || "Vencimento 2"}
                  calc={summary.salary2}
                />
              )}
            </div>
          </div>

          {/* Expenses Breakdown */}
          {summary.totalExpenses > 0 && (
            <div className="bg-white dark:bg-slate-800 rounded-2xl p-5 shadow-sm border border-slate-100 dark:border-slate-700 transition-colors duration-300">
              <h3 className="text-xs font-semibold text-slate-400 dark:text-slate-500 mb-4 tracking-wide uppercase">
                Despesas Mensais
              </h3>
              <div className="space-y-0.5">
                {settings.expenses
                  .filter((e) => e.enabled && e.amount > 0)
                  .map((expense) => (
                    <div
                      key={expense.id}
                      className="flex items-center justify-between py-2.5 border-b border-slate-50 dark:border-slate-700/50 last:border-0"
                    >
                      <div className="flex items-center gap-3">
                        <div
                          className={`w-2.5 h-2.5 rounded-full shrink-0 ${CATEGORY_DOT_COLORS[expense.category]}`}
                        />
                        <div className="flex flex-col">
                          <span className="text-sm font-medium text-slate-700 dark:text-slate-200">
                            {expense.label}
                          </span>
                          <span className="text-[11px] text-slate-400 dark:text-slate-500">
                            {EXPENSE_CATEGORY_LABELS[expense.category]}
                          </span>
                        </div>
                      </div>
                      <span className="text-sm font-semibold text-slate-800 dark:text-slate-100 tabular-nums">
                        {formatCurrency(expense.amount)}
                      </span>
                    </div>
                  ))}
                <div className="flex items-center justify-between pt-3 mt-2 border-t border-slate-200 dark:border-slate-600">
                  <span className="text-sm font-bold text-slate-700 dark:text-slate-200">Total</span>
                  <span className="text-sm font-bold text-red-500">
                    {formatCurrency(summary.totalExpenses)}
                  </span>
                </div>
              </div>
            </div>
          )}

          {/* Charts */}
          <Charts
            summary={summary}
            expenses={settings.expenses}
            enabledCharts={settings.dashboardConfig.enabledCharts}
            dark={dark}
          />

          {/* Bottom spacer */}
          <div className="h-4" />
        </div>
      )}
    </div>
  );
}

function SummaryCard({
  icon,
  label,
  value,
  sublabel,
  color,
}: {
  icon: React.ReactNode;
  label: string;
  value: string;
  sublabel?: string;
  color: "blue" | "emerald" | "amber" | "violet";
}) {
  const styles = {
    blue: {
      badge: "bg-blue-50 dark:bg-blue-900/30 text-blue-500",
      accent: "border-l-blue-400",
    },
    emerald: {
      badge: "bg-emerald-50 dark:bg-emerald-900/30 text-emerald-500",
      accent: "border-l-emerald-400",
    },
    amber: {
      badge: "bg-amber-50 dark:bg-amber-900/30 text-amber-500",
      accent: "border-l-amber-400",
    },
    violet: {
      badge: "bg-violet-50 dark:bg-violet-900/30 text-violet-500",
      accent: "border-l-violet-400",
    },
  };

  const s = styles[color];

  return (
    <div
      className={`bg-white dark:bg-slate-800 rounded-2xl p-4 shadow-sm border border-slate-100 dark:border-slate-700 border-l-[3px] ${s.accent} transition-colors duration-300`}
    >
      <div className={`inline-flex p-2 rounded-xl ${s.badge} mb-2.5`}>
        {icon}
      </div>
      <p className="text-xs font-medium text-slate-400 dark:text-slate-500">{label}</p>
      <p className="text-lg font-bold text-slate-800 dark:text-slate-100 mt-0.5 tracking-tight">{value}</p>
      {sublabel && (
        <p className="text-[11px] text-slate-400 dark:text-slate-500 mt-1.5 leading-snug">{sublabel}</p>
      )}
    </div>
  );
}

function SalaryRow({ label, calc }: { label: string; calc: SalaryCalculation }) {
  const hasMeal = calc.mealAllowance.totalMonthly > 0;
  return (
    <div className="bg-slate-50 dark:bg-slate-700/50 rounded-xl p-4 border border-slate-100 dark:border-slate-600 transition-colors duration-300">
      <div className="flex items-center justify-between mb-3">
        <span className="text-sm font-semibold text-slate-700 dark:text-slate-200">{label}</span>
        <span className="text-sm font-bold text-emerald-500">
          {formatCurrency(calc.totalNetWithMeal)}
        </span>
      </div>
      <div className="grid grid-cols-3 gap-3 text-xs">
        <div>
          <span className="text-slate-400 dark:text-slate-500 font-medium">Bruto</span>
          <p className="text-slate-600 dark:text-slate-300 font-semibold mt-0.5">
            {formatCurrency(calc.grossAmount)}
          </p>
        </div>
        <div>
          <span className="text-slate-400 dark:text-slate-500 font-medium">
            IRS ({formatPercentage(calc.irsRate)})
          </span>
          <p className="text-red-400 font-semibold mt-0.5">
            -{formatCurrency(calc.irsRetention)}
          </p>
        </div>
        <div>
          <span className="text-slate-400 dark:text-slate-500 font-medium">SS (11%)</span>
          <p className="text-amber-500 font-semibold mt-0.5">
            -{formatCurrency(calc.socialSecurity)}
          </p>
        </div>
      </div>
      {hasMeal && (
        <div className="mt-3 pt-3 border-t border-slate-200 dark:border-slate-600 flex items-center justify-between text-xs">
          <span className="text-slate-400 dark:text-slate-500 font-medium">Sub. Alimentação</span>
          <span className="text-emerald-500 font-semibold">
            +{formatCurrency(calc.mealAllowance.netMealAllowance)}
          </span>
        </div>
      )}
    </div>
  );
}
