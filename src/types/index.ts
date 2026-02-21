export type MaritalStatus = "solteiro" | "casado" | "uniao_facto" | "divorciado" | "viuvo";

export type TitularCount = 1 | 2;

export interface PersonalInfo {
  maritalStatus: MaritalStatus;
  titulares: TitularCount;
  dependentes: number;
  deficiente: boolean;
}

export interface SalaryInfo {
  label: string;
  grossAmount: number;
  enabled: boolean;
}

export interface ExpenseItem {
  id: string;
  label: string;
  amount: number;
  category: ExpenseCategory;
  enabled: boolean;
}

export type ExpenseCategory =
  | "telecomunicacoes"
  | "energia"
  | "agua"
  | "alimentacao"
  | "educacao"
  | "habitacao"
  | "transportes"
  | "saude"
  | "lazer"
  | "outros";

export const EXPENSE_CATEGORY_LABELS: Record<ExpenseCategory, string> = {
  telecomunicacoes: "Telecomunicações",
  energia: "Energia",
  agua: "Água",
  alimentacao: "Alimentação",
  educacao: "Educação",
  habitacao: "Habitação",
  transportes: "Transportes",
  saude: "Saúde",
  lazer: "Lazer",
  outros: "Outros",
};

export type ChartType =
  | "expenses_pie"
  | "income_vs_expenses"
  | "net_income_bar"
  | "deductions_breakdown"
  | "savings_rate";

export const CHART_LABELS: Record<ChartType, string> = {
  expenses_pie: "Despesas por Categoria",
  income_vs_expenses: "Rendimento vs Despesas",
  net_income_bar: "Rendimento Líquido",
  deductions_breakdown: "Descontos (IRS + SS)",
  savings_rate: "Taxa de Poupança",
};

export interface DashboardConfig {
  showSummaryCards: boolean;
  enabledCharts: ChartType[];
}

export interface AppSettings {
  personalInfo: PersonalInfo;
  salaries: [SalaryInfo, SalaryInfo];
  expenses: ExpenseItem[];
  dashboardConfig: DashboardConfig;
}

export interface SalaryCalculation {
  grossAmount: number;
  irsRetention: number;
  irsRate: number;
  socialSecurity: number;
  socialSecurityRate: number;
  netAmount: number;
}

export interface BudgetSummary {
  salary1: SalaryCalculation;
  salary2: SalaryCalculation;
  totalGross: number;
  totalNet: number;
  totalIRS: number;
  totalSS: number;
  totalDeductions: number;
  totalExpenses: number;
  netLiquidity: number;
  savingsRate: number;
}
