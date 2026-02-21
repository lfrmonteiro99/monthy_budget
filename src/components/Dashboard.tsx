import {
  Settings as SettingsIcon,
  TrendingUp,
  TrendingDown,
  Wallet,
  PiggyBank,
  ArrowDownCircle,
  ArrowUpCircle,
  CircleDollarSign,
} from "lucide-react";
import type { AppSettings, BudgetSummary } from "../types";
import { EXPENSE_CATEGORY_LABELS, type ExpenseCategory } from "../types";
import { formatCurrency, formatPercentage } from "../utils/calculations";
import Charts from "./Charts";

interface DashboardProps {
  settings: AppSettings;
  summary: BudgetSummary;
  onOpenSettings: () => void;
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

export default function Dashboard({ settings, summary, onOpenSettings }: DashboardProps) {
  const hasData = summary.totalGross > 0;
  const isPositive = summary.netLiquidity >= 0;

  return (
    <div className="min-h-screen bg-slate-50 animate-fade-in">
      {/* Header */}
      <div className="bg-white border-b border-slate-100 px-5 pt-5 pb-6">
        <div className="flex items-center justify-between mb-5">
          <div>
            <h1 className="text-lg font-bold text-slate-800 tracking-tight">
              Orcamento Mensal
            </h1>
            <p className="text-slate-400 text-xs font-medium mt-0.5 tracking-wide uppercase">
              Resumo financeiro
            </p>
          </div>
          <button
            onClick={onOpenSettings}
            className="p-2.5 bg-slate-50 hover:bg-slate-100 rounded-xl transition-colors border border-slate-200"
          >
            <SettingsIcon size={20} className="text-slate-500" />
          </button>
        </div>

        {hasData ? (
          <div className="bg-slate-50 rounded-2xl px-5 py-5 text-center border border-slate-100">
            <p className="text-slate-400 text-xs font-semibold mb-2 tracking-wide uppercase">
              Liquidez Mensal
            </p>
            <p
              className={`text-4xl font-extrabold tracking-tight ${isPositive ? "text-emerald-500" : "text-red-500"}`}
            >
              {formatCurrency(summary.netLiquidity)}
            </p>
            <div className="flex items-center justify-center gap-1.5 mt-3">
              <div
                className={`flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold ${
                  isPositive
                    ? "bg-emerald-50 text-emerald-600"
                    : "bg-red-50 text-red-600"
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
          <div className="bg-blue-50 rounded-2xl px-5 py-8 text-center border border-blue-100">
            <CircleDollarSign size={40} className="text-blue-300 mx-auto mb-3" />
            <p className="text-slate-600 text-sm font-medium mb-4">
              Configure os seus dados para ver o resumo.
            </p>
            <button
              onClick={onOpenSettings}
              className="bg-blue-500 hover:bg-blue-600 text-white px-6 py-2.5 rounded-xl text-sm font-semibold transition-colors shadow-sm"
            >
              Abrir Definicoes
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
                label="Rendimento Bruto"
                value={formatCurrency(summary.totalGross)}
                color="blue"
              />
              <SummaryCard
                icon={<ArrowUpCircle size={18} />}
                label="Rendimento Liquido"
                value={formatCurrency(summary.totalNet)}
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
                label="Taxa Poupanca"
                value={formatPercentage(Math.max(0, summary.savingsRate))}
                sublabel={`Despesas: ${formatCurrency(summary.totalExpenses)}`}
                color="violet"
              />
            </div>
          )}

          {/* Salary Breakdown */}
          <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100">
            <h3 className="text-xs font-semibold text-slate-400 mb-4 tracking-wide uppercase">
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
            <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100">
              <h3 className="text-xs font-semibold text-slate-400 mb-4 tracking-wide uppercase">
                Despesas Mensais
              </h3>
              <div className="space-y-1">
                {settings.expenses
                  .filter((e) => e.enabled && e.amount > 0)
                  .map((expense) => (
                    <div
                      key={expense.id}
                      className="flex items-center justify-between py-2.5 border-b border-slate-50 last:border-0"
                    >
                      <div className="flex items-center gap-2.5">
                        <div
                          className={`w-2 h-2 rounded-full ${CATEGORY_DOT_COLORS[expense.category]}`}
                        />
                        <div>
                          <span className="text-sm font-medium text-slate-700">
                            {expense.label}
                          </span>
                          <span className="text-xs text-slate-400 ml-2">
                            {EXPENSE_CATEGORY_LABELS[expense.category]}
                          </span>
                        </div>
                      </div>
                      <span className="text-sm font-semibold text-slate-800">
                        {formatCurrency(expense.amount)}
                      </span>
                    </div>
                  ))}
                <div className="flex items-center justify-between pt-3 mt-2 border-t border-slate-200">
                  <span className="text-sm font-bold text-slate-700">Total</span>
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
      badge: "bg-blue-50 text-blue-500",
      accent: "border-l-blue-400",
    },
    emerald: {
      badge: "bg-emerald-50 text-emerald-500",
      accent: "border-l-emerald-400",
    },
    amber: {
      badge: "bg-amber-50 text-amber-500",
      accent: "border-l-amber-400",
    },
    violet: {
      badge: "bg-violet-50 text-violet-500",
      accent: "border-l-violet-400",
    },
  };

  const s = styles[color];

  return (
    <div
      className={`bg-white rounded-2xl p-4 shadow-sm border border-slate-100 border-l-[3px] ${s.accent}`}
    >
      <div className={`inline-flex p-2 rounded-xl ${s.badge} mb-2.5`}>
        {icon}
      </div>
      <p className="text-xs font-medium text-slate-400">{label}</p>
      <p className="text-lg font-bold text-slate-800 mt-0.5 tracking-tight">{value}</p>
      {sublabel && (
        <p className="text-[10px] text-slate-400 mt-1 leading-tight">{sublabel}</p>
      )}
    </div>
  );
}

interface SalaryCalcDisplay {
  grossAmount: number;
  irsRetention: number;
  irsRate: number;
  socialSecurity: number;
  netAmount: number;
}

function SalaryRow({ label, calc }: { label: string; calc: SalaryCalcDisplay }) {
  return (
    <div className="bg-slate-50 rounded-xl p-4 border border-slate-100">
      <div className="flex items-center justify-between mb-3">
        <span className="text-sm font-semibold text-slate-700">{label}</span>
        <span className="text-sm font-bold text-emerald-500">
          {formatCurrency(calc.netAmount)}
        </span>
      </div>
      <div className="grid grid-cols-3 gap-3 text-xs">
        <div>
          <span className="text-slate-400 font-medium">Bruto</span>
          <p className="text-slate-600 font-semibold mt-0.5">
            {formatCurrency(calc.grossAmount)}
          </p>
        </div>
        <div>
          <span className="text-slate-400 font-medium">
            IRS ({formatPercentage(calc.irsRate)})
          </span>
          <p className="text-red-400 font-semibold mt-0.5">
            -{formatCurrency(calc.irsRetention)}
          </p>
        </div>
        <div>
          <span className="text-slate-400 font-medium">SS (11%)</span>
          <p className="text-amber-500 font-semibold mt-0.5">
            -{formatCurrency(calc.socialSecurity)}
          </p>
        </div>
      </div>
    </div>
  );
}
