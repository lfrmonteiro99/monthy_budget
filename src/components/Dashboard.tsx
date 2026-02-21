import {
  Settings as SettingsIcon,
  TrendingUp,
  TrendingDown,
  Wallet,
  PiggyBank,
  ArrowDownCircle,
  ArrowUpCircle,
} from "lucide-react";
import type { AppSettings, BudgetSummary } from "../types";
import { formatCurrency, formatPercentage } from "../utils/calculations";
import Charts from "./Charts";

interface DashboardProps {
  settings: AppSettings;
  summary: BudgetSummary;
  onOpenSettings: () => void;
}

export default function Dashboard({ settings, summary, onOpenSettings }: DashboardProps) {
  const hasData = summary.totalGross > 0;
  const isPositive = summary.netLiquidity >= 0;

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-gradient-to-br from-indigo-600 to-indigo-800 text-white px-4 pt-6 pb-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-xl font-bold">Orçamento Mensal</h1>
            <p className="text-indigo-200 text-sm mt-0.5">Resumo financeiro</p>
          </div>
          <button
            onClick={onOpenSettings}
            className="p-2.5 bg-white/10 hover:bg-white/20 rounded-xl transition"
          >
            <SettingsIcon size={22} />
          </button>
        </div>

        {hasData ? (
          <div className="text-center">
            <p className="text-indigo-200 text-sm mb-1">Liquidez Mensal</p>
            <p
              className={`text-4xl font-bold ${isPositive ? "text-emerald-300" : "text-red-300"}`}
            >
              {formatCurrency(summary.netLiquidity)}
            </p>
            <div className="flex items-center justify-center gap-1 mt-2">
              {isPositive ? (
                <TrendingUp size={16} className="text-emerald-300" />
              ) : (
                <TrendingDown size={16} className="text-red-300" />
              )}
              <span
                className={`text-sm ${isPositive ? "text-emerald-300" : "text-red-300"}`}
              >
                {isPositive ? "Saldo positivo" : "Saldo negativo"}
              </span>
            </div>
          </div>
        ) : (
          <div className="text-center py-4">
            <p className="text-indigo-200 text-base">
              Configure os seus dados nas definições para ver o resumo.
            </p>
            <button
              onClick={onOpenSettings}
              className="mt-3 bg-white/20 hover:bg-white/30 px-6 py-2 rounded-lg text-sm font-medium transition"
            >
              Abrir Definições
            </button>
          </div>
        )}
      </div>

      {hasData && (
        <div className="max-w-lg mx-auto px-4 -mt-4 pb-8 space-y-4">
          {/* Summary Cards */}
          {settings.dashboardConfig.showSummaryCards && (
            <div className="grid grid-cols-2 gap-3">
              <SummaryCard
                icon={<Wallet size={18} />}
                label="Rendimento Bruto"
                value={formatCurrency(summary.totalGross)}
                color="indigo"
              />
              <SummaryCard
                icon={<ArrowUpCircle size={18} />}
                label="Rendimento Líquido"
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
                label="Taxa Poupança"
                value={formatPercentage(Math.max(0, summary.savingsRate))}
                sublabel={`Despesas: ${formatCurrency(summary.totalExpenses)}`}
                color="violet"
              />
            </div>
          )}

          {/* Salary Breakdown */}
          <div className="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
            <h3 className="text-sm font-semibold text-gray-700 mb-3">Detalhe Vencimentos</h3>
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
            <div className="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
              <h3 className="text-sm font-semibold text-gray-700 mb-3">Despesas Mensais</h3>
              <div className="space-y-2">
                {settings.expenses
                  .filter((e) => e.enabled && e.amount > 0)
                  .map((expense) => (
                    <div
                      key={expense.id}
                      className="flex items-center justify-between py-1.5 border-b border-gray-50 last:border-0"
                    >
                      <span className="text-sm text-gray-600">{expense.label}</span>
                      <span className="text-sm font-medium text-gray-800">
                        {formatCurrency(expense.amount)}
                      </span>
                    </div>
                  ))}
                <div className="flex items-center justify-between pt-2 border-t border-gray-200">
                  <span className="text-sm font-semibold text-gray-700">Total Despesas</span>
                  <span className="text-sm font-bold text-red-600">
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
  color: "indigo" | "emerald" | "amber" | "violet";
}) {
  const colorMap = {
    indigo: "bg-indigo-50 text-indigo-600",
    emerald: "bg-emerald-50 text-emerald-600",
    amber: "bg-amber-50 text-amber-600",
    violet: "bg-violet-50 text-violet-600",
  };

  return (
    <div className="bg-white rounded-xl p-3.5 shadow-sm border border-gray-100">
      <div className={`inline-flex p-1.5 rounded-lg ${colorMap[color]} mb-2`}>{icon}</div>
      <p className="text-xs text-gray-500">{label}</p>
      <p className="text-base font-bold text-gray-800 mt-0.5">{value}</p>
      {sublabel && <p className="text-xs text-gray-400 mt-0.5">{sublabel}</p>}
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
    <div className="bg-gray-50 rounded-lg p-3">
      <div className="flex items-center justify-between mb-2">
        <span className="text-sm font-medium text-gray-700">{label}</span>
        <span className="text-sm font-bold text-emerald-600">{formatCurrency(calc.netAmount)}</span>
      </div>
      <div className="grid grid-cols-3 gap-2 text-xs">
        <div>
          <span className="text-gray-400">Bruto</span>
          <p className="text-gray-600 font-medium">{formatCurrency(calc.grossAmount)}</p>
        </div>
        <div>
          <span className="text-gray-400">IRS ({formatPercentage(calc.irsRate)})</span>
          <p className="text-red-500 font-medium">-{formatCurrency(calc.irsRetention)}</p>
        </div>
        <div>
          <span className="text-gray-400">SS (11%)</span>
          <p className="text-amber-500 font-medium">-{formatCurrency(calc.socialSecurity)}</p>
        </div>
      </div>
    </div>
  );
}
