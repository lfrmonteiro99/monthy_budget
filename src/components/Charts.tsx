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

// Softer, pastel-leaning palette
const CATEGORY_COLORS: Record<ExpenseCategory, string> = {
  telecomunicacoes: "#818cf8",
  energia: "#fbbf24",
  agua: "#60a5fa",
  alimentacao: "#34d399",
  educacao: "#a78bfa",
  habitacao: "#f87171",
  transportes: "#fb923c",
  saude: "#f472b6",
  lazer: "#2dd4bf",
  outros: "#94a3b8",
};

// Shared chart defaults
const SHARED_FONT = { family: "Inter, system-ui, sans-serif" };

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
    <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100">
      <h3 className="text-xs font-semibold text-slate-400 mb-4 tracking-wide uppercase">
        {title}
      </h3>
      {children}
    </div>
  );
}

function ExpensesPieChart({ expenses }: { expenses: ExpenseItem[] }) {
  const grouped: Record<string, number> = {};
  for (const exp of expenses) {
    const cat = EXPENSE_CATEGORY_LABELS[exp.category];
    grouped[cat] = (grouped[cat] || 0) + exp.amount;
  }

  const labels = Object.keys(grouped);
  const values = Object.values(grouped);

  const bgColors = labels.map((label) => {
    const catKey = Object.entries(EXPENSE_CATEGORY_LABELS).find(
      ([, v]) => v === label,
    )?.[0] as ExpenseCategory | undefined;
    return catKey ? CATEGORY_COLORS[catKey] : "#94a3b8";
  });

  const data = {
    labels,
    datasets: [
      {
        data: values,
        backgroundColor: bgColors,
        borderWidth: 3,
        borderColor: "#ffffff",
        hoverOffset: 6,
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
                labels: {
                  boxWidth: 10,
                  padding: 12,
                  font: { size: 11, ...SHARED_FONT },
                  color: "#64748b",
                  usePointStyle: true,
                  pointStyle: "circle",
                },
              },
              tooltip: {
                backgroundColor: "#1e293b",
                titleFont: { ...SHARED_FONT, size: 12 },
                bodyFont: { ...SHARED_FONT, size: 12 },
                cornerRadius: 10,
                padding: 10,
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
    labels: ["Rend. Liquido", "Despesas", "Liquidez"],
    datasets: [
      {
        data: [summary.totalNet, summary.totalExpenses, Math.max(0, summary.netLiquidity)],
        backgroundColor: ["#34d399", "#f87171", "#818cf8"],
        borderWidth: 0,
        borderRadius: 10,
        borderSkipped: false,
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
                backgroundColor: "#1e293b",
                titleFont: { ...SHARED_FONT, size: 12 },
                bodyFont: { ...SHARED_FONT, size: 12 },
                cornerRadius: 10,
                padding: 10,
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
                  font: { size: 10, ...SHARED_FONT },
                  color: "#94a3b8",
                },
                grid: { color: "#f1f5f9" },
                border: { display: false },
              },
              x: {
                ticks: { font: { size: 11, ...SHARED_FONT }, color: "#64748b" },
                grid: { display: false },
                border: { display: false },
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
    labels: ["Salario Liquido", "IRS", "Seguranca Social"],
    datasets: [
      {
        data: [summary.totalNet, summary.totalIRS, summary.totalSS],
        backgroundColor: ["#34d399", "#f87171", "#fbbf24"],
        borderWidth: 4,
        borderColor: "#ffffff",
        hoverOffset: 6,
      },
    ],
  };

  return (
    <ChartCard title="Descontos (IRS + Seguranca Social)">
      <div className="h-64 flex items-center justify-center">
        <Doughnut
          data={data}
          options={{
            responsive: true,
            maintainAspectRatio: false,
            cutout: "65%",
            plugins: {
              legend: {
                position: "bottom",
                labels: {
                  boxWidth: 10,
                  padding: 12,
                  font: { size: 11, ...SHARED_FONT },
                  color: "#64748b",
                  usePointStyle: true,
                  pointStyle: "circle",
                },
              },
              tooltip: {
                backgroundColor: "#1e293b",
                titleFont: { ...SHARED_FONT, size: 12 },
                bodyFont: { ...SHARED_FONT, size: 12 },
                cornerRadius: 10,
                padding: 10,
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
        borderRadius: 10,
        borderSkipped: false,
      },
      {
        label: "Liquido",
        data: netValues,
        backgroundColor: "#818cf8",
        borderRadius: 10,
        borderSkipped: false,
      },
    ],
  };

  return (
    <ChartCard title="Rendimento Bruto vs Liquido">
      <div className="h-56">
        <Bar
          data={data}
          options={{
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                position: "bottom",
                labels: {
                  boxWidth: 10,
                  padding: 12,
                  font: { size: 11, ...SHARED_FONT },
                  color: "#64748b",
                  usePointStyle: true,
                  pointStyle: "circle",
                },
              },
              tooltip: {
                backgroundColor: "#1e293b",
                titleFont: { ...SHARED_FONT, size: 12 },
                bodyFont: { ...SHARED_FONT, size: 12 },
                cornerRadius: 10,
                padding: 10,
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
                  font: { size: 10, ...SHARED_FONT },
                  color: "#94a3b8",
                },
                grid: { color: "#f1f5f9" },
                border: { display: false },
              },
              x: {
                ticks: { font: { size: 11, ...SHARED_FONT }, color: "#64748b" },
                grid: { display: false },
                border: { display: false },
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
    labels: ["Poupanca", "Despesas"],
    datasets: [
      {
        data: [savingsRate * 100, expenseRate * 100],
        backgroundColor: ["#34d399", "#f1f5f9"],
        borderWidth: 0,
        hoverOffset: 4,
      },
    ],
  };

  return (
    <ChartCard title="Taxa de Poupanca">
      <div className="h-48 flex items-center justify-center relative">
        <Doughnut
          data={data}
          options={{
            responsive: true,
            maintainAspectRatio: false,
            cutout: "78%",
            plugins: {
              legend: { display: false },
              tooltip: {
                backgroundColor: "#1e293b",
                titleFont: { ...SHARED_FONT, size: 12 },
                bodyFont: { ...SHARED_FONT, size: 12 },
                cornerRadius: 10,
                padding: 10,
                callbacks: {
                  label: (ctx) => ` ${ctx.label}: ${ctx.parsed.toFixed(1)}%`,
                },
              },
            },
          }}
        />
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <span className="text-3xl font-extrabold text-emerald-500 tracking-tight">
            {formatPercentage(savingsRate)}
          </span>
          <span className="text-xs font-medium text-slate-400 mt-0.5">poupanca</span>
        </div>
      </div>
    </ChartCard>
  );
}
