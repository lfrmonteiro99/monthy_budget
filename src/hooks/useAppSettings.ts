import { useState, useEffect, useCallback, useRef } from "react";
import { invoke } from "@tauri-apps/api/core";
import type { AppSettings } from "../types";

const DEFAULT_SETTINGS: AppSettings = {
  personalInfo: {
    maritalStatus: "solteiro",
    dependentes: 0,
    deficiente: false,
  },
  salaries: [
    { label: "Vencimento 1", grossAmount: 0, enabled: true, titulares: 1 },
    { label: "Vencimento 2", grossAmount: 0, enabled: false, titulares: 1 },
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
  const [settings, setSettingsState] = useState<AppSettings>(DEFAULT_SETTINGS);
  const [loaded, setLoaded] = useState(false);
  const saving = useRef(false);

  // Load settings from JSON file on mount
  useEffect(() => {
    invoke<string | null>("get_settings")
      .then((data) => {
        if (data) {
          try {
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            const parsed = JSON.parse(data) as any;
            // Migrate: move titulares from personalInfo to each salary if needed
            if (parsed.personalInfo?.titulares !== undefined) {
              const oldTitulares = parsed.personalInfo.titulares;
              delete parsed.personalInfo.titulares;
              for (const s of parsed.salaries ?? []) {
                if (s.titulares === undefined) s.titulares = oldTitulares;
              }
            } else {
              for (const s of parsed.salaries ?? []) {
                if (s.titulares === undefined) s.titulares = 1;
              }
            }
            setSettingsState(parsed as AppSettings);
          } catch {
            // corrupted file — keep defaults
          }
        }
      })
      .catch(() => {
        // Tauri command failed — keep defaults
      })
      .finally(() => setLoaded(true));
  }, []);

  // Persist settings to JSON file whenever they change (after initial load)
  useEffect(() => {
    if (!loaded) return;
    if (saving.current) return;
    saving.current = true;
    invoke("save_settings", { data: JSON.stringify(settings, null, 2) })
      .catch(() => {
        // silently ignore write errors
      })
      .finally(() => {
        saving.current = false;
      });
  }, [settings, loaded]);

  const setSettings = useCallback((value: AppSettings | ((prev: AppSettings) => AppSettings)) => {
    setSettingsState(value);
  }, []);

  return { settings, setSettings, loaded, DEFAULT_SETTINGS };
}
