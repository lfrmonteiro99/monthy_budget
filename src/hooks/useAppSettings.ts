import { useLocalStorage } from "./useLocalStorage";
import type { AppSettings } from "../types";

const DEFAULT_SETTINGS: AppSettings = {
  personalInfo: {
    maritalStatus: "solteiro",
    titulares: 1,
    dependentes: 0,
    deficiente: false,
  },
  salaries: [
    { label: "Vencimento 1", grossAmount: 0, enabled: true },
    { label: "Vencimento 2", grossAmount: 0, enabled: false },
  ],
  expenses: [
    { id: "vodafone", label: "Vodafone", amount: 0, category: "telecomunicacoes", enabled: true },
    { id: "eletricidade", label: "Eletricidade", amount: 0, category: "energia", enabled: true },
    { id: "agua", label: "Água", amount: 0, category: "agua", enabled: true },
    { id: "compras", label: "Compras / Alimentação", amount: 0, category: "alimentacao", enabled: true },
    { id: "escola", label: "Escola", amount: 0, category: "educacao", enabled: true },
  ],
  dashboardConfig: {
    showSummaryCards: true,
    enabledCharts: [
      "expenses_pie",
      "income_vs_expenses",
      "deductions_breakdown",
      "savings_rate",
    ],
  },
};

export function useAppSettings() {
  const [settings, setSettings] = useLocalStorage<AppSettings>(
    "orcamento_mensal_settings",
    DEFAULT_SETTINGS,
  );

  return { settings, setSettings, DEFAULT_SETTINGS };
}
