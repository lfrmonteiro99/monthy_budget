import { Pie, Bar, Doughnut } from "react-chartjs-2";
import {
  Chart as ChartJS,
  ArcElement,
  Tooltip,
  Legend,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
} from "chart.js";
import type { BudgetSummary, ExpenseItem, ChartType } from "../types";
import { EXPENSE_CATEGORY_LABELS, type ExpenseCategory } from "../types";
import { formatCurrency, formatPercentage } from "../utils/calculations";

ChartJS.register(ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement, Title);

const CATEGORY_COLORS: Record<ExpenseCategory, string> = {
  telecomunicacoes: "#6366f1",
  energia: "#f59e0b",
  agua: "#3b82f6",
  alimentacao: "#10b981",
  educacao: "#8b5cf6",
  habitacao: "#ef4444",
  transportes: "#f97316",
  saude: "#ec4899",
  lazer: "#14b8a6",
  outros: "#6b7280",
};

interface ChartsProps {
  summary: BudgetSummary;
  expenses: ExpenseItem[];
  enabledCharts: ChartType[];
}

export default function Charts({ summary, expenses, enabledCharts }: ChartsProps) {
  const activeExpenses = expenses.filter((e) => e.enabled && e.amount > 0);

  return (
    <div className="space-y-4">
      {enabledCharts.includes("expenses_pie") && activeExpenses.length > 0 && (
        <ExpensesPieChart expenses={activeExpenses} />
      )}
      {enabledCharts.includes("income_vs_expenses") && (
        <IncomeVsExpensesChart summary={summary} />
      )}
      {enabledCharts.includes("deductions_breakdown") && (
        <DeductionsChart summary={summary} />
      )}
      {enabledCharts.includes("net_income_bar") && <NetIncomeChart summary={summary} />}
      {enabledCharts.includes("savings_rate") && <SavingsRateChart summary={summary} />}
    </div>
  );
}

function ChartCard({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
      <h3 className="text-sm font-semibold text-gray-700 mb-3">{title}</h3>
      {children}
    </div>
  );
}

function ExpensesPieChart({ expenses }: { expenses: ExpenseItem[] }) {
  // Group expenses by category
  const grouped: Record<string, number> = {};
  for (const exp of expenses) {
    const cat = EXPENSE_CATEGORY_LABELS[exp.category];
    grouped[cat] = (grouped[cat] || 0) + exp.amount;
  }

  const labels = Object.keys(grouped);
  const values = Object.values(grouped);
  const colors = expenses.reduce<string[]>((acc, exp) => {
    const cat = EXPENSE_CATEGORY_LABELS[exp.category];
    if (!acc.some((_, i) => labels[i] === cat)) {
      // do nothing
    }
    return acc;
  }, []);

  // Build color array from category
  const bgColors = labels.map((label) => {
    const catKey = Object.entries(EXPENSE_CATEGORY_LABELS).find(
      ([, v]) => v === label,
    )?.[0] as ExpenseCategory | undefined;
    return catKey ? CATEGORY_COLORS[catKey] : "#6b7280";
  });

  void colors;

  const data = {
    labels,
    datasets: [
      {
        data: values,
        backgroundColor: bgColors,
        borderWidth: 2,
        borderColor: "#ffffff",
      },
    ],
  };

  return (
    <ChartCard title="Despesas por Categoria">
      <div className="h-64 flex items-center justify-center">
        <Pie
          data={data}
          options={{
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                position: "bottom",
                labels: { boxWidth: 12, padding: 8, font: { size: 11 } },
              },
              tooltip: {
                callbacks: {
                  label: (ctx) => {
                    const value = ctx.parsed;
                    const total = values.reduce((a, b) => a + b, 0);
                    const pct = ((value / total) * 100).toFixed(1);
                    return ` ${ctx.label}: ${formatCurrency(value)} (${pct}%)`;
                  },
                },
              },
            },
          }}
        />
      </div>
    </ChartCard>
  );
}

function IncomeVsExpensesChart({ summary }: { summary: BudgetSummary }) {
  const data = {
    labels: ["Rendimento Líquido", "Despesas", "Liquidez"],
    datasets: [
      {
        data: [summary.totalNet, summary.totalExpenses, Math.max(0, summary.netLiquidity)],
        backgroundColor: ["#10b981", "#ef4444", "#6366f1"],
        borderWidth: 0,
        borderRadius: 8,
      },
    ],
  };

  return (
    <ChartCard title="Rendimento vs Despesas">
      <div className="h-56">
        <Bar
          data={data}
          options={{
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: { display: false },
              tooltip: {
                callbacks: {
                  label: (ctx) => ` ${formatCurrency(ctx.parsed.y ?? 0)}`,
                },
              },
            },
            scales: {
              y: {
                beginAtZero: true,
                ticks: {
                  callback: (v) => formatCurrency(v as number),
                  font: { size: 10 },
                },
                grid: { color: "#f3f4f6" },
              },
              x: {
                ticks: { font: { size: 11 } },
                grid: { display: false },
              },
            },
          }}
        />
      </div>
    </ChartCard>
  );
}

function DeductionsChart({ summary }: { summary: BudgetSummary }) {
  if (summary.totalGross === 0) return null;

  const data = {
    labels: ["Salário Líquido", "IRS", "Segurança Social"],
    datasets: [
      {
        data: [summary.totalNet, summary.totalIRS, summary.totalSS],
        backgroundColor: ["#10b981", "#ef4444", "#f59e0b"],
        borderWidth: 3,
        borderColor: "#ffffff",
      },
    ],
  };

  return (
    <ChartCard title="Descontos (IRS + Segurança Social)">
      <div className="h-64 flex items-center justify-center">
        <Doughnut
          data={data}
          options={{
            responsive: true,
            maintainAspectRatio: false,
            cutout: "60%",
            plugins: {
              legend: {
                position: "bottom",
                labels: { boxWidth: 12, padding: 8, font: { size: 11 } },
              },
              tooltip: {
                callbacks: {
                  label: (ctx) => {
                    const value = ctx.parsed;
                    const pct = ((value / summary.totalGross) * 100).toFixed(1);
                    return ` ${ctx.label}: ${formatCurrency(value)} (${pct}%)`;
                  },
                },
              },
            },
          }}
        />
      </div>
    </ChartCard>
  );
}

function NetIncomeChart({ summary }: { summary: BudgetSummary }) {
  const labels = [];
  const grossValues = [];
  const netValues = [];

  if (summary.salary1.grossAmount > 0) {
    labels.push("Vencimento 1");
    grossValues.push(summary.salary1.grossAmount);
    netValues.push(summary.salary1.netAmount);
  }
  if (summary.salary2.grossAmount > 0) {
    labels.push("Vencimento 2");
    grossValues.push(summary.salary2.grossAmount);
    netValues.push(summary.salary2.netAmount);
  }

  if (labels.length === 0) return null;

  const data = {
    labels,
    datasets: [
      {
        label: "Bruto",
        data: grossValues,
        backgroundColor: "#c7d2fe",
        borderRadius: 8,
      },
      {
        label: "Líquido",
        data: netValues,
        backgroundColor: "#6366f1",
        borderRadius: 8,
      },
    ],
  };

  return (
    <ChartCard title="Rendimento Bruto vs Líquido">
      <div className="h-56">
        <Bar
          data={data}
          options={{
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                position: "bottom",
                labels: { boxWidth: 12, padding: 8, font: { size: 11 } },
              },
              tooltip: {
                callbacks: {
                  label: (ctx) => ` ${ctx.dataset.label}: ${formatCurrency(ctx.parsed.y ?? 0)}`,
                },
              },
            },
            scales: {
              y: {
                beginAtZero: true,
                ticks: {
                  callback: (v) => formatCurrency(v as number),
                  font: { size: 10 },
                },
                grid: { color: "#f3f4f6" },
              },
              x: {
                ticks: { font: { size: 11 } },
                grid: { display: false },
              },
            },
          }}
        />
      </div>
    </ChartCard>
  );
}

function SavingsRateChart({ summary }: { summary: BudgetSummary }) {
  if (summary.totalNet === 0) return null;

  const savingsRate = Math.max(0, summary.savingsRate);
  const expenseRate = 1 - savingsRate;

  const data = {
    labels: ["Poupança", "Despesas"],
    datasets: [
      {
        data: [savingsRate * 100, expenseRate * 100],
        backgroundColor: ["#10b981", "#f3f4f6"],
        borderWidth: 0,
      },
    ],
  };

  return (
    <ChartCard title="Taxa de Poupança">
      <div className="h-48 flex items-center justify-center relative">
        <Doughnut
          data={data}
          options={{
            responsive: true,
            maintainAspectRatio: false,
            cutout: "75%",
            plugins: {
              legend: { display: false },
              tooltip: {
                callbacks: {
                  label: (ctx) => ` ${ctx.label}: ${ctx.parsed.toFixed(1)}%`,
                },
              },
            },
          }}
        />
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <span className="text-2xl font-bold text-emerald-600">
            {formatPercentage(savingsRate)}
          </span>
          <span className="text-xs text-gray-500">poupança</span>
        </div>
      </div>
    </ChartCard>
  );
}
